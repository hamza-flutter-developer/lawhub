import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../Call_Pages/ApiKeys.dart';

class LegalChatbotService {
  static const String _apiKey = ApiKeys.groqApiKey;
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  static Future<String> chat(
      String userMessage, List<Map<String, String>> history) async {
    if (userMessage.trim().isEmpty) return 'Please type a message.';

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are LawHub AI, a legal assistant specializing in Pakistani law '
                '(PPC, CrPC, CPC, Constitution of Pakistan, Family Courts Act, NAB, PMLA, etc.) '
                'and international legal concepts. '
                'You ONLY answer law-related questions. If the user asks something unrelated to law, '
                'politely decline and say you can only help with legal queries. '
                'Keep answers concise (3-6 sentences) unless the user asks for detail. '
                'Cite relevant sections and acts when applicable. '
                'Use simple English so non-lawyers can understand.',
      },
      ...history.take(20),
      {'role': 'user', 'content': userMessage},
    ];

    return _callApi(messages, maxTokens: 1500, temperature: 0.4);
  }

  static Future<String> searchCases(String caseDescription) async {
    if (caseDescription.trim().isEmpty) {
      return 'Please describe the case details.';
    }

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are a legal research AI for verified lawyers on the LawHub platform. '
                'The lawyer will describe a case. Your job is to find relevant legal precedents. '
                'Search your knowledge for cases from Pakistan (PLD, SCMR, PCrLJ, MLD, CLC, YLR, NLR) first. '
                'If no strong Pakistani precedents exist, include American or international cases. '
                '\n\n'
                'For EACH case found, provide:\n'
                '• Case name and citation\n'
                '• Court and year\n'
                '• Brief facts (2-3 sentences)\n'
                '• Verdict and key ruling\n'
                '\n'
                'After listing cases, provide a SUMMARY section:\n'
                '• Total related cases found\n'
                '• Win/loss breakdown (how many times the accused/defendant won vs prosecution/plaintiff)\n'
                '• Common legal arguments that succeeded\n'
                '• Recommended legal strategy based on precedents\n'
                '\n'
                'Be thorough but accurate. If you are uncertain about a case, say so. '
                'Do not fabricate citations — if you cannot recall the exact citation, '
                'describe the case by name and approximate year. '
                'Format with clear headings and bullet points.',
      },
      {'role': 'user', 'content': caseDescription},
    ];

    return _callApi(messages, maxTokens: 4000, temperature: 0.3, timeout: 45);
  }

  static Future<String> _callApi(
    List<Map<String, String>> messages, {
    int maxTokens = 1500,
    double temperature = 0.4,
    int timeout = 25,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'max_tokens': maxTokens,
              'temperature': temperature,
            }),
          )
          .timeout(Duration(seconds: timeout));

      if (response.statusCode == 429) {
        return 'Rate limit reached. Please wait a moment and try again.';
      }
      if (response.statusCode == 401) {
        return 'AI service authentication error. Please contact support.';
      }
      if (response.statusCode != 200) {
        return 'AI service error (${response.statusCode}). Please try again.';
      }

      final data = jsonDecode(response.body);
      if (data['choices'] == null || (data['choices'] as List).isEmpty) {
        return 'No response generated. Please try again.';
      }

      final content =
          data['choices'][0]['message']['content']?.toString().trim() ?? '';
      if (content.isEmpty) return 'Empty response. Please rephrase your question.';

      return content;
    } on TimeoutException {
      return 'Request timed out. Please try again.';
    } catch (e) {
      return 'Connection error. Please check your internet and try again.';
    }
  }
}
