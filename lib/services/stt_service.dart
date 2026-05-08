import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SttService {
  final AudioRecorder _recorder = AudioRecorder();

  // TODO: flutter_dotenv 등으로 환경변수 분리 예정
  static const String _apiKey = 'AIzaSyDgwkx-_FTukhxECpDcS0vCNmZv3GaFqj4';

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/stt_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  Future<String?> stopAndTranscribe() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    return await _transcribe(path);
  }

  Future<String?> _transcribe(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final base64Audio = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(
        'https://speech.googleapis.com/v1/speech:recognize?key=$_apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'config': {
          'encoding': 'LINEAR16',
          'sampleRateHertz': 16000,
          'languageCode': 'ko-KR',
        },
        'audio': {'content': base64Audio},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results']?[0]?['alternatives']?[0]?['transcript'] as String?;
    }
    debugPrint('STT 오류: ${response.statusCode} ${response.body}');
    return null;
  }

  void dispose() => _recorder.dispose();
}
