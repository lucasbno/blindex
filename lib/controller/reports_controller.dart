import 'package:flutter/material.dart';
import '../model/password.dart';

class ReportsController extends ChangeNotifier {
  static const int minPasswordLength = 8;
  static final RegExp _specialCharsRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  static final RegExp _numbersRegex = RegExp(r'[0-9]');
  static final RegExp _upperCaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowerCaseRegex = RegExp(r'[a-z]');

  List<Password> getWeakPasswords(List<Password> passwords) {
    return passwords.where((password) => isWeakPassword(password.password)).toList();
  }

  bool isWeakPassword(String password) {
    if (password.isEmpty) return true;
    
    return password.length < minPasswordLength ||
        !_specialCharsRegex.hasMatch(password) ||
        !_numbersRegex.hasMatch(password) ||
        !_upperCaseRegex.hasMatch(password) ||
        !_lowerCaseRegex.hasMatch(password);
  }

  List<Map<String, dynamic>> getReusedPasswords(List<Password> passwords) {
    if (passwords.isEmpty) return [];
    
    Map<String, List<Password>> passwordGroups = {};

    for (var password in passwords) {
      if (password.password.isNotEmpty) {
        passwordGroups.putIfAbsent(password.password, () => []).add(password);
      }
    }

    return passwordGroups.entries
        .where((entry) => entry.value.length > 1)
        .map((entry) => {
              'password': entry.key,
              'accounts': entry.value,
            })
        .toList();
  }

  int getTotalReusedAccounts(List<Map<String, dynamic>> reusedGroups) {
    return reusedGroups.fold(0, (total, group) {
      final accounts = group['accounts'] as List<Password>;
      return total + (accounts.length - 1);
    });
  }

  double calculateSecurityScore(
    List<Password> allPasswords,
    List<Password> weakPasswords,
    List<Map<String, dynamic>> reusedGroups,
  ) {
    if (allPasswords.isEmpty) {
      return 100.0;
    }

    int totalIssues = weakPasswords.length + getTotalReusedAccounts(reusedGroups);
    
    if (totalIssues == 0) {
      return 100.0;
    }
    
    double score = 100.0 - ((totalIssues / allPasswords.length) * 100);
    return score.clamp(0.0, 100.0);
  }

  Color getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  List<String> getPasswordWeaknesses(String password) {
    if (password.isEmpty) {
      return ['Senha vazia'];
    }

    List<String> weaknesses = [];

    if (password.length < minPasswordLength) {
      weaknesses.add('Menos de $minPasswordLength caracteres');
    }
    if (!_specialCharsRegex.hasMatch(password)) {
      weaknesses.add('Sem caracteres especiais');
    }
    if (!_numbersRegex.hasMatch(password)) {
      weaknesses.add('Sem números');
    }
    if (!_upperCaseRegex.hasMatch(password)) {
      weaknesses.add('Sem letras maiúsculas');
    }
    if (!_lowerCaseRegex.hasMatch(password)) {
      weaknesses.add('Sem letras minúsculas');
    }

    return weaknesses;
  }

  String getPasswordStrengthText(String password) {
    if (password.isEmpty) return 'Muito Fraca';
    
    int score = 0;
    if (password.length >= minPasswordLength) score++;
    if (_specialCharsRegex.hasMatch(password)) score++;
    if (_numbersRegex.hasMatch(password)) score++;
    if (_upperCaseRegex.hasMatch(password)) score++;
    if (_lowerCaseRegex.hasMatch(password)) score++;

    switch (score) {
      case 5:
        return 'Muito Forte';
      case 4:
        return 'Forte';
      case 3:
        return 'Média';
      case 2:
        return 'Fraca';
      default:
        return 'Muito Fraca';
    }
  }

  Color getPasswordStrengthColor(String password) {
    if (password.isEmpty) return Colors.grey;
    
    int score = 0;
    if (password.length >= minPasswordLength) score++;
    if (_specialCharsRegex.hasMatch(password)) score++;
    if (_numbersRegex.hasMatch(password)) score++;
    if (_upperCaseRegex.hasMatch(password)) score++;
    if (_lowerCaseRegex.hasMatch(password)) score++;

    switch (score) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
}
