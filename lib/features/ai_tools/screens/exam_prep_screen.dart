import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_study_notes/features/ai_tools/providers/ai_provider.dart';
import 'package:ai_study_notes/features/ai_tools/widgets/mcq_card.dart';
import 'package:ai_study_notes/features/ai_tools/widgets/essay_question_card.dart';
import 'package:ai_study_notes/features/ai_tools/widgets/short_answer_card.dart';

class ExamPrepScreen extends StatefulWidget {
  final String noteContent;

  const ExamPrepScreen({super.key, required this.noteContent});

  @override
  State<ExamPrepScreen> createState() => _ExamPrepScreenState();
}

class _ExamPrepScreenState extends State<ExamPrepScreen> {
  final selectedTypes = <String>{'mcqs'};
  final questionCountController = TextEditingController(text: '3');

  @override
  void dispose() {
    questionCountController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _generateQuestions(BuildContext context) async {
    if (selectedTypes.isEmpty) {
      _showErrorSnackBar('Please select at least one question type.');
      return;
    }

    final countText = questionCountController.text.trim();
    final count = int.tryParse(countText);

    if (count == null || count < 1 || count > 20) {
      _showErrorSnackBar('Please enter a valid number of questions between 1 and 20.');
      return;
    }

    await context.read<AiProvider>().generateExamPrep(
          widget.noteContent,
          selectedTypes,
          count,
        );
  }

  Widget _typeChoice(String value, String label) {
    const Color purpleGlow = Color(0xFFC084FC);
    final isSelected = selectedTypes.contains(value);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedTypes.add(value);
          } else {
            // Keep at least one type selected or allow deselection and handle in trigger
            selectedTypes.remove(value);
          }
        });
      },
      selectedColor: purpleGlow,
      backgroundColor: const Color(0xFFF1F5F9),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFFF8FAFC);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
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
          'AI Exam Prep',
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
          child: Column(
            children: [
              // Configuration Controls Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: purpleGlow.withValues(alpha: 0.04),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question types',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _typeChoice('mcqs', 'MCQ'),
                        _typeChoice('essays', 'Essay'),
                        _typeChoice('shortAnswers', 'Short answer'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: questionCountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Questions per type',
                        labelStyle: TextStyle(
                          color: textSecondary.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        helperText:
                            'Choose 1 to 20 questions for each selected type',
                        helperStyle: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: purpleGlow,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Action Button
              Container(
                width: double.infinity,
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
                  onPressed: aiProvider.isLoading
                      ? null
                      : () => _generateQuestions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpleGlow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.quiz_rounded, size: 20),
                  label: const Text(
                    'Generate Exam Questions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Main Dynamic Content Area
              Expanded(
                child: aiProvider.isLoading
                    ? Center(
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
                                'Generating exam questions...',
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
                    : aiProvider.errorMessage != null
                        ? Center(
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
                                    aiProvider.errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _generateQuestions(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF991B1B),
                                      side: const BorderSide(
                                          color: Color(0xFFEF4444)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                    icon: const Icon(Icons.refresh_rounded,
                                        size: 18),
                                    label: const Text(
                                      'Try again',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              if (aiProvider.mcqs.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  child: Text(
                                    'Multiple Choice Questions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary.withValues(alpha: 0.9),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                ...aiProvider.mcqs.asMap().entries.map(
                                  (entry) {
                                    try {
                                      return McqCard(
                                        mcqData: Map<String, dynamic>.from(
                                            entry.value),
                                        index: entry.key,
                                      );
                                    } catch (e, stackTrace) {
                                      debugPrint(
                                          'Error displaying MCQ item ${entry.key}: $e\n$stackTrace');
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Failed to display MCQ card (${entry.key + 1})',
                                          style: const TextStyle(
                                              color: Color(0xFF991B1B)),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                              if (aiProvider.essays.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  child: Text(
                                    'Essay Questions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary.withValues(alpha: 0.9),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                ...aiProvider.essays.asMap().entries.map(
                                  (entry) {
                                    try {
                                      return EssayQuestionCard(
                                        essayData: Map<String, dynamic>.from(
                                            entry.value),
                                        index: entry.key,
                                      );
                                    } catch (e, stackTrace) {
                                      debugPrint(
                                          'Error displaying Essay item ${entry.key}: $e\n$stackTrace');
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Failed to display Essay card (${entry.key + 1})',
                                          style: const TextStyle(
                                              color: Color(0xFF991B1B)),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                              if (aiProvider.shortAnswers.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  child: Text(
                                    'Short Answer Questions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary.withValues(alpha: 0.9),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                ...aiProvider.shortAnswers.asMap().entries.map(
                                  (entry) {
                                    try {
                                      return ShortAnswerCard(
                                        answerData: Map<String, dynamic>.from(
                                            entry.value),
                                        index: entry.key,
                                      );
                                    } catch (e, stackTrace) {
                                      debugPrint(
                                          'Error displaying Short Answer item ${entry.key}: $e\n$stackTrace');
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Failed to display Short Answer card (${entry.key + 1})',
                                          style: const TextStyle(
                                              color: Color(0xFF991B1B)),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}