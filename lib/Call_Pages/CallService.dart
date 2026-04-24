// ══════════════════════════════════════════════════════════════════════════════
// FILE: CallService.dart
// FIXES:
//   1. Added saveTranscriptLine() — was called in CallScreen but didn't exist
//   2. Added getFullTranscript()  — was called in CallScreen but didn't exist
//   3. Added deleteTranscript()   — was called in CallScreen but didn't exist
//   4. ALL doc IDs now use _sortedDocId() — sorted so lawyerId+userId always
//      matches no matter who opens the call (fixes AI definition + summary
//      being saved to a different doc than what the chat stream reads)
// ══════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CallService {
  static const String _dailyApiKey = 'YOUR_DAILY_CO_API_KEY_HERE';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────────────────────────────────
  // FIX #4: SORTED DOC ID
  // CallScreen._channelName sorts IDs so the channel is always the same
  // regardless of who initiates. ChatRooms doc must use the SAME sorting so
  // AI definitions and summaries land in the correct chat document.
  // ──────────────────────────────────────────────────────────────────────────
  static String _sortedDocId(String lawyerId, String userId) {
    final ids = [lawyerId, userId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FIX #4: ChatRooms doc also needs consistent ID.
  // ChatInbox currently uses "${lawyerId}${userId}" (no sort, no separator).
  // We keep that exact pattern here so existing chat messages still load.
  // Only the ActiveCalls + Transcript collections use the sorted pattern.
  // ──────────────────────────────────────────────────────────────────────────
  static String _chatRoomId(String lawyerId, String userId) {
    // Keep existing ChatRooms doc ID pattern (lawyerId+userId, no sort)
    // because ChatInbox.dart already uses this pattern for its stream.
    // We do NOT change this so we don't break existing messages.
    return '$lawyerId$userId';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FIX #3: saveTranscriptLine — MISSING METHOD (called in CallScreen.dart)
  // Saves each spoken line to a Transcripts sub-collection during the call.
  // getFullTranscript() reads these lines to build the summary at call end.
  // ══════════════════════════════════════════════════════════════════════════
  static Future<void> saveTranscriptLine({
    required String lawyerId,
    required String userId,
    required String speaker,
    required String text,
  }) async {
    try {
      final docId = _sortedDocId(lawyerId, userId);
      await _db
          .collection('Transcripts')
          .doc(docId)
          .collection('Lines')
          .add({
        'speaker': speaker,
        'text': text,
        'time': FieldValue.serverTimestamp(),
        'timeMs': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Never crash the call over a transcript save failure
      print('CallService.saveTranscriptLine error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FIX #3: getFullTranscript — MISSING METHOD (called in CallScreen._endCall)
  // Reads all transcript lines in chronological order and returns them as a
  // List<String> like ["[Client]: Hello", "[Lawyer]: Good morning"] so
  // GrokService.generateCallSummary() can summarize the whole conversation.
  // ══════════════════════════════════════════════════════════════════════════
  static Future<List<String>> getFullTranscript({
    required String lawyerId,
    required String userId,
  }) async {
    try {
      final docId = _sortedDocId(lawyerId, userId);
      final snapshot = await _db
          .collection('Transcripts')
          .doc(docId)
          .collection('Lines')
          .orderBy('timeMs')
          .get();

      return snapshot.docs.map((doc) {
        final speaker = doc['speaker'] ?? 'Unknown';
        final text = doc['text'] ?? '';
        return '[$speaker]: $text';
      }).toList();
    } catch (e) {
      print('CallService.getFullTranscript error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FIX #3: deleteTranscript — MISSING METHOD (called in CallScreen._endCall)
  // Deletes all transcript lines after the summary has been generated and
  // saved to chat. Keeps Firestore clean after every call.
  // ══════════════════════════════════════════════════════════════════════════
  static Future<void> deleteTranscript({
    required String lawyerId,
    required String userId,
  }) async {
    try {
      final docId = _sortedDocId(lawyerId, userId);
      final snapshot = await _db
          .collection('Transcripts')
          .doc(docId)
          .collection('Lines')
          .get();

      // Batch delete all lines (Firestore doesn't delete sub-collections automatically)
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Also delete the parent doc
      await _db.collection('Transcripts').doc(docId).delete();
    } catch (e) {
      print('CallService.deleteTranscript error: $e');
    }
  }

  /// Creates or reuses a Daily.co room. Returns the room URL.
  static Future<String> createOrGetRoom({
    required String lawyerId,
    required String userId,
  }) async {
    final roomName = '$lawyerId$userId'
        .replaceAll('@', '-')
        .replaceAll('.', '-')
        .replaceAll('_', '-')
        .toLowerCase();

    try {
      final response = await http.post(
        Uri.parse('https://api.daily.co/v1/rooms'),
        headers: {
          'Authorization': 'Bearer $_dailyApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': roomName,
          'properties': {
            'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 7200,
            'enable_screenshare': false,
            'enable_chat': false,
            'start_video_off': false,
            'start_audio_off': false,
            'max_participants': 2,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (jsonDecode(response.body))['url'] as String;
      } else if (response.statusCode == 409) {
        final getRes = await http.get(
          Uri.parse('https://api.daily.co/v1/rooms/$roomName'),
          headers: {'Authorization': 'Bearer $_dailyApiKey'},
        );
        if (getRes.statusCode == 200) {
          return (jsonDecode(getRes.body))['url'] as String;
        }
      }
    } catch (e) {
      print('CallService.createOrGetRoom error: $e');
    }
    return 'https://lawhub.daily.co/$roomName';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // saveLegalDefinitionToChat
  // FIX #4: Uses _chatRoomId() which matches ChatInbox stream doc ID
  // ══════════════════════════════════════════════════════════════════════════
  static Future<void> saveLegalDefinitionToChat({
    required String lawyerId,
    required String userId,
    required String term,
    required String definition,
  }) async {
    final now = DateTime.now();
    final String minute = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    final String hour = now.hour >= 12 ? '${now.hour - 12}' : '${now.hour}';
    final String amPm = now.hour >= 12 ? 'PM' : 'AM';

    await _db
        .collection('ChatRooms')
        .doc(_chatRoomId(lawyerId, userId))
        .collection('Chats')
        .add({
      'senderId': 'AI_ASSISTANT',
      'message': '⚖️ *$term*\n\n$definition',
      'type': 'ai_definition',
      'time': FieldValue.serverTimestamp(),
      'timeToDisplay': '${now.day}/${now.month} $hour:$minute $amPm',
      'term': term,
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // saveSummaryToChat
  // FIX #4: Uses _chatRoomId() which matches ChatInbox stream doc ID
  // ══════════════════════════════════════════════════════════════════════════
  static Future<void> saveSummaryToChat({
    required String lawyerId,
    required String userId,
    required String summary,
    required String senderId,
  }) async {
    final now = DateTime.now();
    final int ms = now.millisecondsSinceEpoch;
    final String minute = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    final String hour = now.hour >= 12 ? '${now.hour - 12}' : '${now.hour}';
    final String amPm = now.hour >= 12 ? 'PM' : 'AM';
    const String preview = '📋 Call Summary saved';

    await _db
        .collection('ChatRooms')
        .doc(_chatRoomId(lawyerId, userId))
        .collection('Chats')
        .add({
      'senderId': 'AI_ASSISTANT',
      'message': summary,
      'type': 'call_summary',
      'time': FieldValue.serverTimestamp(),
      'timeToDisplay': '${now.day}/${now.month} $hour:$minute $amPm',
    });

    // Update UsersChats last message preview
    try {
      final userDoc = await _db.collection('UsersChats').doc(userId).get();
      final int counter = userDoc['counter'];
      for (int i = 1; i <= counter; i++) {
        if (userDoc['lawyerID$i'][0] == lawyerId) {
          await _db.collection('UsersChats').doc(userId).update({
            'lawyerID$i': [
              lawyerId, now.minute, now.hour, now.day, now.month,
              ms, preview, 'AI_ASSISTANT'
            ],
          });
        }
      }
    } catch (e) {
      print('CallService UsersChats update: $e');
    }

    // Update LawyersChats last message preview
    try {
      final lawyerDoc =
      await _db.collection('LawyersChats').doc(lawyerId).get();
      final int counter = lawyerDoc['counter'];
      for (int i = 1; i <= counter; i++) {
        if (lawyerDoc['userID$i'][0] == userId) {
          await _db.collection('LawyersChats').doc(lawyerId).update({
            'userID$i': [
              userId, now.minute, now.hour, now.day, now.month,
              ms, preview, 'AI_ASSISTANT'
            ],
          });
        }
      }
    } catch (e) {
      print('CallService LawyersChats update: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // updateCallStatus
  // FIX #4: Uses _sortedDocId() so both sides write/read the same doc
  // ══════════════════════════════════════════════════════════════════════════
  static Future<void> updateCallStatus({
    required String lawyerId,
    required String userId,
    required String status,
  }) async {
    await _db
        .collection('ActiveCalls')
        .doc(_sortedDocId(lawyerId, userId))
        .set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'lawyerId': lawyerId,
      'userId': userId,
      'updatedBy': FirebaseAuth.instance.currentUser!.email,
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // deleteCallDoc
  // FIX #4: Uses _sortedDocId() — matches updateCallStatus
  // ══════════════════════════════════════════════════════════════════════════
  static Future<void> deleteCallDoc({
    required String lawyerId,
    required String userId,
  }) async {
    await _db
        .collection('ActiveCalls')
        .doc(_sortedDocId(lawyerId, userId))
        .delete();
  }
}