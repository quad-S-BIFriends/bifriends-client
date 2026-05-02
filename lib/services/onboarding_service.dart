import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return Platform.isAndroid
        ? 'http://10.0.2.2:8080'
        : 'http://localhost:8080';
  }

  Future<Map<String, String>> _getHeaders() async {
    final String? accessToken = await _storage.read(key: 'accessToken');
    if (accessToken == null) {
      throw Exception('로그인 토큰이 존재하지 않습니다. 다시 로그인해주세요.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<void> updateProfile({required String nickname, required int grade}) async {
    final url = Uri.parse('$_baseUrl/api/v1/onboarding/profile');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'nickname': nickname,
      'grade': grade,
    });

    final response = await http.patch(url, headers: headers, body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('프로필 업데이트 실패: ${response.statusCode}');
    }
  }

  Future<void> updateInterests({required List<String> interests}) async {
    final url = Uri.parse('$_baseUrl/api/v1/onboarding/interests');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'interests': interests,
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('관심사 업데이트 실패: ${response.statusCode}');
    }
  }

  Future<void> selectGift({required String itemType}) async {
    final url = Uri.parse('$_baseUrl/api/v1/onboarding/gift');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'itemType': itemType,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('선물 선택 실패: ${response.statusCode}');
    }
  }
}
