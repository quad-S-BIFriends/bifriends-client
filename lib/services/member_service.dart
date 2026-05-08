import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/member_model.dart';

class MemberService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

  Future<Member> getMe() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/members/me');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(decodedData);
      return Member.fromJson(jsonData);
    } else {
      throw Exception('내 정보 조회 실패: ${response.statusCode}');
    }
  }
}
