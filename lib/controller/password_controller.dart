import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/password.dart';
import '../repository/password_repository.dart';

class PasswordController extends ChangeNotifier {
  final PasswordRepository _repository = PasswordRepository();
  String _searchQuery = '';
  
  // Getters delegados ao repository
  List<Password> get passwords => _repository.passwords;
  bool get isLoading => _repository.isLoading;
  String? get errorMessage => _repository.errorMessage;

  List<Password> get filteredPasswords {
    final List<Password> filtered = _repository.filterPasswords(_searchQuery);
    
    // Ordenar com favoritos primeiro
    filtered.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return filtered;
  }

  String get searchQuery => _searchQuery;

  set searchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await loadPasswords(user.uid);
    }
  }

  // Carregar senhas do Firestore
  Future<void> loadPasswords(String userId) async {
    _repository.addListener(_onRepositoryChanged);
    await _repository.loadPasswords(userId);
  }

  // Callback para mudanças no repository
  void _onRepositoryChanged() {
    notifyListeners();
  }

  // Stream para mudanças em tempo real
  Stream<List<Password>> watchPasswords(String userId) {
    return _repository.watchPasswords(userId);
  }

  // Adicionar nova senha
  Future<bool> addPassword(Password password) async {
    return await _repository.addPassword(password);
  }

  // Atualizar senha existente
  Future<bool> updatePassword(Password password) async {
    return await _repository.updatePassword(password);
  }

  // Deletar senha
  Future<bool> deletePassword(String passwordId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    return await _repository.deletePassword(passwordId, user.uid);
  }

  // Alternar favorito
  Future<bool> toggleFavorite(Password password) async {
    return await _repository.toggleFavorite(password);
  }

  // Buscar senha por ID
  Password? findPasswordById(String id) {
    try {
      return passwords.firstWhere((password) => password.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obter apenas favoritos
  List<Password> get favoritePasswords => _repository.getFavoritePasswords();

  // Limpar erro
  void clearError() {
    _repository.clearError();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}