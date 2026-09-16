import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ai_study_notes/features/auth/providers/auth_provider.dart';
import 'package:ai_study_notes/features/auth/screens/email_verification_screen.dart';
import 'package:ai_study_notes/features/auth/screens/login_screen.dart';
import 'package:ai_study_notes/features/auth/services/email_otp_service.dart';
import 'package:ai_study_notes/features/profile/screens/change_password_screen.dart';
import 'package:ai_study_notes/features/profile/widgets/profile_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      final profile = authProvider.userProfile ?? <String, dynamic>{};
      final displayName = (user?.displayName ?? '').trim().split(' ');

      _emailController = TextEditingController(
        text: (profile['email'] as String?) ?? user?.email ?? '',
      );
      _firstNameController = TextEditingController(
        text: (profile['firstName'] as String?) ??
            (displayName.isNotEmpty ? displayName.first : ''),
      );
      _lastNameController = TextEditingController(
        text: (profile['lastName'] as String?) ??
            (displayName.length > 1 ? displayName.sublist(1).join(' ') : ''),
      );
    } catch (e, stackTrace) {
      debugPrint('Error initializing EditProfileScreen state: $e\n$stackTrace');
      _emailController = TextEditingController();
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<String?> _requestCurrentPassword() async {
    try {
      return await showDialog<String>(
        context: context,
        builder: (_) => const _CurrentPasswordDialog(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error showing current password dialog: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _saveProfileChanges();
    } catch (e, stackTrace) {
      debugPrint('Error saving profile: $e\n$stackTrace');
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfileChanges() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.reloadCurrentUser();
    if (!mounted) return;

    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final currentEmail = authProvider.user?.email?.trim() ?? '';

    if (currentEmail != email) {
      final password = await _requestCurrentPassword();
      if (!mounted || password == null) return;
      final reauthenticated = await authProvider.reauthenticateForEmailChange(
        password: password,
      );
      if (!mounted || !reauthenticated) {
        _showMessage(
          authProvider.errorMessage ?? 'Identity confirmation failed.',
        );
        return;
      }

      final generatedOtp = EmailOtpService.generateOtp();
      final isSent = await EmailOtpService.sendOtp(
        userEmail: email,
        firstName: firstName,
        lastName: lastName,
        otpCode: generatedOtp,
      );
      if (!mounted) return;
      if (!isSent) {
        _showMessage('Failed to send verification code.');
        return;
      }

      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: email,
            generatedOtp: generatedOtp,
            firstName: firstName,
            lastName: lastName,
            onVerified: () async {
              final verificationSent =
                  await authProvider.sendEmailChangeVerification(email);
              if (!verificationSent) return false;

              return authProvider.updateProfile(
                email: authProvider.user?.email ?? '',
                firstName: firstName,
                lastName: lastName,
              );
            },
            onResend: () async {
              final newOtp = EmailOtpService.generateOtp();
              final sent = await EmailOtpService.sendOtp(
                userEmail: email,
                firstName: firstName,
                lastName: lastName,
                otpCode: newOtp,
              );
              return sent ? newOtp : null;
            },
            verificationErrorMessage: () => authProvider.errorMessage,
          ),
        ),
      );

      if (!mounted) return;
      if (verified == true) {
        FocusManager.instance.primaryFocus?.unfocus();
        await authProvider.signOut();
        if (!mounted) return;
        _showMessage(
          'Verification link sent. Open it from your email, then sign in with the new email.',
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => LoginScreen(prefilledEmail: email),
          ),
          (route) => false,
        );
      }
      return;
    }

    final success = await authProvider.updateProfile(
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
    if (!mounted) return;
    if (success) {
      _showMessage('Profile updated successfully.');
      Navigator.pop(context);
    } else {
      _showMessage(authProvider.errorMessage ?? 'Could not update profile.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF0F172A),
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
    const Color textPrimary = Color(0xFF0F172A);
    const Color textSecondary = Color(0xFF64748B);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color deepPurple = Color(0xFF6D28D9);

    try {
      final authProvider = context.watch<AuthProvider>();
      final isProcessing = authProvider.isLoading || _isSaving;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Update profile',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFFF1F5F9),
              height: 1.0,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Section Header
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Update your personal details and contact email address below.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Text Fields
                  ProfileTextField(
                    controller: _firstNameController,
                    labelText: 'First name',
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter your first name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    controller: _lastNameController,
                    labelText: 'Last name',
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter your last name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Enter your email';
                      if (!email.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Primary Action Button (Save Changes)
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isProcessing
                          ? null
                          : const LinearGradient(
                              colors: [
                                primaryPurple,
                                deepPurple,
                              ],
                            ),
                      color: isProcessing ? const Color(0xFFE2E8F0) : null,
                      boxShadow: isProcessing
                          ? null
                          : [
                              BoxShadow(
                                color: primaryPurple.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isProcessing ? null : _saveProfile,
                      child: isProcessing
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: textSecondary,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Save changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secondary Action Button (Reset Password)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: isProcessing
                        ? null
                        : () {
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen(),
                                ),
                              );
                            } catch (e, stackTrace) {
                              debugPrint('Navigation error: $e\n$stackTrace');
                            }
                          },
                    icon: const Icon(
                      Icons.lock_reset_outlined,
                      color: textPrimary,
                      size: 20,
                    ),
                    label: const Text(
                      'Reset password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error rendering EditProfileScreen: $e\n$stackTrace');
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Update profile'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Failed to load edit profile screen: ${e.toString()}',
                    style: const TextStyle(
                      color: Color(0xFF991B1B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _CurrentPasswordDialog extends StatefulWidget {
  const _CurrentPasswordDialog();

  @override
  State<_CurrentPasswordDialog> createState() => _CurrentPasswordDialogState();
}

class _CurrentPasswordDialogState extends State<_CurrentPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF0F172A);
    const Color textSecondary = Color(0xFF64748B);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color deepPurple = Color(0xFF6D28D9);

    try {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Header
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirm your identity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please enter your current password to proceed with changing your email.',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                obscureText: true,
                autofocus: true,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: 'Current password',
                  labelStyle: const TextStyle(color: textSecondary),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: primaryPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        try {
                          Navigator.pop(context);
                        } catch (e, stackTrace) {
                          debugPrint('Error popping dialog: $e\n$stackTrace');
                        }
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            primaryPurple,
                            deepPurple,
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          try {
                            Navigator.pop(context, _controller.text);
                          } catch (e, stackTrace) {
                            debugPrint(
                              'Error submitting dialog: $e\n$stackTrace',
                            );
                          }
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error rendering _CurrentPasswordDialog: $e\n$stackTrace');
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('Failed to load password prompt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }
  }
}