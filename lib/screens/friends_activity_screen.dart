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
    visualDescription: '눈이 동그랗게 커지고, 입이 벌어져 있어. 온몸이 굳어버린 것 같아.',
    question: '이 친구는 어떤 기분일까요?',
    correctIndex: 1,
    options: [
      Step2AnswerOption(
        text: '화가 났어',
        wrongExplanation: '화는 억울하거나 불공평할 때 드는 마음이야. 표정을 다시 살펴봐!',
      ),
      Step2AnswerOption(text: '깜짝 놀랐어'),
      Step2AnswerOption(
        text: '슬펐어',
        wrongExplanation: '슬픔은 무언가를 잃거나 힘들 때 드는 마음이야. 다시 한 번 생각해봐!',
      ),
    ],
    successMessage: '맞아! 눈이 커지고 입이 벌어진 표정은 깜짝 놀랐을 때 나타나는 거야.',
  ),
  step3: FriendsStep3Data(
    panels: [
      ComicPanel(caption: '수업 중에 조용히 앉아있는 지수'),
      ComicPanel(caption: '뒤에서 친구가 "왁!" 하고 놀래켰어'),
      ComicPanel(caption: '가슴이 철렁, 깜짝 놀란 지수'),
    ],
    question: '어떤 일이 있어서 이런 기분이 들었을까요?',
    correctIndex: 1,
    options: [
      Step3CauseOption(
        text: '지수가 먼저 친구를 놀래켰기 때문이야',
        wrongGuidance: '만화를 다시 한 번 살펴봐. 누가 먼저였지?',
      ),
      Step3CauseOption(text: '친구가 갑자기 "왁!" 하고 놀래켰기 때문이야'),
      Step3CauseOption(
        text: '지수가 숙제를 잊어버렸기 때문이야',
        wrongGuidance: '만화 속 상황을 다시 보자. 어떤 일이 일어났지?',
      ),
    ],
    correctExplanation: '맞아! 친구가 갑자기 "왁!" 하고 놀래켰기 때문에 지수는 가슴이 철렁 놀랐어.',
  ),
  step4: FriendsStep4Data(
    leoIntroMessage:
        '맞아요! 친구가 갑자기 놀래켰기 때문에 지수는 깜짝 놀랐어요. 이럴 때 여러분이라면 뭐라고 말해줄까요?',
    scene: Step4Scene(
      scenarioText: '지수가 깜짝 놀라자, 친구가 다가와서 말했어.',
      speakerLabel: '친',
      speakerFullLabel: '친구(이)가 말했어:',
      speakerMessage: '"야, 나도 깜짝 놀랬잖아. 괜찮아?"',
    ),
    question: '가장 알맞은 대답을 골라주세요!',
    correctIndex: 0,
    options: [
      Step4ResponseOption(text: '"응, 나도 많이 놀랐어. 괜찮아!"'),
      Step4ResponseOption(
        text: '"왜 놀래켜! 진짜 짜증나!"',
        wrongExplanation: '화를 내는 건 친구를 속상하게 할 수 있어. 친구의 마음을 먼저 생각해봐!',
      ),
      Step4ResponseOption(
        text: '"아 배고파, 간식 먹으러 가자!"',
        wrongExplanation: '상황과 관계없는 말이야. 친구의 마음을 먼저 살펴봐!',
      ),
    ],
    correctEcho: '"응, 나도 많이 놀랐어. 괜찮아!"',
    leoFeedback: '완벽해요! 자신의 마음을 솔직하게 말하면서 친구에게도 다정하게 대답했어요! 🌟',
  ),
  step5: FriendsStep5Data(
    leoMessage: '오늘 정말 즐거웠어! 마지막으로 리오에게 해주고 싶은 말이 있니?',
    promptLabel: '리오에게 인사해볼까?',
    farewellOptions: ['다음에 또 만나!', '오늘 재미있었어!', '리오 고마워!'],
  ),
);

const int _totalSteps = 5;

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
  int _step2SelectedIndex = -1;
  bool _step2Evaluated = false; // "이 마음 같아!" 버튼이 눌렸는지
  bool _step2IsCorrect = false; // 마지막 제출이 정답인지

  // Step 3 state
  late final PageController _step3PageController;
  int _step3Panel = 0;
  int _step3SelectedIndex = -1;
  bool _step3Evaluated = false;
  bool _step3IsCorrect = false;

  // Step 4 state
  int _step4SelectedIndex = -1;
  bool _step4Evaluated = false;
  bool _step4IsCorrect = false;

  // Step 5 state
  int _step5SelectedIndex = -1;
  bool _step5Loading = false;

  FriendsActivityData get _data => widget.data ?? _mockData;

  @override
  void initState() {
    super.initState();
    _step3PageController = PageController();
  }

  @override
  void dispose() {
    _step3PageController.dispose();
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

  // Step 5 완료 — Firestore 저장 후 세션 종료 (EMO-23, EMO-24)
  void _handleComplete() {
    _saveMindSession();
    _showCompletionDialog();
  }

  void _saveMindSession() {
    // TODO: BE 연동 — Firestore mindSessions 서브 컬렉션에 새 문서로 저장 (EMO-24)
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
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
          ),
        ),
        if (_showSuccessOverlay) _buildSuccessOverlay(),
      ],
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
      case 2:
        final step3 = _data.step3;
        if (step3 == null) {
          return _buildComingSoonPlaceholder(key: key, stepLabel: 'Step 3');
        }
        return _buildStep3(key: key, data: step3);
      case 3:
        final step4 = _data.step4;
        if (step4 == null) {
          return _buildComingSoonPlaceholder(key: key, stepLabel: 'Step 4');
        }
        return _buildStep4(key: key, data: step4);
      case 4:
        final step5 = _data.step5;
        if (step5 == null) {
          return _buildComingSoonPlaceholder(key: key, stepLabel: 'Step 5');
        }
        return _buildStep5(key: key, data: step5);
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
  // Step 2 — 얼굴 확대 이미지 + 감정 선택 퀴즈 (EMO-08~11)
  // ─────────────────────────────────────────────

  Widget _buildStep2({required Key key, required FriendsStep2Data data}) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFaceCard(data),
          const SizedBox(height: 16),
          _buildQuestionPill(data.question),
          const SizedBox(height: 12),
          for (int i = 0; i < data.options.length; i++) ...[
            _buildAnswerOption(data, i),
            if (i < data.options.length - 1) const SizedBox(height: 10),
          ],
          // 오답 설명 (EMO-10): 왜 다른 감정인지 짧고 다정하게 설명
          if (_step2Evaluated &&
              _step2SelectedIndex != -1 &&
              _step2SelectedIndex != data.correctIndex) ...[
            const SizedBox(height: 12),
            _buildWrongExplanation(
              data.options[_step2SelectedIndex].wrongExplanation,
            ),
          ],
          // 정답 피드백 (EMO-11)
          if (_step2Evaluated && _step2IsCorrect) ...[
            const SizedBox(height: 12),
            _buildSuccessBox(data.successMessage),
          ],
          const SizedBox(height: 16),
          _buildStep2ActionButton(data),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // 얼굴 확대 이미지 + 시각적 특징 설명 카드 (EMO-08)
  Widget _buildFaceCard(FriendsStep2Data data) {
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: _buildCharacterImage(data.faceImageUrl),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('👀 ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      data.visualDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSub,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  // Step 3 — 3컷 만화 캐러셀 + 감정 원인 퀴즈 (EMO-12~17)
  // ─────────────────────────────────────────────

  Widget _buildStep3({required Key key, required FriendsStep3Data data}) {
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
            _buildStep3Choice(data, i),
            if (i < data.options.length - 1) const SizedBox(height: 10),
          ],
          // 오답 안내 (EMO-16): 제출 후 오답 / 정답 확정 후 오답 탐색
          if (_step3Evaluated &&
              _step3SelectedIndex != -1 &&
              _step3SelectedIndex != data.correctIndex) ...[
            const SizedBox(height: 12),
            _buildStep3WrongGuidance(
              data.options[_step3SelectedIndex].wrongGuidance,
            ),
          ],
          // 정답 시 원인 설명 (EMO-15)
          if (_step3Evaluated && _step3IsCorrect) ...[
            const SizedBox(height: 12),
            _buildStep3CorrectExplanation(data.correctExplanation),
          ],
          const SizedBox(height: 16),
          // 항상 표시 — 제출/다음 이야기 보기 버튼 (EMO-17)
          _buildStep3ActionButton(data),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // 3컷 만화 캐러셀 (EMO-12, EMO-13)
  Widget _buildComicCard(FriendsStep3Data data) {
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
                    controller: _step3PageController,
                    itemCount: data.panels.length,
                    onPageChanged: (i) => setState(() => _step3Panel = i),
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
                      key: ValueKey(_step3Panel),
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_step3Panel + 1}',
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
                if (_step3Panel > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _step3PageController.previousPage(
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
                if (_step3Panel < data.panels.length - 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _step3PageController.nextPage(
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
          // 컷 설명 캡션 (EMO-13)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                data.panels[_step3Panel].caption,
                key: ValueKey(_step3Panel),
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
                final active = i == _step3Panel;
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
    // TODO: BE 연동 시 imageUrl 사용
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

  Widget _buildStep3Choice(FriendsStep3Data data, int index) {
    final option = data.options[index];
    final isSelected = _step3SelectedIndex == index;
    final isCorrect = index == data.correctIndex;
    final correctConfirmed = _step3Evaluated && _step3IsCorrect;

    Color borderColor = const Color(0xFFEBE6DF);
    Color bgColor = Colors.white;
    Color textColor = AppColors.textMain;
    Color numBgColor = AppColors.cardLight;
    Color numTextColor = AppColors.textSub;

    // 정답 확정 후 — 정답 옵션은 항상 초록으로 고정
    if (correctConfirmed && isCorrect) {
      borderColor = AppColors.primary;
      bgColor = const Color(0xFFEAF3E8);
      textColor = AppColors.primary;
      numBgColor = AppColors.primary;
      numTextColor = Colors.white;
    } else if (isSelected) {
      if (!_step3Evaluated) {
        // 제출 전 선택 — 중립 강조
        borderColor = AppColors.primary.withValues(alpha: 0.5);
        bgColor = const Color(0xFFF0F6EE);
        textColor = AppColors.primary;
        numBgColor = AppColors.primary.withValues(alpha: 0.5);
        numTextColor = Colors.white;
      } else if (isCorrect) {
        borderColor = AppColors.primary;
        bgColor = const Color(0xFFEAF3E8);
        textColor = AppColors.primary;
        numBgColor = AppColors.primary;
        numTextColor = Colors.white;
      } else {
        // 제출 후 오답 / 정답 확정 후 탐색 중 오답
        borderColor = const Color(0xFFE8A09A);
        bgColor = const Color(0xFFFFF2F1);
        textColor = const Color(0xFFD04B44);
        numBgColor = const Color(0xFFE8A09A);
        numTextColor = Colors.white;
      }
    }

    return GestureDetector(
      onTap: () {
        if (correctConfirmed) {
          // 정답 확정 후 — 오답 탭 시 해설 탐색 가능, 정답 탭 시 무시
          if (isCorrect) return;
          setState(() => _step3SelectedIndex = index);
          return;
        }
        setState(() {
          _step3SelectedIndex = index;
          // 오답 제출 후 재선택 시 평가 초기화
          if (_step3Evaluated && !_step3IsCorrect) _step3Evaluated = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: numBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: numTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
          ],
        ),
      ),
    );
  }

  // 오답 안내 — 장면을 다시 보도록 유도 (EMO-16)
  Widget _buildStep3WrongGuidance(String guidance) {
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
          const Text('💭 ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              guidance,
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

  // 정답 시 감정 원인 설명 (EMO-15)
  Widget _buildStep3CorrectExplanation(String explanation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡 ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              explanation,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 제출 → 정답 확정 시 '다음 이야기 보기'로 전환 (EMO-17)
  Widget _buildStep3ActionButton(FriendsStep3Data data) {
    final isConfirmed = _step3Evaluated && _step3IsCorrect;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showSuccessOverlay
            ? null
            : () {
                if (isConfirmed) {
                  _handleNext();
                } else {
                  if (_step3SelectedIndex == -1) return;
                  setState(() {
                    _step3Evaluated = true;
                    _step3IsCorrect =
                        _step3SelectedIndex == data.correctIndex;
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
            isConfirmed ? '다음 이야기 보기' : '이게 이유야! 🔍',
            key: ValueKey(isConfirmed),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Step 4 — 대화 연습 / 공감 반응 선택 (EMO-18~22)
  // ─────────────────────────────────────────────

  Widget _buildStep4({required Key key, required FriendsStep4Data data}) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Leo 역할극 메시지 (EMO-18, EMO-19)
          _buildStep4LeoIntro(data.leoIntroMessage),
          const SizedBox(height: 12),
          // 대화 시나리오 카드
          _buildStep4ScenarioCard(data.scene),
          const SizedBox(height: 16),
          Text(
            data.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < data.options.length; i++) ...[
            _buildStep4Choice(data, i),
            if (i < data.options.length - 1) const SizedBox(height: 10),
          ],
          // 오답 설명 (EMO-22): 제출 후 오답 / 정답 확정 후 오답 탐색
          if (_step4Evaluated &&
              _step4SelectedIndex != -1 &&
              _step4SelectedIndex != data.correctIndex) ...[
            const SizedBox(height: 12),
            _buildStep4WrongExplanation(
              data.options[_step4SelectedIndex].wrongExplanation,
            ),
          ],
          // 정답 피드백 (EMO-21)
          if (_step4Evaluated && _step4IsCorrect) ...[
            const SizedBox(height: 12),
            _buildStep4CorrectEcho(data.correctEcho),
            const SizedBox(height: 12),
            _buildStep4LeoFeedback(data.leoFeedback),
          ],
          const SizedBox(height: 16),
          // 항상 표시 — 제출/다음으로 버튼
          _buildStep4ActionButton(data),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStep4LeoIntro(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4ScenarioCard(Step4Scene scene) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "대화 연습" 배지 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEBE6DF), width: 1),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '💬 대화 연습',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          // 상황 설명
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              scene.scenarioText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSub,
                height: 1.5,
              ),
            ),
          ),
          // 발화자 말풍선
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5C9B8),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          scene.speakerLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scene.speakerFullLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      scene.speakerMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Choice(FriendsStep4Data data, int index) {
    final option = data.options[index];
    final isSelected = _step4SelectedIndex == index;
    final isCorrect = index == data.correctIndex;
    final correctConfirmed = _step4Evaluated && _step4IsCorrect;

    Color borderColor = const Color(0xFFEBE6DF);
    Color bgColor = Colors.white;
    Color textColor = AppColors.textMain;
    Color numBgColor = AppColors.cardLight;
    Color numTextColor = AppColors.textSub;

    // 정답 확정 후 — 정답 옵션은 항상 초록으로 고정
    if (correctConfirmed && isCorrect) {
      borderColor = AppColors.primary;
      bgColor = const Color(0xFFEAF3E8);
      textColor = AppColors.primary;
      numBgColor = AppColors.primary;
      numTextColor = Colors.white;
    } else if (isSelected) {
      if (!_step4Evaluated) {
        // 제출 전 선택 — 중립 강조
        borderColor = AppColors.primary.withValues(alpha: 0.5);
        bgColor = const Color(0xFFF0F6EE);
        textColor = AppColors.primary;
        numBgColor = AppColors.primary.withValues(alpha: 0.5);
        numTextColor = Colors.white;
      } else if (isCorrect) {
        borderColor = AppColors.primary;
        bgColor = const Color(0xFFEAF3E8);
        textColor = AppColors.primary;
        numBgColor = AppColors.primary;
        numTextColor = Colors.white;
      } else {
        // 제출 후 오답 / 정답 확정 후 탐색 중 오답
        borderColor = const Color(0xFFE8A09A);
        bgColor = const Color(0xFFFFF2F1);
        textColor = const Color(0xFFD04B44);
        numBgColor = const Color(0xFFE8A09A);
        numTextColor = Colors.white;
      }
    }

    return GestureDetector(
      onTap: () {
        if (correctConfirmed) {
          // 정답 확정 후 — 오답 탭 시 해설 탐색 가능, 정답 탭 시 무시
          if (isCorrect) return;
          setState(() => _step4SelectedIndex = index);
          return;
        }
        setState(() {
          _step4SelectedIndex = index;
          // 오답 제출 후 재선택 시 평가 초기화
          if (_step4Evaluated && !_step4IsCorrect) _step4Evaluated = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: numBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: numTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStep4WrongExplanation(String explanation) {
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
          const Text('💭 ', style: TextStyle(fontSize: 16)),
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

  Widget _buildStep4CorrectEcho(String echo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5ECD8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('💬 ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              echo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4LeoFeedback(String feedback) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Text(
              feedback,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 제출 → 정답 확정 시 '다음으로'로 전환
  Widget _buildStep4ActionButton(FriendsStep4Data data) {
    final isConfirmed = _step4Evaluated && _step4IsCorrect;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showSuccessOverlay
            ? null
            : () {
                if (isConfirmed) {
                  _handleNext();
                } else {
                  if (_step4SelectedIndex == -1) return;
                  setState(() {
                    _step4Evaluated = true;
                    _step4IsCorrect =
                        _step4SelectedIndex == data.correctIndex;
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
            isConfirmed ? '다음으로' : '이렇게 말할게요! 💬',
            key: ValueKey(isConfirmed),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Step 5 — Leo 인사 / 학습 마무리 (EMO-23)
  // ─────────────────────────────────────────────

  Widget _buildStep5({required Key key, required FriendsStep5Data data}) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Leo 마무리 말풍선
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                  child: Text(
                    data.leoMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 사용자 차례 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                data.promptLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 작별 인사 선택지
          for (int i = 0; i < data.farewellOptions.length; i++) ...[
            _buildFarewellOption(data.farewellOptions[i], i),
            if (i < data.farewellOptions.length - 1) const SizedBox(height: 10),
          ],
          // 선택 후 로딩 또는 완료 (EMO-23)
          if (_step5SelectedIndex != -1) ...[
            const SizedBox(height: 20),
            if (_step5Loading)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DotIndicator(delay: const Duration(milliseconds: 0)),
                    const SizedBox(width: 6),
                    _DotIndicator(delay: const Duration(milliseconds: 200)),
                    const SizedBox(width: 6),
                    _DotIndicator(delay: const Duration(milliseconds: 400)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFarewellOption(String text, int index) {
    final isSelected = _step5SelectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (_step5SelectedIndex != -1) return;
        setState(() {
          _step5SelectedIndex = index;
          _step5Loading = true;
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() => _step5Loading = false);
            _handleComplete();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEBE6DF),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Placeholder (Step 미구현)
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

// 로딩 점 애니메이션 (Step 5)
class _DotIndicator extends StatefulWidget {
  final Duration delay;
  const _DotIndicator({required this.delay});

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.textSub,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
