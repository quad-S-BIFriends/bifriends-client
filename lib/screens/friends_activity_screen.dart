import 'package:flutter/material.dart';
import '../models/friends_activity_model.dart';
import '../theme/app_colors.dart';

// TODO: BE 연동 시 제거하고 API 응답 데이터 사용
final _mockData = FriendsActivityData(
  situationText: '교실에서 갑자기 큰 소리가 났을 때',
  expression: FriendsExpressionData(
    emotionWord: '놀람',
    expression: '가슴이 철렁하다',
    bodyFeeling: '갑자기 너무 놀라서 가슴이 툭 떨어지는 기분이야.',
    whenFeeling: '친구가 뒤에서 갑자기 놀래켰을 때',
  ),
  step2: FriendsStep2Data(
    panels: [
      ComicPanel(caption: '수업 중에 조용히 앉아있는 지수'),
      ComicPanel(caption: '뒤에서 친구가 "왁!" 하고 놀래켰어'),
      ComicPanel(caption: '가슴이 철렁한 지수'),
    ],
    question: '지수는 지금 어떤 마음일까?',
    correctIndex: 1,
    options: [
      Step2AnswerOption(
        text: '화가 났어',
        wrongExplanation: '화는 억울하거나 불공평할 때 드는 마음이야. 지수는 그런 상황이 아니었어!',
      ),
      Step2AnswerOption(text: '깜짝 놀랐어'),
      Step2AnswerOption(
        text: '슬펐어',
        wrongExplanation: '슬픔은 무언가를 잃거나 힘들 때 드는 마음이야. 다시 한 번 생각해봐!',
      ),
    ],
  ),
);

const int _totalSteps = 4;

class FriendsActivityScreen extends StatefulWidget {
  // TODO: BE 연동 시 data 파라미터로 API 응답 전달
  final FriendsActivityData? data;

  const FriendsActivityScreen({super.key, this.data});

  @override
  State<FriendsActivityScreen> createState() => _FriendsActivityScreenState();
}

class _FriendsActivityScreenState extends State<FriendsActivityScreen> {
  int _currentStep = 0;
  bool _showSuccessOverlay = false;

  // Step 2 state
  late final PageController _step2PageController;
  int _step2Panel = 0;
  int _step2SelectedIndex = -1;
  bool _step2Evaluated = false; // "이 마음 같아!" 버튼이 눌렸는지
  bool _step2IsCorrect = false; // 마지막 제출이 정답인지

  FriendsActivityData get _data => widget.data ?? _mockData;

  @override
  void initState() {
    super.initState();
    _step2PageController = PageController();
  }

  @override
  void dispose() {
    _step2PageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _showSuccessOverlay = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showSuccessOverlay = false;
            _currentStep++;
          });
        }
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎯', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              const Text(
                '모두 이해했어!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '오늘 배운 표현들을 잘 기억해줘!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textMain,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '완료!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTopBar(),
                  const SizedBox(height: 16),
                  if (_currentStep == 0) ...[
                    _buildBearRow(),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: _buildCurrentStep(key: ValueKey(_currentStep)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (_showSuccessOverlay) _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '잘 이해했어! 👏',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _data.situationText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildProgressBar(),
        const SizedBox(width: 8),
        Text(
          '${_currentStep + 1}/$_totalSteps',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSub,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: 52,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFFDDD8D0),
        borderRadius: BorderRadius.circular(11),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: constraints.maxWidth * (_currentStep + 1) / _totalSteps,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Bear row (Step 1 전용)
  // ─────────────────────────────────────────────

  Widget _buildBearRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFF5C9B8),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/leo_defaultface.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              '오늘 배울 표현은 이거야! ✨',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Step router
  // ─────────────────────────────────────────────

  Widget _buildCurrentStep({required Key key}) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(key: key);
      case 1:
        final step2 = _data.step2;
        if (step2 == null) {
          return _buildComingSoonPlaceholder(key: key, stepLabel: 'Step 2');
        }
        return _buildStep2(key: key, data: step2);
      default:
        return _buildComingSoonPlaceholder(
          key: key,
          stepLabel: 'Step ${_currentStep + 1}',
        );
    }
  }

  // ─────────────────────────────────────────────
  // Step 1 — 관용 표현 학습 (EMO-07)
  // ─────────────────────────────────────────────

  Widget _buildStep1({required Key key}) {
    final exp = _data.expression;
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Text(
              '"${exp.expression}"',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEBE6DF), thickness: 1),
            const SizedBox(height: 16),
            // TODO: BE 연동 — 감정 단서가 보이는 상반신 이미지 - imageUrl 활용
            _buildCharacterImage(exp.imageUrl),
            const SizedBox(height: 24),
            _buildSectionBlock(label: '우리 몸의 느낌', content: exp.bodyFeeling),
            const SizedBox(height: 16),
            _buildSectionBlock(
              label: '이럴 때 이런 마음이 들어',
              content: exp.whenFeeling,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showSuccessOverlay ? null : _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textMain,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textMain.withValues(
                    alpha: 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '이해했어! 🎯',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterImage(String? imageUrl) {
    // TODO: BE 연동 시 imageUrl 사용 예정 (감정 단서가 잘 보이는 상반신 캐릭터 이미지)
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: 160,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _imagePlaceholder(),
        ),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.face, size: 64, color: AppColors.textSub),
      ),
    );
  }

  Widget _buildSectionBlock({required String label, required String content}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSub,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Step 2 — 3컷 만화 + 감정 선택 퀴즈 (EMO-09~12)
  // ─────────────────────────────────────────────

  Widget _buildStep2({required Key key, required FriendsStep2Data data}) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildComicCard(data),
          const SizedBox(height: 16),
          _buildQuestionPill(data.question),
          const SizedBox(height: 12),
          for (int i = 0; i < data.options.length; i++) ...[
            _buildAnswerOption(data, i),
            if (i < data.options.length - 1) const SizedBox(height: 10),
          ],
          // 오답 설명 (EMO-10): 오답 제출 시 OR 정답 확정 후 다른 선택지 탐색 시
          if (_step2Evaluated &&
              _step2SelectedIndex != -1 &&
              _step2SelectedIndex != data.correctIndex) ...[
            const SizedBox(height: 12),
            _buildWrongExplanation(
              data.options[_step2SelectedIndex].wrongExplanation,
            ),
          ],
          // 정답 성공 피드백 (EMO-11)
          if (_step2Evaluated && _step2IsCorrect) ...[
            const SizedBox(height: 12),
            _buildSuccessBox(data.successMessage),
          ],
          const SizedBox(height: 16),
          // 항상 표시 — 제출 역할 (EMO-11)
          _buildStep2ActionButton(data),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildComicCard(FriendsStep2Data data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: PageView.builder(
                    controller: _step2PageController,
                    itemCount: data.panels.length,
                    onPageChanged: (i) => setState(() => _step2Panel = i),
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(52, 36, 48, 16),
                        child: _buildPanelImage(data.panels[i].imageUrl),
                      );
                    },
                  ),
                ),
                // 패널 번호 뱃지
                Positioned(
                  top: 16,
                  left: 16,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      key: ValueKey(_step2Panel),
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_step2Panel + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 이전 패널 화살표
                if (_step2Panel > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _step2PageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: AppColors.textSub,
                          ),
                        ),
                      ),
                    ),
                  ),
                // 다음 패널 화살표
                if (_step2Panel < data.panels.length - 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _step2PageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: AppColors.textSub,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 캡션
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                data.panels[_step2Panel].caption,
                key: ValueKey(_step2Panel),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSub,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(data.panels.length, (i) {
                final active = i == _step2Panel;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : const Color(0xFFD9D3CB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelImage(String? imageUrl) {
    // TODO: BE 연동 시 imageUrl 사용 (감정 단서가 잘 보이는 상반신 캐릭터 이미지)
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _panelPlaceholder(),
        ),
      );
    }
    return _panelPlaceholder();
  }

  Widget _panelPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 56, color: AppColors.textSub),
      ),
    );
  }

  Widget _buildQuestionPill(String question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '"$question"',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textMain,
        ),
      ),
    );
  }

  Widget _buildAnswerOption(FriendsStep2Data data, int index) {
    final option = data.options[index];
    final isSelected = _step2SelectedIndex == index;
    final isCorrect = index == data.correctIndex;

    Color borderColor = const Color(0xFFEBE6DF);
    Color bgColor = Colors.white;
    Color textColor = AppColors.textMain;

    final correctConfirmed = _step2Evaluated && _step2IsCorrect;

    if (correctConfirmed && isCorrect) {
      // 정답 확정 후 — 정답 옵션은 항상 초록으로 고정
      borderColor = AppColors.primary;
      bgColor = const Color(0xFFEAF3E8);
      textColor = AppColors.primary;
    } else if (isSelected) {
      if (!_step2Evaluated) {
        // 제출 전 선택 — 중립 강조
        borderColor = AppColors.primary.withValues(alpha: 0.5);
        bgColor = const Color(0xFFF0F6EE);
        textColor = AppColors.primary;
      } else if (isCorrect) {
        // 제출 후 정답 (correctConfirmed && !isCorrect 아닌 경우)
        borderColor = AppColors.primary;
        bgColor = const Color(0xFFEAF3E8);
        textColor = AppColors.primary;
      } else {
        // 제출 후 오답 또는 정답 확정 후 탐색 중 오답 선택
        borderColor = const Color(0xFFE8A09A);
        bgColor = const Color(0xFFFFF2F1);
        textColor = const Color(0xFFD04B44);
      }
    }

    return GestureDetector(
      onTap: () {
        if (correctConfirmed) {
          // 정답 확정 후 — 오답 탭 시 왜 틀렸는지 탐색 가능, 정답 탭 시 무시
          if (isCorrect) return;
          setState(() => _step2SelectedIndex = index);
        } else {
          setState(() {
            _step2SelectedIndex = index;
            // 오답 제출 후 재선택 시 평가 초기화
            if (_step2Evaluated && !_step2IsCorrect) _step2Evaluated = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: isSelected ? textColor : AppColors.textSub,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongExplanation(String explanation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDAD8), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💬 ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              explanation,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFD04B44),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('⭐ ', style: TextStyle(fontSize: 22)),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "이 마음 같아!" → 제출, 정답이면 "다음으로" → Step 3 이동 (EMO-11)
  Widget _buildStep2ActionButton(FriendsStep2Data data) {
    final isConfirmed = _step2Evaluated && _step2IsCorrect;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showSuccessOverlay
            ? null
            : () {
                if (isConfirmed) {
                  _handleNext();
                } else {
                  if (_step2SelectedIndex == -1) return;
                  setState(() {
                    _step2Evaluated = true;
                    _step2IsCorrect = _step2SelectedIndex == data.correctIndex;
                  });
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isConfirmed ? '다음으로' : '이 마음 같아! 💕',
            key: ValueKey(isConfirmed),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Placeholder (Steps 3~4)
  // ─────────────────────────────────────────────

  Widget _buildComingSoonPlaceholder({
    required Key key,
    required String stepLabel,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚧', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text(
            '$stepLabel 준비 중!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '곧 만나볼 수 있어요',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textMain,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentStep < _totalSteps - 1 ? '다음으로' : '완료!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
