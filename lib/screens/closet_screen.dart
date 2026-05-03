import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ClosetScreen extends StatelessWidget {
  const ClosetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Leo의 옷장 👔',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F1DF),
                shape: BoxShape.circle,
              ),
              child: const Text('🦫', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 32),
            const Text(
              '곧 멋진 아이템들이 올 거야!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '열심히 풀을 모아서\n레오를 꾸며보자!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSub,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
