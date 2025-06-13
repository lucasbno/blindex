import 'package:blindex/repository/user_repository.dart';
import 'package:flutter/material.dart';

class PwdRecoverController extends ChangeNotifier {
  final UserRepository userRepository;

  PwdRecoverController(this.userRepository);

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final success = await userRepository.resetPassword(email);

      _isLoading = false;

      if (success) {
        _successMessage = 'Email de recuperação enviado com sucesso!';
      } else {
        _errorMessage = 'Erro ao enviar email de recuperação';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao enviar email: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}