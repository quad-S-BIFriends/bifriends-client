// Step 1 데이터
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

// Step 2 — 3컷 만화 패널 (상황 시작 → 문제 발생 → 감정 발생)
class ComicPanel {
  final String? imageUrl; // TODO: BE 연동
  final String caption;

  const ComicPanel({this.imageUrl, required this.caption});

  factory ComicPanel.fromJson(Map<String, dynamic> json) {
    return ComicPanel(
      imageUrl: json['imageUrl'] as String?,
      caption: json['caption'] as String,
    );
  }
}

// Step 2 — 감정 선택지
class Step2AnswerOption {
  final String text;
  final String wrongExplanation; // 오답일 때 표시되는 다정한 설명 (정답은 빈 문자열)

  const Step2AnswerOption({required this.text, this.wrongExplanation = ''});

  factory Step2AnswerOption.fromJson(Map<String, dynamic> json) {
    return Step2AnswerOption(
      text: json['text'] as String,
      wrongExplanation: (json['wrongExplanation'] as String?) ?? '',
    );
  }
}

// Step 2 전체 데이터
class FriendsStep2Data {
  final List<ComicPanel> panels; // 3컷 만화 (EMO-12)
  final String question; // 감정 선택 질문 (EMO-09)
  final List<Step2AnswerOption> options; // 정답 1 + 오답 2 (EMO-09)
  final int correctIndex; // options 중 정답 인덱스
  final String successMessage; // 정답 선택 시 피드백 메시지

  const FriendsStep2Data({
    required this.panels,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.successMessage = '정말 대단해! 상황을 아주 잘 이해했구나.',
  });

  factory FriendsStep2Data.fromJson(Map<String, dynamic> json) {
    return FriendsStep2Data(
      panels: (json['panels'] as List)
          .map((e) => ComicPanel.fromJson(e as Map<String, dynamic>))
          .toList(),
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((e) => Step2AnswerOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctIndex: json['correctIndex'] as int,
      successMessage:
          (json['successMessage'] as String?) ?? '정말 대단해! 상황을 아주 잘 이해했구나.',
    );
  }
}

// 전체 친구랑 활동 데이터
class FriendsActivityData {
  final String situationText;
  final FriendsExpressionData expression; // Step 1
  final FriendsStep2Data? step2; // Step 2 (nullable — BE 연동 전까지 mock 사용)

  const FriendsActivityData({
    required this.situationText,
    required this.expression,
    this.step2,
  });

  factory FriendsActivityData.fromJson(Map<String, dynamic> json) {
    return FriendsActivityData(
      situationText: json['situationText'] as String,
      expression: FriendsExpressionData.fromJson(
        json['expression'] as Map<String, dynamic>,
      ),
      step2: json['step2'] != null
          ? FriendsStep2Data.fromJson(json['step2'] as Map<String, dynamic>)
          : null,
    );
  }
}
