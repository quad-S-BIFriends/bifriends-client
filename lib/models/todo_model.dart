class TodoItem {
  final String title;
  final String emoji;
  final int estimatedMinutes;
  bool isCompleted;
  final int? targetTabIndex;

  TodoItem({
    required this.title,
    required this.emoji,
    required this.estimatedMinutes,
    this.isCompleted = false,
    this.targetTabIndex,
  });

  static List<TodoItem> generateDailyTodos() {
    return [
      TodoItem(
        title: '레오랑 인사하기',
        emoji: '🦫',
        estimatedMinutes: 1,
        targetTabIndex: 2,
      ),
      TodoItem(
        title: '오늘의 문제 3개 풀기',
        emoji: '📚',
        estimatedMinutes: 5,
        targetTabIndex: 1,
      ),
    ];
  }
}
