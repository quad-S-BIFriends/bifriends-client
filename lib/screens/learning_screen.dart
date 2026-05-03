import 'package:flutter/material.dart';
import '../widgets/learning_roadmap.dart';
import '../theme/app_colors.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'title': '생각하는 힘\n키우기', 'icon': '🧠', 'locked': false},
    {'title': '말하는 힘\n키우기', 'icon': '🗣️', 'locked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildCategorySelector(),
            Expanded(
              child: _selectedCategoryIndex == 0
                  ? const LearningRoadmap()
                  : const Center(
                      child: Text(
                        '준비 중인 과정입니다 🔒',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSub,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 힘을 키워볼까?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '하나의 엔진이 켜져있어 💡',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final bool isSelected = _selectedCategoryIndex == index;
          final bool isLocked = category['locked'];

          return GestureDetector(
            onTap: () {
              if (!isLocked) {
                setState(() => _selectedCategoryIndex = index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 130,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF7E2) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF3C74B)
                      : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? const Color(0xFFF5F3ED)
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: isLocked
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Text(
                          category['icon'],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      if (isLocked)
                        const Icon(
                          Icons.lock,
                          color: Color(0xFFDCD5CA),
                          size: 18,
                        )
                      else if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFF3C74B),
                          size: 20,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isLocked ? AppColors.textSub : AppColors.textMain,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
