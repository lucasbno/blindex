import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/password.dart';
import '../repository/password_repository.dart';
import '../components/advanced_search_modal.dart';

class PasswordController extends ChangeNotifier {
  final PasswordRepository _repository = PasswordRepository();
  SearchFilters _filters = SearchFilters();
  
  List<Password> get passwords => _repository.passwords;
  bool get isLoading => _repository.isLoading;
  String? get errorMessage => _repository.errorMessage;
  SearchFilters get filters => _filters;

  List<Password> get filteredPasswords {
    List<Password> filtered = List.from(_repository.passwords);
    
    if (_filters.query.isNotEmpty) {
      final query = _filters.query.toLowerCase();
      filtered = filtered.where((password) {
        return password.title.toLowerCase().contains(query) ||
               password.login.toLowerCase().contains(query) ||
               password.site.toLowerCase().contains(query) ||
               password.notes.toLowerCase().contains(query);
      }).toList();
    }
    
    if (_filters.favoritesOnly) {
      filtered = filtered.where((password) => password.isFavorite).toList();
    }
    
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_filters.sortBy) {
        case SortCriteria.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case SortCriteria.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortCriteria.updatedAt:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case SortCriteria.site:
          comparison = a.site.toLowerCase().compareTo(b.site.toLowerCase());
          break;
        case SortCriteria.login:
          comparison = a.login.toLowerCase().compareTo(b.login.toLowerCase());
          break;
      }
      
      if (_filters.sortOrder == SortOrder.descending) {
        comparison = -comparison;
      }
      
      if (!_filters.favoritesOnly) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
      }
      
      return comparison;
    });

    return filtered;
  }

  String get searchQuery => _filters.query;

  set searchQuery(String query) {
    _filters = _filters.copyWith(query: query);
    notifyListeners();
  }

  void updateFilters(SearchFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void clearFilters() {
    _filters = SearchFilters();
    notifyListeners();
  }

  bool get hasActiveFilters {
    return _filters.query.isNotEmpty ||
           _filters.favoritesOnly ||
           _filters.sortBy != SortCriteria.title ||
           _filters.sortOrder != SortOrder.ascending;
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

  // Mover senha para lixeira
  Future<bool> moveToTrash(String passwordId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    return await _repository.moveToTrash(passwordId, user.uid);
  }

  // Deletar senha permanentemente
  Future<bool> deletePassword(String passwordId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    return await _repository.deletePassword(passwordId, user.uid);
  }

  // Restaurar senha da lixeira
  Future<bool> restoreFromTrash(String passwordId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    return await _repository.restoreFromTrash(passwordId, user.uid);
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