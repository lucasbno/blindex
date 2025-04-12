import 'package:bcrypt/bcrypt.dart';

class User {
  final String name;
  final String phoneNumber;
  final String email;
  final String passwordHash;

  User({required this.name, required this.email, required this.phoneNumber, required String password})
      : passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

  User copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    String? passwordHash,
    }) {
      return User(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: passwordHash ?? this.passwordHash);
    }

  bool checkPassword(String password) {
    return BCrypt.checkpw(password, passwordHash);
  }
}
