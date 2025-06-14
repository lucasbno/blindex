import 'package:blindex/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../repository/password_repository.dart';
import '../repository/user_repository.dart';
import '../model/password.dart';
import '../components/app_bottom_bar.dart';

class TrashView extends StatefulWidget {
  const TrashView({super.key});

  @override
  State<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  late final PasswordRepository _passwordRepository;
  late final UserRepository _userRepository;
  List<Password> _deletedPasswords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _passwordRepository = GetIt.instance.get<PasswordRepository>();
    _userRepository = GetIt.instance.get<UserRepository>();
    _loadDeletedPasswords();
  }

  Future<void> _loadDeletedPasswords() async {
    if (_userRepository.currentUser?.uid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final deletedPasswords = await _passwordRepository
          .loadDeletedPasswords(_userRepository.currentUser!.uid!);
      
      setState(() {
        _deletedPasswords = deletedPasswords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erro ao carregar lixeira: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _restorePassword(Password password) async {
    if (password.id == null || _userRepository.currentUser?.uid == null) return;

    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final success = await _passwordRepository.restoreFromTrash(
        password.id!,
        _userRepository.currentUser!.uid!,
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackBar('Senha restaurada com sucesso!');
          _loadDeletedPasswords();
        } else {
          _showErrorSnackBar('Erro ao restaurar senha');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro inesperado ao restaurar senha');
      }
    }
  }

  Future<void> _deletePermanently(Password password) async {
    if (password.id == null || _userRepository.currentUser?.uid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Permanentemente'),
        content: const Text(
          'Esta ação não pode ser desfeita. A senha será excluída permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Future.delayed(const Duration(milliseconds: 200));
      
      try {
        final success = await _passwordRepository.deletePassword(
          password.id!,
          _userRepository.currentUser!.uid!,
        );

        if (mounted) {
          if (success) {
            _showSuccessSnackBar('Senha excluída permanentemente');
            _loadDeletedPasswords();
          } else {
            _showErrorSnackBar('Erro ao excluir senha');
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Erro inesperado ao excluir senha');
        }
      }
    }
  }

  String _formatDeletedDate(DateTime? deletedAt) {
    if (deletedAt == null) return 'Data desconhecida';
    
    final now = DateTime.now();
    final difference = now.difference(deletedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora há pouco';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lixeira'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_deletedPasswords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDeletedPasswords,
              tooltip: 'Atualizar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletedPasswords.isEmpty
              ? _buildEmptyState()
              : _buildPasswordsList(),
      bottomNavigationBar: const AppBottomBar(
        currentScreen: '/trash',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 80,
            color: AppColors.textColor(context).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Lixeira vazia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor(context).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Senhas excluídas aparecerão aqui',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textColor(context).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordsList() {
    return RefreshIndicator(
      onRefresh: _loadDeletedPasswords,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _deletedPasswords.length,
        itemBuilder: (context, index) {
          final password = _deletedPasswords[index];
          return _buildPasswordCard(password);
        },
      ),
    );
  }

  Widget _buildPasswordCard(Password password) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          child: Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
        ),
        title: Text(
          password.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (password.site.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                password.site,
                style: TextStyle(
                  color: AppColors.textColor(context).withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textColor(context).withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Excluída ${_formatDeletedDate(password.deletedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textColor(context).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'restore':
                _restorePassword(password);
                break;
              case 'delete':
                _deletePermanently(password);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Restaurar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir permanentemente'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
