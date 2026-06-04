import 'package:flutter/material.dart';
import '../services/mind_service.dart';
import '../theme/app_colors.dart';
import 'friends_activity_screen.dart';

class StoryLoadingScreen extends StatefulWidget {
  final String emotion;

  const StoryLoadingScreen({super.key, required this.emotion});

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

    _bounceAnim = Tween<double>(
      begin: 0,
      end: -12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _loadScenario();
  }

  Future<void> _loadScenario() async {
    try {
      final scenario = await MindService().generateScenario(widget.emotion);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FriendsActivityScreen(scenario: scenario),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('시나리오를 불러오지 못했어요: $e'),
          backgroundColor: const Color(0xFFD04B44),
        ),
      );
      Navigator.pop(context);
    }
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
