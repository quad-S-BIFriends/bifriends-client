class FriendsExpressionData {
  final String emotionWord; // 감정 단어 e.g. "놀람"
  final String expression; // 관용 표현 e.g. "가슴이 철렁하다"
  final String? imageUrl; // TODO: BE 연동
  final String bodyFeeling; // 신체 감각 설명 TODO: BE 연동
  final String whenFeeling; // 상황 예시 TODO: BE 연동

  const FriendsExpressionData({
    required this.emotionWord,
    required this.expression,
    this.imageUrl,
    required this.bodyFeeling,
    required this.whenFeeling,
  });

  factory FriendsExpressionData.fromJson(Map<String, dynamic> json) {
    return FriendsExpressionData(
      emotionWord: json['emotionWord'] as String,
      expression: json['expression'] as String,
      imageUrl: json['imageUrl'] as String?,
      bodyFeeling: json['bodyFeeling'] as String,
      whenFeeling: json['whenFeeling'] as String,
    );
  }
}

class FriendsActivityData {
  final String situationText; // 시나리오 상황
  final FriendsExpressionData expression; // 오늘의 감정 표현

  const FriendsActivityData({
    required this.situationText,
    required this.expression,
  });

  factory FriendsActivityData.fromJson(Map<String, dynamic> json) {
    return FriendsActivityData(
      situationText: json['situationText'] as String,
      expression: FriendsExpressionData.fromJson(
        json['expression'] as Map<String, dynamic>,
      ),
    );
  }
}
