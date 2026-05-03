import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../screens/learning_activity_screen.dart';
import '../theme/app_colors.dart';

enum LevelStatus { completed, current, locked }

class LevelData {
  final int level;
  final String title;
  final String description;
  final LevelStatus status;

  LevelData({
    required this.level,
    required this.title,
    required this.description,
    required this.status,
  });
}

class LearningRoadmap extends StatefulWidget {
  const LearningRoadmap({super.key});

  @override
  State<LearningRoadmap> createState() => _LearningRoadmapState();
}

class _LearningRoadmapState extends State<LearningRoadmap> {
  final List<LevelData> _levels = [
    LevelData(
      level: 1,
      title: 'LEVEL 1',
      description: '명사 이름 알기',
      status: LevelStatus.completed,
    ),
    LevelData(
      level: 2,
      title: 'LEVEL 2',
      description: '나의 행동 말하기',
      status: LevelStatus.completed,
    ),
    LevelData(
      level: 3,
      title: 'LEVEL 3',
      description: '학교 생활 말하기',
      status: LevelStatus.current,
    ),
    LevelData(
      level: 4,
      title: 'LEVEL 4',
      description: '감정 표현하기',
      status: LevelStatus.locked,
    ),
    LevelData(
      level: 5,
      title: 'LEVEL 5',
      description: '접속사 연결하기',
      status: LevelStatus.locked,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final nodeHeight = 140.0;
        final totalHeight = _levels.length * nodeHeight + 100.0;

        final centers = <Offset>[];
        for (int i = 0; i < _levels.length; i++) {
          final xOffset = _getXOffsetFactor(i);
          final x = (screenWidth / 2) + (xOffset * 80.0);
          final y = 60.0 + (i * nodeHeight);
          centers.add(Offset(x, y));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: totalHeight,
            width: screenWidth,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: RoadmapPainter(centers: centers, levels: _levels),
                  ),
                ),
                for (int i = 0; i < _levels.length; i++)
                  Positioned(
                    left: centers[i].dx - 60,
                    top: centers[i].dy - 40,
                    child: _buildNode(_levels[i]),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getXOffsetFactor(int index) {
    return (index % 4 == 0)
        ? 0
        : (index % 4 == 1)
        ? 1
        : (index % 4 == 2)
        ? 0
        : -1;
  }

  Widget _buildNode(LevelData level) {
    final bool isCompleted = level.status == LevelStatus.completed;
    final bool isCurrent = level.status == LevelStatus.current;
    final bool isLocked = level.status == LevelStatus.locked;

    final Color borderColor = isCompleted
        ? AppColors.primary
        : isCurrent
        ? const Color(0xFFF3C74B)
        : const Color(0xFFDCD5CA);
    final Color bgColor = isCurrent
        ? Colors.white
        : (isCompleted ? const Color(0xFFF0F8ED) : const Color(0xFFF9F7F3));

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LearningActivityScreen(levelData: level),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                if (isCurrent)
                  BoxShadow(
                    color: const Color(0xFFF3C74B).withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                if (isCompleted)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.primary, size: 36)
                  : isLocked
                  ? const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSub,
                      size: 30,
                    )
                  : const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFFF3C74B),
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isLocked ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isLocked
                  ? null
                  : Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: isLocked
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Text(
                  level.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isCompleted
                        ? AppColors.primary
                        : isCurrent
                        ? const Color(0xFFF07D4F)
                        : AppColors.textSub,
                  ),
                ),
                Text(
                  level.description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isLocked
                        ? AppColors.textSub
                        : AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoadmapPainter extends CustomPainter {
  final List<Offset> centers;
  final List<LevelData> levels;

  RoadmapPainter({required this.centers, required this.levels});

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.isEmpty) return;

    final paintCompleted = Paint()
      ..color = const Color(0xFF75A66B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final paintLocked = Paint()
      ..color = const Color(0xFFDCD5CA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < centers.length - 1; i++) {
      final p1 = centers[i];
      final p2 = centers[i + 1];

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      final controlPoint1 = Offset(p1.dx, p1.dy + (p2.dy - p1.dy) / 2);
      final controlPoint2 = Offset(p2.dx, p2.dy - (p2.dy - p1.dy) / 2);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );

      final bool isCompletedPath =
          levels[i].status == LevelStatus.completed &&
          levels[i + 1].status != LevelStatus.locked;

      if (isCompletedPath) {
        canvas.drawPath(path, paintCompleted);
      } else {
        _drawDashedPath(canvas, path, paintLocked);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 10.0;
    const double dashSpace = 8.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (draw) {
          canvas.drawPath(
            pathMetric.extractPath(distance, distance + length),
            paint,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadmapPainter oldDelegate) {
    return true;
  }
}
