import 'package:blindex/theme/app_themes.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'view/login_view.dart';

final g = GetIt.instance;

void main() {
  g.registerSingleton<AppThemes>(AppThemes());
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