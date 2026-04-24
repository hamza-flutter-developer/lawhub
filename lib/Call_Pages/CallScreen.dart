// ══════════════════════════════════════════════════════════════════════════════
// FILE: CallScreen.dart
// FIXES APPLIED:
//   FIX #1: VAD threshold raised from 20 → 50 (was pausing STT on any noise)
//   FIX #2: Speaker toggle now uses audioScenarioChatRoom (keeps hardware AEC
//            active when on loudspeaker — this was causing echo on speaker mode)
//   FIX #3: _callDocId now uses SAME sorted pattern as CallService._sortedDocId
//            so _listenForCallEnd() actually listens to the correct document
//   FIX #4: Video→Voice UI switch — when local video is off, the video grid
//            collapses into a WhatsApp-style voice call avatar screen.
//            When video is turned back on, it returns to video layout.
//   FIX #5: _analyzeTranscriptForLegalTerms is now called only on isFinal
//            transcripts (was being called on interim results too, spamming Grok)
// ══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'DeepgramSTTService.dart';
import 'ApiKeys.dart';
import 'CallService.dart';
import 'GrokService.dart';

class CallScreen extends StatefulWidget {
  final String lawyerId;
  final String userId;
  final String otherPersonName;
  final String otherPersonImage;
  final bool isUser;

  const CallScreen({
    Key? key,
    required this.lawyerId,
    required this.userId,
    required this.otherPersonName,
    required this.otherPersonImage,
    required this.isUser,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {

  // ─── AGORA ──────────────────────────────────────────────────────────────────
  RtcEngine? _engine;
  bool _localUserJoined = false;
  int? _remoteUid;

  // ─── RECONNECT ───────────────────────────────────────────────────────────────
  bool _remoteDropped = false;
  Timer? _reconnectTimer;

  // ─── SPEECH TO TEXT ─────────────────────────────────────────────────────────
  final DeepgramSTTService _sttService = DeepgramSTTService();
  bool _isListening = false;
  String _currentTranscript = '';

  // ─── CALL STATE ─────────────────────────────────────────────────────────────
  bool _isMuted = false;
  bool _isVideoOff = false;         // local camera off
  bool _remoteVideoOff = false;     // FIX #4: track remote video state
  bool _isSpeakerOn = false;        // starts on earpiece (echo protection)
  bool _callActive = true;
  bool _isEndingCall = false;
  int _callDurationSeconds = 0;
  Timer? _callTimer;
  Timer? _speechAnalysisTimer;

  // ─── TRANSCRIPT + AI ────────────────────────────────────────────────────────
  final List<String> _fullTranscript = [];
  String? _currentAiDefinition;
  String? _currentAiTerm;
  bool _showAiCard = false;
  Timer? _aiCardTimer;

  // ─── ANIMATION ──────────────────────────────────────────────────────────────
  late AnimationController _aiCardController;
  late Animation<Offset> _aiCardSlide;
  late Animation<double> _aiCardFade;

  // ─── FIRESTORE LISTENER ──────────────────────────────────────────────────────
  StreamSubscription? _callStatusListener;

  // ─── CHANNEL NAME ────────────────────────────────────────────────────────────
  String get _channelName {
    final ids = [widget.lawyerId, widget.userId]..sort();
    final raw = '${ids[0]}${ids[1]}'
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toLowerCase();
    return raw.length > 64 ? raw.substring(0, 64) : raw;
  }

  // FIX #3: _callDocId now uses SORTED + underscore pattern matching
  // CallService._sortedDocId() exactly, so _listenForCallEnd reads the
  // same ActiveCalls doc that CallService.updateCallStatus writes to.
  String get _callDocId {
    final ids = [widget.lawyerId, widget.userId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // FIX #4: true when BOTH local and remote video are off → show voice UI
  bool get _isVoiceMode => _isVideoOff && _remoteVideoOff;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initAgoraAndSpeech();
    _startCallTimer();
    _listenForCallEnd();
    _startSpeechAnalysisTimer();
  }

  Future<void> _initAgoraAndSpeech() async {
    await _initAgora();
  }

  // ============================================================
  // _initAnimations
  // ============================================================
  void _initAnimations() {
    _aiCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _aiCardSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _aiCardController,
      curve: Curves.easeOutCubic,
    ));
    _aiCardFade = CurvedAnimation(
      parent: _aiCardController,
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // _initAgora
  // ============================================================
  Future<void> _initAgora() async {
    final statuses =
    await [Permission.microphone, Permission.camera].request();
    if (statuses[Permission.microphone]!.isDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1B2A3B),
            title: const Text('Permission Required',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                'Microphone permission is needed for the call.',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initAgora();
                },
                child: const Text('Retry',
                    style: TextStyle(color: Color(0xFF1E88E5))),
              ),
            ],
          ),
        );
      }
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(
      appId: ApiKeys.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await _engine!.enableAudio();
    await _engine!.enableVideo();

    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 600,
        orientationMode: OrientationMode.orientationModeAdaptive,
        degradationPreference: DegradationPreference.maintainFramerate,
      ),
    );

    // FIX #2: Use audioScenarioChatRoom — this is the ONLY scenario that keeps
    // hardware AEC (echo cancellation) active when the user switches to
    // loudspeaker mode. audioScenarioDefault disables hardware AEC on speaker.
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileSpeechStandard,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    // Stronger echo cancellation + noise suppression
    await _engine!.setParameters('{"che.audio.aec.enable":true}');
    await _engine!.setParameters('{"che.audio.agc.enable":true}');
    await _engine!.setParameters('{"che.audio.ns.enable":true}');
    await _engine!.enableAudio();
    await _engine!.setEnableSpeakerphone(false);

    await _engine!.setRecordingAudioFrameParameters(
      sampleRate: 16000,
      channel: 1,
      mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadOnly,
      samplesPerCall: 1024,
    );

    _engine!.getMediaEngine().registerAudioFrameObserver(
      AudioFrameObserver(
        onRecordAudioFrame: (String channelId, AudioFrame audioFrame) {
          if (!_isMuted && _isListening) {
            final buffer = audioFrame.buffer;
            if (buffer != null) {
              _sttService.feedAudioFrame(buffer);
            }
          }
        },
        onPlaybackAudioFrame: (String channelId, AudioFrame audioFrame) {},
        onMixedAudioFrame: (String channelId, AudioFrame audioFrame) {},
      ),
    );

    await _sttService.start(
      apiKey: ApiKeys.deepgramApiKey,
      onTranscript: (text, isFinal) {
        if (!mounted) return;
        setState(() => _currentTranscript = text);
        if (isFinal && text.isNotEmpty) {
          final speaker = widget.isUser ? 'Client' : 'Lawyer';
          _fullTranscript.add('[$speaker]: $text');
          // FIX #5: Only analyze on final transcript (not interim) to avoid
          // spamming Grok API with partial words mid-sentence.
          _analyzeTranscriptForLegalTerms(text);
        }
      },
    );
    if (mounted) setState(() => _isListening = true);

    await _engine!.enableAudioVolumeIndication(
      interval: 300,
      smooth: 3,
      reportVad: true,
    );

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        if (mounted) setState(() => _localUserJoined = true);
        // Start on earpiece — physically prevents mic picking up speaker audio
        _engine!.setEnableSpeakerphone(false);
        if (mounted) setState(() => _isSpeakerOn = false);
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        if (mounted) {
          setState(() {
            _remoteUid = remoteUid;
            _remoteDropped = false;
          });
          _reconnectTimer?.cancel();
        }
      },

      // FIX #4: Detect when remote user mutes/unmutes their camera
      // so we know when to switch to voice-call UI
      onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
        if (!mounted) return;
        setState(() {
          // state 0 = stopped, state 1 = starting, state 2 = decoding (active)
          _remoteVideoOff = (state == RemoteVideoState.remoteVideoStateStopped ||
              state == RemoteVideoState.remoteVideoStateFrozen);
        });
      },

      // FIX #1: VAD threshold raised from 20 → 50.
      // At 20, any background noise (fan, keyboard, AC) would pause STT.
      // 50 is a good middle ground — only pauses on actual speech volume.
      onAudioVolumeIndication:
          (connection, speakers, speakerNumber, totalVolume) {
        if (!mounted || _isMuted || !_callActive) return;
        bool remoteSpeaking = false;
        for (final speaker in speakers) {
          // FIX #1: threshold raised from 20 to 50
          if (speaker.uid != 0 && (speaker.volume ?? 0) > 50) {
            remoteSpeaking = true;
            break;
          }
        }
        if (remoteSpeaking && _isListening) {
          _sttService.pause();
          if (mounted) setState(() => _isListening = false);
        } else if (!remoteSpeaking && !_isListening && !_isMuted && _callActive) {
          _sttService.resume();
          if (mounted) setState(() => _isListening = true);
        }
      },

      onUserOffline: (connection, remoteUid, reason) {
        if (!mounted) return;
        if (reason == UserOfflineReasonType.userOfflineDropped) {
          setState(() {
            _remoteDropped = true;
            _remoteUid = null;
          });
          _reconnectTimer?.cancel();
          _reconnectTimer = Timer(const Duration(seconds: 30), () {
            if (mounted && _remoteDropped) {
              _endCall(initiatedByOther: true);
            }
          });
        } else {
          setState(() => _remoteUid = null);
          _endCall(initiatedByOther: true);
        }
      },
    ));

    await _engine!.joinChannel(
      token: '',
      channelId: _channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishMicrophoneTrack: true,
        publishCameraTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  // ============================================================
  // _startSpeechAnalysisTimer
  // ============================================================
  void _startSpeechAnalysisTimer() {
    _speechAnalysisTimer =
        Timer.periodic(const Duration(seconds: 30), (_) async {
          if (!_callActive || _fullTranscript.isEmpty) return;
          final lastLine = _fullTranscript.last
              .replaceAll(RegExp(r'^\[.*?\]:\s*'), '');
          await _analyzeTranscriptForLegalTerms(lastLine);
        });
  }

  // ============================================================
  // _analyzeTranscriptForLegalTerms
  // ============================================================
  Future<void> _analyzeTranscriptForLegalTerms(String transcript) async {
    final speaker = widget.isUser ? 'Client' : 'Lawyer';

    await CallService.saveTranscriptLine(
      lawyerId: widget.lawyerId,
      userId: widget.userId,
      speaker: speaker,
      text: transcript,
    );

    final result = await GrokService.detectAndDefine(transcript);

    if (result != null && mounted) {
      _showAiDefinition(result['term']!, result['definition']!);

      await CallService.saveLegalDefinitionToChat(
        lawyerId: widget.lawyerId,
        userId: widget.userId,
        term: result['term']!,
        definition: result['definition']!,
      );
    }
  }

  // ============================================================
  // _showAiDefinition
  // ============================================================
  void _showAiDefinition(String term, String definition) {
    if (_aiCardController.isAnimating) {
      _aiCardController.stop();
    }
    setState(() {
      _currentAiTerm = term;
      _currentAiDefinition = definition;
      _showAiCard = true;
    });
    _aiCardController.forward(from: 0);
    _aiCardTimer?.cancel();
    _aiCardTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        _aiCardController.reverse().then((_) {
          if (mounted) setState(() => _showAiCard = false);
        });
      }
    });
  }

  // ============================================================
  // _startCallTimer
  // ============================================================
  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callDurationSeconds++);
    });
  }

  // ============================================================
  // _listenForCallEnd — FIX #3: now uses _callDocId (sorted with underscore)
  // which matches CallService._sortedDocId exactly
  // ============================================================
  void _listenForCallEnd() {
    _callStatusListener = FirebaseFirestore.instance
        .collection('ActiveCalls')
        .doc(_callDocId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final status = snapshot.data()?['status'];
      if (status == 'ended' && mounted && _callActive) {
        _endCall(initiatedByOther: true);
      }
    });
  }

  // ============================================================
  // _endCall
  // ============================================================
  Future<void> _endCall({bool initiatedByOther = false}) async {
    if (!_callActive || _isEndingCall) return;
    _isEndingCall = true;

    setState(() => _callActive = false);

    _callTimer?.cancel();
    _speechAnalysisTimer?.cancel();
    _aiCardTimer?.cancel();
    _reconnectTimer?.cancel();
    await _sttService.stop();

    await _engine?.leaveChannel();

    if (!initiatedByOther) {
      await CallService.updateCallStatus(
        lawyerId: widget.lawyerId,
        userId: widget.userId,
        status: 'ended',
      );
    }

    if (!initiatedByOther) {
      // Only the person who ended the call generates and saves the summary
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _SummaryLoadingDialog(),
        );
      }

      final fullLines = await CallService.getFullTranscript(
        lawyerId: widget.lawyerId,
        userId: widget.userId,
      );
      final summary = await GrokService.generateCallSummary(fullLines);

      final currentUserEmail =
      FirebaseAuth.instance.currentUser!.email.toString();
      await CallService.saveSummaryToChat(
        lawyerId: widget.lawyerId,
        userId: widget.userId,
        summary: '📞 Call Summary\n\n$summary\n\n'
            '⏱ Duration: ${_formatDuration(_callDurationSeconds)}',
        senderId: currentUserEmail,
      );

      await CallService.deleteTranscript(
        lawyerId: widget.lawyerId,
        userId: widget.userId,
      );

      try {
        await CallService.deleteCallDoc(
          lawyerId: widget.lawyerId,
          userId: widget.userId,
        );
      } catch (_) {}

      if (mounted) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      }
    } else {
      // Other side just exits the call screen
      if (mounted) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      }
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _speechAnalysisTimer?.cancel();
    _aiCardTimer?.cancel();
    _reconnectTimer?.cancel();
    _sttService.stop();
    _aiCardController.dispose();
    _callStatusListener?.cancel();
    if (_callActive) {
      _engine?.leaveChannel();
    }
    _engine?.release();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // FIX #4: Switch between video layout and voice-call avatar layout
          _isVoiceMode ? _buildVoiceCallView() : _buildVideoView(),
          _buildTopOverlay(),
          if (_showAiCard)
            _buildAiDefinitionCard()
          else if (_currentTranscript.isNotEmpty)
            _buildTranscriptTicker(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildControlBar(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIX #4: _buildVoiceCallView — WhatsApp-style voice call UI
  // Shows when BOTH local and remote video are off.
  // ============================================================
  Widget _buildVoiceCallView() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2137), Color(0xFF0A1628)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated pulsing avatar ring
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1.05),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.otherPersonImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1B2A3B),
                      child: const Icon(Icons.person,
                          color: Colors.white54, size: 60),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.otherPersonName,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Voice Call · ${_formatDuration(_callDurationSeconds)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontFamily: 'roboto',
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Show "Camera Off" badge
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off,
                      color: Colors.white54, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Camera off',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'roboto',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // _buildVideoView — standard video grid (shown when video is on)
  // ============================================================
  Widget _buildVideoView() {
    return Positioned.fill(
      child: Stack(
        children: [
          _remoteUid != null && !_remoteVideoOff
              ? AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine!,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: _channelName),
            ),
          )
              : Container(
            color: const Color(0xFF0A1628),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show avatar if remote video is off
                  if (_remoteVideoOff && _remoteUid != null) ...[
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: (widget.otherPersonImage != 'null' && widget.otherPersonImage.isNotEmpty)
                          ? NetworkImage(widget.otherPersonImage)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.otherPersonName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'roboto',
                          fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Camera off',
                      style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'roboto',
                          fontSize: 13),
                    ),
                  ] else ...[
                    const CircularProgressIndicator(
                        color: Color(0xFF1E88E5)),
                    const SizedBox(height: 16),
                    Text(
                      _remoteDropped
                          ? 'Reconnecting...'
                          : 'Waiting for other person...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 16,
                      ),
                    ),
                    if (_remoteDropped) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Will end in 30s if not reconnected',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontFamily: 'roboto',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // Local video preview (bottom-right pip)
          if (_localUserJoined && _engine != null && !_isVideoOff)
            Positioned(
              top: 100,
              right: 16,
              child: SizedBox(
                width: 100,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildTopOverlay
  // ============================================================
  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent
              ],
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: (widget.otherPersonImage != 'null' && widget.otherPersonImage.isNotEmpty)
                    ? NetworkImage(widget.otherPersonImage)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherPersonName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.isUser ? 'Lawyer' : 'Client',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontFamily: 'roboto',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _remoteDropped
                            ? Colors.orange
                            : const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(_callDurationSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildTranscriptTicker
  // ============================================================
  Widget _buildTranscriptTicker() {
    return Positioned(
      bottom: 130,
      left: 16,
      right: 16,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Icon(Icons.mic, color: Color(0xFF4CAF50), size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _currentTranscript,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'roboto',
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // _buildAiDefinitionCard
  // ============================================================
  Widget _buildAiDefinitionCard() {
    return Positioned(
      bottom: 130,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _aiCardSlide,
        child: FadeTransition(
          opacity: _aiCardFade,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2137).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color:
                  const Color(0xFF1E88E5).withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('⚖️',
                          style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'AI Legal Assistant',
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _aiCardTimer?.cancel();
                        _aiCardController.reverse().then((_) {
                          if (mounted)
                            setState(() => _showAiCard = false);
                        });
                      },
                      child: const Icon(Icons.close,
                          color: Colors.white38, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _currentAiTerm ?? '',
                    style: const TextStyle(
                      color: Color(0xFF64B5F6),
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentAiDefinition ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFamily: 'roboto',
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saved to your chat ✓',
                  style: TextStyle(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
                    fontFamily: 'roboto',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildControlBar
  // FIX #2: Speaker toggle now sets audioScenarioChatRoom (keeps AEC active)
  // FIX #4: Video button label reflects current mode (Video/Voice)
  // ============================================================
  Widget _buildControlBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.transparent
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            color: _isMuted ? Colors.red : Colors.white,
            bgColor: _isMuted
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.15),
            onTap: () async {
              setState(() => _isMuted = !_isMuted);
              await _engine?.muteLocalAudioStream(_isMuted);
              if (_isMuted) {
                _sttService.pause();
                if (mounted) setState(() => _isListening = false);
              } else {
                _sttService.resume();
                if (mounted) setState(() => _isListening = true);
              }
            },
          ),

          // FIX #4: Video toggle — switches between video and voice UI
          _buildControlButton(
            icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
            label: _isVideoOff ? 'Video' : 'Hide',
            color: _isVideoOff ? Colors.orange : Colors.white,
            bgColor: _isVideoOff
                ? Colors.orange.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.15),
            onTap: () async {
              setState(() => _isVideoOff = !_isVideoOff);
              await _engine?.muteLocalVideoStream(_isVideoOff);
              // When turning video back on, re-enable local camera preview
              if (!_isVideoOff) {
                await _engine?.enableLocalVideo(true);
              }
            },
          ),

          // End call button
          GestureDetector(
            onTap: () => _confirmEndCall(),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF5350).withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child:
              const Icon(Icons.call_end, color: Colors.white, size: 30),
            ),
          ),

          // FIX #2: Speaker toggle — audioScenarioChatRoom keeps AEC active
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
            color: _isSpeakerOn ? Colors.white : Colors.grey,
            bgColor: Colors.white.withValues(alpha: 0.15),
            onTap: () async {
              setState(() => _isSpeakerOn = !_isSpeakerOn);
              await _engine?.setEnableSpeakerphone(_isSpeakerOn);
              // FIX #2: Always keep audioScenarioChatRoom — it preserves
              // hardware AEC on BOTH earpiece and loudspeaker mode.
              // The old audioScenarioDefault disables AEC when on speaker.
              await _engine?.setAudioProfile(
                profile: AudioProfileType.audioProfileSpeechStandard,
                scenario: AudioScenarioType.audioScenarioChatroom,
              );
            },
          ),

          // AI status button
          _buildControlButton(
            icon: Icons.psychology,
            label: 'AI On',
            color: const Color(0xFF4CAF50),
            bgColor: const Color(0xFF4CAF50).withValues(alpha: 0.15),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI is listening for legal terms...'),
                  backgroundColor: Color(0xFF1E88E5),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildControlButton
  // ============================================================
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'roboto',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _confirmEndCall
  // ============================================================
  void _confirmEndCall() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B2A3B),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'End Call?',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'The AI will generate a summary of this consultation and save it to your chat.',
          style: TextStyle(
              color: Colors.white70,
              fontFamily: 'roboto',
              fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _endCall();
            },
            child: const Text(
              'End Call',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _SummaryLoadingDialog
// ══════════════════════════════════════════════════════════════════════════════
class _SummaryLoadingDialog extends StatelessWidget {
  const _SummaryLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B2A3B),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1E88E5)),
            const SizedBox(height: 20),
            const Text(
              'Generating Call Summary',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI is summarizing your consultation...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontFamily: 'roboto',
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}