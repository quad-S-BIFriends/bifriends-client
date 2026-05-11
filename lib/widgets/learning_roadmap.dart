import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/math_cycle_screen.dart';
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

class _LevelDef {
  final int level;
  final String cardTitle;
  final String name;
  final String subtitle;
  const _LevelDef(this.level, this.cardTitle, this.name, this.subtitle);
}

const List<_LevelDef> _mathLevelDefs = [
  _LevelDef(1, 'LEVEL 1', '숫자 세기', '1부터 10까지 세어봐요'),
  _LevelDef(2, 'LEVEL 2', '도형 알기', '세모 네모 동그라미를 찾아요'),
  _LevelDef(3, 'LEVEL 3', '더하기', '합치면 몇 개가 될까요?'),
  _LevelDef(4, 'LEVEL 4', '빼기', '빼면 몇 개가 남을까요?'),
  _LevelDef(5, 'LEVEL 5', '크기 비교', '어느 쪽이 더 클까요?'),
];

// Dots per level = total cycles per level.
// Completing each cycle fills one dot; all filled → level complete.
const int _cyclesPerLevel = 5;

class LearningRoadmap extends StatefulWidget {
  const LearningRoadmap({super.key});

  @override
  State<LearningRoadmap> createState() => _LearningRoadmapState();
}

class _LearningRoadmapState extends State<LearningRoadmap> {
  // level → number of completed cycles (0 … _cyclesPerLevel)
  Map<int, int> _completedCycles = {};
  bool _loaded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, int> cycles = {};
    for (final def in _mathLevelDefs) {
      cycles[def.level] = prefs.getInt('math_level_${def.level}_cycles') ?? 0;
    }
    // First-time default: levels 1 and 2 already completed
    if (!prefs.containsKey('math_level_1_cycles')) {
      cycles[1] = _cyclesPerLevel;
      cycles[2] = _cyclesPerLevel;
    }
    if (!mounted) return;
    setState(() {
      _completedCycles = cycles;
      _loaded = true;
    });
    // LRN_MATH_06: scroll to current level on re-entry
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLevel());
  }

  Future<void> _markCycleCompleted(int level) async {
    if (!mounted) return;
    final next = (_completedCycles[level] ?? 0) + 1;
    setState(() => _completedCycles[level] = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('math_level_${level}_cycles', next);
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients) return;
    const nodeHeight = 160.0;
    final currentIndex = _levelDatas.indexWhere((l) => l.status == LevelStatus.current);
    if (currentIndex <= 1) return;
    final targetY = (currentIndex * nodeHeight - 80.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      targetY,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  bool _isLevelComplete(int level) =>
      (_completedCycles[level] ?? 0) >= _cyclesPerLevel;

  LevelStatus _statusFor(int level) {
    if (_isLevelComplete(level)) return LevelStatus.completed;
    if (level == 1 || _isLevelComplete(level - 1)) return LevelStatus.current;
    return LevelStatus.locked;
  }

  List<LevelData> get _levelDatas => _mathLevelDefs
      .map((d) => LevelData(
            level: d.level,
            title: d.cardTitle,
            description: d.name,
            status: _statusFor(d.level),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth;
        const nodeHeight = 190.0;
        const circleAreaSize = 130.0;
        const gap = 14.0;
        // Card width: enough room from circle edge to screen edge with 16px margin
        final cardWidth = (sw * 0.7 - 80).clamp(130.0, 185.0);
        final totalHeight = _mathLevelDefs.length * nodeHeight + 80.0;

        final centers = <Offset>[];
        for (int i = 0; i < _mathLevelDefs.length; i++) {
          final isLeft = i % 2 == 0;
          final x = isLeft ? sw * 0.30 : sw * 0.70;
          final y = 60.0 + i * nodeHeight;
          centers.add(Offset(x, y));
        }

        final levelDatas = _levelDatas;

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: totalHeight,
            width: sw,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: RoadmapPainter(centers: centers, levels: levelDatas),
                  ),
                ),
                for (int i = 0; i < _mathLevelDefs.length; i++)
                  Positioned(
                    // Row left edge: for left node, align row so circle center = centers[i].dx
                    // for right node, card is first, so shift left by card+gap+half-circle
                    left: (i % 2 == 0)
                        ? centers[i].dx - circleAreaSize / 2
                        : centers[i].dx - circleAreaSize / 2 - gap - cardWidth,
                    // Center the 100px-tall circle vertically around centers[i].dy
                    top: centers[i].dy - circleAreaSize / 2,
                    child: _buildNodeRow(
                      levelDatas[i],
                      def: _mathLevelDefs[i],
                      isLeft: i % 2 == 0,
                      cardWidth: cardWidth,
                      gap: gap,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNodeRow(
    LevelData level, {
    required _LevelDef def,
    required bool isLeft,
    required double cardWidth,
    required double gap,
  }) {
    final isLocked = level.status == LevelStatus.locked;
    final circleWidget = _buildCircleWithDots(level);
    final cardWidget = SizedBox(width: cardWidth, child: _buildCard(level, def: def));

    return GestureDetector(
      onTap: isLocked
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MathCycleScreen(
                    levelData: level,
                    onCompleted: level.status == LevelStatus.current
                        ? () => _markCycleCompleted(level.level)
                        : null,
                  ),
                ),
              ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [circleWidget, SizedBox(width: gap), cardWidget]
            : [cardWidget, SizedBox(width: gap), circleWidget],
      ),
    );
  }

  Widget _buildCycleDot(int dotIndex, int filledCount, bool isLocked) {
    final isFilled = dotIndex < filledCount;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled
            ? AppColors.primary
            : isLocked
            ? const Color(0xFFDCD5CA)
            : Colors.white,
        border: (!isFilled && !isLocked)
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              )
            : null,
      ),
    );
  }

  Widget _buildCircleWithDots(LevelData level) {
    final isCompleted = level.status == LevelStatus.completed;
    final isCurrent = level.status == LevelStatus.current;
    final isLocked = level.status == LevelStatus.locked;

    // How many dots are filled: all for completed, counted for current, none for locked
    final filledCount = isCompleted
        ? _cyclesPerLevel
        : (_completedCycles[level.level] ?? 0);

    final Color borderColor = isCompleted || isCurrent
        ? AppColors.primary
        : const Color(0xFFDCD5CA);
    final Color bgColor = isCompleted
        ? const Color(0xFFF0F8ED)
        : isCurrent
        ? Colors.white
        : const Color(0xFFF9F7F3);

    // 130×130 container; 80×80 circle centered at (65, 65)
    // 5 dots orbit at radius 55 — evenly spaced at 72° each, starting from top
    const containerSize = 130.0;
    const circleSize = 80.0;
    const circleInset = (containerSize - circleSize) / 2; // 25
    const cx = containerSize / 2; // 65
    const cy = containerSize / 2; // 65
    const orbitRadius = 55.0;
    const dotSize = 12.0;

    final dotPositioned = <Widget>[
      for (int i = 0; i < _cyclesPerLevel; i++)
        () {
          final angle = -math.pi / 2 + i * 2 * math.pi / _cyclesPerLevel;
          final dx = cx + orbitRadius * math.cos(angle);
          final dy = cy + orbitRadius * math.sin(angle);
          return Positioned(
            left: dx - dotSize / 2,
            top: dy - dotSize / 2,
            child: _buildCycleDot(i, filledCount, isLocked),
          );
        }(),
    ];

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: circleInset,
            top: circleInset,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  if (isCurrent)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 18,
                      spreadRadius: 5,
                    ),
                  if (isCompleted)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 38)
                    : isCurrent
                    ? const Icon(Icons.eco_rounded, color: AppColors.primary, size: 36)
                    : Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 28),
              ),
            ),
          ),
          ...dotPositioned,
        ],
      ),
    );
  }

  Widget _buildCard(LevelData level, {required _LevelDef def}) {
    final isLocked = level.status == LevelStatus.locked;
    final labelColor = isLocked ? AppColors.textSub : const Color(0xFFF07D4F);
    final titleColor = isLocked ? AppColors.textSub : AppColors.textMain;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            def.cardTitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            def.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            def.subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSub,
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
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final paintLocked = Paint()
      ..color = const Color(0xFFDCD5CA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < centers.length - 1; i++) {
      final p1 = centers[i];
      final p2 = centers[i + 1];

      final path = Path()..moveTo(p1.dx, p1.dy);
      final mid = (p2.dy - p1.dy) / 2;
      path.cubicTo(
        p1.dx, p1.dy + mid,
        p2.dx, p2.dy - mid,
        p2.dx, p2.dy,
      );

      final isCompletedPath =
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
    const dashWidth = 10.0;
    const dashSpace = 8.0;
    for (ui.PathMetric m in path.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < m.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) canvas.drawPath(m.extractPath(d, d + len), paint);
        d += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadmapPainter oldDelegate) => true;
}
