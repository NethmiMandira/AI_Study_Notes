import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_study_notes/features/notes/providers/note_provider.dart';
import 'package:ai_study_notes/features/notes/screens/note_detail_screen.dart';
import 'package:ai_study_notes/features/notes/widgets/note_card.dart';
import 'package:ai_study_notes/features/notes/widgets/search_bar_widget.dart';

class SearchNotesScreen extends StatefulWidget {
  const SearchNotesScreen({super.key});

  @override
  State<SearchNotesScreen> createState() => _SearchNotesScreenState();
}

class _SearchNotesScreenState extends State<SearchNotesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();

    // Design palette values matching the modern theme
    const Color scaffoldBgColor = Color(0xFFF8FAFC);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color purpleGlow = Color(0xFFC084FC);
    const Color emptyIconBg = Color(0xFFF1F5F9);

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
                  _showErrorSnackBar(
                    context,
                    'Unable to go back: ${e.toString()}',
                  );
                }
              },
            ),
          ),
        ),
        title: const Text(
          'Search Notes',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              SearchBarWidget(
                controller: _searchController,
                onChanged: (query) {
                  try {
                    noteProvider.searchNotes(query);
                  } catch (e, stackTrace) {
                    debugPrint('Search error: $e\n$stackTrace');
                    _showErrorSnackBar(
                      context,
                      'Failed to execute search: ${e.toString()}',
                    );
                  }
                },
                onClear: () {
                  try {
                    noteProvider.searchNotes('');
                  } catch (e, stackTrace) {
                    debugPrint('Clear search error: $e\n$stackTrace');
                    _showErrorSnackBar(
                      context,
                      'Failed to clear search: ${e.toString()}',
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: noteProvider.notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: emptyIconBg,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: purpleGlow.withValues(alpha: 0.08),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 36,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No matching notes found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try searching with a different keyword',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: noteProvider.notes.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final note = noteProvider.notes[index];
                          return NoteCard(
                            note: note,
                            onTap: () {
                              try {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NoteDetailScreen(note: note),
                                  ),
                                );
                              } catch (e, stackTrace) {
                                debugPrint(
                                    'Note navigate error: $e\n$stackTrace');
                                _showErrorSnackBar(
                                  context,
                                  'Could not open note details: ${e.toString()}',
                                );
                              }
                            },
                            onDelete: () async {
                              try {
                                await noteProvider.deleteNote(note.id);
                              } catch (e, stackTrace) {
                                debugPrint(
                                    'Note deletion error: $e\n$stackTrace');
                                if (!context.mounted) return;
                                _showErrorSnackBar(
                                  context,
                                  'Failed to delete note: ${e.toString()}',
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}