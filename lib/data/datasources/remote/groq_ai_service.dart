import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/ai_generated_content_model.dart';

class GroqAiService {
  final String _apiKey;
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _modelName = 'openai/gpt-oss-120b';

  GroqAiService({required String apiKey}) : _apiKey = apiKey.trim();

  void _ensureApiKeyConfigured() {
    if (_apiKey.isEmpty) {
      throw StateError(
        'GROQ_API_KEY is not configured. Run Flutter with '
        '--dart-define=GROQ_API_KEY=your_groq_api_key.',
      );
    }
  }

  Future<String> _generateText(
    String prompt, {
    bool jsonResponse = false,
  }) async {
    _ensureApiKeyConfigured();
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _modelName,
        'temperature': 0.2,
        'max_tokens': 8192,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        if (jsonResponse) 'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = 'HTTP ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['error']?['message'];
        if (message is String && message.isNotEmpty) detail = message;
      } catch (_) {
        // Keep the HTTP status when Groq does not return JSON.
      }
      throw Exception('Groq request failed: $detail');
    }

    final body = jsonDecode(response.body);
    final content = body['choices']?[0]?['message']?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw const FormatException('The AI returned an empty response.');
    }
    return content.trim();
  }

  // 1. Summarize Note (Returns SummaryResult with Short, Detailed, Key Points, Terms)
  Future<SummaryResult> summarizeContent(String text) async {
    final prompt = '''
Analyze the following study note and generate a structured summary in JSON format.
Return ONLY a valid JSON object without markdown formatting or code blocks.

The JSON object must contain these exact keys:
- "shortSummary": A brief 2-3 sentence overview.
- "detailedSummary": A detailed paragraph explaining the main concept thoroughly.
- "keyPoints": A list of key takeaway points (strings).
- "importantTerms": An object/map with key-value pairs where key is the Term and value is its Definition/Explanation.

Text:
<study_note>
$text
</study_note>
''';

    final rawText = await _generateText(prompt, jsonResponse: true);

    // Clean JSON formatting if enclosed in code blocks
    final cleanJson =
        rawText.replaceAll('```json', '').replaceAll('```', '').trim();

    final Map<String, dynamic> jsonMap = jsonDecode(cleanJson);
    return SummaryResult.fromJson(jsonMap);
  }

  // 2. Generate Exam Prep Questions
  Future<Map<String, dynamic>> generateExamPrep(
    String text,
    Set<String> questionTypes,
    int questionCount,
  ) async {
    final requestedTypes = questionTypes.join(', ');
    final formatSections = <String>[
      if (questionTypes.contains('mcqs'))
        '''"mcqs": [
    {
      "question": "Question text",
      "options": ["Opt 1", "Opt 2", "Opt 3", "Opt 4"],
      "correctOptionIndex": 0,
      "explanation": "Brief explanation for the correct answer"
    }
  ]''',
      if (questionTypes.contains('essays'))
        '''"essays": [
    {
      "question": "Question text",
      "sampleAnswer": "Sample answer points",
      "keyPoints": ["Key point 1", "Key point 2"]
    }
  ]''',
      if (questionTypes.contains('shortAnswers'))
        '''"shortAnswers": [
    {
      "question": "Question text",
      "answer": "Expected short answer"
    }
  ]''',
    ];
    final prompt = '''
Based on the following text, generate exactly $questionCount questions for each requested type: $requestedTypes.
Return ONLY a valid JSON object without markdown formatting or code blocks.
Return only the requested keys. Do not include explanations outside the JSON object.

Required JSON format:
{
  ${formatSections.join(',\n  ')}
}

Do not generate extra questions.

Text:
$text
''';

    final rawText = await _generateText(prompt, jsonResponse: true);

    final jsonMap = _decodeJsonObject(rawText);
    for (final key in const ['mcqs', 'essays', 'shortAnswers']) {
      final value = jsonMap[key];
      if (value == null && !questionTypes.contains(key)) {
        jsonMap[key] = <dynamic>[];
      } else if (value is! List) {
        throw FormatException('Missing or invalid "$key" questions.');
      }
    }
    return jsonMap;
  }

  Map<String, dynamic> _decodeJsonObject(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) {
      throw const FormatException('The AI returned an empty response.');
    }

    final objectStart = text.indexOf('{');
    final objectEnd = text.lastIndexOf('}');
    if (objectStart == -1 || objectEnd <= objectStart) {
      throw const FormatException('The AI response did not contain JSON.');
    }

    final jsonText = text.substring(objectStart, objectEnd + 1);
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('The AI response was not a JSON object.');
      }
      return decoded;
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('The AI returned malformed JSON: $error');
    }
  }

  // 3. Translate Note Content
  Future<String> translateContent(String text, String targetLanguage) async {
    final prompt =
        'Translate the following study text accurately into $targetLanguage while maintaining academic accuracy and natural tone:\n\n$text';

    final translated = (await _generateText(prompt)).trim();
    if (translated.isEmpty) {
      throw const FormatException('The AI returned an empty translation.');
    }

    try {
      final decoded = jsonDecode(translated);
      if (decoded is Map<String, dynamic>) {
        final translation = decoded['translation'] ?? decoded['translatedText'];
        if (translation is String && translation.trim().isNotEmpty) {
          return translation.trim();
        }
      }
    } on FormatException {
      // The model may return a normal plain-text translation.
    }

    return translated.replaceAll('```json', '').replaceAll('```', '').trim();
  }

  Future<String> translateExamPrep(String text, String targetLanguage) async {
    final prompt = '''
Translate these exam-preparation questions into $targetLanguage.
Return readable plain text only. Do not return JSON, Markdown code fences, or code.
Keep the question types, question numbers, answer choices, and answers clear.

Questions:
$text
''';

    final translated = (await _generateText(prompt)).trim();
    if (translated.isEmpty) {
      throw const FormatException('The AI returned an empty translation.');
    }
    return translated.replaceAll('```json', '').replaceAll('```', '').trim();
  }
}
