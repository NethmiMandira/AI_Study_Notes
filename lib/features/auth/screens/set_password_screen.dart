import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:ai_study_notes/features/auth/providers/auth_provider.dart';
import 'package:ai_study_notes/features/notes/screens/home_screen.dart';
import 'package:ai_study_notes/features/auth/widgets/auth_text_field.dart';
import 'package:ai_study_notes/features/auth/widgets/custom_auth_button.dart';

class SetPasswordScreen extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;

  const SetPasswordScreen({
    super.key,
    required this.email,
    this.firstName = '',
    this.lastName = '',
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  // Modern Design Color Palette
  static const Color primaryPurple = Color(0xFFC084FC);
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _mapRegistrationError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please sign in instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Choose a stronger password with at least 8 characters.';
        case 'operation-not-allowed':
          return 'Email/password sign-up is currently disabled. Please contact support.';
        case 'network-request-failed':
          return 'Network error. Please check your connection and try again.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        default:
          return error.message?.trim().isNotEmpty == true
              ? error.message!
              : 'Registration failed. Please try again.';
      }
    }

    if (error is FirebaseException) {
      return 'We couldn’t save your profile. Please try again.';
    }

    if (error is SocketException) {
      return 'Network error. Please check your internet connection.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again later.';
    }

    return 'Something went wrong while creating your account. Please try again.';
  }

  // Modern Floating Error SnackBar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleSavePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard prior to starting async call
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: _newPasswordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'unknown', message: 'Account creation failed.');
      }

      final fullName = '${widget.firstName} ${widget.lastName}'.trim();
      if (fullName.isNotEmpty) {
        await user.updateDisplayName(fullName);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'email': widget.email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        await context.read<AuthProvider>().fetchUserProfile(user.uid);
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_mapRegistrationError(e));
    } catch (e) {
      _showErrorSnackBar(_mapRegistrationError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: textDark, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: const Text(
          'Set Password',
          style: TextStyle(
              color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Integrated Icon Header with Gradient & AI Badge
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [primaryPurple, accentBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withValues(alpha: 0.3),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.lock_open_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: lightBg,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: primaryPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Secure Your Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Create a strong password for ${widget.email} to finish setting up your account.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Input Fields Wrapper for shadow
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: textDark.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _newPasswordController,
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _isObscureNew,
                        enabled: !_isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textMuted,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _isObscureNew = !_isObscureNew),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Must be at least 8 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: _isObscureConfirm,
                        enabled: !_isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _isObscureConfirm = !_isObscureConfirm),
                        ),
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Premium Styled Action Button Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: textDark.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CustomAuthButton(
                    text: 'Save & Create Account',
                    isLoading: _isLoading,
                    onPressed: _handleSavePassword,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}