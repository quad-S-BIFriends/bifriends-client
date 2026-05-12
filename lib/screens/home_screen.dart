import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';
import '../widgets/falling_leaves.dart';
import '../services/member_service.dart';
import '../services/home_service.dart';
import '../theme/app_colors.dart';
import 'closet_screen.dart';
import 'my_info_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '친구';
  String? _representativeItemType;
  int _consecutiveDays = 0;
  int _currentLevel = 1;
  int _availablePool = 0;
  int _currentLevelProgress = 0;
  int _totalPoolForLevelUp = 1000;
  int _poolNeededForNextLevel = 1000;

  late List<TodoItem> _todos;
  final _memberService = MemberService();
  final _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    _todos = [];
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchHomeData(), _fetchUserInfo()]);
  }

  Future<void> _fetchHomeData() async {
    try {
      final home = await _homeService.getHome();
      if (mounted) {
        setState(() {
          _userName = home.member.nickname;
          _consecutiveDays = home.stats.streakDays;
          _currentLevel = home.stats.level;
          _availablePool = home.stats.availablePool;
          _currentLevelProgress = home.stats.currentLevelProgress;
          _totalPoolForLevelUp = home.stats.totalPoolForCurrentLevelUp;
          _poolNeededForNextLevel = home.stats.poolNeededForNextLevel;
          _todos = home.todos.map(TodoItem.fromResponse).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _todos = TodoItem.generateDailyTodos();
        });
      }
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      final member = await _memberService.getMe();
      if (mounted) {
        setState(() {
          // Home API 실패 시 fallback으로 이름 설정
          if (_userName == '친구') {
            _userName = member.nickname ?? member.name;
          }
          _representativeItemType = member.representativeItemType;
        });
      }
    } catch (_) {}
  }

  Future<void> _completeTodoSafely(TodoItem todo) async {
    try {
      await _homeService.completeTodo(todo.id!);
    } catch (_) {
      if (mounted) setState(() => todo.isCompleted = false);
    }
  }

  void _handleTodoTap(TodoItem todo) {
    if (todo.isCompleted) return;

    setState(() => todo.isCompleted = true);

    if (todo.id != null) {
      _completeTodoSafely(todo);
    }

    if (todo.targetTabIndex != null) {
      widget.onNavigateToTab?.call(todo.targetTabIndex!);
    }
  }

  void _showTodoSheet({TodoItem? existing}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TodoSheet(
        existing: existing,
        onSave: (title, minutes) async {
          Navigator.pop(ctx);
          if (existing == null) {
            await _createTodo(title, minutes);
          } else {
            await _updateTodo(existing, title, minutes);
          }
        },
      ),
    );
  }

  Future<void> _createTodo(String title, int estimatedMinutes) async {
    final localTodo = TodoItem(
      title: title,
      emoji: '',
      estimatedMinutes: estimatedMinutes,
      isUserCreated: true,
    );
    setState(() => _todos.add(localTodo));

    try {
      final saved = await _homeService.createTodo(
        title: title,
        estimatedMinutes: estimatedMinutes,
      );
      if (mounted) {
        setState(() {
          final idx = _todos.indexOf(localTodo);
          if (idx >= 0) _todos[idx] = saved;
        });
      }
    } catch (_) {
      // BE 미구현 구간에서는 로컬 항목 유지
    }
  }

  Future<void> _updateTodo(
      TodoItem todo, String title, int estimatedMinutes) async {
    final idx = _todos.indexOf(todo);
    final updated = TodoItem(
      id: todo.id,
      title: title,
      emoji: todo.emoji,
      estimatedMinutes: estimatedMinutes,
      isCompleted: todo.isCompleted,
      isUserCreated: true,
    );
    setState(() => _todos[idx] = updated);

    try {
      if (todo.id != null) {
        await _homeService.updateTodo(
          todoId: todo.id!,
          title: title,
          estimatedMinutes: estimatedMinutes,
        );
      }
    } catch (_) {
      // BE 미구현 구간에서는 로컬 변경 유지
    }
  }

  Future<void> _deleteTodo(TodoItem todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _DeleteConfirmDialog(todoTitle: todo.title),
    );
    if (confirmed != true) return;

    final idx = _todos.indexOf(todo);
    setState(() => _todos.removeAt(idx));

    try {
      if (todo.id != null) {
        await _homeService.deleteTodo(todo.id!);
      }
    } catch (_) {
      // BE 미구현 구간에서는 로컬 삭제 유지
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyInfoScreen()),
    );
  }

  String _getCharacterImagePath() {
    const imageMap = {
      'GIFT_1': 'assets/images/leo_studying.png',
      'GIFT_2': 'assets/images/leo_ribbon.png',
      'GIFT_3': 'assets/images/leo_flower.png',
      'GIFT_4': 'assets/images/leo_sunglasses.png',
      'GIFT_5': 'assets/images/leo_dinosaur.png',
      'GIFT_6': 'assets/images/leo_scientist.png',
      'GIFT_7': 'assets/images/leo_singer.png',
    };
    return imageMap[_representativeItemType] ?? 'assets/images/leo_default.png';
  }

  void _navigateToCloset() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClosetScreen(
          initialAvailablePool: _availablePool,
          initialRepresentativeItemType: _representativeItemType,
        ),
      ),
    ).then((_) => _fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(left: 24.0, right: 8.0),
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
            label: '${formatCurrency.format(_availablePool)}개',
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
              _getCharacterImagePath(),
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
    final double progress = _totalPoolForLevelUp > 0
        ? (_currentLevelProgress / _totalPoolForLevelUp)
        : 0.0;

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
                    text: '$_poolNeededForNextLevel',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘의 할 일',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              GestureDetector(
                onTap: () => _showTodoSheet(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '추가',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_todos.length, (index) {
            final todo = _todos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            if (todo.isUserCreated) ...[
              const SizedBox(width: 4),
              _buildTodoAction(
                icon: Icons.edit_outlined,
                onTap: () => _showTodoSheet(existing: todo),
              ),
              const SizedBox(width: 2),
              _buildTodoAction(
                icon: Icons.delete_outline,
                onTap: () => _deleteTodo(todo),
                isDestructive: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTodoAction({
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: isDestructive
              ? Colors.red.shade300
              : AppColors.textSub,
        ),
      ),
    );
  }
}

class _TodoSheet extends StatefulWidget {
  final TodoItem? existing;
  final void Function(String title, int estimatedMinutes) onSave;

  const _TodoSheet({this.existing, required this.onSave});

  @override
  State<_TodoSheet> createState() => _TodoSheetState();
}

class _TodoSheetState extends State<_TodoSheet> {
  late final TextEditingController _titleController;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing?.title ?? '');
    _minutes = widget.existing?.estimatedMinutes ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final canSave = _titleController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? '할 일 수정하기' : '할 일 추가하기',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _titleController,
                autofocus: true,
                maxLength: 40,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
                decoration: const InputDecoration(
                  hintText: '할 일을 입력해 주세요',
                  hintStyle: TextStyle(color: AppColors.textSub),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.textSub),
                const SizedBox(width: 8),
                const Text(
                  '예상 시간',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                const Spacer(),
                _StepperButton(
                  icon: Icons.remove,
                  onTap: _minutes > 1
                      ? () => setState(() => _minutes--)
                      : null,
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '$_minutes분',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  onTap: _minutes < 60
                      ? () => setState(() => _minutes++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSave
                    ? () => widget.onSave(
                          _titleController.text.trim(),
                          _minutes,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryDisabled,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEdit ? '수정하기' : '추가하기',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.cardLight : AppColors.borderLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.textMain : AppColors.textSub,
        ),
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  final String todoTitle;

  const _DeleteConfirmDialog({required this.todoTitle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDED),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFFE53935),
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '정말 삭제할까? 😮',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '"$todoTitle"\n미션을 목록에서 지울게!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSub,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '아니, 둘래',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSub,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '응, 삭제해줘!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
