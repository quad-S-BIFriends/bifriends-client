import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../widgets/falling_leaves.dart';
import '../services/member_service.dart';
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
  final int _consecutiveDays = 3;
  final int _grassCount = 150;
  final int _currentLevel = 3;
  final int _currentGrass = 150;
  final int _nextLevelGrass = 200;

  late List<TodoItem> _todos;
  final _memberService = MemberService();

  @override
  void initState() {
    super.initState();
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

  String _generateGreeting() {
    if (_consecutiveDays >= 7) {
      return '와! $_userName, $_consecutiveDays일 연속이야!\n정말 대단해! 🌟';
    } else if (_consecutiveDays >= 3) {
      return '안녕 $_userName!\n$_consecutiveDays일 연속 왔네, 멋져! 💪';
    } else {
      return '안녕 $_userName!\n오늘도 반가워! 😊';
    }
  }

  int get _completedCount => _todos.where((t) => t.isCompleted).length;

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
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              _buildGreetingSection(),
              _buildStatusChips(),
              _buildCharacterArea(),
              _buildProgressBar(),
              const SizedBox(height: 8),
              _buildTodoSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),

        Positioned(right: 20, bottom: 20, child: _buildClosetFab()),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF75A66B), Color(0xFF5D8F53)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF75A66B).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Lv.$_currentLevel',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: const Color(0xFFF0EBE1), width: 1),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF4A3E39),
                size: 22,
              ),
              onPressed: _navigateToProfile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Text(
        _generateGreeting(),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4A3E39),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildStatusChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _buildChip(
            icon: '🔥',
            label: '$_consecutiveDays일째',
            bgColor: const Color(0xFFFFF1EB),
            borderColor: const Color(0xFFFFDCC8),
          ),
          const SizedBox(width: 10),
          _buildChip(
            icon: '🌿',
            label: '$_grassCount개',
            bgColor: const Color(0xFFE4F1DF),
            borderColor: const Color(0xFFC8E0C1),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A3E39),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterArea() {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: FallingLeaves(leafCount: 6)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE4F1DF).withValues(alpha: 0.9),
                      const Color(0xFFE4F1DF).withValues(alpha: 0.2),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF75A66B).withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/leo_defaultface.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('🦫', style: TextStyle(fontSize: 72)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF0EBE1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Leo 🌟',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A3E39),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _currentGrass / _nextLevelGrass;
    final percentage = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0EBE1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '다음 레벨까지',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8D837D),
                  ),
                ),
                Text(
                  '🌿 $_currentGrass / $_nextLevelGrass',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF75A66B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8BC34A), Color(0xFF75A66B)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF75A66B).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF75A66B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosetFab() {
    return GestureDetector(
      onTap: _navigateToCloset,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF3C74B), Color(0xFFF07D4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF07D4F).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: Text('👔', style: TextStyle(fontSize: 24))),
      ),
    );
  }

  Widget _buildTodoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF75A66B),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '오늘의 할 일',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF75A66B),
                    ),
                  ),
                ],
              ),
              Text(
                '$_completedCount / ${_todos.length} 완료',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB1AA9E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(_todos.length, (index) {
            final todo = _todos[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _todos.length - 1 ? 10 : 0,
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: todo.isCompleted ? const Color(0xFFF0F8ED) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: todo.isCompleted ? 0.01 : 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: todo.isCompleted
                ? const Color(0xFFC8E0C1)
                : const Color(0xFFF0EBE1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(todo.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: todo.isCompleted
                          ? const Color(0xFFB1AA9E)
                          : const Color(0xFF4A3E39),
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: const Color(0xFFB1AA9E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '약 ${todo.estimatedMinutes}분',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB1AA9E),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: todo.isCompleted
                  ? const Icon(
                      Icons.check_circle,
                      key: ValueKey('checked'),
                      color: Color(0xFF75A66B),
                      size: 26,
                    )
                  : Container(
                      key: const ValueKey('unchecked'),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFDCD5CA),
                          width: 2,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
