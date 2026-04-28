import 'package:flutter/material.dart';
import 'package:bifriends_client/screens/login_screen.dart';

void main() {
  runApp(const BifriendsApp());
}

class BifriendsApp extends StatelessWidget {
  const BifriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bifriends',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F0E8), // Warm off-white background
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF75A66B)), // Natural green
        useMaterial3: true,
        fontFamily: 'Pretendard', // Fallback to system fonts if not installed, but good conventional default
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D5A3C),
            disabledBackgroundColor: const Color(0xFF8B9D8A),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
          ),
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
