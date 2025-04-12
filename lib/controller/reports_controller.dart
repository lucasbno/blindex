import 'package:flutter/material.dart';
import '../model/password.dart';

class ReportsController extends ChangeNotifier {
  List<Password> getWeakPasswords(List<Password> passwords) {
    const minLength = 8;
    RegExp specialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    RegExp numbers = RegExp(r'[0-9]');
    RegExp upperCase = RegExp(r'[A-Z]');

    return passwords.where((pw) {
      return pw.password.length < minLength ||
          !specialChars.hasMatch(pw.password) ||
          !numbers.hasMatch(pw.password) ||
          !upperCase.hasMatch(pw.password);
    }).toList();
  }

  List<Map<String, dynamic>> getReusedPasswords(List<Password> passwords) {
    Map<String, List<Password>> passwordGroups = {};

    for (var pw in passwords) {
      if (passwordGroups.containsKey(pw.password)) {
        passwordGroups[pw.password]!.add(pw);
      } else {
        passwordGroups[pw.password] = [pw];
      }
    }

    List<Map<String, dynamic>> reusedGroups = [];
    passwordGroups.forEach((pwValue, pwList) {
      if (pwList.length > 1) {
        reusedGroups.add({'password': pwValue, 'accounts': pwList});
      }
    });

    return reusedGroups;
  }

  double calculateSecurityScore(
    List<Password> allPasswords,
    List<Password> weakPasswords,
    List<Map<String, dynamic>> reusedPasswords,
  ) {
    if (allPasswords.isEmpty) {
      return 100;
    }

    int totalIssues = weakPasswords.length;

    for (var group in reusedPasswords) {
      totalIssues += (group['accounts'] as List).length - 1;
    }
    
    double score = 100 - ((totalIssues / allPasswords.length) * 100);

    return score.clamp(0, 100);
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
    List<String> weaknesses = [];

    if (password.length < 8) {
      weaknesses.add('Menos de 8 caracteres');
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      weaknesses.add('Sem caracteres especiais');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      weaknesses.add('Sem números');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      weaknesses.add('Sem letras maiúsculas');
    }

    return weaknesses;
  }
}
