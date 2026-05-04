import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import '../models/announcement_model.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Announcement> _announcements = [];
  List<Announcement> _filteredAnnouncements = [];
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedArea;
  String? _selectedCategory;
  String? _searchQuery;
  String? _currentUserId;

  List<Announcement> get announcements => _filteredAnnouncements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedArea => _selectedArea;
  String? get selectedCategory => _selectedCategory;
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  List<AppNotification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();

  AnnouncementProvider() {
    _subscribeToAnnouncements();
  }

  void initUser(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _subscribeToNotifications(userId);
  }

  void _subscribeToNotifications(String userId) {
    _firestoreService.getNotificationsStream(userId).listen((notifications) {
      _notifications = notifications;
      _updateBadge();
      notifyListeners();
    });
  }

  void _updateBadge() {
    final count = unreadCount;
    if (count > 0) {
      FlutterAppBadger.updateBadgeCount(count);
    } else {
      FlutterAppBadger.removeBadge();
    }
  }

  void _subscribeToAnnouncements() {
    _firestoreService.getAnnouncementsStream().listen(
      (announcements) {
        _announcements = announcements;
        _applyFilters();
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void setSelectedArea(String? area) {
    _selectedArea = area;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredAnnouncements = _announcements;

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredAnnouncements = _filteredAnnouncements
          .where((a) => a.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }

    if (_selectedArea != null && _selectedArea!.isNotEmpty && _selectedCategory != 'Billing & Rates') {
      _filteredAnnouncements = _filteredAnnouncements
          .where((a) => a.area.toLowerCase() == _selectedArea!.toLowerCase())
          .toList();
    }

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final searchTerms = _searchQuery!.toLowerCase().split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
      _filteredAnnouncements = _filteredAnnouncements.where((a) {
        final content = '${a.title} ${a.description} ${a.area} ${a.category}'.toLowerCase();
        return searchTerms.every((term) => content.contains(term));
      }).toList();
    }
  }

  Future<bool> createAnnouncement({
    required String title,
    required String description,
    required String area,
    required String category,
    required DateTime startTime,
    required DateTime endTime,
    required String createdBy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final announcementId = await _firestoreService.createAnnouncement(
        title: title,
        description: description,
        area: area,
        category: category,
        startTime: startTime,
        endTime: endTime,
        createdBy: createdBy,
      );

      await _firestoreService.createNotificationsForAllClients(
        announcementId: announcementId,
        title: title,
        area: area,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsResolved(Announcement announcement) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resolved = announcement.copyWith(category: 'Resolved');
      await _firestoreService.updateAnnouncement(resolved);
      await _firestoreService.createNotificationsForAllClients(
        announcementId: announcement.id,
        title: 'Resolved: ${announcement.title}',
        area: announcement.area,
        type: 'resolved',
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAnnouncement(Announcement announcement) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateAnnouncement(announcement);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteAnnouncement(id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          announcementId: _notifications[index].announcementId,
          title: _notifications[index].title,
          area: _notifications[index].area,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        _updateBadge();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    if (_currentUserId == null) return;
    try {
      await _firestoreService.markAllNotificationsAsRead(_currentUserId!);
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        userId: n.userId,
        announcementId: n.announcementId,
        title: n.title,
        area: n.area,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      _updateBadge();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String userId, String announcementId) async {
    try {
      await _firestoreService.markAsRead(userId, announcementId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
