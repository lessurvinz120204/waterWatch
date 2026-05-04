import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String announcementId;
  final String title;
  final String area;
  final bool isRead;
  final DateTime createdAt;
  final String type; // 'new' or 'resolved'

  AppNotification({
    required this.id,
    required this.userId,
    required this.announcementId,
    required this.title,
    required this.area,
    this.isRead = false,
    required this.createdAt,
    this.type = 'new',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'announcementId': announcementId,
        'title': title,
        'area': area,
        'isRead': isRead,
        'createdAt': createdAt,
        'type': type,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as String,
        userId: map['userId'] as String,
        announcementId: map['announcementId'] as String,
        title: map['title'] as String,
        area: map['area'] as String,
        isRead: map['isRead'] as bool? ?? false,
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        type: map['type'] as String? ?? 'new',
      );
}
