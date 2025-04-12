import 'package:flutter/material.dart';
import '../controller/login_screen_controller.dart';
import 'package:get_it/get_it.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final loginController = GetIt.I.get<LoginScreenController>();

  bool _loginSuccess = false;
  bool passwordHidden = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPress() {
    final email = emailController.text;
    final password = passwordController.text;

    final success = loginController.login(email, password);

    setState(() {
      _loginSuccess = success;
    });

    if (_loginSuccess) {
      if (!mounted) return;

      Navigator.pushNamed(context, '/passwords');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Background color
      body: Center(
        child: Builder(
          builder:
              (context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  //Logo
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.shield, size: 30, color: Colors.white),
                  ),

                  //Login card
                  _buildLogIn(context),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildLogIn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0), // To avoid edges
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Makes the column size fit content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  'Entrar',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 26), // Spacing between title and fields
              // Username TextField
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          Theme.of(
                            context,
                          ).primaryColor, // Accent color for border
                    ),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20), // Space between fields
              // Password TextField
              TextFormField(
                controller: passwordController,
                obscureText: passwordHidden,
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
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        passwordHidden = !passwordHidden;
                      });
                    },
                    icon:
                        passwordHidden
                            ? Icon(Icons.remove_red_eye)
                            : Icon(Icons.remove_red_eye_outlined),
                  ),
                ),
              ),

              const SizedBox(height: 24), // Space before button
              // [BM] Login Button
              SizedBox(
                width: double.infinity, // Make button stretch
                child: ElevatedButton(
                  onPressed: () {
                    _onLoginPress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            _loginSuccess ? Colors.blue : Colors.red,
                        content: Center(
                          child: Text(
                            _loginSuccess
                                ? 'Login com sucesso!'
                                : 'Login Invalido.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                    ), // Taller button
                  ),
                  child: Text('Entrar'),
                ),
              ),

              SizedBox(height: 12),

              // Signup Button
              SizedBox(
                width: double.infinity, // Make button stretch
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signUp');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text(
                    'Cadastre-se',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),

              SizedBox(height: 24),

              //Forgot Password TextButton
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Esqueceu a Senha?',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
