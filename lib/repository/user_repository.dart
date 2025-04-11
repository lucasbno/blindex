import 'package:flutter/material.dart';
import '../model/user_model.dart';


class UserRepository extends ChangeNotifier {
  final List<User?> users = [
    User(email: 'alice@example.com', password: 'password123'),
    User(email: 'bob@example.com', password: 'hunter2')
  ];
}
