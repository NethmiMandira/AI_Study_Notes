import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ai_study_notes/data/datasources/remote/firebase_firestore_service.dart';
import 'package:ai_study_notes/data/models/note_model.dart';

class NoteProvider with ChangeNotifier {
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();

  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<NoteModel>>? _notesSubscription;

  // NoteProvider.dart

// Getter එක වඩා පැහැදිලි ලෙස සකසන්න
  List<NoteModel> get notes => _searchQuery.isEmpty ? _notes : _filteredNotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';

  void listenToNotes(String userId) {
    _isLoading = true;
    notifyListeners();

    _notesSubscription?.cancel();
    _notesSubscription = _firestoreService.getUserNotesStream(userId).listen(
      (notesList) {
        _notes = notesList;
        // Search query එකක් තිබේ නම් පමණක් filter කරන්න
        if (_searchQuery.isNotEmpty) {
          _filterNotes(_searchQuery);
        }
        _isLoading = false;
        notifyListeners(); // UI එක update කරයි
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void searchNotes(String query) {
    _searchQuery = query.toLowerCase().trim();
    _filterNotes(_searchQuery);
    notifyListeners();
  }

  void _filterNotes(String query) {
    if (query.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(query);
        final contentMatch = note.content.toLowerCase().contains(query);
        final tagMatch =
            note.tags.any((tag) => tag.toLowerCase().contains(query));
        return titleMatch || contentMatch || tagMatch;
      }).toList();
    }
  }

  Future<bool> addNote({
    required String userId,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    try {
      final docId = DateTime.now().millisecondsSinceEpoch.toString();
      final newNote = NoteModel(
        id: docId,
        userId: userId,
        title: title,
        content: content,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createNote(newNote);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNote(NoteModel updatedNote) async {
    try {
      final noteToSave = updatedNote.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateNote(noteToSave);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      await _firestoreService.deleteNote(noteId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
