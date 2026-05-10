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
  int _currentStep = 0; // 0-indexed: 0=Step1, 1=Step2, ...
  bool _showSuccessOverlay = false;

  FriendsActivityData get _data => widget.data ?? _mockData;

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
                  _buildBearRow(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
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
              width:
                  constraints.maxWidth * (_currentStep + 1) / _totalSteps,
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

  Widget _buildCurrentStep({required Key key}) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Card(key: key);
      default:
        return _buildComingSoonPlaceholder(
          key: key,
          stepLabel: 'Step ${_currentStep + 1}',
        );
    }
  }

  // Step 1: 관용 표현 + 감정 단어 + 신체 감각 설명 + 상황 예시 (EMO-06)
  Widget _buildStep1Card({required Key key}) {
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
            // 관용 표현
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
            const SizedBox(height: 20),
            _buildSectionBlock(
              label: '우리 몸의 느낌',
              content: exp.bodyFeeling,
            ),
            const SizedBox(height: 16),
            // 상황 예시
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
                  disabledBackgroundColor: AppColors.textMain.withValues(alpha: 0.5),
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

  Widget _buildComingSoonPlaceholder({required Key key, required String stepLabel}) {
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

  // TODO: BE 연동 시 imageUrl 사용 (감정 단서가 잘 보이는 상반신 캐릭터 이미지)
  Widget _buildCharacterImage(String? imageUrl) {
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
}
