import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_study_notes/features/ai_tools/providers/ai_provider.dart';
import 'package:ai_study_notes/features/ai_tools/widgets/language_selector_dropdown.dart';

class TranslateScreen extends StatefulWidget {
  final String noteContent;

  const TranslateScreen({super.key, required this.noteContent});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  String selectedLang = 'Sinhala';

  Future<void> _handleTranslation() async {
    if (widget.noteContent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note content is empty. Nothing to translate.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    try {
      await context
          .read<AiProvider>()
          .translate(widget.noteContent, selectedLang);
    } catch (e) {
      // Handles unhandled synchronous exceptions if any escape the provider
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Parses technical/JSON API exception strings into user-friendly messages.
  String _formatErrorMessage(String rawError) {
    if (rawError.contains('503') || rawError.contains('UNAVAILABLE')) {
      return 'The AI service is currently experiencing high demand. Please try again in a few moments.';
    } else if (rawError.contains('429') || rawError.contains('RESOURCE_EXHAUSTED')) {
      return 'Rate limit exceeded. Please wait a moment before trying again.';
    } else if (rawError.contains('SocketException') || rawError.contains('NetworkException')) {
      return 'Network error. Please check your internet connection.';
    } else if (rawError.contains('401') || rawError.contains('UNAUTHENTICATED')) {
      return 'Authentication failed. Please check your API credentials.';
    }
    
    // Fallback cleaning if string contains raw exception wrapper
    return rawError
        .replaceAll(RegExp(r'GenerativeAIException:?'), '')
        .replaceAll(RegExp(r'AI request failed \(.*?\):?'), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFFF8FAFC);
    const Color textPrimary = Color(0xFF1E293B);
    const Color purpleGlow = Color(0xFFC084FC);
    const Color cardBgColor = Colors.white;

    final aiProvider = context.watch<AiProvider>();

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'AI Translator',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LanguageSelectorDropdown(
                  selectedLanguage: selectedLang,
                  onChanged: (val) {
                    if (val != null) setState(() => selectedLang = val);
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: purpleGlow.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        aiProvider.isLoading ? null : _handleTranslation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purpleGlow,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.translate_rounded, size: 20),
                    label: Text(
                      'Translate to $selectedLang',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (aiProvider.isLoading)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: purpleGlow.withValues(alpha: 0.06),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3,
                            color: purpleGlow,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Translating note content...',
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (aiProvider.errorMessage != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFCA5A5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatErrorMessage(aiProvider.errorMessage!),
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _handleTranslation,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF991B1B),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text(
                              'Try again',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (aiProvider.translatedText.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: purpleGlow.withValues(alpha: 0.06),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.g_translate_rounded,
                              size: 18,
                              color: purpleGlow,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Translation ($selectedLang)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 16),
                        SelectableText(
                          aiProvider.translatedText,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}