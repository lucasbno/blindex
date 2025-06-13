import 'package:blindex/controller/pwd_recover_controller.dart';
import 'package:blindex/repository/user_repository.dart';
import 'package:blindex/repository/password_repository.dart';
import 'package:blindex/theme/app_themes.dart';
import 'package:blindex/view/about_view.dart';
import 'package:blindex/view/edit_profile_view.dart';
import 'package:blindex/view/forgot_pwd_view.dart';
import 'package:blindex/view/login_view.dart';
import 'package:blindex/view/home_view.dart' as home;
import 'package:blindex/view/password_details_view.dart';
import 'package:blindex/view/reports_view.dart';
import 'package:blindex/view/sign_up_view.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:blindex/view/profile_view.dart';
import 'controller/login_screen_controller.dart';
import 'controller/sign_up_controller.dart';
import 'controller/password_controller.dart';
import 'package:blindex/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:blindex/controller/reports_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final g = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

  g.registerSingleton<AppThemes>(AppThemes());
  g.registerSingleton<UserRepository>(UserRepository());
  g.registerSingleton<PasswordRepository>(PasswordRepository());
  g.registerSingleton<PwdRecoverController>(PwdRecoverController(GetIt.I.get<UserRepository>()));
  g.registerSingleton<SignUpController>(SignUpController(GetIt.I.get<UserRepository>()));
  g.registerSingleton<LoginScreenController>(LoginScreenController(GetIt.I.get<UserRepository>()));
  g.registerSingleton<PasswordController>(PasswordController());
  g.registerSingleton<ReportsController>(ReportsController());
  g.registerSingleton<ThemeProvider>(ThemeProvider());

  // Carregar usuário atual se estiver logado
  await g.get<UserRepository>().loadCurrentUser();

  runApp(
    DevicePreview(
      builder: (context) => ChangeNotifierProvider.value(
        value: g<ThemeProvider>(),
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      theme: AppThemes.lightTheme,  
      darkTheme: AppThemes.darkTheme,  
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      title: 'Blindex',
      home: const AuthWrapper(),
      routes: {
        '/about': (context) => const AboutView(),
        '/signUp': (context) => const SignUpView(),
        '/login': (context) => const LoginView(),
        '/forgot': (context) => const ForgotPwdView(),
        '/profile': (context) => const ProfileView(),
        '/passwords': (context) => const home.PasswordListView(),
        '/reports': (context) => const ReportsView(),
        '/edit-profile': (context) => const EditProfileView(),
        '/password/edit': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PasswordCreateView(
            isEditing: true,
            initialData: args,
          );
        },
      },
    );
  }
}

// Widget para verificar autenticação
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = GetIt.I<UserRepository>();
    
    return ListenableBuilder(
      listenable: userRepository,
      builder: (context, child) {
        // Se há um usuário logado, vai para as senhas
        if (userRepository.currentUser != null) {
          return const home.PasswordListView();
        }
        
        // Caso contrário, vai para o login
        return const LoginView();
      },
    );
  }
}
