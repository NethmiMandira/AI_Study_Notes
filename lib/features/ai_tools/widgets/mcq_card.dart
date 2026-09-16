import 'package:flutter/material.dart';

class McqCard extends StatefulWidget {
  final Map<String, dynamic> mcqData;
  final int index;

  const McqCard({super.key, required this.mcqData, required this.index});

  @override
  State<McqCard> createState() => _McqCardState();
}

class _McqCardState extends State<McqCard> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF0F172A);
    const Color textSecondary = Color(0xFF64748B);
    const Color purpleGlow = Color(0xFF8B5CF6);
    const Color cardBgColor = Colors.white;

    try {
      final options = List<String>.from(widget.mcqData['options'] ?? []);
      final correctAnswer = widget.mcqData['correctAnswer'] ??
          (widget.mcqData['correctOptionIndex'] is int &&
                  widget.mcqData['correctOptionIndex'] < options.length
              ? options[widget.mcqData['correctOptionIndex'] as int]
              : '');
      final question =
          widget.mcqData['question']?.toString() ?? 'No question provided';

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: purpleGlow.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag & Question Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          purpleGlow.withValues(alpha: 0.15),
                          purpleGlow.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Q${widget.index + 1}',
                      style: const TextStyle(
                        color: purpleGlow,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SelectableText(
                      question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: textPrimary,
                        letterSpacing: -0.3,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Options List
              ...options.asMap().entries.map((entry) {
                final idx = entry.key;
                final opt = entry.value;
                final optionLabel = String.fromCharCode(65 + idx); // A, B, C, D...

                Color tileColor = const Color(0xFFF8FAFC);
                Color borderColor = const Color(0xFFE2E8F0);
                Color textColor = textPrimary;
                IconData? stateIcon;
                Color iconColor = textSecondary;
                Color badgeBgColor = const Color(0xFFE2E8F0);
                Color badgeTextColor = textSecondary;

                if (selectedOption != null) {
                  if (opt == correctAnswer) {
                    tileColor = const Color(0xFFECFDF5);
                    borderColor = const Color(0xFF10B981);
                    textColor = const Color(0xFF065F46);
                    stateIcon = Icons.check_circle_rounded;
                    iconColor = const Color(0xFF10B981);
                    badgeBgColor = const Color(0xFF10B981);
                    badgeTextColor = Colors.white;
                  } else if (opt == selectedOption) {
                    tileColor = const Color(0xFFFEF2F2);
                    borderColor = const Color(0xFFEF4444);
                    textColor = const Color(0xFF991B1B);
                    stateIcon = Icons.cancel_rounded;
                    iconColor = const Color(0xFFEF4444);
                    badgeBgColor = const Color(0xFFEF4444);
                    badgeTextColor = Colors.white;
                  }
                }

                final isSelected = selectedOption == opt;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected && selectedOption != null
                          ? borderColor
                          : const Color(0xFFF1F5F9),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        try {
                          setState(() {
                            selectedOption = opt;
                          });
                        } catch (e, stackTrace) {
                          debugPrint('Error selecting option: $e\n$stackTrace');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            // Styled Badge Indicator (A, B, C, D)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  optionLabel,
                                  style: TextStyle(
                                    color: badgeTextColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: textColor,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (stateIcon != null) ...[
                              const SizedBox(width: 10),
                              Icon(stateIcon, color: iconColor, size: 22),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error rendering McqCard: $e\n$stackTrace');
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to display MCQ card (${widget.index + 1}): ${e.toString()}',
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