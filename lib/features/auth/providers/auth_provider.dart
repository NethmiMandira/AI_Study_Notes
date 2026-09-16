import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        fetchUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  // Fetch User Profile from Firestore
  Future<void> fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userProfile = doc.data() as Map<String, dynamic>?;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  // Sign In with Email & Password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
          'email': credential.user!.email,
        }, SetOptions(merge: true));

        await fetchUserProfile(credential.user!.uid);
      }
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
      _setLoading(false);
      return false;
    }
  }

  // Register User and Save to Firestore
  Future<bool> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = credential.user;
      if (user != null) {
        String fullName = '$firstName $lastName'.trim();
        await user.updateDisplayName(fullName);

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        await fetchUserProfile(user.uid);
      }
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Failed to create account.";
      _setLoading(false);
      return false;
    }
  }

  // Send Password Reset Email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Could not send reset email.";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _errorMessage = 'No signed-in user found.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      await currentUser.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }
      _user = refreshedUser;

      final trimmedEmail = email.trim();
      final trimmedFirstName = firstName.trim();
      final trimmedLastName = lastName.trim();
      final fullName = '$trimmedFirstName $trimmedLastName'.trim();

      if (refreshedUser.email != trimmedEmail) {
        throw FirebaseAuthException(
          code: 'email-change-pending',
          message: 'Verify the new email address before saving the profile.',
        );
      }
      await refreshedUser.updateDisplayName(fullName);
      await refreshedUser.reload();
      _user = _auth.currentUser;
      final savedEmail = _user?.email ?? trimmedEmail;
      await _firestore.collection('users').doc(refreshedUser.uid).set({
        'firstName': trimmedFirstName,
        'lastName': trimmedLastName,
        'email': savedEmail,
      }, SetOptions(merge: true));

      await fetchUserProfile(refreshedUser.uid);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = switch (e.code) {
        'requires-recent-login' =>
          'For security, sign out and sign in again before changing your email.',
        'operation-not-allowed' =>
          'Firebase does not allow email changes for this app. Confirm that Email/Password is enabled in the same Firebase project used by this app.',
        'email-already-in-use' => 'That email address is already in use.',
        'invalid-email' => 'Enter a valid email address.',
        _ => e.message ?? 'Could not update profile. (${e.code})',
      };
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Could not update profile.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendEmailChangeVerification(String newEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _errorMessage = 'No signed-in user found.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      await currentUser.verifyBeforeUpdateEmail(newEmail.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = switch (e.code) {
        'requires-recent-login' =>
          'For security, confirm your current password again.',
        'email-already-in-use' => 'That email address is already in use.',
        'invalid-email' => 'Enter a valid email address.',
        'operation-not-allowed' =>
          'Firebase email verification is not enabled for this project.',
        _ => e.message ?? 'Could not send the email verification link.',
      };
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Could not send the email verification link.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> reauthenticateForEmailChange({String? password}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _errorMessage = 'No signed-in user found.';
      notifyListeners();
      return false;
    }

    try {
      final providerIds =
          currentUser.providerData.map((info) => info.providerId);
      if (providerIds.contains('password')) {
        if (password == null || password.isEmpty || currentUser.email == null) {
          _errorMessage = 'Enter your current password to continue.';
          notifyListeners();
          return false;
        }
        final credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(credential);
        return true;
      }

      _errorMessage =
          'A current password is required to change your email address.';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = switch (e.code) {
        'wrong-password' ||
        'invalid-credential' =>
          'The current password is incorrect.',
        'user-mismatch' => 'The current password is incorrect.',
        'too-many-requests' =>
          'Too many attempts. Please wait and try again later.',
        _ => e.message ?? 'Reauthentication failed.',
      };
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Could not confirm your identity.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _errorMessage = 'No signed-in user found.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      final usesPassword =
          currentUser.providerData.any((info) => info.providerId == 'password');
      if (!usesPassword || currentUser.email == null) {
        _errorMessage =
            'Password changes are available only for email and password accounts.';
        _setLoading(false);
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = switch (e.code) {
        'wrong-password' ||
        'invalid-credential' =>
          'The current password is incorrect.',
        'weak-password' => 'Choose a stronger password.',
        'requires-recent-login' =>
          'For security, enter your current password again.',
        _ => e.message ?? 'Could not update password.',
      };
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Could not update password.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _errorMessage = 'No signed-in user found.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      final notes = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      final batch = _firestore.batch();
      for (final note in notes.docs) {
        batch.delete(note.reference);
      }
      batch.delete(_firestore.collection('users').doc(currentUser.uid));
      await batch.commit();

      await currentUser.delete();
      _user = null;
      _userProfile = null;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.code == 'requires-recent-login'
          ? 'For security, sign in again before deleting your account.'
          : e.message ?? 'Could not delete your account.';
      _setLoading(false);
      return false;
    } on FirebaseException catch (e) {
      _errorMessage = switch (e.code) {
        'permission-denied' =>
          'You do not have permission to delete your account data.',
        'unavailable' =>
          'Network unavailable. Check your connection and try again.',
        _ => e.message ?? 'Could not delete your account data.',
      };
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Could not delete your account.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
