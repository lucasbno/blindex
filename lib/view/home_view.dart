import 'package:blindex/components/app_bottom_bar.dart';
import 'package:blindex/model/password.dart';
import 'package:blindex/view/delete_password_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/password_controller.dart';
import 'password_details_view.dart';

class PasswordListView extends StatefulWidget {
  const PasswordListView({super.key});

  @override
  State<PasswordListView> createState() => _PasswordListViewState();
}

class _PasswordListViewState extends State<PasswordListView> {
  late PasswordController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = GetIt.instance.get<PasswordController>();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar se usuário está logado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Faça login para acessar suas senhas'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text('Fazer Login'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<PasswordController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Erro ao carregar senhas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(controller.errorMessage!),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        controller.clearError();
                        _initializeController();
                      },
                      child: Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredPasswords = controller.filteredPasswords;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 0,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildSearchBar(context, controller),
                  Expanded(
                    child: _buildPasswordList(
                      context,
                      controller,
                      filteredPasswords,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const AppBottomBar(
              currentScreen: '/passwords',
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, PasswordController controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 20.0,
        bottom: 12.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  controller.searchQuery = value;
                },
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Pesquisar senhas...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PasswordCreateView(),
          ),
        );
      },
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhuma senha encontrada',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente outros termos de pesquisa',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordList(
    BuildContext context,
    PasswordController controller,
    List<Password> passwords,
  ) {
    if (passwords.isEmpty) {
      return _buildEmptyState(context);
    }

    final List<Password> favoritePasswords =
        passwords.where((p) => p.isFavorite).toList();
    final List<Password> otherPasswords =
        passwords.where((p) => !p.isFavorite).toList();

    return ListView(
      children: [
        if (favoritePasswords.isNotEmpty) ...[
          _buildSectionHeader(context, 'Favoritos'),
          ...favoritePasswords.map(
            (password) => _buildPasswordCard(context, controller, password),
          ),
        ],
        if (otherPasswords.isNotEmpty) ...[
          _buildSectionHeader(context, 'Outras senhas'),
          ...otherPasswords.map(
            (password) => _buildPasswordCard(context, controller, password),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordCard(
    BuildContext context,
    PasswordController controller,
    Password password,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: _buildPasswordAvatar(context, password.title, password.icon),
        title: Text(password.title,
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(password.login,
            style: Theme.of(context).textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                password.isFavorite ? Icons.star : Icons.star_border,
                color: password.isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: () async => await controller.toggleFavorite(password),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: () => _showDeleteConfirmation(context, controller, password),
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/password/edit',
            arguments: password.toMap(),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context, 
    PasswordController controller,
    Password password,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DeletePasswordDialog(password: password, onDelete: () async {
              if (password.id != null) {
                await controller.deletePassword(password.id!);
              }
              Navigator.of(context).pop();
            }),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        opaque: false,
        barrierColor: Colors.black54,
      ),
    );
  }

  Widget _buildPasswordAvatar(BuildContext context, String title, String icon) {
    return icon.isNotEmpty
        ? CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.lock, color: Colors.white),
          )
        : CircleAvatar(
            backgroundColor: Theme.of(context).primaryColorLight,
            child: Text(
              title.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
