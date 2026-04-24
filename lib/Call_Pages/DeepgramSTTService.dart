import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef TranscriptCallback = void Function(String text, bool isFinal);

class DeepgramSTTService {

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  bool _isRunning = false;
  bool _isPaused = false;
  TranscriptCallback? _onTranscript;
  String? _apiKey;

  Future<void> start({
    required String apiKey,
    required TranscriptCallback onTranscript,
  }) async {
    _apiKey = apiKey;
    _onTranscript = onTranscript;
    await _connect();
  }

  Future<void> _connect() async {
    try {
      final uri = Uri.parse(
        'wss://api.deepgram.com/v1/listen'
            '?encoding=linear16'
            '&sample_rate=16000'
            '&channels=1'
            '&model=nova-2'
            '&language=multi'   // ✅ Auto-detects English + Urdu/Hindi mid-sentence
            '&punctuate=true'
            '&smart_format=true'
            '&interim_results=true'
            '&utterance_end_ms=1000'
            '&vad_events=true',
      );

      _channel = WebSocketChannel.connect(
        uri,
        protocols: ['token', _apiKey!],
      );

      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: (error) {
          print('[Deepgram] WebSocket error: $error');
          if (_isRunning) {
            Future.delayed(const Duration(seconds: 2), _connect);
          }
        },
        onDone: () {
          if (_isRunning) {
            Future.delayed(const Duration(seconds: 1), _connect);
          }
        },
        cancelOnError: false,
      );

      _isRunning = true;
      print('[Deepgram] WebSocket connected (multilingual mode)');
    } catch (e) {
      print('[Deepgram] Connection failed: $e');
      if (_isRunning) {
        Future.delayed(const Duration(seconds: 2), _connect);
      }
    }
  }

  void _onMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String);
      final type = json['type'] as String?;

      if (type == 'Results') {
        final channel = json['channel'];
        if (channel == null) return;

        final alternatives = channel['alternatives'] as List<dynamic>?;
        if (alternatives == null || alternatives.isEmpty) return;

        final transcript = alternatives[0]['transcript'] as String? ?? '';
        if (transcript.trim().isEmpty) return;

        final isFinal = json['is_final'] as bool? ?? false;

        _onTranscript?.call(transcript.trim(), isFinal);
      }
    } catch (e) {
      print('[Deepgram] Parse error: $e');
    }
  }

  void feedAudioFrame(Uint8List pcmBytes) {
    if (!_isRunning || _isPaused || _channel == null) return;
    try {
      _channel!.sink.add(pcmBytes);
    } catch (e) {
      print('[Deepgram] Feed error: $e');
    }
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
  }

  Future<void> stop() async {
    _isRunning = false;
    _isPaused = false;
    _onTranscript = null;
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.sink.close();
    _channel = null;
  }
}