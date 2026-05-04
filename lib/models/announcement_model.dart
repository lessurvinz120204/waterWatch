import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final String area;
  final DateTime startTime;
  final DateTime endTime;
  final String createdBy; // Admin ID
  final DateTime createdAt;
  final bool isActive;
  final String category;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.area,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.createdAt,
    this.category = 'Maintenance',
    this.isActive = true,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'area': area,
      'startTime': startTime,
      'endTime': endTime,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'category': category,
      'isActive': isActive,
    };
  }

  // Create Announcement from Firestore document
  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      area: map['area'] as String,
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      createdBy: map['createdBy'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      category: map['category'] as String? ?? 'Maintenance',
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  // Create copy with modifications
  Announcement copyWith({
    String? id,
    String? title,
    String? description,
    String? area,
    DateTime? startTime,
    DateTime? endTime,
    String? createdBy,
    DateTime? createdAt,
    String? category,
    bool? isActive,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      area: area ?? this.area,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }
}
