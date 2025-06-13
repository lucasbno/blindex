import 'package:blindex/repository/user_repository.dart';
import 'package:flutter/material.dart';

class SignUpController extends ChangeNotifier {
  final UserRepository userRepository;

  SignUpController(this.userRepository);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signUp(
    String name,
    String phoneNumber,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validar se as senhas coincidem
      if (password != passwordConfirm) {
        _errorMessage = 'As senhas não coincidem';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validar campos obrigatórios
      if (name.trim().isEmpty ||
          email.trim().isEmpty ||
          phoneNumber.trim().isEmpty ||
          password.trim().isEmpty) {
        _errorMessage = 'Todos os campos são obrigatórios';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Tentar cadastrar com Firebase Auth
      final success = await userRepository.signUp(
        name: name.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        password: password,
      );

      _isLoading = false;

      if (!success) {
        _errorMessage = 'Erro ao criar conta. Verifique os dados e tente novamente.';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao criar conta: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
