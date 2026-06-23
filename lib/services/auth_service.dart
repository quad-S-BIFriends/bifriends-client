import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String email;
  final String name;
  final String? profileImageUrl;
  final bool onboardingCompleted;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.onboardingCompleted,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      onboardingCompleted: json['onboardingCompleted'] ?? false,
    );
  }
}

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  // Android: google-services.json 자동 사용, iOS: GoogleService-Info.plist 자동 사용
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final String? firebaseIdToken;

      if (kIsWeb) {
        // 웹: FirebaseAuth 팝업 플로우 사용 (google_sign_in 미사용)
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);
        firebaseIdToken = await userCredential.user?.getIdToken();
      } else {
        // 모바일: google_sign_in → Firebase credential
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        firebaseIdToken = await userCredential.user?.getIdToken();
      }

      if (firebaseIdToken == null) {
        throw Exception('Firebase 로그인 실패: Firebase idToken을 가져올 수 없습니다.');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/members/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': firebaseIdToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final authResponse = AuthResponse.fromJson(data);

        await _storage.write(
          key: 'accessToken',
          value: authResponse.accessToken,
        );
        await _storage.write(
          key: 'refreshToken',
          value: authResponse.refreshToken,
        );

        return authResponse;
      } else {
        throw Exception('서버 로그인 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) await _googleSignIn.signOut();
    await _auth.signOut();
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<void> deleteAccount() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) {
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/members/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }
    await signOut();
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  /// Firebase ID 토큰을 강제 갱신한 뒤 백엔드에서 새 accessToken을 발급받아 저장.
  /// 성공 시 새 토큰 반환, 실패 시 null 반환.
  Future<String?> refreshAccessToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final idToken = await user.getIdToken(true); // force refresh
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/members/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final newToken = data['accessToken'] as String;
        await _storage.write(key: 'accessToken', value: newToken);
        return newToken;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
