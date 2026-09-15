import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final List<String> fcmTokens;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.fcmTokens = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmTokens': fcmTokens,
    };
  }
}
