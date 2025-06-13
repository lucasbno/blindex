import 'package:blindex/repository/user_repository.dart';
import 'package:flutter/material.dart';

class LoginScreenController extends ChangeNotifier {
  final UserRepository userRepository;

  LoginScreenController(this.userRepository);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await userRepository.signIn(
        email: email,
        password: password,
      );

      _isLoading = false;
      
      if (!success) {
        _errorMessage = 'Email ou senha incorretos';
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao fazer login: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
