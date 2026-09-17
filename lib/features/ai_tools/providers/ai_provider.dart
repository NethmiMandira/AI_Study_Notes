import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_study_notes/data/datasources/remote/gemini_ai_service.dart';
import 'package:ai_study_notes/data/models/ai_generated_content_model.dart';

class AiProvider extends ChangeNotifier {
  final GeminiAiService _aiService;

  AiProvider({required GeminiAiService aiService}) : _aiService = aiService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SummaryResult? _summaryResult;
  SummaryResult? get summaryResult => _summaryResult;

  String _translatedText = '';
  String get translatedText => _translatedText;

  List<dynamic> _mcqs = [];
  List<dynamic> get mcqs => _mcqs;

  List<dynamic> _essays = [];
  List<dynamic> get essays => _essays;

  List<dynamic> _shortAnswers = [];
  List<dynamic> get shortAnswers => _shortAnswers;

  String _translatedExamPrep = '';
  String get translatedExamPrep => _translatedExamPrep;

  void clearTranslatedExamPrep() {
    _translatedExamPrep = '';
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Summarize Action
  Future<void> summarize(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      _summaryResult = null;
      _errorMessage = 'There is no note content to summarize.';
      notifyListeners();
      return;
    }

    _summaryResult = null;
    _setLoading(true);
    _errorMessage = null;
    try {
      _summaryResult = await _aiService.summarizeContent(trimmedText);
    } catch (error) {
      _errorMessage = _friendlyErrorMessage(error);
    } finally {
      _setLoading(false);
    }
  }

  String _friendlyErrorMessage(Object error) {
    debugPrint('AI service error: $error');
    final rawMessage = error.toString();
    final message = rawMessage.toLowerCase();

    if (message.contains('503') ||
      message.contains('high demand') ||
      message.contains('spikes in demand')) {
      return 'The AI service is currently experiencing high demand. Please try again in a few moments.';
    }
    if (message.contains('429') ||
        message.contains('resource exhausted') ||
        message.contains('rate limit') ||
        message.contains('quota')) {
      return 'Rate limit reached. Please wait a moment before trying again.';
    }
    if (message.contains('socket') ||
        message.contains('network') ||
        message.contains('timeout')) {
      return 'Could not reach the AI service. Check your connection and try again.';
    }
    if (message.contains('401') ||
        message.contains('unauthenticated') ||
        message.contains('unauthorized')) {
      return 'Authentication failed. Please check your AI service configuration.';
    }

    if (message.contains('api key') || message.contains('unauthorized')) {
      return 'The AI service is not configured correctly. Check the Gemini API key.';
    }
    if (message.contains('not found') || message.contains('not available')) {
      return 'The selected Gemini model is unavailable for this account. Update the model configuration and try again.';
    }
    if (error is FormatException) {
      return 'The AI response was invalid: ${error.message}';
    }

    final detail = rawMessage
        .replaceAll(RegExp(r'GenerativeAIException:?\s*'), '')
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .trim();
    return 'AI request failed (${error.runtimeType}):$detail';
  }

  // Exam Prep Action
  Future<void> generateExamPrep(
    String text,
    Set<String> questionTypes,
    int questionCount,
  ) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      _errorMessage = 'There is no note content to generate questions from.';
      notifyListeners();
      return;
    }
    if (questionTypes.isEmpty) {
      _errorMessage = 'Select at least one question type.';
      notifyListeners();
      return;
    }
    if (questionCount < 1 || questionCount > 20) {
      _errorMessage = 'Choose between 1 and 20 questions per type.';
      notifyListeners();
      return;
    }

    _mcqs = [];
    _essays = [];
    _shortAnswers = [];
    _translatedExamPrep = '';
    _setLoading(true);
    _errorMessage = null;
    try {
      final data = await _aiService.generateExamPrep(
        trimmedText,
        questionTypes,
        questionCount,
      );
      _mcqs = data['mcqs'] ?? [];
      _essays = data['essays'] ?? [];
      _shortAnswers = data['shortAnswers'] ?? [];
    } catch (error) {
      _errorMessage = _friendlyErrorMessage(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> translateExamPrep(String content, String language) async {
    final trimmedContent = content.trim();
    final trimmedLanguage = language.trim();
    if (trimmedContent.isEmpty) {
      _errorMessage = 'Generate exam questions before translating them.';
      notifyListeners();
      return;
    }
    if (trimmedLanguage.isEmpty) {
      _errorMessage = 'Select a target language before translating.';
      notifyListeners();
      return;
    }

    _translatedExamPrep = '';
    _setLoading(true);
    _errorMessage = null;
    try {
      final responseText = await _aiService.translateExamPrep(
        trimmedContent,
        trimmedLanguage,
      );
      _translatedExamPrep = _extractCleanText(responseText);
    } catch (error) {
      _errorMessage = _friendlyErrorMessage(error);
    } finally {
      _setLoading(false);
    }
  }

  // Translate Action
  Future<void> translate(String text, String language) async {
    final trimmedText = text.trim();
    final trimmedLanguage = language.trim();
    if (trimmedText.isEmpty) {
      _translatedText = '';
      _errorMessage = 'There is no note content to translate.';
      notifyListeners();
      return;
    }
    if (trimmedLanguage.isEmpty) {
      _translatedText = '';
      _errorMessage = 'Select a target language before translating.';
      notifyListeners();
      return;
    }

    _translatedText = '';
    _setLoading(true);
    _errorMessage = null;
    try {
      final rawResponse = await _aiService.translateContent(
        trimmedText,
        trimmedLanguage,
      );
      _translatedText = _extractCleanText(rawResponse);
    } catch (error) {
      _errorMessage = _friendlyErrorMessage(error);
    } finally {
      _setLoading(false);
    }
  }

  /// Helper method to clean Markdown code blocks and extract raw translation text
  String _extractCleanText(String rawInput) {
    String cleaned = rawInput.trim();

    // Strip Markdown code block wrappers (```json ... ``` or ``` ...)
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned
          .replaceAll(RegExp(r'^```json\s*'), '')
          .replaceAll(RegExp(r'\s*```$'), '');
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceAll(RegExp(r'^```\s*'), '')
          .replaceAll(RegExp(r'\s*```$'), '');
    }

    cleaned = cleaned.trim();

    // Try parsing as JSON object in case Gemini returns a JSON structure
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('translated_text')) {
          return decoded['translated_text'].toString();
        } else if (decoded.containsKey('translation')) {
          return decoded['translation'].toString();
        } else if (decoded.containsKey('text')) {
          return decoded['text'].toString();
        }
      }
    } catch (_) {
      // If parsing fails, fall back to plain string treatment
    }

    // Regex fallback to extract string if JSON decoding fails due to escaping/formatting issues
    final match = RegExp(
      r'"(?:translated_text|translation|text)"\s*:\s*"(.*?)"',
      dotAll: true,
    ).firstMatch(cleaned);

    if (match != null && match.group(1) != null) {
      return match
          .group(1)!
          .replaceAll(r'\"', '"')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\\', '\\');
    }

    return cleaned;
  }
}