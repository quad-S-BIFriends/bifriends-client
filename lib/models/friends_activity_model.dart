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

// ─── Step 4 ─── EMO-18 to EMO-24
// 대화 연습 (역할극 — 공감 반응 선택)

class Step4Scene {
  final String scenarioText; // (EMO-18 요약)
  final String speakerLabel; 
  final String speakerFullLabel; 
  final String speakerMessage; // 발화 내용

  const Step4Scene({
    required this.scenarioText,
    required this.speakerLabel,
    required this.speakerFullLabel,
    required this.speakerMessage,
  });

  factory Step4Scene.fromJson(Map<String, dynamic> json) {
    return Step4Scene(
      scenarioText: json['scenarioText'] as String,
      speakerLabel: json['speakerLabel'] as String,
      speakerFullLabel: json['speakerFullLabel'] as String,
      speakerMessage: json['speakerMessage'] as String,
    );
  }
}

// 공감 반응 선택지 (공감 1 + 무관심 1 + 무관한 반응 1)
class Step4ResponseOption {
  final String text;
  final String wrongExplanation; // 오답 시 설명 (EMO-22)

  const Step4ResponseOption({required this.text, this.wrongExplanation = ''});

  factory Step4ResponseOption.fromJson(Map<String, dynamic> json) {
    return Step4ResponseOption(
      text: json['text'] as String,
      wrongExplanation: (json['wrongExplanation'] as String?) ?? '',
    );
  }
}

class FriendsStep4Data {
  final String leoIntroMessage; // (EMO-19)
  final Step4Scene scene;
  final String question;
  final List<Step4ResponseOption> options; // (EMO-20)
  final int correctIndex;
  final String correctEcho;
  final String leoFeedback; // 정답 시 칭찬 (EMO-21)

  const FriendsStep4Data({
    required this.leoIntroMessage,
    required this.scene,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.correctEcho,
    required this.leoFeedback,
  });

  factory FriendsStep4Data.fromJson(Map<String, dynamic> json) {
    return FriendsStep4Data(
      leoIntroMessage: json['leoIntroMessage'] as String,
      scene: Step4Scene.fromJson(json['scene'] as Map<String, dynamic>),
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((e) => Step4ResponseOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctIndex: json['correctIndex'] as int,
      correctEcho: json['correctEcho'] as String,
      leoFeedback: json['leoFeedback'] as String,
    );
  }
}

// ─── Step 5 ─── Leo 인사 / 학습 마무리

class FriendsStep5Data {
  final String leoMessage;
  final String promptLabel; 
  final List<String> farewellOptions;

  const FriendsStep5Data({
    required this.leoMessage,
    required this.promptLabel,
    required this.farewellOptions,
  });

  factory FriendsStep5Data.fromJson(Map<String, dynamic> json) {
    return FriendsStep5Data(
      leoMessage: json['leoMessage'] as String,
      promptLabel: json['promptLabel'] as String,
      farewellOptions:
          (json['farewellOptions'] as List).map((e) => e as String).toList(),
    );
  }
}

// ─── 전체 활동 데이터 ──────────────────────────────
class FriendsActivityData {
  final String situationText;
  final FriendsExpressionData expression; // Step 1
  final FriendsStep2Data? step2;
  final FriendsStep3Data? step3;
  final FriendsStep4Data? step4;
  final FriendsStep5Data? step5;

  const FriendsActivityData({
    required this.situationText,
    required this.expression,
    this.step2,
    this.step3,
    this.step4,
    this.step5,
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
      step4: json['step4'] != null
          ? FriendsStep4Data.fromJson(json['step4'] as Map<String, dynamic>)
          : null,
      step5: json['step5'] != null
          ? FriendsStep5Data.fromJson(json['step5'] as Map<String, dynamic>)
          : null,
    );
  }
}
