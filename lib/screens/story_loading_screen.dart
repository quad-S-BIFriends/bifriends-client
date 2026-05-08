import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StoryLoadingScreen extends StatefulWidget {
  const StoryLoadingScreen({super.key});

  @override
  State<StoryLoadingScreen> createState() => _StoryLoadingScreenState();
}

class _StoryLoadingScreenState extends State<StoryLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // TODO: BE 연동 시 실제 로딩 완료 시점으로 교체
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _bounceAnim.value),
                child: child,
              ),
              child: Image.asset(
                'assets/images/leo_defaultface.png',
                width: 110,
                height: 110,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '레오가 특별한 마음 여행을\n준비하고 있어!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '잠시만 기다려줘..!!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
