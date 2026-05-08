class GuardianMission {
  final String praisePhrase;
  final String activitySuggestion;

  const GuardianMission({
    required this.praisePhrase,
    required this.activitySuggestion,
  });

  factory GuardianMission.fromJson(Map<String, dynamic> json) {
    return GuardianMission(
      praisePhrase: json['praisePhrase'] as String,
      activitySuggestion: json['activitySuggestion'] as String,
    );
  }

  // TODO: BE 연동 시 fromJson으로 교체
  static GuardianMission mock() => const GuardianMission(
    praisePhrase:
        '"화가 났을 때 동생을 밀지 않고 숨을 크게 마시기로 약속한 정우치치의 예쁜 마음을 듬뿍 칭찬해 주세요!"',
    activitySuggestion:
        '주말에 아이와 함께 무서운 상황에서 \'심장이 콩닥콩닥\' 뛸 때 서로의 가슴에 손을 얹고 함께 심호흡하는 놀이를 해보세요.',
  );
}
