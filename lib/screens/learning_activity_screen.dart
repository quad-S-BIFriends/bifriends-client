import 'package:flutter/material.dart';
import '../models/learning_model.dart';
import '../widgets/learning_roadmap.dart' show LevelData;
import '../theme/app_colors.dart';

class LearningActivityScreen extends StatefulWidget {
  final LevelData levelData;
  final int initialStep;
  final VoidCallback? onStepCompleted;
  final String subject;

  const LearningActivityScreen({
    super.key,
    required this.levelData,
    this.initialStep = 1,
    this.onStepCompleted,
    this.subject = 'math',
  });

  @override
  State<LearningActivityScreen> createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen> {
  late LearningStep _step;
  late int _currentCycleIdx;
  int _currentQuestionIdx = 0;
  int _hintsShown = 0;
  String? _selectedChoice;
  bool _showWrongFeedback = false;
  bool _showSuccessOverlay = false;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _step = widget.subject == 'korean'
        ? mockKoreanStepForLevel(widget.levelData.level)
        : mockStepForLevel(widget.levelData.level);
    _currentCycleIdx = (widget.initialStep - 1).clamp(
      0,
      _step.cycles.length - 1,
    );
    _answerController = TextEditingController();
    _answerController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  LearningCycle get _currentCycle => _step.cycles[_currentCycleIdx];
  int get _totalCycles => _step.cycles.length;
  bool get _isLastCycle => _currentCycleIdx >= _totalCycles - 1;
  bool get _isLastQuestion =>
      _currentQuestionIdx >= _currentCycle.questionCount - 1;

  bool get _isCurrentAnswerCorrect {
    switch (_currentCycle.type) {
      case CycleType.concept:
        return true;
      case CycleType.choice:
        final q = _currentCycle.choiceQuestions![_currentQuestionIdx];
        return _selectedChoice == q.answer;
      case CycleType.shortAnswer:
        final q = _currentCycle.shortAnswerQuestions![_currentQuestionIdx];
        return _answerController.text.trim() == q.answer;
    }
  }

  bool get _canProceed {
    switch (_currentCycle.type) {
      case CycleType.concept:
        return true;
      case CycleType.choice:
        return _selectedChoice != null;
      case CycleType.shortAnswer:
        return _answerController.text.trim().isNotEmpty &&
            _isCurrentAnswerCorrect;
    }
  }

  void _resetQuestionState() {
    _selectedChoice = null;
    _hintsShown = 0;
    _showWrongFeedback = false;
    _answerController.clear();
  }

  void _onChoiceTap(String option) {
    if (_showWrongFeedback) return;
    setState(() => _selectedChoice = option);
  }

  void _onConfirm() {
    if (!_canProceed) return;
    FocusScope.of(context).unfocus();

    if (_currentCycle.type == CycleType.choice && !_isCurrentAnswerCorrect) {
      setState(() => _showWrongFeedback = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _showWrongFeedback = false;
            _selectedChoice = null;
          });
        }
      });
      return;
    }

    if (!_isLastQuestion) {
      setState(() {
        _currentQuestionIdx++;
        _resetQuestionState();
      });
    } else if (!_isLastCycle) {
      setState(() => _showSuccessOverlay = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          widget.onStepCompleted?.call();
          setState(() {
            _showSuccessOverlay = false;
            _currentCycleIdx++;
            _currentQuestionIdx = 0;
            _resetQuestionState();
          });
        }
      });
    } else {
      widget.onStepCompleted?.call();
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
                  child: Text('🌿', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '풀 획득!',
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
                    '계속하기',
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCycleContent(
                      key: ValueKey('${_currentCycleIdx}_$_currentQuestionIdx'),
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
          if (_showSuccessOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.primary,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '와! 정말 잘했어! 🎉',
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
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
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
                    width:
                        constraints.maxWidth *
                        ((_currentCycleIdx + 1) / _totalCycles),
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
            '${_currentCycleIdx + 1}/$_totalCycles',
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

  Widget _buildCycleContent({required Key key}) {
    switch (_currentCycle.type) {
      case CycleType.concept:
        return _buildConceptSlide(key: key);
      case CycleType.choice:
        return _buildChoiceQuestion(key: key);
      case CycleType.shortAnswer:
        return _buildShortAnswerQuestion(key: key);
    }
  }

  // ── Concept slide ─────────────────────────────────────────────────────────

  Widget _buildConceptSlide({required Key key}) {
    final slide = _currentCycle.slides![_currentQuestionIdx];
    final conceptLabel = widget.subject == 'korean' ? '낱말 카드' : '개념 이야기';

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
              color: const Color(0xFFF0F8ED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              conceptLabel,
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
              color: const Color(0xFFF0F8ED),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(slide.image, style: const TextStyle(fontSize: 72)),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            slide.text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildQuestionDots(),
        ],
      ),
    );
  }

  // ── Choice question ───────────────────────────────────────────────────────

  Widget _buildChoiceQuestion({required Key key}) {
    final q = _currentCycle.choiceQuestions![_currentQuestionIdx];

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionLabel('문제 풀기'),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              q.questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: q.options
                .map((opt) => _buildChoiceOption(opt, q.answer))
                .toList(),
          ),
          const SizedBox(height: 16),
          _buildHintPanel(q.hints),
          const SizedBox(height: 8),
          _buildQuestionDots(),
        ],
      ),
    );
  }

  Widget _buildChoiceOption(String option, String correctAnswer) {
    final isSelected = _selectedChoice == option;
    final showWrong = isSelected && _showWrongFeedback;

    Color borderColor = const Color(0xFFDCD5CA);
    Color bgColor = Colors.white;
    Color textColor = AppColors.textMain;

    if (showWrong) {
      borderColor = const Color(0xFFE57373);
      bgColor = const Color(0xFFFFF3F3);
      textColor = const Color(0xFFE57373);
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = const Color(0xFFF0F8ED);
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => _onChoiceTap(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (showWrong
                            ? const Color(0xFFE57373)
                            : AppColors.primary)
                        .withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            if (showWrong)
              const Icon(
                Icons.cancel_rounded,
                color: Color(0xFFE57373),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ── Short answer question ─────────────────────────────────────────────────

  Widget _buildShortAnswerQuestion({required Key key}) {
    final q = _currentCycle.shortAnswerQuestions![_currentQuestionIdx];

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionLabel('직접 써보기'),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              q.questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                    decoration: InputDecoration(
                      hintText: '?',
                      hintStyle: const TextStyle(color: Color(0xFFDCD5CA)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFDCD5CA),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _isCurrentAnswerCorrect
                              ? AppColors.primary
                              : const Color(0xFFF3C74B),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '개',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildHintPanel(q.hints),
          const SizedBox(height: 8),
          _buildQuestionDots(),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _buildQuestionLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildQuestionDots() {
    final count = _currentCycle.questionCount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final isActive = i == _currentQuestionIdx;
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

  Widget _buildHintPanel(List<String> hints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hintsShown < hints.length)
          SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: () => setState(() => _hintsShown++),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                '💡 힌트 보기 (${hints.length - _hintsShown}개 남음)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
            ),
          ),
        for (int i = 0; i < _hintsShown; i++)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '힌트 ${i + 1}: ${hints[i]}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA07000),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isLastOverall = _isLastCycle && _isLastQuestion;
    final isConceptLast =
        _currentCycle.type == CycleType.concept && _isLastQuestion;

    final String label;
    if (isLastOverall) {
      label = '마치기';
    } else if (isConceptLast) {
      label = '이해했어요!';
    } else if (_currentCycle.type == CycleType.concept) {
      label = '다음';
    } else {
      label = _isLastQuestion ? '확인' : '확인';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      color: AppColors.background,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: (_showSuccessOverlay || !_canProceed) ? null : _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primaryDisabled,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              label,
              key: ValueKey(label),
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
