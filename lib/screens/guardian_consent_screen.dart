import 'package:flutter/material.dart';
import 'parent_setup_screen.dart';

class GuardianConsentScreen extends StatefulWidget {
  const GuardianConsentScreen({super.key});

  @override
  State<GuardianConsentScreen> createState() => _GuardianConsentScreenState();
}

class _GuardianConsentScreenState extends State<GuardianConsentScreen> {
  bool _allAgreed = false;
  bool _termsAgreed = false;
  bool _privacyAgreed = false;
  bool _childInfoAgreed = false;

  bool get _canProceed => _termsAgreed && _privacyAgreed && _childInfoAgreed;

  void _toggleAll(bool value) {
    setState(() {
      _allAgreed = value;
      _termsAgreed = value;
      _privacyAgreed = value;
      _childInfoAgreed = value;
    });
  }

  void _updateAllAgreed() {
    setState(() {
      _allAgreed = _termsAgreed && _privacyAgreed && _childInfoAgreed;
    });
  }

  void _showTermsDetail(String title, String content) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 100),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B4423),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Color(0xFF8A7E74)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B4423),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '확인했어요',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_outline,
                          color: Color(0xFF3D6B35),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      '보호자 동의',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6B4423),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'BiFriend는 아이의 학습과 감정 성장을\n돕는 따뜻한 AI 친구입니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A7E74),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildAllAgreeCheckbox(),
                  const Divider(height: 28, color: Color(0xFFE8E0D5)),
                  _buildTermItem(
                    '이용약관 동의 (필수)',
                    _termsAgreed,
                    (v) {
                      setState(() => _termsAgreed = v);
                      _updateAllAgreed();
                    },
                    () => _showTermsDetail(
                      '이용약관',
                      'BiFriend 서비스 이용약관입니다. 본 서비스는 아동의 학습과 정서 발달을 돕기 위해 제공되며...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTermItem(
                    '개인정보 수집 및 이용 동의 (필수)',
                    _privacyAgreed,
                    (v) {
                      setState(() => _privacyAgreed = v);
                      _updateAllAgreed();
                    },
                    () => _showTermsDetail(
                      '개인정보',
                      '개인정보 수집 및 이용 동의서입니다. 수집한 정보는 서비스 제공 및 개선 목적으로만 사용합니다.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTermItem(
                    '만 14세 미만 아동 정보 수집 동의\n(필수)',
                    _childInfoAgreed,
                    (v) {
                      setState(() => _childInfoAgreed = v);
                      _updateAllAgreed();
                    },
                    () => _showTermsDetail(
                      '아동정보',
                      '만 14세 미만 아동의 개인정보 수집에 대한 법정대리인 동의서입니다. 보호자의 동의 없이는 아동의 정보를 수집하지 않습니다.',
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      onPressed: _canProceed
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ParentSetupScreen(),
                                ),
                              );
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '부모님 비밀번호 설정하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllAgreeCheckbox() {
    return GestureDetector(
      onTap: () => _toggleAll(!_allAgreed),
      child: Row(
        children: [
          _buildCheckIcon(_allAgreed, size: 26),
          const SizedBox(width: 12),
          const Text(
            '모두 동의할게요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3D3229),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(
    String title,
    bool isChecked,
    ValueChanged<bool> onChanged,
    VoidCallback onDetailTap,
  ) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!isChecked),
          child: _buildCheckIcon(isChecked, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onDetailTap,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B5B4E),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onDetailTap,
          child: const Icon(
            Icons.chevron_right,
            color: Color(0xFFB8A590),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckIcon(bool checked, {double size = 24}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? const Color(0xFF3D5A3C) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? const Color(0xFF3D5A3C) : const Color(0xFFCCC5BB),
          width: 2,
        ),
      ),
      child: checked
          ? Icon(Icons.check, size: size * 0.65, color: Colors.white)
          : null,
    );
  }
}
