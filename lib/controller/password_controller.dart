import 'package:flutter/material.dart';
import '../model/password.dart';

class PasswordController extends ChangeNotifier {
  final List<Password> _passwords = [
    Password(
      id: '1685432161000',
      title: 'Gmail',
      login: 'exemplo@gmail.com',
      password: 'senhaGmail123',
      site: 'https://gmail.com',
      notes: 'Conta de email pessoal',
      isFavorite: true,
    ),
    Password(
      id: '1685432162000',
      title: 'Banco Itaú',
      login: 'usuario_itau',
      password: 'SenhaDoBanco!2023',
      site: 'https://www.itau.com.br',
      notes: 'Conta corrente principal, agência 1234',
      isFavorite: true,
    ),
    Password(
      id: '1685432163000',
      title: 'Facebook',
      login: 'meu.email@facebook.com',
      password: 'Facebook2023',
      site: 'https://facebook.com',
      notes: 'Perfil pessoal',
      isFavorite: false,
    ),
    Password(
      id: '1685432164000',
      title: 'Netflix',
      login: 'usuario_netflix',
      password: 'SenhaNetflix2023!',
      site: 'https://netflix.com',
      notes: 'Plano premium, renovação em 15/06',
      isFavorite: true,
    ),
    Password(
      id: '1685432165000',
      title: 'Nubank',
      login: 'cpf_nubank',
      password: 'NubankRoxo2023!',
      site: 'https://nubank.com.br',
      notes: 'Cartão de crédito principal',
      isFavorite: true,
    ),
    Password(
      id: '1685432166000',
      title: 'Spotify',
      login: 'musica@email.com',
      password: 'SpotifyMusica!2023',
      site: 'https://spotify.com',
      notes: 'Plano família, renovação automática',
      isFavorite: false,
    ),
    Password(
      id: '1685432166000',
      title: 'Instagram',
      login: 'usuario_instagram',
      password: 'Facebook2023',
      site: 'https://instagram.com',
      notes: 'Perfil pessoal, fotos de viagens',
      isFavorite: false,
    ),
  ];

  String _searchQuery = '';

  List<Password> get filteredPasswords {
    final List<Password> filtered = _passwords
        .where(
          (password) =>
              password.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
              password.login.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();

    filtered.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return 0;
    });

    return filtered;
  }

  List<Password> get passwords => List.unmodifiable(_passwords);

  set searchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  String get searchQuery => _searchQuery;

  void toggleFavorite(Password password) {
    password.isFavorite = !password.isFavorite;
    notifyListeners();
  }

  Password? findPasswordById(String id) {
    try {
      return _passwords.firstWhere(
        (password) => password.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  void addPassword(Password password) {
    _passwords.add(password);
    notifyListeners();
  }

  void updatePassword(String id, Password updatedPassword) {
    final index = _passwords.indexWhere((password) => password.id == id);
    if (index != -1) {
      _passwords[index] = updatedPassword;
      notifyListeners();
    }
  }

  void deletePassword(String id) {
    _passwords.removeWhere((password) => password.id == id);
    notifyListeners();
  }
}