import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const PromptAddaApp());
}

class PromptAddaApp extends StatelessWidget {
  const PromptAddaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prompt Adda',
      theme: AppTheme.lightTheme,
      home: const SplashScreen()
   
    );
  }
}