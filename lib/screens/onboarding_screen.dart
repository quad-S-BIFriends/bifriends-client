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

  int? _selectedGrade;
  final List<String> _selectedInterests = [];

  final List<String> _interests = ['수학', '과학', '미술', '음악', '운동', '독서'];
  final Map<String, String> _interestIcons = {
    '수학': '📘',
    '과학': '🧪',
    '미술': '🎨',
    '음악': '🎵',
    '운동': '⚽️',
    '독서': '📚',
  };

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finish onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScaffold()),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EB),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A3E39), size: 20),
                      onPressed: _prevPage,
                    )
                  else
                    const SizedBox(width: 48, height: 48), // Placeholder
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildGradePage(),
                  _buildInterestPage(),
                ],
              ),
            ),
            _buildBottomFadedNavPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          const Text('🦫', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 32),
          const Text(
            '안녕! 나는 카피바라야!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4A3E39),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '너의 공부 친구가 되어줄게.\n먼저 나에 대해 조금 알려줄래?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8D837D),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 1),
          _buildActionButton(
            text: '시작하기 ->',
            isActive: true,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGradePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🎓 ', style: TextStyle(fontSize: 20)),
              Text(
                '지금 몇 학년이야?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A3E39),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(6, (index) {
              final grade = index + 1;
              final isSelected = _selectedGrade == grade;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGrade = grade;
                  });
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF75A66B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      grade.toString(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : const Color(0xFF4A3E39),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(flex: 1),
          _buildActionButton(
            text: '다음으로 ->',
            isActive: _selectedGrade != null,
            onPressed: _selectedGrade != null ? _nextPage : () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInterestPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🤍 ', style: TextStyle(fontSize: 20)),
              Text(
                '무엇을 좋아해?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A3E39),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '좋아하는 걸 모두 골라줘! (여러 개 가능)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8D837D),
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _interests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF8A7761) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_interestIcons[interest]!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        interest,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : const Color(0xFF4A3E39),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(flex: 1),
          _buildActionButton(
            text: '준비 끝! ✨',
            isActive: _selectedInterests.isNotEmpty,
            onPressed: _selectedInterests.isNotEmpty ? _nextPage : () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String text, required bool isActive, required VoidCallback onPressed}) {
    return SizedBox(
      width: 200, // Matching the fixed width look in design
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFF75A66B) : const Color(0xFFDCD5CA),
          foregroundColor: isActive ? Colors.white : const Color(0xFF8D837D),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFadedNavPlaceholder() {
    // Mimicking the faded bottom bar shown in the design edge.
    return Opacity(
      opacity: 0.3,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Icon(Icons.home_outlined, color: Colors.grey),
            Icon(Icons.menu_book_outlined, color: Colors.grey),
            Icon(Icons.chat_bubble_outline, color: Colors.grey),
            Icon(Icons.card_giftcard_outlined, color: Colors.grey),
            Icon(Icons.person_outline, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
