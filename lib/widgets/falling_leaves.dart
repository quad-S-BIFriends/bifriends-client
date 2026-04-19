import 'dart:math';
import 'package:flutter/material.dart';

class FallingLeaves extends StatefulWidget {
  final int leafCount;

  const FallingLeaves({super.key, this.leafCount = 8});

  @override
  State<FallingLeaves> createState() => _FallingLeavesState();
}

class _FallingLeavesState extends State<FallingLeaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Leaf> _leaves;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _leaves = List.generate(widget.leafCount, (_) => _generateLeaf());
  }

  _Leaf _generateLeaf() {
    final emojis = ['🍃', '🌿', '☘️', '🍀'];
    return _Leaf(
      emoji: emojis[_random.nextInt(emojis.length)],
      startX: _random.nextDouble(),
      speed: 0.3 + _random.nextDouble() * 0.7,
      amplitude: 20 + _random.nextDouble() * 40,
      phase: _random.nextDouble() * 2 * pi,
      size: 14 + _random.nextDouble() * 14,
      initialY: -_random.nextDouble(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _leaves.map((leaf) {
            final progress =
                ((_controller.value * leaf.speed + leaf.initialY) % 1.3) - 0.1;
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            final swayX = leaf.startX * screenWidth +
                sin(progress * 4 * pi + leaf.phase) * leaf.amplitude;
            final y = progress * screenHeight;

            final rotation =
                sin(progress * 3 * pi + leaf.phase) * 0.5;
            final opacity = progress < 0
                ? 0.0
                : progress > 1.0
                    ? (1.3 - progress) / 0.3
                    : 1.0;

            return Positioned(
              left: swayX,
              top: y,
              child: Opacity(
                opacity: opacity.clamp(0.0, 0.6),
                child: Transform.rotate(
                  angle: rotation,
                  child: Text(
                    leaf.emoji,
                    style: TextStyle(fontSize: leaf.size),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Leaf {
  final String emoji;
  final double startX;
  final double speed;
  final double amplitude;
  final double phase;
  final double size;
  final double initialY;

  _Leaf({
    required this.emoji,
    required this.startX,
    required this.speed,
    required this.amplitude,
    required this.phase,
    required this.size,
    required this.initialY,
  });
}
