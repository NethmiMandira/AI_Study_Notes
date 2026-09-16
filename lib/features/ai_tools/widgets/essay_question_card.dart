import 'package:flutter/material.dart';

class EssayQuestionCard extends StatefulWidget {
  final Map<String, dynamic> essayData;
  final int index;

  const EssayQuestionCard({
    super.key,
    required this.essayData,
    required this.index,
  });

  @override
  State<EssayQuestionCard> createState() => _EssayQuestionCardState();
}

class _EssayQuestionCardState extends State<EssayQuestionCard> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color purpleGlow = Color(0xFFC084FC);
    const Color cardBgColor = Colors.white;

    try {
      final String question =
          widget.essayData['question']?.toString() ?? 'No essay question available';
      final String sampleAnswer =
          widget.essayData['sampleAnswer']?.toString() ?? 'No sample answer provided.';

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag & Question
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: purpleGlow.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Essay Q${widget.index + 1}',
                      style: const TextStyle(
                        color: purpleGlow,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectableText(
                      question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: textPrimary,
                        letterSpacing: -0.3,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Toggle Button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    try {
                      setState(() => _showAnswer = !_showAnswer);
                    } catch (e, stackTrace) {
                      debugPrint('Error toggling answer state: $e\n$stackTrace');
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: purpleGlow,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    _showAnswer
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _showAnswer ? 'Hide Sample Answer' : 'Show Sample Answer',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              // Sample Answer Box
              if (_showAnswer) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 16,
                            color: purpleGlow,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Sample Answer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: purpleGlow,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        sampleAnswer,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: textSecondary,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error rendering EssayQuestionCard: $e\n$stackTrace');
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                'Failed to display essay question (${widget.index + 1}): ${e.toString()}',
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