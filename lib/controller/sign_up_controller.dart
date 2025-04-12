import 'package:blindex/model/user_model.dart';
import 'package:blindex/repository/user_repository.dart';
import 'package:flutter/material.dart';

class SignUpController extends ChangeNotifier {

  final UserRepository userRepository;

  SignUpController(this.userRepository);

  bool signUp(String name, String phoneNumber, String email, String password, String passwordConfirm) {
    final users = userRepository.users;
      
    final userExists = users.any(
      (u) => u != null && u.email == email,
    );

    if (userExists) return false;

    if (password != passwordConfirm) return false;

    final newUser = User(name: name, email: email, phoneNumber: phoneNumber, password: password);
    users.add(newUser);

    return true;
  }
}
