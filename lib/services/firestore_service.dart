import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';
import '../models/notification_model.dart';
import '../models/read_status_model.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ANNOUNCEMENTS OPERATIONS

  // Create announcement
  Future<String> createAnnouncement({
    required String title,
    required String description,
    required String area,
    required String category,
    required DateTime startTime,
    required DateTime endTime,
    required String createdBy,
  }) async {
    try {
      final announcementId = const Uuid().v4();
      final announcement = Announcement(
        id: announcementId,
        title: title,
        description: description,
        area: area,
        category: category,
        startTime: startTime,
        endTime: endTime,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('announcements')
          .doc(announcementId)
          .set(announcement.toMap());

      return announcementId;
    } catch (e) {
      rethrow;
    }
  }

  // Get announcement by ID
  Future<Announcement?> getAnnouncement(String id) async {
    try {
      final doc = await _firestore.collection('announcements').doc(id).get();
      if (doc.exists) {
        return Announcement.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get all announcements stream (real-time)
  Stream<List<Announcement>> getAnnouncementsStream() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Announcement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get announcements by area
  Stream<List<Announcement>> getAnnouncementsByAreaStream(String area) {
    return _firestore
        .collection('announcements')
        .where('area', isEqualTo: area)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Announcement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Search announcements
  Future<List<Announcement>> searchAnnouncements(String keyword) async {
    try {
      final snapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      final announcements = snapshot.docs
          .map((doc) => Announcement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by keyword
      return announcements
          .where((a) =>
              a.title.toLowerCase().contains(keyword.toLowerCase()) ||
              a.description.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update announcement
  Future<void> updateAnnouncement(Announcement announcement) async {
    try {
      await _firestore
          .collection('announcements')
          .doc(announcement.id)
          .update(announcement.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete announcement
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get admin announcements
  Stream<List<Announcement>> getAdminAnnouncementsStream(String adminId) {
    return _firestore
        .collection('announcements')
        .where('createdBy', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Announcement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Clean up old announcements (older than 30 days)
  Future<void> cleanupOldAnnouncements() async {
    try {
      final thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('announcements')
          .where('createdAt', isLessThan: thirtyDaysAgo)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // READ/UNREAD STATUS

  // Mark announcement as read
  Future<void> markAsRead(String userId, String announcementId) async {
    try {
      final statusId = '$userId-$announcementId';
      final readStatus = ReadStatus(
        id: statusId,
        userId: userId,
        announcementId: announcementId,
        isRead: true,
        readAt: DateTime.now(),
      );

      await _firestore
          .collection('read_status')
          .doc(statusId)
          .set(readStatus.toMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // Check if announcement is read
  Future<bool> isAnnouncementRead(String userId, String announcementId) async {
    try {
      final statusId = '$userId-$announcementId';
      final doc = await _firestore
          .collection('read_status')
          .doc(statusId)
          .get();

      if (doc.exists) {
        return doc.data()?['isRead'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Get read status stream
  Stream<List<ReadStatus>> getReadStatusStream(String userId) {
    return _firestore
        .collection('read_status')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReadStatus.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // NOTIFICATIONS

  // Create notifications for all client users when announcement is posted
  Future<void> createNotificationsForAllClients({
    required String announcementId,
    required String title,
    required String area,
    String type = 'new',
  }) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'client')
          .get();

      final batch = _firestore.batch();
      for (final userDoc in usersSnapshot.docs) {
        final notifId = const Uuid().v4();
        final ref = _firestore.collection('notifications').doc(notifId);
        batch.set(ref, AppNotification(
          id: notifId,
          userId: userDoc.id,
          announcementId: announcementId,
          title: title,
          area: area,
          isRead: false,
          createdAt: DateTime.now(),
          type: type,
        ).toMap());
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Get notifications stream for a user
  Stream<List<AppNotification>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.data()))
            .toList());
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      rethrow;
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // ANALYTICS

  // Get total announcements count
  Future<int> getTotalAnnouncementsCount() async {
    try {
      final snapshot = await _firestore.collection('announcements').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  // Get active users count
  Future<int> getActiveUsersCount() async {
    try {
      final snapshot = await _firestore.collection('users').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  // Get announcements count by area
  Future<int> getAnnouncementsCountByArea(String area) async {
    try {
      final snapshot = await _firestore
          .collection('announcements')
          .where('area', isEqualTo: area)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      rethrow;
    }
  }
}
