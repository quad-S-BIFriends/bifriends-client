import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/home_model.dart';

class HomeService {
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

  Future<HomeResponse> getHome() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/home');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(decodedData);
      return HomeResponse.fromJson(jsonData as Map<String, dynamic>);
    } else {
      throw Exception('홈 정보 조회 실패: ${response.statusCode}');
    }
  }

  Future<TodoCompleteResult> completeTodo(String todoId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/todos/$todoId/complete');
    final headers = await _getHeaders();

    final response = await http.patch(url, headers: headers);

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(decodedData);
      return TodoCompleteResult.fromJson(jsonData as Map<String, dynamic>);
    } else {
      throw Exception('할 일 완료 처리 실패: ${response.statusCode}');
    }
  }
}
