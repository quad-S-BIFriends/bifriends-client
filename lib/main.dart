import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bifriends_client/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const BifriendsApp());
}

class BifriendsApp extends StatelessWidget {
  const BifriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bifriends',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF75A66B)),
        useMaterial3: true,
        fontFamily: 'Pretendard',
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
