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
    final user = userRepository.users[0];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Perfil', style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: AppColors.textColor(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile avatar section
              Center(
                child: Column(
                  children: [
                    _buildAvatar(context, user!),
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
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, User user) {
    // Generate initials from name
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
            // Edit profile action
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Editar Perfil'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // Log out action
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Log Out'),
        ),
      ],
    );
  }
}

// Helper function
int min(int a, int b) {
  return a < b ? a : b;
}