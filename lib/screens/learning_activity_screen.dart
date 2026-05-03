import 'package:flutter/material.dart';
import '../widgets/learning_roadmap.dart' show LevelData;
import '../theme/app_colors.dart';

class LearningActivityScreen extends StatefulWidget {
  final LevelData levelData;

  const LearningActivityScreen({super.key, required this.levelData});

  @override
  State<LearningActivityScreen> createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen> {
  int _currentStep = 1;
  final int _totalSteps = 5;
  bool _showSuccessOverlay = false;

  // --- (Learning) Interaction States ---
  // Step 2
  final List<String> _sentenceOptions = ['사과를', '좋아해요', '나는'];
  final List<String> _selectedSentence = [];

  // Step 3
  String? _selectedParticle;

  // Step 4
  bool _isRecording = false;
  bool _hasReadVoice = false;

  // Step 5
  late TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController();
    _countController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  // mock data
  bool get _isStepComplete {
    switch (_currentStep) {
      case 1:
        return true;
      case 2:
        return _selectedSentence.join(' ') == '나는 사과를 좋아해요';
      case 3:
        return _selectedParticle == '가';
      case 4:
        return _hasReadVoice;
      case 5:
        return _countController.text.trim() == '3';
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_isStepComplete) return;

    if (_currentStep < _totalSteps) {
      FocusScope.of(context).unfocus();
      setState(() {
        _showSuccessOverlay = true;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showSuccessOverlay = false;
            _currentStep++;
          });
        }
      });
    } else {
      _showRewardDialog();
    }
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
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
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentContent(key: ValueKey(_currentStep)),
                  ),
                ),
                _buildBottomBar(),
              ],
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
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF75A66B,
                                ).withValues(alpha: 0.2),
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
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 10,
                      width:
                          constraints.maxWidth * (_currentStep / _totalSteps),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$_currentStep/$_totalSteps',
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

  Widget _buildCurrentContent({required Key key}) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Observe(key: key);
      case 2:
        return _buildStep2Sentence(key: key);
      case 3:
        return _buildStep3Select(key: key);
      case 4:
        return _buildStep4Read(key: key);
      case 5:
        return _buildStep5Count(key: key);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepContainer({
    required Key key,
    required String title,
    required Widget child,
  }) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }

  // Step 1: 단어 구성 보기
  Widget _buildStep1Observe({required Key key}) {
    return _buildStepContainer(
      key: key,
      title: '단어를 살펴봐요',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🍎', style: TextStyle(fontSize: 80)),
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildTag('사과'),
              _buildTag('빨간색'),
              _buildTag('맛있는'),
              _buildTag('과일'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCD5CA), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textSub,
        ),
      ),
    );
  }

  // Step 2: 문장 만들기
  Widget _buildStep2Sentence({required Key key}) {
    return _buildStepContainer(
      key: key,
      title: '문장을 만들어봐요',
      child: Column(
        children: [
          // Target box
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFF3C74B),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_selectedSentence.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      '아래 단어를 순서대로 탭하세요',
                      style: TextStyle(color: AppColors.textSub, fontSize: 14),
                    ),
                  ),
                for (final word in _selectedSentence)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSentence.remove(word);
                      });
                    },
                    child: _buildSentenceChip(word, isLight: false),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final word in _sentenceOptions)
                GestureDetector(
                  onTap: _selectedSentence.contains(word)
                      ? null
                      : () {
                          setState(() {
                            _selectedSentence.add(word);
                          });
                        },
                  child: Opacity(
                    opacity: _selectedSentence.contains(word) ? 0.3 : 1.0,
                    child: _buildSentenceChip(word, isLight: true),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceChip(String text, {required bool isLight}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFFF9F7F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? const Color(0xFFDCD5CA) : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.textMain : AppColors.primary,
        ),
      ),
    );
  }

  // Step 3: 알맞은 단어(조사) 고르기
  Widget _buildStep3Select({required Key key}) {
    return _buildStepContainer(
      key: key,
      title: '알맞은 단어를 골라봐요',
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Text(
                '사과',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              Container(
                width: 60,
                height: 48,
                decoration: BoxDecoration(
                  color: _selectedParticle != null
                      ? const Color(0xFFE4F1DF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedParticle != null
                        ? AppColors.primary
                        : const Color(0xFFDCD5CA),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _selectedParticle ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const Text(
                '맛있어요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectionButton('가'),
              const SizedBox(width: 16),
              _buildSelectionButton('를'),
              const SizedBox(width: 16),
              _buildSelectionButton('은'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(String text) {
    final bool isSelected = _selectedParticle == text;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedParticle = text);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFDCD5CA),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }

  // Step 4: 문장 말해보기 (STT 미구현)
  Widget _buildStep4Read({required Key key}) {
    return _buildStepContainer(
      key: key,
      title: '큰 소리로 읽어봐요',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EB),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFDCC8), width: 1),
            ),
            child: const Text(
              '나는 빨간 사과를 좋아해요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF07D4F),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          GestureDetector(
            onLongPressStart: (_) {
              setState(() => _isRecording = true);
            },
            onLongPressEnd: (_) {
              setState(() {
                _isRecording = false;
                _hasReadVoice = true;
              });
            },
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('마이크 버튼을 꾹 누르고 말해보세요!')),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isRecording ? 90 : 80,
              height: _isRecording ? 90 : 80,
              decoration: BoxDecoration(
                color: _hasReadVoice
                    ? AppColors.textMain
                    : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  if (_isRecording)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 10,
                    )
                  else
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                ],
              ),
              child: Icon(
                _hasReadVoice ? Icons.check : Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _hasReadVoice ? '정말 잘 읽었어요!' : '마이크를 길게 누르고 읽어보세요',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _hasReadVoice
                  ? AppColors.primary
                  : AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  // Step 5: 개수 세어보기
  Widget _buildStep5Count({required Key key}) {
    return _buildStepContainer(
      key: key,
      title: '사과가 몇 개 있나요?',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF3C74B), width: 1),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🍎', style: TextStyle(fontSize: 48)),
                SizedBox(width: 10),
                Text('🍎', style: TextStyle(fontSize: 48)),
                SizedBox(width: 10),
                Text('🍎', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
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
                  borderSide: const BorderSide(
                    color: Color(0xFFF3C74B),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool canProceed = _isStepComplete;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: (_showSuccessOverlay || !canProceed) ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Text(
            _currentStep < _totalSteps ? '확인' : '마치기',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
