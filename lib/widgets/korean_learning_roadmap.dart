import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/learning_activity_screen.dart';
import '../widgets/learning_roadmap.dart' show LevelData, LevelStatus, RoadmapPainter;
import '../theme/app_colors.dart';

class _LevelDef {
  final int level;
  final String cardTitle;
  final String name;
  final String subtitle;
  const _LevelDef(this.level, this.cardTitle, this.name, this.subtitle);
}

const List<_LevelDef> _koreanLevelDefs = [
  _LevelDef(1, 'STEP 1', '비 오는 날', '감각적 표현을 배워요'),
  _LevelDef(2, 'STEP 2', '친구의 선물', '마음을 전하는 글을 읽어요'),
  _LevelDef(3, 'STEP 3', '바닷가에서', '장소를 나타내는 말을 배워요'),
  _LevelDef(4, 'STEP 4', '봄이 왔어요', '계절과 자연을 느껴봐요'),
  _LevelDef(5, 'STEP 5', '우리 마을', '우리 주변을 이야기로 써봐요'),
];

const int _cyclesPerLevel = 5;

class KoreanLearningRoadmap extends StatefulWidget {
  const KoreanLearningRoadmap({super.key});

  @override
  State<KoreanLearningRoadmap> createState() => _KoreanLearningRoadmapState();
}

class _KoreanLearningRoadmapState extends State<KoreanLearningRoadmap> {
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
    for (final def in _koreanLevelDefs) {
      cycles[def.level] =
          prefs.getInt('korean_level_${def.level}_cycles') ?? 0;
    }
    if (!mounted) return;
    setState(() {
      _completedCycles = cycles;
      _loaded = true;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToCurrentLevel(),
    );
  }

  Future<void> _markCycleCompleted(int level) async {
    if (!mounted) return;
    final next = (_completedCycles[level] ?? 0) + 1;
    setState(() => _completedCycles[level] = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('korean_level_${level}_cycles', next);
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients) return;
    const nodeHeight = 160.0;
    final currentIndex = _levelDatas.indexWhere(
      (l) => l.status == LevelStatus.current,
    );
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

  List<LevelData> get _levelDatas => _koreanLevelDefs
      .map(
        (d) => LevelData(
          level: d.level,
          title: d.cardTitle,
          description: d.name,
          status: _statusFor(d.level),
        ),
      )
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
        final cardWidth = (sw * 0.7 - 80).clamp(130.0, 185.0);
        final totalHeight = _koreanLevelDefs.length * nodeHeight + 80.0;

        final centers = <Offset>[];
        for (int i = 0; i < _koreanLevelDefs.length; i++) {
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
                    painter: RoadmapPainter(
                      centers: centers,
                      levels: levelDatas,
                    ),
                  ),
                ),
                for (int i = 0; i < _koreanLevelDefs.length; i++)
                  Positioned(
                    left: (i % 2 == 0)
                        ? centers[i].dx - circleAreaSize / 2
                        : centers[i].dx - circleAreaSize / 2 - gap - cardWidth,
                    top: centers[i].dy - circleAreaSize / 2,
                    child: _buildNodeRow(
                      levelDatas[i],
                      def: _koreanLevelDefs[i],
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
    final cardWidget = SizedBox(
      width: cardWidth,
      child: _buildCard(level, def: def),
    );

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              final completedCycles = _completedCycles[level.level] ?? 0;
              final initialStep = _isLevelComplete(level.level)
                  ? 1
                  : (completedCycles + 1).clamp(1, 5);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LearningActivityScreen(
                    levelData: level,
                    initialStep: initialStep,
                    subject: 'korean',
                    onStepCompleted: level.status == LevelStatus.current
                        ? () => _markCycleCompleted(level.level)
                        : null,
                  ),
                ),
              );
            },
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

    const containerSize = 130.0;
    const circleSize = 80.0;
    const circleInset = (containerSize - circleSize) / 2;
    const cx = containerSize / 2;
    const cy = containerSize / 2;
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
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 38,
                      )
                    : isCurrent
                    ? const Icon(
                        Icons.eco_rounded,
                        color: AppColors.primary,
                        size: 36,
                      )
                    : Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.grey.shade400,
                        size: 28,
                      ),
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
    final labelColor = isLocked ? AppColors.textSub : AppColors.primary;
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
