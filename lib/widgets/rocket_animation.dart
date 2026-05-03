import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RocketAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const RocketAnimation({super.key, required this.onComplete});

  @override
  State<RocketAnimation> createState() => _RocketAnimationState();
}

class _RocketAnimationState extends State<RocketAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rocketController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late Animation<double> _rocketY;
  late Animation<double> _rocketScale;
  late Animation<double> _rocketRotation;
  late Animation<double> _textOpacity;
  late Animation<double> _textScale;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _rocketY = Tween<double>(begin: 1.3, end: -0.3).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeInQuart),
    );

    _rocketScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 40),
    ]).animate(_rocketController);

    _rocketRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.05), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0), weight: 60),
    ]).animate(_rocketController);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
    );

    _generateParticles();

    _startAnimationSequence();
  }

  void _generateParticles() {
    final emojis = ['⭐', '✨', '🌟', '💫', '🎉', '🎊', '💚'];
    for (int i = 0; i < 30; i++) {
      _particles.add(
        _Particle(
          emoji: emojis[_random.nextInt(emojis.length)],
          startX: _random.nextDouble(),
          startY: 0.3 + _random.nextDouble() * 0.4,
          velocityX: (_random.nextDouble() - 0.5) * 2,
          velocityY: -_random.nextDouble() * 1.5 - 0.5,
          delay: _random.nextDouble() * 0.4,
          size: 16 + _random.nextDouble() * 20,
          rotationSpeed: (_random.nextDouble() - 0.5) * 4,
        ),
      );
    }
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _rocketController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _rocketController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Container(
              color: Colors.black.withValues(
                alpha: 0.5 * (1 - _particleController.value),
              ),
            );
          },
        ),

        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _particleController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        ..._buildParticleWidgets(),

        AnimatedBuilder(
          animation: _rocketController,
          builder: (context, child) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            return Positioned(
              left: screenWidth / 2 - 30,
              top: screenHeight * _rocketY.value,
              child: Transform.rotate(
                angle: _rocketRotation.value,
                child: Transform.scale(
                  scale: _rocketScale.value,
                  child: const Text('🚀', style: TextStyle(fontSize: 60)),
                ),
              ),
            );
          },
        ),

        Center(
          child: FadeTransition(
            opacity: _textOpacity,
            child: ScaleTransition(
              scale: _textScale,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '환영해! 🎉',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '이제 함께 시작해보자!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildParticleWidgets() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final progress = _particleController.value;
          if (progress < particle.delay) return const SizedBox.shrink();

          final adjustedProgress =
              ((progress - particle.delay) / (1 - particle.delay)).clamp(
                0.0,
                1.0,
              );

          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          final x =
              (particle.startX + particle.velocityX * adjustedProgress) *
              screenWidth;
          final y =
              (particle.startY + particle.velocityY * adjustedProgress) *
              screenHeight;

          final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);

          return Positioned(
            left: x,
            top: y,
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: particle.rotationSpeed * adjustedProgress * 3.14,
                child: Text(
                  particle.emoji,
                  style: TextStyle(fontSize: particle.size),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class _Particle {
  final String emoji;
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double delay;
  final double size;
  final double rotationSpeed;

  _Particle({
    required this.emoji,
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.delay,
    required this.size,
    required this.rotationSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 가운데에서 퍼져나가는 빛 효과
    if (progress > 0.2) {
      final lightProgress = ((progress - 0.2) / 0.8).clamp(0.0, 1.0);
      final center = Offset(size.width / 2, size.height * 0.4);
      final radius = size.width * lightProgress * 0.8;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(
              0xFF75A66B,
            ).withValues(alpha: 0.15 * (1 - lightProgress)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
