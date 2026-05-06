import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bifriends_client/firebase_options.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? DefaultFirebaseOptions.ios.iosClientId : null,
  );
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8080';
    return Platform.isAndroid
        ? 'http://10.0.2.2:8080'
        : 'http://127.0.0.1:8080';
  }

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('구글 로그인 실패: idToken을 가져올 수 없습니다.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Firebase 로그인 실패: Firebase idToken을 가져올 수 없습니다.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/members/auth/google'),
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
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }
}
