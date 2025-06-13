import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? uid; // Firebase UID
  final String name;
  final String phoneNumber;
  final String email;
  final DateTime? createdAt;

  User({
    this.uid,
    required this.name, 
    required this.email, 
    required this.phoneNumber,
    this.createdAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  User copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}