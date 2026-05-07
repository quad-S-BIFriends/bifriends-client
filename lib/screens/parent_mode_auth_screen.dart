import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_colors.dart';
import 'parent_dashboard_screen.dart';

class ParentModeAuthScreen extends StatefulWidget {
  const ParentModeAuthScreen({super.key});

  @override
  State<ParentModeAuthScreen> createState() => _ParentModeAuthScreenState();
}

class _ParentModeAuthScreenState extends State<ParentModeAuthScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _pin = '';
  bool _isError = false;

  void _onNumTap(String value) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += value;
      _isError = false;
    });
    if (_pin.length == 4) _verifyPin();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _isError = false;
    });
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pin;
    final storedPin = await _storage.read(key: 'parentPin');
    debugPrint('[ParentAuth] entered: $enteredPin, stored: $storedPin');
    if (!mounted) return;
    if (enteredPin == storedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ParentDashboardScreen()),
      );
    } else {
      setState(() {
        _isError = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Parent Mode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _buildHeader(),
            const SizedBox(height: 40),
            _buildPinBoxes(),
            if (_isError) ...[
              const SizedBox(height: 14),
              const Text(
                '비밀번호가 일치하지 않아요',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF8A80),
                ),
              ),
            ],
            const Spacer(),
            _buildNumpad(),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // TODO: PIN 초기화 플로우
              },
              child: const Text(
                '비밀번호를 잊어버렸나요? (비밀번호 초기화)',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF8A80),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFFF8A80),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primary,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '보호자 확인',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '성장 리포트를 보기 위해\n비밀번호 4자리를 입력해주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white60,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPinBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 56,
          height: 64,
          decoration: BoxDecoration(
            color: isFilled
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isError
                  ? const Color(0xFFFF8A80)
                  : Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isFilled
                ? const Text(
                    '●',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildNumRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildNumRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildNumRow(['7', '8', '9']),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionButton('취소', onTap: () => Navigator.pop(context)),
              _buildNumberButton('0'),
              _buildActionButton('지우기', onTap: _onDelete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumRow(List<String> numbers) {
    return Row(children: numbers.map(_buildNumberButton).toList());
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: () => _onNumTap(number),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, {required VoidCallback onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
