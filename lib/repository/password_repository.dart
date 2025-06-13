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
        
        _passwords = passwords; // Filtra senhas não deletadas
        
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
  
  // Move senha para lixeira (mover para coleção separada)
  Future<bool> moveToTrash(String passwordId, String userId) async {
    try {
      // Buscar a senha original
      final passwordDoc = await _firestore
          .collection('cofre')
          .doc(passwordId)
          .get();
      
      if (!passwordDoc.exists) {
        _errorMessage = 'Senha não encontrada';
        notifyListeners();
        return false;
      }
      
      final password = Password.fromFirestore(passwordDoc);
      
      // Criar dados para a lixeira
      final trashData = password.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
      ).toFirestore();
      
      // Adicionar à coleção lixeira
      await _firestore
          .collection('lixeira')
          .doc(passwordId) // Usar o mesmo ID
          .set(trashData);
      
      // Remover da coleção cofre
      await _firestore
          .collection('cofre')
          .doc(passwordId)
          .delete();
      
      await loadPasswords(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao mover senha para lixeira: $e';
      notifyListeners();
      print('Erro ao mover senha para lixeira: $e');
      return false;
    }
  }

  // Deleta senha permanentemente da lixeira
  Future<bool> deletePassword(String passwordId, String userId) async {
    try {
      await _firestore
          .collection('lixeira')
          .doc(passwordId)
          .delete();
      
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao deletar senha permanentemente: $e';
      notifyListeners();
      print('Erro ao deletar senha permanentemente: $e');
      return false;
    }
  }

  // Restaura senha da lixeira para o cofre
  Future<bool> restoreFromTrash(String passwordId, String userId) async {
    try {
      // Buscar a senha na lixeira
      final trashDoc = await _firestore
          .collection('lixeira')
          .doc(passwordId)
          .get();
      
      if (!trashDoc.exists) {
        _errorMessage = 'Senha não encontrada na lixeira';
        notifyListeners();
        return false;
      }
      
      final password = Password.fromFirestore(trashDoc);
      
      // Criar dados para restaurar (remover campos da lixeira)
      final restoredData = password.copyWith(
        isDeleted: false,
        deletedAt: null,
      ).toFirestore();
      
      // Remover campos específicos da lixeira
      restoredData.remove('isDeleted');
      restoredData.remove('deletedAt');
      restoredData['updatedAt'] = DateTime.now();
      
      // Adicionar de volta ao cofre
      await _firestore
          .collection('cofre')
          .doc(passwordId)
          .set(restoredData);
      
      // Remover da lixeira
      await _firestore
          .collection('lixeira')
          .doc(passwordId)
          .delete();
      
      await loadPasswords(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao restaurar senha: $e';
      notifyListeners();
      print('Erro ao restaurar senha: $e');
      return false;
    }
  }

  // Carrega senhas da lixeira
  Future<List<Password>> loadDeletedPasswords(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('lixeira')
          .where('userId', isEqualTo: userId)
          .orderBy('deletedAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Password.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao carregar lixeira: $e');
      // Fallback se não há índice para deletedAt
      try {
        final querySnapshot = await _firestore
            .collection('lixeira')
            .where('userId', isEqualTo: userId)
            .get();
        
        final passwords = querySnapshot.docs
            .map((doc) => Password.fromFirestore(doc))
            .toList();
        
        passwords.sort((a, b) {
          if (a.deletedAt == null && b.deletedAt == null) return 0;
          if (a.deletedAt == null) return 1;
          if (b.deletedAt == null) return -1;
          return b.deletedAt!.compareTo(a.deletedAt!);
        });
        
        return passwords;
      } catch (e2) {
        print('Erro ao carregar lixeira (fallback): $e2');
        return [];
      }
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
