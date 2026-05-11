import 'package:flutter/material.dart';
import '../widgets/learning_roadmap.dart' show LevelData;
import '../theme/app_colors.dart';

class _ConceptSlide {
  final String emoji;
  final String title;
  final String body;
  final Color bgColor;

  const _ConceptSlide({
    required this.emoji,
    required this.title,
    required this.body,
    required this.bgColor,
  });
}

List<_ConceptSlide> _slidesForLevel(int level) {
  switch (level) {
    case 1:
      return const [
        _ConceptSlide(emoji: '🔢', title: '숫자가 뭘까?', bgColor: Color(0xFFF0F8ED),
            body: '숫자는 물건의 개수를 나타내는 기호예요.\n우리 주변 곳곳에 숫자가 있답니다!'),
        _ConceptSlide(emoji: '🖐', title: '1부터 5까지', bgColor: Color(0xFFF0F8ED),
            body: '하나, 둘, 셋, 넷, 다섯!\n손가락을 하나씩 펴면서 세어봐요.'),
        _ConceptSlide(emoji: '🙌', title: '6부터 10까지', bgColor: Color(0xFFF0F8ED),
            body: '여섯, 일곱, 여덟, 아홉, 열!\n양손을 모두 써서 세어봐요.'),
      ];
    case 2:
      return const [
        _ConceptSlide(emoji: '🔷', title: '도형이 뭘까?', bgColor: Color(0xFFFFF0E4),
            body: '도형은 선으로 이루어진 모양이에요.\n세모, 네모, 동그라미가 대표적이에요!'),
        _ConceptSlide(emoji: '🔺🟦⭕', title: '세 가지 기본 도형', bgColor: Color(0xFFFFF0E4),
            body: '세모(삼각형), 네모(사각형),\n동그라미(원)를 알아봐요!'),
        _ConceptSlide(emoji: '🏠', title: '주변에서 찾아봐요', bgColor: Color(0xFFFFF0E4),
            body: '지붕은 세모, 창문은 네모,\n시계는 동그라미! 어디에나 있어요.'),
      ];
    case 3:
      return const [
        _ConceptSlide(emoji: '🍎🍊', title: '더하기란 뭘까?', bgColor: Color(0xFFEEF3FE),
            body: '물건을 합치면 개수가 늘어나요.\n이렇게 합치는 것을 더하기라고 해요!'),
        _ConceptSlide(emoji: '➕', title: '+ 기호 알기', bgColor: Color(0xFFEEF3FE),
            body: '더하기는 + 기호로 나타내요.\n2 + 3 = 5 이렇게 쓰면 돼요!'),
        _ConceptSlide(emoji: '🤲', title: '같이 세어봐요', bgColor: Color(0xFFEEF3FE),
            body: '사과 2개와 귤 3개를 합치면\n모두 몇 개일까요? 함께 세어봐요!'),
      ];
    case 4:
      return const [
        _ConceptSlide(emoji: '🎈', title: '빼기란 뭘까?', bgColor: Color(0xFFFEECEF),
            body: '물건이 사라지면 개수가 줄어요.\n이렇게 빼는 것을 빼기라고 해요!'),
        _ConceptSlide(emoji: '➖', title: '– 기호 알기', bgColor: Color(0xFFFEECEF),
            body: '빼기는 – 기호로 나타내요.\n5 – 2 = 3 이렇게 쓰면 돼요!'),
        _ConceptSlide(emoji: '🍪', title: '같이 빼봐요', bgColor: Color(0xFFFEECEF),
            body: '쿠키 5개 중 2개를 먹었어요.\n남은 쿠키는 몇 개일까요?'),
      ];
    case 5:
      return const [
        _ConceptSlide(emoji: '⚖️', title: '크기 비교란?', bgColor: Color(0xFFF5EDFC),
            body: '두 수 중 어느 쪽이 더 큰지,\n작은지 알아보는 거예요!'),
        _ConceptSlide(emoji: '↔️', title: '기호 알기', bgColor: Color(0xFFF5EDFC),
            body: '> 는 왼쪽이 크다, < 는 오른쪽이 커요.\n3 > 1, 2 < 5 이렇게 써요!'),
        _ConceptSlide(emoji: '🏆', title: '더 크고 더 작은 수', bgColor: Color(0xFFF5EDFC),
            body: '7과 4 중 어느 게 더 클까요?\n손가락으로 세어 비교해봐요!'),
      ];
    default:
      return [];
  }
}

class MathCycleScreen extends StatefulWidget {
  final LevelData levelData;
  final VoidCallback? onCompleted;

  const MathCycleScreen({
    super.key,
    required this.levelData,
    this.onCompleted,
  });

  @override
  State<MathCycleScreen> createState() => _MathCycleScreenState();
}

class _MathCycleScreenState extends State<MathCycleScreen> {
  late final List<_ConceptSlide> _slides;
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _slides = _slidesForLevel(widget.levelData.level);
  }

  void _advance() {
    if (_currentSlide < _slides.length - 1) {
      setState(() => _currentSlide++);
    } else {
      widget.onCompleted?.call();
      _showRewardDialog();
    }
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '개념 완료!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '경험치 +10',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '로드맵 보러가기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            '준비 중인 내용이에요 🔒',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textSub,
            ),
          ),
        ),
      );
    }

    final slide = _slides[_currentSlide];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(slide),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _buildSlideContent(
                  slide,
                  key: ValueKey(_currentSlide),
                ),
              ),
            ),
            _buildDotIndicator(slide),
            _buildBottomBar(slide),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(_ConceptSlide slide) {
    final total = _slides.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBE6DF),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 10,
                    width: constraints.maxWidth * ((_currentSlide + 1) / total),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${_currentSlide + 1}/$total',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSlideContent(_ConceptSlide slide, {required Key key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: slide.bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '개념 이야기',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 44),
            decoration: BoxDecoration(
              color: slide.bgColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSub,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(_ConceptSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_slides.length, (i) {
          final isActive = i == _currentSlide;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : const Color(0xFFDCD5CA),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(_ConceptSlide slide) {
    final isLast = _currentSlide == _slides.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      color: AppColors.background,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _advance,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              isLast ? '이해했어요! ✓' : '다음',
              key: ValueKey(isLast),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
