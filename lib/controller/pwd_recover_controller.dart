import 'package:bcrypt/bcrypt.dart';
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

    if (user == null && newPassword != passwordConfirm) return false;

    if (user!.checkPassword(newPassword)) return false;

    final passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    User updatedUser = user.copyWith(passwordHash: passwordHash);

    userRepository.updateUser(updatedUser);

    return true;
  }
}
