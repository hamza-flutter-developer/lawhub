import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'ApiKeys.dart';

class GrokService {
  static const String _apiKey = ApiKeys.groqApiKey;
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  // No cooldown — every sentence is checked independently.
  // Each FINAL transcript line from Deepgram is a different sentence,
  // so even if the same section is mentioned again in a new sentence it will
  // still be detected and shown.

  // ============================================================
  // detectAndDefine — detects legal terms and law sections
  // ============================================================
  static Future<Map<String, String>?> detectAndDefine(String transcript) async {
    if (transcript.trim().isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
              'You are a legal assistant AI in a lawyer-client call app in Pakistan. '
                  'Detect ANY legal term, law section, or legal jargon spoken. '
                  'This includes Pakistani laws like PPC sections (Section 302, Section 301, etc.), '
                  'CrPC, FIR, bail, habeas corpus, contempt of court, writ petition, '
                  'suo motu, injunction, stay order, PMLA, NAB, etc. '
                  'If you detect a legal term or section reference: '
                  'Respond ONLY with valid JSON: '
                  '{"term": "exact term or section", "definition": "simple 1-2 sentence plain English explanation"} '
                  'If NO legal term detected, respond ONLY with: {"term": null, "definition": null} '
                  'No markdown, no extra text. Only JSON.'
            },
            {
              'role': 'user',
              'content': 'Detect any legal term in this transcript: "$transcript"'
            }
          ],
          'max_tokens': 300,
          'temperature': 0.1,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[Grok] detectAndDefine timed out');
          return http.Response('{"error": "timeout"}', 408);
        },
      );

      if (response.statusCode == 429) {
        print('[Grok] Rate limit hit');
        return null;
      }
      if (response.statusCode == 408) return null;
      if (response.statusCode == 401) {
        print('[Grok] Invalid API key');
        return null;
      }
      if (response.statusCode == 400) {
        print('[Grok] Bad request: ${response.body}');
        return null;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['choices'] == null || data['choices'].isEmpty) return null;

        final finishReason = data['choices'][0]['finish_reason'];
        if (finishReason == 'length') {
          print('[Grok] Token limit hit on detect');
          return null;
        }

        final content = data['choices'][0]['message']['content']?.toString().trim();
        if (content == null || content.isEmpty) return null;

        Map<String, dynamic> parsed;
        try {
          final cleaned = content
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
          parsed = jsonDecode(cleaned);
        } catch (e) {
          print('[Grok] JSON parse failed: $e — raw: $content');
          return null;
        }

        if (parsed['term'] == null || parsed['definition'] == null) return null;

        print('[Grok] Detected legal term: "${parsed['term']}"');
        return {
          'term': parsed['term'].toString(),
          'definition': parsed['definition'].toString(),
        };
      } else {
        print('[Grok] Unexpected status: ${response.statusCode} — ${response.body}');
      }
    } on TimeoutException {
      print('[Grok] Timeout on detectAndDefine');
    } on FormatException catch (e) {
      print('[Grok] Format error: $e');
    } catch (e) {
      print('[Grok] Unexpected error: $e');
    }

    return null;
  }

  // ============================================================
  // generateCallSummary — summarizes full call transcript
  // ============================================================
  static Future<String> generateCallSummary(List<String> transcriptLines) async {
    if (transcriptLines.isEmpty) {
      return 'No transcript available for this call.';
    }

    // Trim if too long — keep first 20 + last 80 lines
    List<String> trimmedLines = transcriptLines;
    if (transcriptLines.length > 100) {
      trimmedLines = [
        ...transcriptLines.take(20),
        '... [middle of conversation trimmed] ...',
        ...transcriptLines.skip(transcriptLines.length - 80),
      ];
      print('[Grok] Transcript trimmed: ${transcriptLines.length} → ${trimmedLines.length} lines');
    }

    final fullTranscript = trimmedLines.join('\n');
    print('[Grok] Generating summary for ${trimmedLines.length} transcript lines...');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
              'You are a legal consultation assistant in Pakistan. '
                  'Summarize the following lawyer-client call transcript in 3-5 bullet points. '
                  'Focus on: main legal issue discussed, legal advice given, '
                  'any sections or laws referenced (PPC, CrPC, etc.), next steps. '
                  'Keep it concise and professional. '
                  'Start directly with bullet points (use • symbol). No intro sentence.'
            },
            {
              'role': 'user',
              'content': 'Summarize this consultation:\n\n$fullTranscript'
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.3,
        }),
      ).timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          print('[Grok] generateCallSummary timed out');
          return http.Response('{"error": "timeout"}', 408);
        },
      );

      if (response.statusCode == 429) {
        return 'AI summary unavailable — rate limit reached. Please try again later.';
      }
      if (response.statusCode == 408) {
        return 'AI summary timed out. The call has ended.';
      }
      if (response.statusCode == 401) {
        return 'AI summary unavailable — invalid API key.';
      }
      if (response.statusCode == 400) {
        print('[Grok] Summary bad request: ${response.body}');
        return 'AI summary unavailable — request error.';
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['choices'] == null || data['choices'].isEmpty) {
          return 'Summary could not be generated.';
        }

        final finishReason = data['choices'][0]['finish_reason'];
        final content = data['choices'][0]['message']['content']?.toString().trim() ?? '';

        if (finishReason == 'length') {
          return '$content\n\n⚠️ Summary trimmed due to length.';
        }

        print('[Grok] Summary generated (${content.length} chars)');
        return content.isNotEmpty ? content : 'Summary could not be generated.';
      } else {
        print('[Grok] Summary unexpected status: ${response.statusCode} — ${response.body}');
      }
    } on TimeoutException {
      return 'AI summary timed out. The call has ended.';
    } on FormatException catch (e) {
      print('[Grok] Summary format error: $e');
      return 'Summary formatting error.';
    } catch (e) {
      print('[Grok] Summary error: $e');
    }

    return 'Summary could not be generated.';
  }
}