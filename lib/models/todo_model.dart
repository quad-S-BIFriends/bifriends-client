enum TodoType { greeting, learning, chat, report, heart }

class TodoItem {
  final String id;
  final String title;
  final String emoji;
  final int estimatedMinutes;
  final TodoType type;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.emoji,
    required this.estimatedMinutes,
    required this.type,
    this.isCompleted = false,
  });

  static List<TodoItem> generateDailyTodos() {
    return [
      TodoItem(
        id: 'daily_greeting',
        title: '레오랑 인사하기',
        emoji: '🦫',
        estimatedMinutes: 1,
        type: TodoType.greeting,
      ),
      TodoItem(
        id: 'daily_learning',
        title: '오늘의 배움 시작하기',
        emoji: '📚',
        estimatedMinutes: 10,
        type: TodoType.learning,
      ),
      TodoItem(
        id: 'daily_chat',
        title: 'AI와 대화하기',
        emoji: '💬',
        estimatedMinutes: 5,
        type: TodoType.chat,
      ),
    ];
  }

  int? get targetTabIndex {
    switch (type) {
      case TodoType.learning:
        return 1;
      case TodoType.chat:
        return 2;
      case TodoType.report:
        return 3;
      case TodoType.heart:
        return 4;
      case TodoType.greeting:
        return null;
    }
  }
}
