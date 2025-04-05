import 'package:flutter/material.dart';
import '../model/user_model.dart';


class LoginScreenController extends ChangeNotifier {

  final List<User?> users = [
    User(email: 'alice@example.com', password: 'password123'),
    User(email: 'bob@example.com', password: 'hunter2')
  ];

bool login(String email, String password) {
  final user = users.firstWhere(
    (u) => u != null && u.email == email && u.checkPassword(password),
    orElse: () => null,
  );

  return user != null;
}

}
