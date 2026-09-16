import 'package:flutter/material.dart';
import 'package:ai_study_notes/data/models/ai_generated_content_model.dart';

class SummaryView extends StatelessWidget {
  final SummaryResult summary;
  final Set<String> selectedSections;

  const SummaryView({
    super.key,
    required this.summary,
    this.selectedSections = const {
      'shortSummary',
      'detailedSummary',
      'keyPoints',
      'importantTerms',
    },
  });

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFFF8FAFC);

    try {
      return Container(
        color: scaffoldBgColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Short Summary
              if (selectedSections.contains('shortSummary') &&
                  summary.shortSummary.isNotEmpty) ...[
                _buildCard(
                  context,
                  title: '⚡ Short Summary',
                  child: SelectableText(
                    summary.shortSummary,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Key Points
              if (selectedSections.contains('keyPoints') &&
                  summary.keyPoints.isNotEmpty) ...[
                _buildCard(
                  context,
                  title: '📌 Key Points',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summary.keyPoints
                        .map(
                          (point) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6, right: 10),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC084FC),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: SelectableText(
                                    point,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3. Important Terms
              if (selectedSections.contains('importantTerms') &&
                  summary.importantTerms.isNotEmpty) ...[
                _buildCard(
                  context,
                  title: '🏷️ Important Terms',
                  child: Column(
                    children: summary.importantTerms.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              '${entry.key}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Detailed Summary
              if (selectedSections.contains('detailedSummary') &&
                  summary.detailedSummary.isNotEmpty)
                _buildCard(
                  context,
                  title: '📖 Detailed Summary',
                  child: SelectableText(
                    summary.detailedSummary,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error rendering SummaryView: $e\n$stackTrace');
      return Container(
        padding: const EdgeInsets.all(16),
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
                'An error occurred displaying summary content: ${e.toString()}',
                style: const TextStyle(
                  color: Color(0xFF991B1B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    const Color textPrimary = Color(0xFF1E293B);
    const Color purpleGlow = Color(0xFFC084FC);
    const Color cardBgColor = Colors.white;

    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}