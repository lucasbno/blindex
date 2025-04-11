import 'package:bcrypt/bcrypt.dart';

class User {
  String? email;
  final String? _passwordHash;

  User({this.email, required String password})
      : _passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

  bool checkPassword(String password) {
    return BCrypt.checkpw(password, _passwordHash ?? '');
  }

}
