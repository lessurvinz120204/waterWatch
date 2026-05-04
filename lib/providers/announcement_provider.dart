import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/firestore_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Announcement> _announcements = [];
  List<Announcement> _filteredAnnouncements = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedArea;
  String? _selectedCategory;
  String? _searchQuery;

  List<Announcement> get announcements => _filteredAnnouncements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedArea => _selectedArea;
  String? get selectedCategory => _selectedCategory;

  AnnouncementProvider() {
    _subscribeToAnnouncements();
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

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredAnnouncements = _filteredAnnouncements
          .where((a) => a.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }

    // Filter by area
    if (_selectedArea != null && _selectedArea!.isNotEmpty) {
      _filteredAnnouncements = _filteredAnnouncements
          .where((a) => a.area.toLowerCase() == _selectedArea!.toLowerCase())
          .toList();
    }

    // Filter by search query
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
      await _firestoreService.createAnnouncement(
        title: title,
        description: description,
        area: area,
        category: category,
        startTime: startTime,
        endTime: endTime,
        createdBy: createdBy,
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
