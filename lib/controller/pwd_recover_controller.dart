import 'package:blindex/model/user_model.dart';
import 'package:blindex/repository/user_repository.dart';
import 'package:flutter/material.dart';

class PwdRecoverController extends ChangeNotifier {
  final UserRepository userRepository;

  PwdRecoverController(this.userRepository);

  bool checkUser(String email) {
    final users = userRepository.users;

    final user = users.firstWhere(
      (u) => u != null && u.email == email,
      orElse: () => null,
    );

    return user != null;
  }

  bool checkValidation(String validationCode) {
    return validationCode == '12345';
  }

  bool resetPassword(String email, String newPassword, String passwordConfirm) {
    final users = userRepository.users;

    final user = users.firstWhere(
      (u) => u != null && u.email == email,
      orElse: () => null,
    );

    // Check if user exists and passwords match
    if (user == null || newPassword != passwordConfirm) return false;

    // Check if new password is the same as the old one
    if (user.checkPassword(newPassword)) return false;

    // Use the updated copyWith method with newPassword parameter
    User updatedUser = user.copyWith(newPassword: newPassword);

    userRepository.updateUser(updatedUser);

    return true;
  }
}