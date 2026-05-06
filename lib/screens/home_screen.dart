import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';
import '../widgets/falling_leaves.dart';
import '../services/member_service.dart';
import '../theme/app_colors.dart';
import 'closet_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '친구';
  bool _isLoadingUser = true;
  final int _consecutiveDays = 7;
  final int _currentLevel = 3;
  final int _currentGrass = 1250;
  final int _nextLevelGrass = 1500;

  late List<TodoItem> _todos;
  final _memberService = MemberService();

  @override
  void initState() {
    super.initState();
    // Todo나 레벨 등의 학습 상태 데이터는 API 연동 전까지 Mock 데이터 유지
    _todos = TodoItem.generateDailyTodos();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final member = await _memberService.getMe();
      if (mounted) {
        setState(() {
          _userName = member.nickname ?? member.name;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  void _handleTodoTap(TodoItem todo) {
    if (todo.isCompleted) return;

    if (todo.targetTabIndex != null) {
      widget.onNavigateToTab?.call(todo.targetTabIndex!);
      setState(() => todo.isCompleted = true);
    } else {
      setState(() => todo.isCompleted = true);
    }
  }

  void _navigateToProfile() {
    widget.onNavigateToTab?.call(3);
  }

  void _navigateToCloset() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClosetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            _buildHeader(),
            _buildStatusChips(),
            _buildCharacterArea(),
            _buildProgressBar(),
            const SizedBox(height: 24),
            _buildTodoSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lv. $_currentLevel',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.gaegu(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSub,
                  ),
                  children: [
                    const TextSpan(text: '안녕, '),
                    TextSpan(
                      text: _userName,
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    const TextSpan(text: '! 오늘도 반가워 🦫'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSub,
              size: 28,
            ),
            onPressed: _navigateToProfile,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    final formatCurrency = NumberFormat('#,###');
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _buildChip(icon: '🔥', label: '$_consecutiveDays일 연속'),
          const SizedBox(width: 10),
          _buildChip(
            icon: '🌱',
            label: '${formatCurrency.format(_currentGrass)}개',
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required String icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterArea() {
    return SizedBox(
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: FallingLeaves(leafCount: 4)),

          Positioned(
            bottom: 20,
            child: Image.asset(
              'assets/images/leo_flower.png',
              height: 260,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('🦫', style: TextStyle(fontSize: 120)),
            ),
          ),

          Positioned(
            right: 40,
            bottom: 30,
            child: GestureDetector(
              onTap: _navigateToCloset,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.checkroom,
                      color: AppColors.textSub,
                      size: 32,
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D150),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
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

  Widget _buildProgressBar() {
    final int requiredGrass = _nextLevelGrass - _currentGrass;
    final double progress = _currentGrass / _nextLevelGrass;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '다음 레벨까지',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Lv.$_currentLevel → Lv.${_currentLevel + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight, width: 1),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSub,
                ),
                children: [
                  TextSpan(text: 'Lv.${_currentLevel + 1}까지 '),
                  TextSpan(
                    text: '$requiredGrass',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const TextSpan(text: '개의 풀이 더 필요해! 🌱'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 할 일',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_todos.length, (index) {
            final todo = _todos[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _todos.length - 1 ? 12 : 0,
              ),
              child: _buildTodoCard(todo),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTodoCard(TodoItem todo) {
    return GestureDetector(
      onTap: () => _handleTodoTap(todo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: todo.isCompleted
                  ? const Icon(
                      Icons.check_circle,
                      key: ValueKey('checked'),
                      color: AppColors.primary,
                      size: 28,
                    )
                  : Container(
                      key: const ValueKey('unchecked'),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFDCD5CA),
                          width: 2.5,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${todo.title} ${todo.emoji}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: todo.isCompleted
                          ? AppColors.textSub
                          : AppColors.textMain,
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textSub,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppColors.textSub,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '약 ${todo.estimatedMinutes}분 소요',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
