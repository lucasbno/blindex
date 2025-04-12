import 'package:flutter/material.dart';
import '../model/user_model.dart';


class UserRepository extends ChangeNotifier {
  List<User?> users = [
    User(name: 'Alice', phoneNumber: '(16) 0555-2368', email: 'alice@example.com', password: 'password123'),
    User(name: 'Bob', phoneNumber: '(80) 0451-1138', email: 'bob@example.com', password: 'hunter2')
  ];

  void updateUser(User updatedUser) {
    users = users.map( (u) => u?.email == updatedUser.email ? updatedUser : u).toList();
  }
}
