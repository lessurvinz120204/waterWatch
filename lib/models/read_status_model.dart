import 'package:cloud_firestore/cloud_firestore.dart';

class ReadStatus {
  final String id;
  final String userId;
  final String announcementId;
  final bool isRead;
  final DateTime readAt;

  ReadStatus({
    required this.id,
    required this.userId,
    required this.announcementId,
    this.isRead = false,
    required this.readAt,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'announcementId': announcementId,
      'isRead': isRead,
      'readAt': readAt,
    };
  }

  // Create ReadStatus from Firestore document
  factory ReadStatus.fromMap(Map<String, dynamic> map) {
    return ReadStatus(
      id: map['id'] as String,
      userId: map['userId'] as String,
      announcementId: map['announcementId'] as String,
      isRead: map['isRead'] as bool? ?? false,
      readAt: (map['readAt'] as Timestamp).toDate(),
    );
  }
}
