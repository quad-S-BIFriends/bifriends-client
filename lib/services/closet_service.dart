import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/closet_model.dart';

class ClosetService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final String? accessToken = await _storage.read(key: 'accessToken');
    if (accessToken == null) throw Exception('로그인 토큰이 존재하지 않습니다.');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<List<ClosetItem>> getMyItems() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/items/my');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return list
          .map((e) => ClosetItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('아이템 조회 실패: ${response.statusCode}');
  }

  Future<List<ClosetItem>> getShopItems() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/items/shop');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return list
          .map((e) => ClosetItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('상점 조회 실패: ${response.statusCode}');
  }

  Future<int> purchaseItem(String itemType) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/items/$itemType/purchase');
    final headers = await _getHeaders();
    final response = await http.post(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return json['availablePool'] as int? ?? 0;
    }
    throw Exception('아이템 구매 실패: ${response.statusCode}');
  }

  Future<void> setRepresentativeItem(String? itemType) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/members/me/representative-item');
    final headers = await _getHeaders();
    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({'itemType': itemType}),
    );
    if (response.statusCode != 200) {
      throw Exception('대표 아이템 설정 실패: ${response.statusCode}');
    }
  }
}
