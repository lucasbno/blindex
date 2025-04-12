import 'package:blindex/repository/user_repository.dart';
import 'package:flutter/material.dart';


class LoginScreenController extends ChangeNotifier {

  final UserRepository userRepository;

  LoginScreenController(this.userRepository);

  bool login(String email, String password) {
    final users = userRepository.users;

    final user = users.firstWhere(
      (u) => u != null && u.email == email && u.checkPassword(password),
      orElse: () => null,
    );

    return user != null;
  }
}
