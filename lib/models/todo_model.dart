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
        title: '새로운 단어 3개 배우기',
        emoji: '📚',
        estimatedMinutes: 10,
        targetTabIndex: 1,
      ),
      TodoItem(
        title: '오늘의 감정 이야기하기',
        emoji: '💬',
        estimatedMinutes: 5,
        targetTabIndex: 2,
      ),
      TodoItem(
        title: '심호흡하며 휴식하기',
        emoji: '🧘',
        estimatedMinutes: 5,
      ),
    ];
  }
}
