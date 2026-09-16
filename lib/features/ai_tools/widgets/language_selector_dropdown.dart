import 'package:flutter/material.dart';

class LanguageSelectorDropdown extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String?> onChanged;

  const LanguageSelectorDropdown({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  static const languages = [
    'Sinhala',
    'Tamil',
    'English',
    'Spanish',
    'French',
    'German',
    'Japanese',
  ];

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF1E293B);
    const Color purpleGlow = Color(0xFFC084FC);
    const Color cardBgColor = Colors.white;

    try {
      final String safeValue =
          languages.contains(selectedLanguage) ? selectedLanguage : languages.first;

      return Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
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
        padding: const EdgeInsets.all(4),
        child: DropdownButtonFormField<String>(
          initialValue: safeValue,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: purpleGlow,
            size: 24,
          ),
          dropdownColor: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          style: const TextStyle(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: 'Select Target Language',
            labelStyle: const TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.language_rounded,
              color: purpleGlow,
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: purpleGlow,
                width: 1.5,
              ),
            ),
          ),
          items: languages
              .map(
                (lang) => DropdownMenuItem<String>(
                  value: lang,
                  child: Text(
                    lang,
                    style: const TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            try {
              onChanged(val);
            } catch (e, stackTrace) {
              debugPrint('Error selecting language: $e\n$stackTrace');
            }
          },
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error rendering LanguageSelectorDropdown: $e\n$stackTrace');
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to display language selector: ${e.toString()}',
                style: const TextStyle(
                  color: Color(0xFF991B1B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}