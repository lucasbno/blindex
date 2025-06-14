import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/credit_card.dart';

class CreditCardRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<CreditCard> _cards = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<CreditCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadCards(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final querySnapshot = await _firestore
          .collection('cartoes')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      _cards = querySnapshot.docs
          .map((doc) => CreditCard.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Erro de índice detectado, usando query alternativa: $e');
      
      try {
        final querySnapshot = await _firestore
            .collection('cartoes')
            .where('userId', isEqualTo: userId)
            .get();
        
        final cards = querySnapshot.docs
            .map((doc) => CreditCard.fromFirestore(doc))
            .toList();
        
        cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _cards = cards;
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Erro ao carregar cartões: $e';
        _isLoading = false;
        notifyListeners();
        print('Erro ao carregar cartões: $e');
      }
    }
  }
  
  Future<bool> addCard(CreditCard card) async {
    try {
      final docRef = await _firestore
          .collection('cartoes')
          .add(card.toFirestore());
      
      final newCard = card.copyWith();
      _cards.insert(0, CreditCard(
        id: docRef.id,
        userId: newCard.userId,
        title: newCard.title,
        cardholderName: newCard.cardholderName,
        cardNumber: newCard.cardNumber,
        expiryDate: newCard.expiryDate,
        securityCode: newCard.securityCode,
        pin: newCard.pin,
        notes: newCard.notes,
        createdAt: newCard.createdAt,
        updatedAt: newCard.updatedAt,
      ));
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar cartão: $e';
      notifyListeners();
      print('Erro ao adicionar cartão: $e');
      return false;
    }
  }
  
  Future<bool> updateCard(CreditCard card) async {
    if (card.id == null) return false;
    
    try {
      await _firestore
          .collection('cartoes')
          .doc(card.id)
          .update(card.toFirestore());
      
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = card;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar cartão: $e';
      notifyListeners();
      print('Erro ao atualizar cartão: $e');
      return false;
    }
  }
  
  Future<bool> deleteCard(String cardId, String userId) async {
    try {
      await _firestore
          .collection('cartoes')
          .doc(cardId)
          .delete();
      
      _cards.removeWhere((card) => card.id == cardId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao deletar cartão: $e';
      notifyListeners();
      print('Erro ao deletar cartão: $e');
      return false;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
