import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_study_notes/data/models/note_model.dart';
import 'package:ai_study_notes/features/ai_tools/screens/exam_prep_screen.dart';
import 'package:ai_study_notes/features/ai_tools/screens/summarize_screen.dart';
import 'package:ai_study_notes/features/ai_tools/screens/translate_screen.dart';
import 'package:ai_study_notes/features/ai_tools/providers/ai_provider.dart';
import 'package:ai_study_notes/features/notes/providers/note_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers(widget.note);
  }

  void _initControllers(NoteModel note) {
    _titleController = TextEditingController(text: note.title);
    _contentController = TextEditingController(text: note.content);
    _tagsController = TextEditingController(text: note.tags.join(', '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
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

  Future<void> _handleSaveUpdate() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final tagsList = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final updatedNote = widget.note.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: tagsList,
      );

      final success = await context.read<NoteProvider>().updateNote(updatedNote);

      if (mounted) {
        setState(() {
          _isSaving = false;
          if (success) {
            _isEditing = false;
          } else {
            _showErrorSnackBar('Failed to update note. Please try again.');
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating note: $e\n$stackTrace');
      if (mounted) {
        setState(() => _isSaving = false);
        _showErrorSnackBar('An error occurred while saving: ${e.toString()}');
      }
    }
  }

  void _toggleEditMode() {
    try {
      if (_isEditing) {
        _handleSaveUpdate();
      } else {
        setState(() => _isEditing = true);
      }
    } catch (e, stackTrace) {
      debugPrint('Error toggling edit mode: $e\n$stackTrace');
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    }
  }

  Future<void> _showSummaryOptions() async {
    try {
      final result = await showModalBottomSheet<Set<String>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) {
          return const _ModernSummarySelectorSheet();
        },
      );

      if (!mounted || result == null || result.isEmpty) return;

      final aiProvider = context.read<AiProvider>();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: aiProvider.isolatedInstance(),
            child: SummarizeScreen(
              noteContent: _contentController.text,
              selectedSections: result,
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error showing summary options: $e\n$stackTrace');
      _showErrorSnackBar('Could not launch summarizer: ${e.toString()}');
    }
  }

  void _openTranslator() {
    try {
      final aiProvider = context.read<AiProvider>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: aiProvider.isolatedInstance(),
            child: TranslateScreen(noteContent: _contentController.text),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error opening translator: $e\n$stackTrace');
      _showErrorSnackBar('Could not open translator: ${e.toString()}');
    }
  }

  void _openExamPrep() {
    try {
      final aiProvider = context.read<AiProvider>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: aiProvider.isolatedInstance(),
            child: ExamPrepScreen(noteContent: _contentController.text),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error opening exam prep: $e\n$stackTrace');
      _showErrorSnackBar('Could not open exam prep: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFFF8FAFC);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color purpleGlow = Color(0xFFC084FC);
    const Color cardBgColor = Colors.white;

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
              onPressed: () {
                try {
                  Navigator.pop(context);
                } catch (e, stackTrace) {
                  debugPrint('Navigation error: $e\n$stackTrace');
                  _showErrorSnackBar('Unable to go back: ${e.toString()}');
                }
              },
            ),
          ),
        ),
        title: const Text(
          'Note Details',
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
              child: _isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: purpleGlow,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isEditing
                            ? Icons.check_rounded
                            : Icons.edit_outlined,
                        color: purpleGlow,
                        size: 20,
                      ),
                      onPressed: _toggleEditMode,
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card containing Title and Tags
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: purpleGlow.withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
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
                    if (_isEditing)
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: const TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    else
                      Text(
                        _titleController.text.isEmpty
                            ? 'Untitled Note'
                            : _titleController.text,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_isEditing)
                      TextField(
                        controller: _tagsController,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Tags (comma separated)',
                          labelStyle: const TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    else if (_tagsController.text.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _tagsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#$t',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: purpleGlow,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // AI Actions Bar
              if (!_isEditing) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.summarize_rounded,
                        label: 'Summarize',
                        color: const Color(0xFFC084FC),
                        onPressed: _showSummaryOptions,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.translate_rounded,
                        label: 'Translate',
                        color: const Color(0xFF38BDF8),
                        onPressed: _openTranslator,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.quiz_rounded,
                        label: 'Exam Prep',
                        color: const Color(0xFFF59E0B),
                        onPressed: _openExamPrep,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Content Body Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isEditing
                    ? TextField(
                        controller: _contentController,
                        maxLines: null,
                        minLines: 8,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Content',
                          alignLabelWithHint: true,
                          labelStyle: const TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    : Text(
                        _contentController.text,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
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

class _ModernSummarySelectorSheet extends StatefulWidget {
  const _ModernSummarySelectorSheet();

  @override
  State<_ModernSummarySelectorSheet> createState() =>
      __ModernSummarySelectorSheetState();
}

class __ModernSummarySelectorSheetState
    extends State<_ModernSummarySelectorSheet> {
  final Set<String> _selectedSections = {
    'shortSummary',
    'detailedSummary',
    'keyPoints',
    'importantTerms',
  };

  final List<Map<String, dynamic>> _options = const [
    {
      'key': 'shortSummary',
      'title': 'Short Summary',
      'subtitle': 'A quick 2-3 sentence overview',
      'icon': Icons.flash_on_rounded,
    },
    {
      'key': 'detailedSummary',
      'title': 'Detailed Summary',
      'subtitle': 'Comprehensive breakdown of content',
      'icon': Icons.article_rounded,
    },
    {
      'key': 'keyPoints',
      'title': 'Key Points',
      'subtitle': 'Bullet points of core concepts',
      'icon': Icons.task_alt_rounded,
    },
    {
      'key': 'importantTerms',
      'title': 'Important Terms',
      'subtitle': 'Definitions and terminology',
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC084FC);
    const textPrimary = Color(0xFF1E293B);
    const textSecondary = Color(0xFF64748B);

    final isAllSelected = _selectedSections.length == _options.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Summary Format',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (isAllSelected) {
                      _selectedSections.clear();
                    } else {
                      _selectedSections.addAll(
                        _options.map((e) => e['key'] as String),
                      );
                    }
                  });
                },
                child: Text(
                  isAllSelected ? 'Deselect All' : 'Select All',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose the sections you want in your summary',
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: _options.map((option) {
              final String key = option['key'];
              final bool isSelected = _selectedSections.contains(key);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.08)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSections.remove(key);
                          } else {
                            _selectedSections.add(key);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : const Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option['icon'] as IconData,
                                size: 20,
                                color: isSelected
                                    ? Colors.white
                                    : textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['title'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? textPrimary
                                          : textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    option['subtitle'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary.withValues(alpha: 0.8),
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
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _selectedSections.isEmpty
                  ? null
                  : () => Navigator.pop(context, _selectedSections),
              child: const Text(
                'Generate Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 24 + MediaQuery.viewPaddingOf(context).bottom,
          ),
        ],
      ),
    );
  }
}