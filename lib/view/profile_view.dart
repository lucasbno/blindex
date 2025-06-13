import 'package:blindex/components/app_bottom_bar.dart';
import 'package:blindex/model/user_model.dart';
import 'package:blindex/repository/user_repository.dart';
import 'package:blindex/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:blindex/theme/theme_provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = GetIt.I<UserRepository>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListenableBuilder(
        listenable: userRepository,
        builder: (context, child) {
          final user = userRepository.currentUser;
          
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando perfil...'),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile avatar section
                  Center(
                    child: Column(
                      children: [
                        _buildAvatar(context, user),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Theme switcher
              _buildThemeSwitcher(context),
              
              const SizedBox(height: 32),
              
              // User information section
              _buildInfoSection(context, user),
              
              const SizedBox(height: 32),
              
              // Action buttons
              _buildActionButtons(context),
              ],
            ),
          ),
        );
        },
      ),
      bottomNavigationBar: const AppBottomBar(
        currentScreen: '/profile',
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, User user) {
  final initials = user.name.trim().isNotEmpty
    ? user.name.trim()[0].toUpperCase()
    : '?';

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.accent(context).withValues(alpha: 0.2),
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.accent(context),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.accent(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit,
              size: 20,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSwitcher(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.textColor(context).withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.accent(context),
                ),
                const SizedBox(width: 12),
                Text(
                  'Modo Escuro',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: AppColors.accent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, User user) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.textColor(context).withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Perfil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Nome', user.name),
            _buildInfoRow(context, 'E-mail', user.email),
            _buildInfoRow(context, 'Celular', user.phoneNumber),
            _buildInfoRow(context, 'Senha', '••••••••••'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textColor(context).withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/edit-profile');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Editar Perfil'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/about');
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: BorderSide(color: AppColors.accent(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 8),
              const Text('Sobre o App'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            final userRepository = GetIt.I<UserRepository>();
            
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
            
            try {
              await userRepository.signOut();
              
              if (context.mounted) {
                Navigator.of(context).pop();
                
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      'Erro ao fazer logout: $e',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }
            }
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: Colors.red),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Sair', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

int min(int a, int b) {
  return a < b ? a : b;
}