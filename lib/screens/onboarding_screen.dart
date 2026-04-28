import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_scaffold.dart';

class SpeechBubbleShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.only(bottom: 16);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height - 16),
      const Radius.circular(20),
    );
    final path = Path()..addRRect(rrect);

    path.moveTo(rect.left + 30, rect.bottom - 16);
    path.lineTo(rect.left + 35, rect.bottom);
    path.lineTo(rect.left + 45, rect.bottom - 16);
    path.close();

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

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
  String? _selectedGift;

  static const int _maxInterests = 3;

  final List<Map<String, dynamic>> _interestItems = const [
    {'name': '운동', 'icon': Icons.fitness_center},
    {'name': '음악', 'icon': Icons.music_note},
    {'name': '게임', 'icon': Icons.sports_esports},
    {'name': '공부', 'icon': Icons.menu_book},
    {'name': '그림', 'icon': Icons.palette},
    {'name': '책', 'icon': Icons.book},
  ];

  final List<Map<String, dynamic>> _giftItems = const [
    {'id': 'hat', 'name': '모자', 'icon': Icons.adjust},
    {'id': 'top_hat', 'name': '정장\n모자', 'icon': Icons.auto_awesome},
    {'id': 'crown', 'name': '왕관', 'icon': Icons.workspace_premium},
    {'id': 'flower', 'name': '꽃', 'icon': Icons.filter_vintage},
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

      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildNameInputPage(),
                  _buildGradePage(),
                  _buildInterestPage(),
                  _buildGreetingPage(),
                  _buildGiftPage(),
                  _buildFinalPage(),
                ],
              ),
            ),
            if (_currentPage > 0)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Color(0xFF5C4A3A),
                  ),
                  onPressed: _prevPage,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasJongseong(String str) {
    if (str.isEmpty) return false;
    final lastChar = str.runes.last;
    if (lastChar < 0xAC00 || lastChar > 0xD7A3) return false;
    return (lastChar - 0xAC00) % 28 > 0;
  }

  Widget _buildTopProgressBar(int step) {
    final progress = (step + 1) / 5;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 16),
      child: Container(
        height: 6,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEAE5DB),
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8B7D6B),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 36),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: SpeechBubbleShape(),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.gaegu(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5C4A3A),
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildCharacter({double size = 120, String? overrideImage}) {
    final String assetPath = overrideImage ?? 'assets/images/leo_default.png';
    return SizedBox(
      height: size,
      width: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text('🦫', style: TextStyle(fontSize: size * 0.8)),
          );
        },
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
              ? const Color(0xFF738A58)
              : const Color(0xFFC5D4B6),
          foregroundColor: Colors.white,
          elevation: isActive ? 4 : 0,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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

  Widget _buildPageWrapper({
    required int step,
    required Widget child,
    required String buttonText,
    required bool buttonActive,
    required VoidCallback onButtonPressed,
    bool showProgressBar = true,
  }) {
    return Column(
      children: [
        const SizedBox(height: 48),
        if (showProgressBar) _buildTopProgressBar(step),
        Expanded(child: child),
        _buildActionButton(
          text: buttonText,
          isActive: buttonActive,
          onPressed: onButtonPressed,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNameInputPage() {
    return _buildPageWrapper(
      step: 0,
      buttonText: '다음',
      buttonActive: _userName.isNotEmpty,
      onButtonPressed: _nextPage,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildCharacter(size: 100),
          const SizedBox(height: 12),
          _buildSpeechBubble('불리고 싶은 이름을 적어줘!'),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                hintText: '닉네임 입력',
                hintStyle: TextStyle(
                  color: Color(0xFFCCC5BB),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGradePage() {
    return _buildPageWrapper(
      step: 1,
      buttonText: '다음',
      buttonActive: _selectedGrade != null,
      onButtonPressed: _nextPage,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildCharacter(size: 100),
          const SizedBox(height: 12),
          _buildSpeechBubble('너는 몇 학년이야?'),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: List.generate(6, (index) {
              final grade = index + 1;
              final isSelected = _selectedGrade == grade;
              return GestureDetector(
                onTap: () => setState(() => _selectedGrade = grade),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF4EFE7) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF738A58)
                          : const Color(0xFFE5DED5),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$grade',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF738A58)
                            : const Color(0xFF5C4A3A),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildInterestPage() {
    return _buildPageWrapper(
      step: 2,
      buttonText: '다음',
      buttonActive: _selectedInterests.isNotEmpty,
      onButtonPressed: _nextPage,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            '어떤 걸 좋아해?',
            style: GoogleFonts.gaegu(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5C4A3A),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: _interestItems.map((item) {
                final name = item['name'] as String;
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
                          ? const Color(0xFF8B7D6B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8B7D6B)
                            : const Color(0xFFE5DED5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 32,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF5C4A3A),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF5C4A3A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingPage() {
    final displayName = _userName.isEmpty ? '친구' : _userName;
    final particle = _hasJongseong(displayName) ? '이구나' : '구나';
    return _buildPageWrapper(
      step: 3,
      buttonText: '나도 반가워!',
      buttonActive: true,
      onButtonPressed: _nextPage,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSpeechBubble('오! 이름이 $displayName$particle!\n만나서 정말 반가워! 😊'),
          const Spacer(),
          _buildCharacter(size: 140),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGiftPage() {
    final displayName = _userName.isEmpty ? '친구' : _userName;
    final particle = _hasJongseong(displayName) ? '아' : '야';
    String? currentImage;
    if (_selectedGift != null) {
      currentImage = 'assets/images/leo_${_selectedGift}.png';
    }
    return _buildPageWrapper(
      step: 4,
      buttonText: '이걸로 할래!',
      buttonActive: _selectedGift != null,
      onButtonPressed: _nextPage,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSpeechBubble('$displayName$particle,\n나한테 선물 하나만 골라줘!'),
          const Spacer(),
          _buildCharacter(size: 140, overrideImage: currentImage),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _giftItems.map((item) {
              final isSelected = _selectedGift == item['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedGift = item['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE5E9D8)
                        : const Color(0xFFF4EFE7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF738A58)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 28,
                        color: isSelected
                            ? const Color(0xFF5C4A3A)
                            : const Color(0xFF8B7D6B),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF5C4A3A)
                              : const Color(0xFF8B7D6B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFinalPage() {
    final displayName = _userName.isEmpty ? '친구' : _userName;
    final particle = _hasJongseong(displayName) ? '이의' : '의';
    String? finalImage;
    if (_selectedGift != null) {
      finalImage = 'assets/images/leo_${_selectedGift}.png';
    }
    return _buildPageWrapper(
      step: 5,
      showProgressBar: false,
      buttonText: '응, 좋아!',
      buttonActive: true,
      onButtonPressed: _nextPage,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSpeechBubble(
            '부모님께도 매주 $displayName$particle 언어\n발달 소식을 알려드릴게!\n부모님이 정말 좋아하실 거야! 😊',
          ),
          const Spacer(),
          _buildCharacter(size: 140, overrideImage: finalImage),
          const Spacer(),
          const Text(
            '처음에 입력된 부모님 번호로 소식을 보내드릴게!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8B7D6B),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
