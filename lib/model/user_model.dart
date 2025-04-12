import 'package:bcrypt/bcrypt.dart';

class User {
  final String name;
  final String phoneNumber;
  final String email;
  final String passwordHash;

  // Regular constructor that hashes the password
  User({required this.name, required this.email, required this.phoneNumber, required String password})
      : passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

  // Add a named constructor for creating with an existing hash
  User.withExistingHash({
    required this.name, 
    required this.email, 
    required this.phoneNumber, 
    required this.passwordHash
  });

  // Fixed copyWith method
  User copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    String? newPassword,  // Changed to newPassword to make intent clear
  }) {
    if (newPassword != null) {
      // If a new password is provided, hash it
      return User(
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email ?? this.email,
        password: newPassword,
      );
    } else {
      // If no new password, keep the existing hash
      return User.withExistingHash(
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email ?? this.email,
        passwordHash: this.passwordHash,
      );
    }
  }

  bool checkPassword(String password) {
    return BCrypt.checkpw(password, passwordHash);
  }
}