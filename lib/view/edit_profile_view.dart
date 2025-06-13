import 'package:blindex/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../repository/user_repository.dart';
import '../model/user_model.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final UserRepository _userRepository;
  bool _isLoading = false;
  bool _isInitialized = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _userRepository = GetIt.instance.get<UserRepository>();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      _currentUser = _userRepository.currentUser;
      if (_currentUser != null) {
        _nameController.text = _currentUser!.name;
        _phoneController.text = _currentUser!.phoneNumber;
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar dados do usuário');
    } finally {
      setState(() {
        _isInitialized = true;
      });
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

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Nome não pode estar vazio');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userRepository.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      
      _showSuccessSnackBar('Perfil atualizado com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Erro ao atualizar perfil: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_currentUser?.email == null) {
      _showErrorSnackBar('E-mail não encontrado');
      return;
    }

    try {
      await _userRepository.sendPasswordResetEmail(_currentUser!.email);
      _showSuccessSnackBar('E-mail de redefinição de senha enviado!');
    } catch (e) {
      _showErrorSnackBar('Erro ao enviar e-mail: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(context),
              const SizedBox(height: 40),
              _buildCurrentEmailSection(context),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Nome completo',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              _buildPasswordResetSection(context),
              const SizedBox(height: 40),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final initials = _currentUser?.name.isNotEmpty == true 
        ? _currentUser!.name.substring(0, 1).toUpperCase()
        : 'U';

    return Center(
      child: Stack(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: 24,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentEmailSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'E-mail atual',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.textColor(context).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.textColor(context).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppColors.textColor(context).withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentUser?.email ?? 'E-mail não encontrado',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textColor(context).withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'O e-mail não pode ser alterado após o cadastro.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textColor(context).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordResetSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redefinir senha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Para alterar sua senha, enviaremos um link de redefinição para seu e-mail.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textColor(context).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _sendPasswordReset,
            icon: const Icon(Icons.email_outlined),
            label: const Text('Enviar link para redefinir senha'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.accent(context)),
              foregroundColor: AppColors.accent(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.textColor(context).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.accent(context),
          ),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Salvar Alterações'),
      ),
    );
  }
}