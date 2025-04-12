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

  void _onSignUpPress() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();
    final password = passwordController.text.trim();
    final confirm_pwd = pwdConfirmController.text.trim();

    final success = signUpController.signUp(name, phoneNumber, email, password, confirm_pwd);

    setState(() {
      _signUpSuccess = success;
    });

    if (_signUpSuccess) {
      Future.delayed(Duration(milliseconds: 1000), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Background color
      body: Center(
        child: Builder(builder: (context) => _buildSignUp(context),
        ),
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {

    var mobilePhoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', 
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0), // To avoid edges
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                  'Cadastre-se',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 26), // Spacing between title and fields

              // Username TextField
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, // Accent color for border
                    ),
                  ),
                  prefixIcon: const Icon(Icons.person_2_sharp)
                ),
              ),

              const SizedBox(height: 20),

              // email TextField
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, // Accent color for border
                    ),
                  ),
                  prefixIcon: const Icon(Icons.email)
                ),
              ),

              const SizedBox(height: 20), // Space between fields

              //Phone Number
              TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                inputFormatters: [mobilePhoneMask],
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(99) 04242-0564',
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, // Accent color for border
                    ),
                  ),
                  prefixIcon: const Icon(Icons.smartphone)
                ),
              ),

              const SizedBox(height: 20), // Space between fields

              // Password TextField
              TextFormField(
                controller: passwordController,
                obscureText: true,
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
                  suffixIcon: IconButton(onPressed: () { setState(() {passwordHidden = !passwordHidden; }); }, 
                  icon: passwordHidden ?  Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye_outlined))
                ),
              ),

              const SizedBox(height: 20), // Space between fields

              // Password Confirm TextField
              TextFormField(
                controller: pwdConfirmController,
                obscureText: true,
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
                  suffixIcon: IconButton(onPressed: () { setState(() {passwordConfirmHidden = !passwordConfirmHidden; }); }, 
                  icon: passwordConfirmHidden ?  Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye_outlined))
                ),
              ),

              const SizedBox(height: 24), // Space before button

              // Signup Button
              SizedBox(
                width: double.infinity, // Make button stretch
                child: ElevatedButton(
                  onPressed: () { _onSignUpPress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _signUpSuccess ? Colors.blue : Colors.red,
                        content: Center(child: Text(
                          _signUpSuccess ? 'Cadastro com sucesso!' : 'Cadastro Invalido.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ))
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20), // Taller button
                  ),
                  child: Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
