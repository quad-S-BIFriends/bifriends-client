import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'guardian_mission_model.dart';

enum ChatSafetyLevel { green, yellow, red }

extension ChatSafetyLevelExt on ChatSafetyLevel {
  String get label {
    switch (this) {
      case ChatSafetyLevel.green:
        return 'Green';
      case ChatSafetyLevel.yellow:
        return 'Yellow';
      case ChatSafetyLevel.red:
        return 'Red';
    }
  }

  String get defaultDescription {
    switch (this) {
      case ChatSafetyLevel.green:
        return '아이가 정서적으로 안정된 상태에서 학습에 참여하고 있습니다.';
      case ChatSafetyLevel.yellow:
        return '일부 활동에서 감정 기복이 관찰되었어요. 가벼운 대화로 기분을 확인해 주세요.';
      case ChatSafetyLevel.red:
        return '부정적인 감정 표현이 반복 감지되었어요. 학교나 친구 관계에서 어려움이 있는지 따뜻하게 여쭤봐 주세요.';
    }
  }

  static ChatSafetyLevel fromString(String value) {
    switch (value.toUpperCase()) {
      case 'YELLOW':
        return ChatSafetyLevel.yellow;
      case 'RED':
        return ChatSafetyLevel.red;
      default:
        return ChatSafetyLevel.green;
    }
  }

  Color get color {
    switch (this) {
      case ChatSafetyLevel.green:
        return const Color(0xFF4CAF50);
      case ChatSafetyLevel.yellow:
        return const Color(0xFFFFB300);
      case ChatSafetyLevel.red:
        return const Color(0xFFE53935);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ChatSafetyLevel.green:
        return const Color(0xFFE8F5F0);
      case ChatSafetyLevel.yellow:
        return const Color(0xFFFFF8E1);
      case ChatSafetyLevel.red:
        return const Color(0xFFFFEBEE);
    }
  }

  Color get borderColor {
    switch (this) {
      case ChatSafetyLevel.green:
        return const Color(0xFF80CBC4);
      case ChatSafetyLevel.yellow:
        return const Color(0xFFFFCC80);
      case ChatSafetyLevel.red:
        return const Color(0xFFEF9A9A);
    }
  }
}

class ReportSummary {
  final int reportId;
  final String weekStart;
  final String weekEnd;
  final ChatSafetyLevel safetySignal;
  final bool hasMission;

  const ReportSummary({
    required this.reportId,
    required this.weekStart,
    required this.weekEnd,
    required this.safetySignal,
    required this.hasMission,
  });

  String get weekRange => _formatRange(weekStart, weekEnd);

  static String _formatRange(String start, String end) {
    try {
      final s = DateTime.parse(start);
      final e = DateTime.parse(end);
      return '${s.month}월 ${s.day}일 ~ ${e.month}월 ${e.day}일';
    } catch (_) {
      return '$start ~ $end';
    }
  }

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
    reportId: json['reportId'] as int,
    weekStart: json['weekStart'] as String,
    weekEnd: json['weekEnd'] as String,
    safetySignal:
        ChatSafetyLevelExt.fromString(json['safetySignal'] as String? ?? ''),
    hasMission: json['hasMission'] as bool? ?? false,
  );
}

class GrowthSection {
  final String summary;
  final String? parentTip;

  const GrowthSection({required this.summary, this.parentTip});

  factory GrowthSection.fromJson(Map<String, dynamic> json) => GrowthSection(
    summary: json['summary'] as String,
    parentTip: json['parentTip'] as String?,
  );
}

class LearningPattern {
  final List<int> learningDays; // 1=월 ~ 7=일 (ISO weekday)
  final int completedTodoCount;

  const LearningPattern({
    required this.learningDays,
    required this.completedTodoCount,
  });

  static const allDayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  // 1-indexed: 1=월, 7=일
  bool isDayActive(int isoWeekday) => learningDays.contains(isoWeekday);

  factory LearningPattern.fromJson(Map<String, dynamic> json) => LearningPattern(
    learningDays: (json['learningDays'] as List<dynamic>)
        .map((e) => e as int)
        .toList(),
    completedTodoCount: json['completedTodoCount'] as int? ?? 0,
  );
}

class SubjectSummary {
  final String key; // 'math', 'korean', 'emotion'
  final String summary;

  const SubjectSummary({required this.key, required this.summary});

  String get displayName {
    switch (key) {
      case 'math':
        return '수학';
      case 'korean':
        return '국어';
      case 'emotion':
        return '감정';
      default:
        return key;
    }
  }

  IconData get icon {
    switch (key) {
      case 'math':
        return Icons.gps_fixed;
      case 'korean':
        return Icons.menu_book;
      case 'emotion':
        return Icons.favorite_border;
      default:
        return Icons.school_outlined;
    }
  }

  Color get color {
    switch (key) {
      case 'math':
        return const Color(0xFFE07070);
      case 'korean':
        return const Color(0xFF5B9BD5);
      case 'emotion':
        return AppColors.primary;
      default:
        return AppColors.textSub;
    }
  }
}

class LearningStatus {
  final SubjectSummary math;
  final SubjectSummary korean;
  final SubjectSummary emotion;

  const LearningStatus({
    required this.math,
    required this.korean,
    required this.emotion,
  });

  List<SubjectSummary> get all => [korean, math, emotion];

  factory LearningStatus.fromJson(Map<String, dynamic> json) {
    SubjectSummary parse(String key) => SubjectSummary(
      key: key,
      summary: (json[key] as Map<String, dynamic>?)?['summary'] as String? ?? '',
    );
    return LearningStatus(
      math: parse('math'),
      korean: parse('korean'),
      emotion: parse('emotion'),
    );
  }
}

class ChatSafetyDetail {
  final ChatSafetyLevel signal;
  final int score;
  final String reasonSummary;

  const ChatSafetyDetail({
    required this.signal,
    required this.score,
    required this.reasonSummary,
  });

  factory ChatSafetyDetail.fromJson(Map<String, dynamic> json) =>
      ChatSafetyDetail(
        signal: ChatSafetyLevelExt.fromString(
          json['signal'] as String? ?? '',
        ),
        score: json['score'] as int? ?? 0,
        reasonSummary: json['reasonSummary'] as String? ?? '',
      );
}

class ReportDetail {
  final int reportId;
  final String weekStart;
  final String weekEnd;
  final GrowthSection growth;
  final LearningPattern learningPattern;
  final LearningStatus learningStatus;
  final ChatSafetyDetail? chatSafety;
  final GuardianMission? parentMission;
  final List<String> keywords;

  const ReportDetail({
    required this.reportId,
    required this.weekStart,
    required this.weekEnd,
    required this.growth,
    required this.learningPattern,
    required this.learningStatus,
    this.chatSafety,
    this.parentMission,
    this.keywords = const [],
  });

  String get weekRange => ReportSummary._formatRange(weekStart, weekEnd);

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    final safetyJson = json['chatSafety'] as Map<String, dynamic>?;
    final missionJson = json['parentMission'] as Map<String, dynamic>?;
    return ReportDetail(
      reportId: json['reportId'] as int,
      weekStart: json['weekStart'] as String,
      weekEnd: json['weekEnd'] as String,
      growth: GrowthSection.fromJson(json['growth'] as Map<String, dynamic>),
      learningPattern: LearningPattern.fromJson(
        json['learningPattern'] as Map<String, dynamic>,
      ),
      learningStatus: LearningStatus.fromJson(
        json['learningStatus'] as Map<String, dynamic>,
      ),
      chatSafety:
          safetyJson != null ? ChatSafetyDetail.fromJson(safetyJson) : null,
      parentMission:
          missionJson != null ? GuardianMission.fromJson(missionJson) : null,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  static ReportSummary mockSummary() => ReportSummary(
    reportId: -1,
    weekStart: '2026-05-26',
    weekEnd: '2026-06-01',
    safetySignal: ChatSafetyLevel.green,
    hasMission: true,
  );

  static ReportDetail mock() => ReportDetail(
    reportId: -1,
    weekStart: '2026-05-26',
    weekEnd: '2026-06-01',
    growth: const GrowthSection(
      summary:
          '이번 주 아이는 수학에서 눈에 띄는 성장을 보여줬어요. '
          '더하기 개념을 꾸준히 연습하며 자신감이 붙었고, 국어 독해에서도 이야기의 흐름을 파악하는 능력이 향상되었습니다. '
          '스스로 문제를 풀어보려는 태도가 정말 훌륭했어요!',
      parentTip: '오늘 배운 내용을 저녁 식사 시간에 아이에게 한 번 물어봐 주세요. 설명하면서 더 깊이 이해하게 됩니다.',
    ),
    learningPattern: const LearningPattern(
      learningDays: [1, 2, 3, 5, 6],
      completedTodoCount: 15,
    ),
    learningStatus: const LearningStatus(
      korean: SubjectSummary(
        key: 'korean',
        summary: '비 오는 날 학습을 통해 감각적 표현을 익히고 문장을 완성하는 능력이 향상되었어요.',
      ),
      math: SubjectSummary(
        key: 'math',
        summary: '더하기 개념을 완벽히 이해하고 빠르게 계산하는 연습을 잘 해내고 있어요.',
      ),
      emotion: SubjectSummary(
        key: 'emotion',
        summary: '감정을 언어로 표현하는 연습을 통해 자신의 마음을 잘 인식하고 있어요.',
      ),
    ),
    chatSafety: const ChatSafetyDetail(
      signal: ChatSafetyLevel.green,
      score: 92,
      reasonSummary:
          '아이가 정서적으로 안정된 상태에서 학습에 참여하고 있으며, 긍정적인 감정 표현이 많았습니다.',
    ),
    parentMission: const GuardianMission(
      praisePhrase: '"이번 주 정말 열심히 공부했구나! 스스로 문제를 끝까지 풀려고 한 모습이 정말 대견해!"',
      activitySuggestion: '주말에 아이와 함께 오늘 배운 수학 문제를 게임처럼 풀어보세요. 부모님이 문제를 내고 아이가 맞히는 방식으로 해보면 재미있어요.',
    ),
    keywords: ['더하기', '감각적 표현', '문장 완성', '감정 표현'],
  );
}
