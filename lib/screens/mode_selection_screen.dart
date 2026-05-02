import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member_model.dart';
import '../services/member_service.dart';
import 'main_scaffold.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  final MemberService _memberService = MemberService();
  bool _isLoading = true;
  String _displayName = '친구';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final member = await _memberService.getMe();
      if (mounted) {
        setState(() {
          _displayName = member.nickname ?? member.name;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '정보를 불러오는데 실패했어요.\n$e';
          _isLoading = false;
        });
      }
    }
  }

  bool _hasJongseong(String str) {
    if (str.isEmpty) return false;
    final lastChar = str.codeUnitAt(str.length - 1);
    if (lastChar < 0xAC00 || lastChar > 0xD7A3) return false;
    return (lastChar - 0xAC00) % 28 > 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF75A66B)),
        ),
      );
    }

    final particle = _hasJongseong(_displayName) ? '아' : '야';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Image.asset(
                  'assets/images/leo_defaultface.png',
                  height: 140,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('🦫', style: TextStyle(fontSize: 100)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '안녕, $_displayName$particle!\n누가 접속했나요?',
                textAlign: TextAlign.center,
                style: GoogleFonts.gaegu(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B4423),
                  height: 1.3,
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 48),
              _buildModeCard(
                context: context,
                title: '아이 모드',
                subtitle: '재미있는 공부방으로 갈래요!',
                icon: Icons.face,
                color: const Color(0xFF75A66B),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScaffold(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildModeCard(
                context: context,
                title: '부모님 모드',
                subtitle: '아이의 학습 현황을 관리할래요.',
                icon: Icons.admin_panel_settings,
                color: const Color(0xFF8B6D55),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('부모님 대시보드는 준비 중입니다.'),
                      backgroundColor: Color(0xFF8B6D55),
                    ),
                  );
                },
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A7E74),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 28, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
