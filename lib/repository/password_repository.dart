import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/password.dart';
import '../components/advanced_search_modal.dart';

class PasswordRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Password> _passwords = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Password> get passwords => _passwords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadPasswords(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final querySnapshot = await _firestore
          .collection('cofre')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      _passwords = querySnapshot.docs
          .map((doc) => Password.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Erro de índice detectado, usando query alternativa: $e');
      
      try {
        final querySnapshot = await _firestore
            .collection('cofre')
            .where('userId', isEqualTo: userId)
            .get();
        
        final passwords = querySnapshot.docs
            .map((doc) => Password.fromFirestore(doc))
            .toList();
        
        passwords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _passwords = passwords;
        
        _isLoading = false;
        notifyListeners();
      } catch (fallbackError) {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar senhas: $fallbackError';
        notifyListeners();
        print('Erro ao carregar senhas: $fallbackError');
      }
    }
  }
  
  Future<bool> addPassword(Password password) async {
    try {
      await _firestore
          .collection('cofre')
          .add(password.toFirestore());
      
      await loadPasswords(password.userId);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar senha: $e';
      notifyListeners();
      print('Erro ao adicionar senha: $e');
      return false;
    }
  }
  
  Future<bool> updatePassword(Password password) async {
    if (password.id == null) return false;
    
    try {
      await _firestore
          .collection('cofre')
          .doc(password.id)
          .update(password.toFirestore());
      
      await loadPasswords(password.userId);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar senha: $e';
      notifyListeners();
      print('Erro ao atualizar senha: $e');
      return false;
    }
  }
  
  Future<bool> deletePassword(String passwordId, String userId) async {
    try {
      await _firestore
          .collection('cofre')
          .doc(passwordId)
          .delete();
      
      await loadPasswords(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao deletar senha: $e';
      notifyListeners();
      print('Erro ao deletar senha: $e');
      return false;
    }
  }
  
  Future<bool> toggleFavorite(Password password) async {
    if (password.id == null) return false;
    
    try {
      final updatedPassword = password.copyWith(isFavorite: !password.isFavorite);
      return await updatePassword(updatedPassword);
    } catch (e) {
      _errorMessage = 'Erro ao alterar favorito: $e';
      notifyListeners();
      print('Erro ao alterar favorito: $e');
      return false;
    }
  }
  
  List<Password> filterPasswords(String query) {
    if (query.isEmpty) return _passwords;
    
    return _passwords.where((password) {
      return password.title.toLowerCase().contains(query.toLowerCase()) ||
             password.login.toLowerCase().contains(query.toLowerCase()) ||
             password.site.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
  
  List<Password> getFavoritePasswords() {
    return _passwords.where((password) => password.isFavorite).toList();
  }
  
  List<Password> getSortedPasswords({
    required SortCriteria criteria,
    bool ascending = true,
  }) {
    final sortedList = List<Password>.from(_passwords);
    
    switch (criteria) {
      case SortCriteria.title:
        sortedList.sort((a, b) => ascending 
            ? a.title.compareTo(b.title) 
            : b.title.compareTo(a.title));
        break;
      case SortCriteria.createdAt:
        sortedList.sort((a, b) => ascending 
            ? a.createdAt.compareTo(b.createdAt) 
            : b.createdAt.compareTo(a.createdAt));
        break;
      case SortCriteria.updatedAt:
        sortedList.sort((a, b) => ascending 
            ? a.updatedAt.compareTo(b.updatedAt) 
            : b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortCriteria.site:
        sortedList.sort((a, b) => ascending 
            ? a.site.compareTo(b.site) 
            : b.site.compareTo(a.site));
        break;
      case SortCriteria.login:
        sortedList.sort((a, b) => ascending 
            ? a.login.compareTo(b.login) 
            : b.login.compareTo(a.login));
        break;
    }
    
    return sortedList;
  }
  
  // Stream para escutar mudanças em tempo real
  Stream<List<Password>> watchPasswords(String userId) {
    return _firestore
        .collection('cofre')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final passwords = snapshot.docs
          .map((doc) => Password.fromFirestore(doc))
          .toList();
      
      passwords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return passwords;
    });
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
