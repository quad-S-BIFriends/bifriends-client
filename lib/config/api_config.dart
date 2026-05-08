import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const int _port = 18080;

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:$_port';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_port';
    return 'http://127.0.0.1:$_port';
  }
}
