import 'package:flutter/material.dart';
import 'main_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 6;

  final TextEditingController _nameController = TextEditingController();
  int? _selectedGrade;
  final List<String> _selectedInterests = [];

  static const int _maxInterests = 3;

  final List<Map<String, String>> _interestItems = const [
    {'name': '공룡', 'emoji': '🦕'},
    {'name': '동물', 'emoji': '🐶'},
    {'name': '우주', 'emoji': '🚀'},
    {'name': '스포츠', 'emoji': '🏆'},
    {'name': 'K-POP/음악', 'emoji': '🎵'},
    {'name': '게임', 'emoji': '🎮'},
    {'name': '맛집/요리', 'emoji': '🔍'},
    {'name': '그리기/만들기', 'emoji': '🎨'},
    {'name': '과학/실험', 'emoji': '🧪'},
  ];

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScaffold(isFirstVisit: true),
        ),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  String get _userName => _nameController.text.trim();

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Color(0xFF6B4423),
                    ),
                    onPressed: _prevPage,
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: _buildProgressBar()),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildIntroPage(),
                  _buildNameInputPage(),
                  _buildNameConfirmPage(),
                  _buildGradePage(),
                  _buildInterestPage(),
                  _buildCompletionPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_totalPages, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index <= _currentPage
                  ? const Color(0xFF3D6B35)
                  : const Color(0xFFE0D8CC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // ── Shared Widgets ──

  Widget _buildSpeechBubble(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB8A590), width: 2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5C4A3A),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBeaver({double size = 90}) {
    return Text('🦫', style: TextStyle(fontSize: size));
  }

  Widget _buildUserAvatar(String initial, {Color? bgColor}) {
    final color = bgColor ?? const Color(0xFFFF69B4);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? const Color(0xFF3D6B35)
              : const Color(0xFFD5CDC3),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isActive ? onPressed : null,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ── Page 0: Intro ──

  Widget _buildIntroPage() {
    return GestureDetector(
      onTap: _nextPage,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 1),
            _buildSpeechBubble('안녕! 나는 레오야,\n우리 같이 재밌는 거 해보자! 🌟'),
            const SizedBox(height: 32),
            _buildBeaver(size: 100),
            const Spacer(flex: 1),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Onboarding step 1: Name Input ──

  Widget _buildNameInputPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          _buildSpeechBubble('불리고 싶은 이름을 적어 줘!'),
          const SizedBox(height: 32),
          _buildBeaver(size: 80),
          const Spacer(flex: 1),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB8A590), width: 1.5),
              color: Colors.white,
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C4A3A),
              ),
              decoration: const InputDecoration(
                hintText: '여기에 이름을 써줘!',
                hintStyle: TextStyle(
                  color: Color(0xFFCCC5BB),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            text: '다음',
            isActive: _userName.isNotEmpty,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Onboarding step 2: Name Confirm ──

  Widget _buildNameConfirmPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          _buildSpeechBubble('오! 이름이 $_userName이구나!\n만나서 정말 반가워! 😊'),
          const SizedBox(height: 32),
          _buildBeaver(size: 80),
          const Spacer(flex: 1),
          _buildActionButton(
            text: '나도 반가워!',
            isActive: true,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Onboarding step 3: Grade Selection ──

  Widget _buildGradePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          _buildSpeechBubble('$_userName, 몇 학년이야?'),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: List.generate(6, (index) {
              final grade = index + 1;
              final isSelected = _selectedGrade == grade;
              return GestureDetector(
                onTap: () => setState(() => _selectedGrade = grade),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3D6B35) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF3D6B35)
                          : const Color(0xFFE0D8CC),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$grade학년',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6B4423),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(flex: 1),
          _buildActionButton(
            text: '다음',
            isActive: _selectedGrade != null,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Onboarding step4 - Interest Selection ──

  Widget _buildInterestPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildSpeechBubble('뭐 좋아해? 골라봐!\n여러 개 골라도 돼 🤩'),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: _interestItems.map((item) {
                final name = item['name']!;
                final emoji = item['emoji']!;
                final isSelected = _selectedInterests.contains(name);
                final canSelect = _selectedInterests.length < _maxInterests;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(name);
                      } else if (canSelect) {
                        _selectedInterests.add(name);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE1EDDE)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3D6B35)
                            : const Color(0xFFB8A590),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF3D6B35)
                                : const Color(0xFF6B5B4E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            text: '다음',
            isActive: _selectedInterests.isNotEmpty,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Onboarding step5: Completion ──

  Widget _buildCompletionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          _buildSpeechBubble('오 좋아! 우린 꼭 잘 맞을 거야! 👋\n그럼 앞으로 잘 부탁해!'),
          const SizedBox(height: 32),
          _buildBeaver(size: 110),
          const Spacer(flex: 1),
          _buildActionButton(
            text: '시작하기 🌟',
            isActive: true,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
