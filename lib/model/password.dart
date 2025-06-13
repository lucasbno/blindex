import 'package:cloud_firestore/cloud_firestore.dart';

class Password {
  final String? id;
  final String userId;
  String title;
  String login;
  String password;
  String site;
  String notes;
  String icon;
  bool isFavorite;
  bool isDeleted;
  DateTime? deletedAt;
  final DateTime createdAt;
  DateTime updatedAt;

  Password({
    this.id,
    required this.userId,
    required this.title,
    required this.login,
    required this.password,
    this.site = '',
    this.notes = '',
    this.icon = '',
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Password.create({
    required String userId,
    required String title,
    required String login,
    required String password,
    String site = '',
    String notes = '',
    String icon = '',
    bool isFavorite = false,
    bool isDeleted = false,
  }) {
    return Password(
      userId: userId,
      title: title,
      login: login,
      password: password,
      site: site,
      notes: notes,
      icon: icon,
      isFavorite: isFavorite,
      isDeleted: isDeleted,
    );
  }

  factory Password.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Password(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      login: data['login'] ?? '',
      password: data['password'] ?? '',
      site: data['site'] ?? '',
      notes: data['notes'] ?? '',
      icon: data['icon'] ?? '',
      isFavorite: data['isFavorite'] == true,
      isDeleted: data['isDeleted'] == true,
      deletedAt: data['deletedAt']?.toDate(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Converte Password para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'login': login,
      'password': password,
      'site': site,
      'notes': notes,
      'icon': icon,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  Password copyWith({
    String? title,
    String? login,
    String? password,
    String? site,
    String? notes,
    String? icon,
    bool? isFavorite,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Password(
      id: id,
      userId: userId,
      title: title ?? this.title,
      login: login ?? this.login,
      password: password ?? this.password,
      site: site ?? this.site,
      notes: notes ?? this.notes,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Converte Password para Map (compatibilidade com navegação)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'login': login,
      'password': password,
      'site': site,
      'notes': notes,
      'icon': icon,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      site: map['site'] ?? '',
      notes: map['notes'] ?? '',
      icon: map['icon'] ?? '',
      isFavorite: map['isFavorite'] == true,
      isDeleted: map['isDeleted'] == true,
      deletedAt: map['deletedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'])
          : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Password(id: $id, title: $title, login: $login, userId: $userId)';
  }
}