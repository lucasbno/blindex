import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../model/password.dart';

class PasswordFormController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final siteController = TextEditingController();
  final notesController = TextEditingController();
  bool isFavorite = false;
  bool obscurePassword = true;

  int passwordLength = 12;
  bool includeSpecialChars = true;
  bool includeNumbers = true;
  bool includeUppercase = true;
  String generatedPassword = '';

  void populateForm(Password password) {
    titleController.text = password.title;
    loginController.text = password.login;
    passwordController.text = password.password;
    siteController.text = password.site;
    notesController.text = password.notes;
    isFavorite = password.isFavorite;
    notifyListeners();
  }

  void clear() {
    titleController.clear();
    loginController.clear();
    passwordController.clear();
    siteController.clear();
    notesController.clear();
    generatedPassword = '';
    isFavorite = false;
    obscurePassword = true;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Password? validateAndGetPassword({String? existingId}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    
    if (formKey.currentState?.validate() ?? false) {
      if (existingId != null) {
        return Password(
          id: existingId,
          userId: user.uid,
          title: titleController.text,
          login: loginController.text,
          password: passwordController.text,
          site: siteController.text,
          notes: notesController.text,
          isFavorite: isFavorite,
        );
      } else {
        return Password.create(
          userId: user.uid,
          title: titleController.text,
          login: loginController.text,
          password: passwordController.text,
          site: siteController.text,
          notes: notesController.text,
          isFavorite: isFavorite,
        );
      }
    }
    return null;
  }

  String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      if (fieldName == 'um título' || fieldName == 'um login' || fieldName == 'uma senha') {
        return 'Por favor, insira $fieldName';
      }
    }
    
    if (fieldName == 'um título' && value != null && value.length < 3) {
      return 'O título deve ter pelo menos 3 caracteres';
    }
    
    return null;
  }

  void generateNewPassword() {
    String chars = 'abcdefghijklmnopqrstuvwxyz';
    
    if (includeUppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (includeNumbers) chars += '0123456789';
    if (includeSpecialChars) chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    final random = Random.secure();
    final password = List.generate(passwordLength, (_) {
      return chars[random.nextInt(chars.length)];
    }).join('');
    
    generatedPassword = password;
    notifyListeners();
  }

  void applyGeneratedPassword() {
    passwordController.text = generatedPassword;
    notifyListeners();
  }

  void updatePasswordLength(int newLength) {
    passwordLength = newLength;
    notifyListeners();
  }

  void toggleSpecialChars() {
    includeSpecialChars = !includeSpecialChars;
    notifyListeners();
  }

  void toggleNumbers() {
    includeNumbers = !includeNumbers;
    notifyListeners();
  }

  void toggleUppercase() {
    includeUppercase = !includeUppercase;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    loginController.dispose();
    passwordController.dispose();
    siteController.dispose();
    notesController.dispose();
    super.dispose();
  }
}