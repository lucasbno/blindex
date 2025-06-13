import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';

class UserRepository extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  
  UserRepository() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        loadCurrentUser();
      }
    });
  }
  
  User? get currentUser => _currentUser;
  
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> signUp({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = User(
          uid: credential.user!.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('usuarios')
            .doc(credential.user!.uid)
            .set(user.toFirestore());

        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no cadastro: $e');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final doc = await _firestore
            .collection('usuarios')
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          _currentUser = User.fromFirestore(doc);
        } else {
          _currentUser = User(
            uid: credential.user!.uid,
            name: credential.user!.displayName ?? '',
            email: credential.user!.email ?? email,
            phoneNumber: '',
            createdAt: DateTime.now(),
          );
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateUser(User updatedUser) async {
    try {
      if (_currentUser?.uid != null) {
        await _firestore
            .collection('usuarios')
            .doc(_currentUser!.uid)
            .update(updatedUser.toFirestore());
        
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          _currentUser = User.fromFirestore(doc);
          notifyListeners();
        }
      } catch (e) {
        print('Erro ao carregar usuário: $e');
      }
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Erro ao resetar senha: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      if (_currentUser?.uid != null) {
        final updatedUser = User(
          uid: _currentUser!.uid,
          name: name,
          email: _currentUser!.email,
          phoneNumber: phoneNumber,
          createdAt: _currentUser!.createdAt,
        );

        await _firestore
            .collection('usuarios')
            .doc(_currentUser!.uid)
            .update({
          'name': name,
          'phoneNumber': phoneNumber,
        });
        
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Erro ao enviar e-mail de reset: $e');
      return false;
    }
  }
}
