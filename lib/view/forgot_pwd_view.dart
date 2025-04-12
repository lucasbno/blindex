import 'package:blindex/controller/pwd_recover_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Define the possible states for password recovery flow
enum PasswordRecoveryState {
  emailEntry,
  validationCode,
  newPassword,
  success
}

class ForgotPwdView extends StatefulWidget {
  const ForgotPwdView({super.key});

  @override
  State<ForgotPwdView> createState() => _ForgotPwdViewState();
}

class _ForgotPwdViewState extends State<ForgotPwdView> {
  final emailController = TextEditingController();
  final validationCodeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPwdController = TextEditingController();

  final forgotPwdController = GetIt.I.get<PwdRecoverController>();

  // Current state in the recovery flow
  PasswordRecoveryState _currentState = PasswordRecoveryState.emailEntry;
  
  // Error messages
  String? _errorMessage;
  
  // Store user email for the flow
  String _userEmail = '';

  //Password hiders
  bool passwordHidden = true;
  bool passwordConfirmHidden = true;

  @override
  void dispose() {
    emailController.dispose();
    validationCodeController.dispose();
    passwordController.dispose();
    confirmPwdController.dispose();
    super.dispose();
  }

  // Handle email submission
  void _submitEmail() {
    setState(() {
      _errorMessage = null;
    });
    
    _userEmail = emailController.text.trim();
    
    if (_userEmail.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira seu email';
      });
      return;
    }
    
    // Validate email with controller
    final isValid = forgotPwdController.checkUser(_userEmail);
    
    if (isValid) {
      // Move to next state if email is valid
      setState(() {
        _currentState = PasswordRecoveryState.validationCode;
      });
    } else {
      setState(() {
        _errorMessage = 'Email não encontrado';
      });
    }
  }

  // Handle validation code submission
  void _submitValidationCode() {
    setState(() {
      _errorMessage = null;
    });
    
    final code = validationCodeController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira o código de validação';
      });
      return;
    }
    
    // Validate code with controller
    final isValid = forgotPwdController.checkValidation(code);
    
    if (isValid) {
      // Move to password reset state if code is valid
      setState(() {
        _currentState = PasswordRecoveryState.newPassword;
      });
    } else {
      setState(() {
        _errorMessage = 'Código de validação inválido';
      });
    }
  }

  // Handle password reset
  void _resetPassword() {
    setState(() {
      _errorMessage = null;
    });
    
    final password = passwordController.text;
    final confirmPassword = confirmPwdController.text;
    
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira uma nova senha';
      });
      return;
    }
    
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'As senhas não coincidem';
      });
      return;
    }
    
    // Reset password with controller
    final success = forgotPwdController.resetPassword(_userEmail, password, confirmPassword);
    
    if (success) {
      setState(() {
        _currentState = PasswordRecoveryState.success;
      });
    } else {
      setState(() {
        _errorMessage = 'Erro ao redefinir senha. Verifique os requisitos de senha.';
      });
    }
  }

  // Return to login screen
  void _returnToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Recuperação de Senha'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: _buildCurrentState(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentState(BuildContext context) {
    switch (_currentState) {
      case PasswordRecoveryState.emailEntry:
        return _buildEmailEntryState(context);
      case PasswordRecoveryState.validationCode:
        return _buildValidationCodeState(context);
      case PasswordRecoveryState.newPassword:
        return _buildNewPasswordState(context);
      case PasswordRecoveryState.success:
        return _buildSuccessState(context);
    }
  }

  Widget _buildEmailEntryState(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Recuperação de Senha',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Digite seu email para receber o código de recuperação',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Enviar Código'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _returnToLogin,
              child: const Text('Voltar para o Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationCodeState(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Verificação',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Digite o código de segurança enviado para $_userEmail',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: validationCodeController,
              decoration: InputDecoration(
                labelText: 'Código de Verificação',
                hintText: 'XXX-XXX',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                prefixIcon: const Icon(Icons.security),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitValidationCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Verificar Código'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentState = PasswordRecoveryState.emailEntry;
                  _errorMessage = null;
                });
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPasswordState(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nova Senha',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Digite e confirme sua nova senha',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: passwordController,
              obscureText: passwordHidden,
              decoration: InputDecoration(
                labelText: 'Nova Senha',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(onPressed: () { setState(() {passwordHidden = !passwordHidden; }); }, 
                  icon: passwordHidden ?  Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye_outlined))
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmPwdController,
              obscureText: passwordConfirmHidden,
              decoration: InputDecoration(
                labelText: 'Confirmar Nova Senha',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(onPressed: () { setState(() {passwordConfirmHidden = !passwordConfirmHidden; }); }, 
                  icon: passwordConfirmHidden ?  Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye_outlined))
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Redefinir Senha'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentState = PasswordRecoveryState.validationCode;
                  _errorMessage = null;
                });
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Senha Redefinida!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sua senha foi alterada com sucesso. Você já pode fazer login com sua nova senha.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _returnToLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Voltar ao Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}