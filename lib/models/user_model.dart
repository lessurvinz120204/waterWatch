import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, client }

class User {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String? area;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.area,
    required this.createdAt,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'area': area,
      'createdAt': createdAt,
    };
  }

  // Create User from Firestore document
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.client,
      ),
      area: map['area'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create copy with modifications
  User copyWith({
    String? userId,
    String? name,
    String? email,
    UserRole? role,
    String? area,
    DateTime? createdAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      area: area ?? this.area,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
