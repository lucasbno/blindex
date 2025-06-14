import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/credit_card_repository.dart';
import '../model/credit_card.dart';

class CreditCardController extends ChangeNotifier {
  final CreditCardRepository _repository;
  
  String _searchQuery = '';
  
  CreditCardController(this._repository) {
    _repository.addListener(() {
      notifyListeners();
    });
  }
  
  List<CreditCard> get cards => _repository.cards;
  bool get isLoading => _repository.isLoading;
  String? get errorMessage => _repository.errorMessage;
  
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }
  
  List<CreditCard> get filteredCards {
    if (_searchQuery.isEmpty) {
      return cards;
    }
    
    return cards.where((card) {
      return card.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             card.cardholderName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             card.maskedCardNumber.contains(_searchQuery) ||
             card.cardBrand.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  Future<void> loadCards() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _repository.loadCards(user.uid);
    }
  }
  
  Future<bool> addCard(CreditCard card) async {
    return await _repository.addCard(card);
  }
  
  Future<bool> updateCard(CreditCard card) async {
    return await _repository.updateCard(card);
  }
  
  Future<bool> deleteCard(String cardId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    return await _repository.deleteCard(cardId, user.uid);
  }
  
  CreditCard? findCardById(String id) {
    try {
      return cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }
  
  void clearError() {
    _repository.clearError();
  }
}
