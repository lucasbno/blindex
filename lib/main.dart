import 'package:blindex/repository/user_repository.dart';
import 'package:blindex/theme/app_themes.dart';
import 'package:blindex/view/login_view.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'controller/login_screen_controller.dart';
import 'controller/sign_up_controller.dart';

final g = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  g.registerSingleton<AppThemes>(AppThemes());
  g.registerSingleton<UserRepository>(UserRepository());
  g.registerSingleton<SignUpController>(SignUpController(GetIt.I.get<UserRepository>()));
  g.registerSingleton<LoginScreenController>(LoginScreenController(GetIt.I.get<UserRepository>()));

  runApp(DevicePreview(builder: (context)=>const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      theme: AppThemes.lightTheme,  
      darkTheme: AppThemes.darkTheme,  
      themeMode: ThemeMode.system,
      title: 'Blindex',
      home: LoginView(),
    );
  }
}