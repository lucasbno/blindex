import 'package:bcrypt/bcrypt.dart';

class User {
  final String email;
  final String passwordHash;

  User({required this.email, required String password})
      : passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

  User copyWith({
    String? email,
    String? passwordHash,
    }) {
      return User(
      email: email ?? this.email, 
      password: passwordHash ?? this.passwordHash);
    }

  bool checkPassword(String password) {
    return BCrypt.checkpw(password, passwordHash ?? '');
  }
}
