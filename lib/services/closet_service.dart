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

  Future<({List<ClosetItem> items, EquippedItems equipped})> getMyItems() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/shop/my-items');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final items = (json['items'] as List<dynamic>)
          .map((e) => ClosetItem.fromMyItemJson(e as Map<String, dynamic>))
          .toList();
      final equipped =
          EquippedItems.fromJson(json['equipped'] as Map<String, dynamic>);
      return (items: items, equipped: equipped);
    }
    throw Exception('보유 아이템 조회 실패: ${response.statusCode}');
  }

  Future<({List<ClosetItem> items, int availablePool})> getShopItems() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/shop/items');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final items = (json['items'] as List<dynamic>)
          .map((e) => ClosetItem.fromShopJson(e as Map<String, dynamic>))
          .toList();
      final availablePool = json['availablePool'] as int? ?? 0;
      return (items: items, availablePool: availablePool);
    }
    throw Exception('상점 조회 실패: ${response.statusCode}');
  }

  Future<int> purchaseItem(int itemId) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/shop/items/$itemId/purchase');
    final headers = await _getHeaders();
    final response = await http.post(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return json['remainingPool'] as int? ?? 0;
    }
    throw Exception('아이템 구매 실패: ${response.statusCode}');
  }

  Future<EquippedItems> equipItem(int itemId) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/shop/items/$itemId/equip');
    final headers = await _getHeaders();
    final response = await http.patch(url, headers: headers);
    if (response.statusCode == 200) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return EquippedItems.fromJson(json['equipped'] as Map<String, dynamic>);
    }
    throw Exception('아이템 착용 실패: ${response.statusCode}');
  }

  Future<EquippedItems> unequipItem(String category) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/shop/items/$category/equip');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return EquippedItems.fromJson(json['equipped'] as Map<String, dynamic>);
    }
    throw Exception('아이템 탈착 실패: ${response.statusCode}');
  }
}
