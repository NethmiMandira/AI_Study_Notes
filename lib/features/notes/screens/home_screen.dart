import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_study_notes/features/auth/providers/auth_provider.dart';
import 'package:ai_study_notes/features/notes/providers/note_provider.dart';
import 'package:ai_study_notes/features/notes/screens/create_note_screen.dart';
import 'package:ai_study_notes/features/notes/screens/note_detail_screen.dart';
import 'package:ai_study_notes/features/notes/screens/search_notes_screen.dart';
import 'package:ai_study_notes/features/notes/widgets/note_card.dart';
import 'package:ai_study_notes/features/notes/widgets/search_bar_widget.dart';
import 'package:ai_study_notes/features/profile/screens/profile_screen.dart';
import 'package:ai_study_notes/features/settings/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _dummySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotesListener();
    });
  }

  void _initNotesListener() {
    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<NoteProvider>().listenToNotes(authProvider.user!.uid);
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing notes listener: $e\n$stackTrace');
      _showErrorSnackBar('Failed to load notes. Please try again.');
    }
  }

  @override
  void dispose() {
    _dummySearchController.dispose();
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

  Future<void> _confirmDelete(BuildContext context, String noteId) async {
    try {
      final noteProvider = context.read<NoteProvider>();
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete Note',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this note?',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final success = await noteProvider.deleteNote(noteId);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Note deleted successfully'
                  : (noteProvider.errorMessage ?? 'Failed to delete note'),
            ),
            backgroundColor:
                success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error deleting note: $e\n$stackTrace');
      _showErrorSnackBar('An error occurred while deleting: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFFF8FAFC);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color purpleGlow = Color(0xFFC084FC);

    final authProvider = context.watch<AuthProvider>();
    final noteProvider = context.watch<NoteProvider>();
    final firstName =
        authProvider.userProfile?['firstName']?.toString().trim() ?? '';
    final lastName =
        authProvider.userProfile?['lastName']?.toString().trim() ?? '';
    final profileName = '$firstName $lastName'.trim();
    final greetingName = profileName.isNotEmpty
        ? profileName
        : (authProvider.user?.displayName ?? '').trim().isNotEmpty
            ? authProvider.user!.displayName!.trim()
            : 'there';

    if (authProvider.user != null &&
        !noteProvider.isLoading &&
        noteProvider.notes.isEmpty) {
      // Retained flow for stream check
    }

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          'Hello $greetingName!',
          style: const TextStyle(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
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
                  Icons.account_circle_outlined,
                  color: textPrimary,
                  size: 22,
                ),
                tooltip: 'Profile',
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  } catch (e, stackTrace) {
                    debugPrint('Navigation error: $e\n$stackTrace');
                    _showErrorSnackBar('Unable to open profile: ${e.toString()}');
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
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
                  Icons.settings_outlined,
                  color: textPrimary,
                  size: 22,
                ),
                tooltip: 'Settings',
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  } catch (e, stackTrace) {
                    debugPrint('Navigation error: $e\n$stackTrace');
                    _showErrorSnackBar('Unable to open settings: ${e.toString()}');
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBarWidget(
                controller: _dummySearchController,
                readOnly: true,
                onChanged: (_) {},
                onTap: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchNotesScreen(),
                      ),
                    );
                  } catch (e, stackTrace) {
                    debugPrint('Navigation error: $e\n$stackTrace');
                    _showErrorSnackBar('Unable to open search: ${e.toString()}');
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Notes',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: noteProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: purpleGlow,
                        ),
                      )
                    : noteProvider.notes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_alt_outlined,
                                  size: 48,
                                  color: textSecondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No notes found. Create your first note!',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: purpleGlow,
                            onRefresh: () async {
                              try {
                                if (authProvider.user != null) {
                                  noteProvider.listenToNotes(
                                    authProvider.user!.uid,
                                  );
                                }
                              } catch (e, stackTrace) {
                                debugPrint('Refresh error: $e\n$stackTrace');
                                _showErrorSnackBar('Failed to refresh notes.');
                              }
                            },
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: noteProvider.notes.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
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
                                          'Navigation error: $e\n$stackTrace');
                                      _showErrorSnackBar(
                                          'Could not open note details.');
                                    }
                                  },
                                  onDelete: () =>
                                      _confirmDelete(context, note.id),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: purpleGlow.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: purpleGlow,
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () async {
            try {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateNoteScreen(),
                ),
              );

              if (!context.mounted) return;
              final user = authProvider.user;
              if (user != null) {
                context.read<NoteProvider>().searchNotes('');
                context.read<NoteProvider>().listenToNotes(user.uid);
              }
            } catch (e, stackTrace) {
              debugPrint('Error creating note flow: $e\n$stackTrace');
              _showErrorSnackBar('An error occurred: ${e.toString()}');
            }
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New Note',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}