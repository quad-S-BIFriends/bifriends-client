// ─── Step 1 ───────────────────────────────────────
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

// ─── Step 2 ─── EMO-08 to EMO-11
// 얼굴 확대 이미지 + 시각적 특징 -> 감정 맞추기 퀴즈

// 감정 선택지 (정답 1 + 유사 오답 2)
class Step2AnswerOption {
  final String text;
  final String wrongExplanation; // 오답 시 표시 (정답은 빈 문자열)

  const Step2AnswerOption({required this.text, this.wrongExplanation = ''});

  factory Step2AnswerOption.fromJson(Map<String, dynamic> json) {
    return Step2AnswerOption(
      text: json['text'] as String,
      wrongExplanation: (json['wrongExplanation'] as String?) ?? '',
    );
  }
}

class FriendsStep2Data {
  final String? faceImageUrl; // 얼굴 확대 이미지 (EMO-08) TODO: BE 연동
  final String visualDescription; // 시각적 특징 설명 (EMO-08)
  final String question; // "이 친구는 어떤 기분일까요?"
  final List<Step2AnswerOption> options; // 정답 1 + 유사 오답 2 (EMO-09)
  final int correctIndex;
  final String successMessage; // 정답 시 피드백

  const FriendsStep2Data({
    this.faceImageUrl,
    required this.visualDescription,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.successMessage = '잘 맞혔어! 표정을 잘 관찰했구나.',
  });

  factory FriendsStep2Data.fromJson(Map<String, dynamic> json) {
    return FriendsStep2Data(
      faceImageUrl: json['faceImageUrl'] as String?,
      visualDescription: json['visualDescription'] as String,
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((e) => Step2AnswerOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctIndex: json['correctIndex'] as int,
      successMessage:
          (json['successMessage'] as String?) ?? '잘 맞혔어! 표정을 잘 관찰했구나.',
    );
  }
}

// ─── Step 3 ─── EMO-12 to EMO-17
// 3컷 만화 캐러셀 -> 감정 원인 맞추기 퀴즈

// 만화 컷 (상황 시작 -> 문제 발생 -> 감정 발생)
class ComicPanel {
  final String? imageUrl; // TODO: BE 연동
  final String caption; // 각 컷의 짧은 문장 (EMO-13)

  const ComicPanel({this.imageUrl, required this.caption});

  factory ComicPanel.fromJson(Map<String, dynamic> json) {
    return ComicPanel(
      imageUrl: json['imageUrl'] as String?,
      caption: json['caption'] as String,
    );
  }
}

// 감정 원인 선택지
class Step3CauseOption {
  final String text;
  final String wrongGuidance; // 오답 시 장면 재확인 안내 (EMO-16)

  const Step3CauseOption({required this.text, this.wrongGuidance = ''});

  factory Step3CauseOption.fromJson(Map<String, dynamic> json) {
    return Step3CauseOption(
      text: json['text'] as String,
      wrongGuidance: (json['wrongGuidance'] as String?) ?? '',
    );
  }
}

class FriendsStep3Data {
  final List<ComicPanel> panels; // 3컷 만화 (EMO-12, EMO-13)
  final String question; // "어떤 일이 있어서 이런 기분이 들었을까요?" (EMO-14)
  final List<Step3CauseOption> options;
  final int correctIndex;
  final String correctExplanation; // 정답 시 원인 설명 (EMO-15)

  const FriendsStep3Data({
    required this.panels,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.correctExplanation,
  });

  factory FriendsStep3Data.fromJson(Map<String, dynamic> json) {
    return FriendsStep3Data(
      panels: (json['panels'] as List)
          .map((e) => ComicPanel.fromJson(e as Map<String, dynamic>))
          .toList(),
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((e) => Step3CauseOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctIndex: json['correctIndex'] as int,
      correctExplanation: json['correctExplanation'] as String,
    );
  }
}

// ─── 전체 활동 데이터 ──────────────────────────────
class FriendsActivityData {
  final String situationText;
  final FriendsExpressionData expression; // Step 1
  final FriendsStep2Data? step2;
  final FriendsStep3Data? step3;

  const FriendsActivityData({
    required this.situationText,
    required this.expression,
    this.step2,
    this.step3,
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
      step3: json['step3'] != null
          ? FriendsStep3Data.fromJson(json['step3'] as Map<String, dynamic>)
          : null,
    );
  }
}
