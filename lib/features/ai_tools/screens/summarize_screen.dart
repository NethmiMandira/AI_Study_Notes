import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_study_notes/features/ai_tools/providers/ai_provider.dart';
import 'package:ai_study_notes/features/ai_tools/widgets/summary_view.dart';

class SummarizeScreen extends StatefulWidget {
  final String noteContent;
  final Set<String> selectedSections;

  const SummarizeScreen({
    super.key,
    required this.noteContent,
    this.selectedSections = const {
      'shortSummary',
      'detailedSummary',
      'keyPoints',
      'importantTerms',
    },
  });

  @override
  State<SummarizeScreen> createState() => _SummarizeScreenState();
}

class _SummarizeScreenState extends State<SummarizeScreen> {
  late Set<String> _activeSections;
  String? _localError;

  final List<Map<String, String>> _sectionOptions = const [
    {'key': 'shortSummary', 'label': 'Short Summary'},
    {'key': 'detailedSummary', 'label': 'Detailed'},
    {'key': 'keyPoints', 'label': 'Key Points'},
    {'key': 'importantTerms', 'label': 'Terms'},
  ];

  @override
  void initState() {
    super.initState();
    _activeSections = Set<String>.from(widget.selectedSections);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleSummarize();
      }
    });
  }

  /// Parses raw exception strings / JSON into clean user messages
  String _formatErrorMessage(String rawError) {
    if (rawError.contains('503') || rawError.contains('UNAVAILABLE')) {
      return 'The AI service is currently experiencing high demand. Please try again in a few moments.';
    }
    if (rawError.contains('429') || rawError.contains('RESOURCE_EXHAUSTED')) {
      return 'Rate limit reached. Please wait a moment before trying again.';
    }

    // Try extracting message key if raw string contains JSON payload
    try {
      final jsonStart = rawError.indexOf('{');
      final jsonEnd = rawError.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonStr = rawError.substring(jsonStart, jsonEnd + 1);
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map && decoded.containsKey('error')) {
          final errMap = decoded['error'];
          if (errMap is Map && errMap.containsKey('message')) {
            return errMap['message'].toString();
          }
        }
      }
    } catch (_) {
      // Fallback to clean default if JSON parsing fails
    }

    return rawError.replaceAll(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _handleSummarize() async {
    if (!mounted) return;

    setState(() {
      _localError = null;
    });

    if (widget.noteContent.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _localError =
              'Note content is empty. Please provide valid text to summarize.';
        });
      }
      return;
    }

    try {
      await context.read<AiProvider>().summarize(widget.noteContent);
    } catch (e, stackTrace) {
      debugPrint('Unhandled error in _handleSummarize: $e\n$stackTrace');
      if (mounted) {
        final sanitizedMsg = _formatErrorMessage(e.toString());
        setState(() {
          _localError = sanitizedMsg;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sanitizedMsg),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleSection(String key) {
    if (!mounted) return;
    setState(() {
      if (_activeSections.contains(key)) {
        if (_activeSections.length > 1) {
          _activeSections.remove(key);
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('At least one section must be selected.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        _activeSections.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFFF8FAFC);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color purpleGlow = Color(0xFFB877FF);
    const Color cardBgColor = Colors.white;

    final aiProvider = context.watch<AiProvider>();
    final rawError = _localError ?? aiProvider.errorMessage;
    final activeError =
        rawError != null ? _formatErrorMessage(rawError) : null;

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
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
        title: const Text(
          'AI Summarizer',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
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
                  Icons.refresh_rounded,
                  size: 20,
                  color: purpleGlow,
                ),
                onPressed: aiProvider.isLoading ? null : _handleSummarize,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chip Selector Header
            Container(
              color: scaffoldBgColor,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _sectionOptions.map((opt) {
                    final key = opt['key']!;
                    final label = opt['label']!;
                    final isSelected = _activeSections.contains(key);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        showCheckmark: true,
                        checkmarkColor: Colors.white,
                        label: Text(label),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : textSecondary,
                        ),
                        selectedColor: purpleGlow,
                        backgroundColor: cardBgColor,
                        elevation: isSelected ? 3 : 0,
                        shadowColor: purpleGlow.withValues(alpha: 0.35),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? purpleGlow
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (_) => _toggleSection(key),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Builder(
                  builder: (context) {
                    if (aiProvider.isLoading) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: purpleGlow.withValues(alpha: 0.08),
                                blurRadius: 20,
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
                              SizedBox(height: 18),
                              Text(
                                'Summarizing your study note...',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (activeError != null) {
                      return Center(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFFECDD3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE4E6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFE11D48),
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                activeError,
                                style: const TextStyle(
                                  color: Color(0xFF9F1239),
                                  fontSize: 14,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                onPressed: _handleSummarize,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF9F1239),
                                  side: const BorderSide(
                                    color: Color(0xFFFDA4AF),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Try again',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (aiProvider.summaryResult != null) {
                      try {
                        return SummaryView(
                          key: ValueKey(_activeSections.join(',')),
                          summary: aiProvider.summaryResult!,
                          selectedSections: Set<String>.from(_activeSections),
                        );
                      } catch (e, stackTrace) {
                        debugPrint(
                            'Rendering error in SummaryView: $e\n$stackTrace');
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFECDD3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFE11D48),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Failed to display summary output: ${e.toString()}',
                                    style: const TextStyle(
                                      color: Color(0xFF9F1239),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    }

                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: purpleGlow.withValues(alpha: 0.08),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: purpleGlow.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: purpleGlow,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Ready to Summarize',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Generating your study note summary...',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}