import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_study_notes/data/models/user_model.dart';
import 'package:ai_study_notes/data/models/note_model.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _notesRef =>
      _firestore.collection('notes');

  // ================= USER OPERATIONS ================= //

  // Save or update user profile in Firestore
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _usersRef.doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Fetch user profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _usersRef.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    try {
      await _usersRef.doc(uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update login timestamp: $e');
    }
  }

  // ================= NOTES OPERATIONS ================= //

  // Save a new note
  Future<void> createNote(NoteModel note) async {
    try {
      await _notesRef.doc(note.id).set(note.toMap());
    } catch (e) {
      throw Exception('Failed to save note: $e');
    }
  }

  // Get notes for a specific user as a real-time Stream
  Stream<List<NoteModel>> getUserNotesStream(String userId) {
    return _notesRef
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoteModel.fromDocument(doc)).toList());
  }

  // Update an existing note
  Future<void> updateNote(NoteModel note) async {
    try {
      await _notesRef.doc(note.id).update(note.toMap());
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note by ID
  Future<void> deleteNote(String noteId) async {
    try {
      await _notesRef.doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}