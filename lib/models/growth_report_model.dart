import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SubjectType { korean, math, social }

extension SubjectTypeExt on SubjectType {
  IconData get icon {
    switch (this) {
      case SubjectType.korean:
        return Icons.menu_book;
      case SubjectType.math:
        return Icons.gps_fixed;
      case SubjectType.social:
        return Icons.people_alt_outlined;
    }
  }

  Color get color {
    switch (this) {
      case SubjectType.korean:
        return const Color(0xFF5B9BD5);
      case SubjectType.math:
        return const Color(0xFFE07070);
      case SubjectType.social:
        return AppColors.textSub;
    }
  }

  static SubjectType fromString(String value) {
    switch (value) {
      case 'korean':
        return SubjectType.korean;
      case 'math':
        return SubjectType.math;
      case 'social':
        return SubjectType.social;
      default:
        return SubjectType.korean;
    }
  }
}

class SubjectReport {
  final String name;
  final SubjectType type;
  final String goodPoint;
  final String? hardPoint;

  const SubjectReport({
    required this.name,
    required this.type,
    required this.goodPoint,
    this.hardPoint,
  });

  factory SubjectReport.fromJson(Map<String, dynamic> json) {
    return SubjectReport(
      name: json['name'] as String,
      type: SubjectTypeExt.fromString(json['type'] as String),
      goodPoint: json['goodPoint'] as String,
      hardPoint: json['hardPoint'] as String?,
    );
  }
}

class LearningPattern {
  final List<String> studyDays;
  final int totalStudyCount;

  const LearningPattern({
    required this.studyDays,
    required this.totalStudyCount,
  });

  factory LearningPattern.fromJson(Map<String, dynamic> json) {
    return LearningPattern(
      studyDays: List<String>.from(json['studyDays'] as List),
      totalStudyCount: json['totalStudyCount'] as int,
    );
  }
}

class GrowthReport {
  final String childName;
  final String weekRange;
  final String summary;
  final LearningPattern pattern;
  final List<SubjectReport> subjects;

  const GrowthReport({
    required this.childName,
    required this.weekRange,
    required this.summary,
    required this.pattern,
    required this.subjects,
  });

  factory GrowthReport.fromJson(Map<String, dynamic> json) {
    return GrowthReport(
      childName: json['childName'] as String,
      weekRange: json['weekRange'] as String,
      summary: json['summary'] as String,
      pattern: LearningPattern.fromJson(
        json['learningPattern'] as Map<String, dynamic>,
      ),
      subjects: (json['subjects'] as List)
          .map((s) => SubjectReport.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  static GrowthReport mock() => const GrowthReport(
    childName: '정우치치',
    weekRange: '4월 26일 ~ 5월 2일',
    summary:
        '이번 한 주 동안 정우치치는 자신의 감정을 들여다보고 솔직하게 표현하는 법을 배우며 마음의 키가 쑥쑥 자랐어요. '
        '분노와 두려움이라는 어려운 감정을 만났을 때, 어떻게 마음을 다스리고 도움을 요청해야 하는지 진지하게 고민하는 모습이 참 기특했답니다. '
        '비록 모든 활동을 다 완료하지는 못했지만, 매 순간 최선을 다해 참여하며 성장해 나가는 정우치치를 함께 응원해 주세요!',
    pattern: LearningPattern(
      studyDays: ['월', '화', '목', '토'],
      totalStudyCount: 12,
    ),
    subjects: [
      SubjectReport(
        name: '국어',
        type: SubjectType.korean,
        goodPoint: '국어 1단계 학습을 시작하며 한글과 친해지는 과정을 차근차근 밟아나가고 있어요.',
        hardPoint: '학습 빈도를 조금 더 높여서 꾸준히 문장을 읽고 이해하는 연습이 필요해 보여요.',
      ),
      SubjectReport(
        name: '수학',
        type: SubjectType.math,
        goodPoint: '매일 주어지는 \'오늘의 문제\' 풀이에 도전하며 수학적 사고력을 기르고 있습니다.',
        hardPoint: '어려운 문제가 나와도 포기하지 않고 끝까지 문제를 해결하려는 끈기가 조금 더 필요해요.',
      ),
      SubjectReport(
        name: '관계 시나리오',
        type: SubjectType.social,
        goodPoint:
            '\'머리끝까지 화가 난다\', \'심장이 콩닥콩닥\' 같은 풍부한 감정 표현을 익히고, '
            '화가 날 때 숨을 깊게 마시는 건강한 대처법을 잘 이해하고 있어요.',
        hardPoint: null,
      ),
    ],
  );
}
