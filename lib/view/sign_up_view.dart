import 'package:blindex/controller/sign_up_controller.dart';
import 'package:blindex/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pwdConfirmController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final nameController = TextEditingController();

  final signUpController = GetIt.I.get<SignUpController>();

  bool passwordHidden = true;
  bool passwordConfirmHidden = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    pwdConfirmController.dispose();
    phoneNumberController.dispose();
    nameController.dispose();
    super.dispose();
  }

  bool _signUpSuccess = false;

  void _onSignUpPress() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phoneNumber = phoneNumberController.text.trim();
      final password = passwordController.text.trim();
      final confirm_pwd = pwdConfirmController.text.trim();

      final success = await signUpController.signUp(name, phoneNumber, email, password, confirm_pwd);

      setState(() {
        _signUpSuccess = success;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _signUpSuccess ? Colors.blue : Colors.red,
            content: Center(
              child: Text(
                _signUpSuccess
                    ? 'Cadastro realizado com sucesso!'
                    : signUpController.errorMessage ?? 'Erro no cadastro',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );
      }

      if (_signUpSuccess) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
          );
        });
      }
    } else {
      setState(() {
        _signUpSuccess = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
              'Preencha todos os campos obrigatórios',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Builder(
          builder: (context) => _buildSignUp(context),
        ),
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    var mobilePhoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Cadastre-se',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 26),

                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.person_2_sharp),
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'E-mail é obrigatório';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'E-mail',
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

                const SizedBox(height: 20),

                TextFormField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [mobilePhoneMask],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Telefone é obrigatório';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(99) 04242-0564',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.smartphone),
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: passwordController,
                  obscureText: passwordHidden,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passwordHidden = !passwordHidden;
                        });
                      },
                      icon: passwordHidden
                          ? Icon(Icons.remove_red_eye)
                          : Icon(Icons.remove_red_eye_outlined),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: pwdConfirmController,
                  obscureText: passwordConfirmHidden,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Confirmação de senha é obrigatória';
                    }
                    if (value != passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passwordConfirmHidden = !passwordConfirmHidden;
                        });
                      },
                      icon: passwordConfirmHidden
                          ? Icon(Icons.remove_red_eye)
                          : Icon(Icons.remove_red_eye_outlined),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ListenableBuilder(
                  listenable: signUpController,
                  builder: (context, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: signUpController.isLoading ? null : () {
                          _onSignUpPress();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: signUpController.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Cadastrar'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
