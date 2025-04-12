import 'package:flutter/material.dart';
import '../model/user_model.dart';


class UserRepository extends ChangeNotifier {
  List<User?> users = [
    User(email: 'alice@example.com', password: 'password123'),
    User(email: 'bob@example.com', password: 'hunter2')
  ];

  void updateUser(User updatedUser) {
    users = users.map( (u) => u?.email == updatedUser.email ? updatedUser : u).toList();
  }
}
