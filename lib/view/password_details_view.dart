import 'package:blindex/model/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../controller/password_controller.dart';
import '../controller/password_form_controller.dart';
import '../components/password_generator_modal.dart';

class PasswordCreateView extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final bool isEditing;

  const PasswordCreateView({
    super.key,
    this.initialData,
    this.isEditing = false,
  });

  @override
  State<PasswordCreateView> createState() => PasswordCreateViewState();
}

class PasswordCreateViewState extends State<PasswordCreateView> {
  late final PasswordFormController _formController;
  late final PasswordController _passwordController;

  @override
  void initState() {
    super.initState();
    _formController = PasswordFormController();
    _passwordController = GetIt.instance.get<PasswordController>();

    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.initialData != null) {
      final password = Password.fromMap(widget.initialData!);
      _formController.populateForm(password);
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop();
  }

  void _savePassword(PasswordFormController formController) {
    final Password? passwordData =
        widget.isEditing && widget.initialData != null
            ? formController.validateAndGetPassword(
              existingId: widget.initialData!['id'].toString(),
            )
            : formController.validateAndGetPassword();

    //NOTE CREATE / UPDATE
    if (passwordData != null) {
      if (widget.isEditing && widget.initialData != null) {
        _updateExistingPassword(passwordData);
      } else {
        _createNewPassword(passwordData);
      }

      _close();
    }
  }

  void _updateExistingPassword(Password password) {
    _passwordController.updatePassword(password.id, password);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Senha atualizada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createNewPassword(Password password) {
    _passwordController.addPassword(password);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Senha adicionada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: ChangeNotifierProvider.value(
        value: _formController,
        child: Consumer<PasswordFormController>(
          builder: (context, formController, _) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: SafeArea(
                child: Form(
                  key: formController.formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleField(context, formController),
                              const SizedBox(height: 20),

                              _buildLoginField(context, formController),
                              const SizedBox(height: 20),

                              _buildPasswordField(context, formController),
                              const SizedBox(height: 16),

                              _buildSiteField(context, formController),
                              const SizedBox(height: 20),

                              _buildNotesField(context, formController),
                              const SizedBox(height: 16),

                              _buildFavoriteSwitch(context, formController),
                            ],
                          ),
                        ),
                      ),

                      _buildBottomActionButton(context, formController),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            widget.isEditing ? Icons.edit_note : Icons.add_circle_outline,
            size: 22,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          const SizedBox(width: 8),
          Text(
            widget.isEditing ? 'Editar Senha' : 'Nova Senha',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: _close,
      ),
      centerTitle: false,
      titleSpacing: 0,
    );
  }

  Widget _buildTitleField(
    BuildContext context,
    PasswordFormController formController,
  ) {
    return TextFormField(
      controller: formController.titleController,
      decoration: InputDecoration(
        labelText: 'Título',
        hintText: 'Ex: Gmail, Facebook, Banco',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => formController.validateField(value, 'um título'),
    );
  }

  Widget _buildLoginField(
    BuildContext context,
    PasswordFormController formController,
  ) {
    return TextFormField(
      controller: formController.loginController,
      decoration: InputDecoration(
        labelText: 'Login',
        hintText: 'Ex: seu.email@gmail.com',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => formController.validateField(value, 'um login'),
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    PasswordFormController formController,
  ) {
    return TextFormField(
      controller: formController.passwordController,
      obscureText: formController.obscurePassword,
      decoration: InputDecoration(
        labelText: 'Senha',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Gerar senha',
              onPressed: () {
                PasswordGeneratorModal.show(context, formController);
              },
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copiar senha',
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: formController.passwordController.text),
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Senha copiada para a área de transferência'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                formController.obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: formController.togglePasswordVisibility,
            ),
          ],
        ),
      ),
      validator: (value) => formController.validateField(value, 'uma senha'),
    );
  }

  Widget _buildSiteField(
    BuildContext context,
    PasswordFormController formController,
  ) {
    return TextFormField(
      controller: formController.siteController,
      decoration: InputDecoration(
        labelText: 'Site/URL',
        hintText: 'Ex: https://www.gmail.com',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildNotesField(
    BuildContext context,
    PasswordFormController formController,
  ) {
    return TextFormField(
      controller: formController.notesController,
      decoration: InputDecoration(
        labelText: 'Notas',
        hintText: 'Informações adicionais...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: 3,
    );
  }

  Widget _buildFavoriteSwitch(
    BuildContext context,
    PasswordFormController formController,
  ) {
    return SwitchListTile(
      title: const Text('Adicionar aos favoritos'),
      value: formController.isFavorite,
      onChanged: (_) => formController.toggleFavorite(),
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildBottomActionButton(
    BuildContext context,
    PasswordFormController formController,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _savePassword(formController),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.isEditing ? 'Atualizar Senha' : 'Salvar Senha',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
