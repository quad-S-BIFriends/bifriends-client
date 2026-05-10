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

// ─── Step 2 ───────────────────────────────────────

// 3컷 만화 패널 (상황 시작 → 문제 발생 → 감정 발생)
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

// 감정 선택지
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
  final List<ComicPanel> panels; // 3컷 만화 (EMO-12)
  final String question;
  final List<Step2AnswerOption> options; // 정답 1 + 오답 2 (EMO-09)
  final int correctIndex;
  final String successMessage;

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

// ─── Step 3 ───────────────────────────────────────

// 대화 연습 씬 (EMO-13)
class Step3DialogScene {
  final String? imageUrl; // TODO: BE 연동 (만화 컷 이미지)
  final String scenarioText; // 상황 설명
  final String speakerLabel; // 아바타 레이블 e.g. "엄"
  final String speakerFullLabel; // e.g. "엄마(이)가 말했어:"
  final String speakerMessage; // 발화 내용

  const Step3DialogScene({
    this.imageUrl,
    required this.scenarioText,
    required this.speakerLabel,
    required this.speakerFullLabel,
    required this.speakerMessage,
  });

  factory Step3DialogScene.fromJson(Map<String, dynamic> json) {
    return Step3DialogScene(
      imageUrl: json['imageUrl'] as String?,
      scenarioText: json['scenarioText'] as String,
      speakerLabel: json['speakerLabel'] as String,
      speakerFullLabel: json['speakerFullLabel'] as String,
      speakerMessage: json['speakerMessage'] as String,
    );
  }
}

// 대화 선택지
class Step3AnswerOption {
  final String text;
  final String wrongGuidance; 

  const Step3AnswerOption({required this.text, this.wrongGuidance = ''});

  factory Step3AnswerOption.fromJson(Map<String, dynamic> json) {
    return Step3AnswerOption(
      text: json['text'] as String,
      wrongGuidance: (json['wrongGuidance'] as String?) ?? '',
    );
  }
}

class FriendsStep3Data {
  final Step3DialogScene scene;
  final String question;
  final List<Step3AnswerOption> options;
  final int correctIndex;
  final String correctEcho;
  final String leoFeedback;

  const FriendsStep3Data({
    required this.scene,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.correctEcho,
    required this.leoFeedback,
  });

  factory FriendsStep3Data.fromJson(Map<String, dynamic> json) {
    return FriendsStep3Data(
      scene: Step3DialogScene.fromJson(json['scene'] as Map<String, dynamic>),
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((e) => Step3AnswerOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctIndex: json['correctIndex'] as int,
      correctEcho: json['correctEcho'] as String,
      leoFeedback: json['leoFeedback'] as String,
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
