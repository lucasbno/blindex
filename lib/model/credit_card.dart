import 'package:cloud_firestore/cloud_firestore.dart';

class CreditCard {
  final String? id;
  final String userId;
  String title;
  String cardholderName;
  String cardNumber;
  String expiryDate;
  String securityCode;
  String pin;
  String notes;
  final DateTime createdAt;
  DateTime updatedAt;

  CreditCard({
    this.id,
    required this.userId,
    required this.title,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.securityCode,
    this.pin = '',
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CreditCard.create({
    required String userId,
    required String title,
    required String cardholderName,
    required String cardNumber,
    required String expiryDate,
    required String securityCode,
    String pin = '',
    String notes = '',
  }) {
    return CreditCard(
      userId: userId,
      title: title,
      cardholderName: cardholderName,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      securityCode: securityCode,
      pin: pin,
      notes: notes,
    );
  }

  factory CreditCard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CreditCard(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      cardholderName: data['cardholderName'] ?? '',
      cardNumber: data['cardNumber'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
      securityCode: data['securityCode'] ?? '',
      pin: data['pin'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'cardholderName': cardholderName,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'securityCode': securityCode,
      'pin': pin,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  CreditCard copyWith({
    String? title,
    String? cardholderName,
    String? cardNumber,
    String? expiryDate,
    String? securityCode,
    String? pin,
    String? notes,
  }) {
    return CreditCard(
      id: id,
      userId: userId,
      title: title ?? this.title,
      cardholderName: cardholderName ?? this.cardholderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      securityCode: securityCode ?? this.securityCode,
      pin: pin ?? this.pin,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'cardholderName': cardholderName,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'securityCode': securityCode,
      'pin': pin,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'],
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      cardholderName: map['cardholderName'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      securityCode: map['securityCode'] ?? '',
      pin: map['pin'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  String get formattedCardNumber {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  String get cardBrand {
    final number = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'American Express';
    if (number.startsWith('6')) return 'Elo';
    return 'Outro';
  }

  @override
  String toString() {
    return 'CreditCard(id: $id, title: $title, cardholderName: $cardholderName, userId: $userId)';
  }
}
