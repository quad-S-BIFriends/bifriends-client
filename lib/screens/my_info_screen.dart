import 'package:flutter/material.dart';
import 'login_screen.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('내정보 페이지'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('로그아웃'),
          )
        ],
      ),
    );
  }
}
