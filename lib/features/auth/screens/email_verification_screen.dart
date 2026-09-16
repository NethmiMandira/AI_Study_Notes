import 'dart:async';
import 'dart:io'; // Import for SocketException handling
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ai_study_notes/features/auth/screens/set_password_screen.dart';
import 'package:ai_study_notes/features/auth/widgets/custom_auth_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String generatedOtp;
  final String firstName;
  final String lastName;
  final Future<bool> Function()? onVerified;
  final Future<String?> Function()? onResend;
  final String? Function()? verificationErrorMessage;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.generatedOtp,
    required this.firstName,
    required this.lastName,
    this.onVerified,
    this.onResend,
    this.verificationErrorMessage,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _keyboardFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  bool _canResend = false;
  Timer? _cooldownTimer;
  int _resendCooldown = 30;
  late String _currentOtp;

  // Modern Design Color Palette
  static const Color primaryPurple = Color(0xFFC084FC);
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.generatedOtp;
    _startCooldownTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var node in _keyboardFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCooldownTimer() {
    if (!mounted) return;
    setState(() {
      _canResend = false;
      _resendCooldown = 30;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final otp = _enteredOtp;
    if (otp.length < 6 || _isVerifying) return;

    setState(() => _isVerifying = true);
    // Clearing focus to hide keyboard during verification feel
    for (var node in _focusNodes) {
      node.unfocus();
    }

    try {
      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      if (otp == _currentOtp) {
        if (widget.onVerified != null) {
          final success = await widget.onVerified!();
          if (!mounted) return;
          if (success) {
            Navigator.of(context).pop(true);
          } else {
            // Error handling from callback
            _showError(
              widget.verificationErrorMessage?.call() ??
                  'Could not update your email at this time.',
            );
            _resetOtpFields();
          }
          return;
        }

        // Default flow: Navigation to Set Password
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => SetPasswordScreen(
              email: widget.email,
              firstName: widget.firstName,
              lastName: widget.lastName,
            ),
          ),
          (route) => false,
        );
      } else {
        // Invalid OTP handling
        _showError('Invalid verification code. Please try again.');
        _resetOtpFields();
      }
    } on SocketException {
      _showError('Network error. Please check your internet connection.');
    } on TimeoutException {
      _showError('Verification timed out. Please try again.');
    } catch (error) {
      if (mounted) {
        final message = error is FormatException
            ? 'Verification data format is invalid.'
            : 'An unexpected error occurred during verification.';
        _showError(message);
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // Helper to clear fields on error
  void _resetOtpFields() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendCode() async {
    if (!_canResend || _isResending || widget.onResend == null) return;

    setState(() => _isResending = true);
    try {
      final newOtp = await widget.onResend!();
      if (!mounted) return;

      if (newOtp == null) {
        _showError(
            'Could not resend the verification code. Please try again later.');
        return;
      }

      _currentOtp = newOtp;
      _resetOtpFields();
      _startCooldownTimer();

      // Modern Success SnackBar
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('A new code has been sent to your email.'),
            ],
          ),
          backgroundColor: accentBlue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (error) {
      if (mounted) {
        _showError('Failed to resend the code. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // Modern Floating Error SnackBar
  void _showError(String message) {
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

  void _onOtpInputChanged(String value, int index) {
    // Handle paste action (6-digit code copied into any box)
    if (value.length > 1) {
      final cleanDigits = value.replaceAll(RegExp(r'\D'), '');
      if (cleanDigits.length >= 6) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = cleanDigits[i];
        }
        _focusNodes[5].requestFocus();
        _verifyOtp();
        return;
      }
    }

    // Auto-advance focus on typing a digit
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Trigger verification automatically when complete
    if (_enteredOtp.length == 6) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modern Box Decoration for Input Fields
    final inputDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: textDark.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

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
          'Verify Email',
          style: TextStyle(
              color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Integrated Notes + AI Logo Composition
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
                      // Base Security/Lock Icon (Representing Verification)
                      const Center(
                        child: Icon(
                          Icons.phonelink_lock_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      // Overlay AI Sparkle Badge (Top Right)
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
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'We have sent a 6-digit confirmation code to:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: textMuted,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 40),
              // Modern OTP Input Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 48,
                    height: 60,
                    decoration: inputDecoration,
                    child: KeyboardListener(
                      focusNode: _keyboardFocusNodes[index],
                      onKeyEvent: (event) {
                        // Move focus backwards when pressing backspace on empty box
                        if (event.logicalKey == LogicalKeyboardKey.backspace &&
                            _controllers[index].text.isEmpty &&
                            index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                      child: Center(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1, // Restrict native input to 1 char
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: primaryPurple,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none, // Hide native border
                          ),
                          onChanged: (val) => _onOtpInputChanged(val, index),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Modern Resend Section
              Center(
                child: Column(
                  children: [
                    Text(
                      _canResend
                          ? "Didn't receive the code?"
                          : "You can resend the code in",
                      style: const TextStyle(color: textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: widget.onResend == null ||
                              _isResending ||
                              !_canResend
                          ? null
                          : _resendCode,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        _isResending
                            ? 'Sending code...'
                            : _canResend
                                ? 'Resend Code'
                                : '${_resendCooldown}s',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.onResend == null ||
                                  _isResending ||
                                  !_canResend
                              ? textMuted.withValues(alpha: 0.5)
                              : primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Sleek Dark Premium Action Button
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
                  text: 'Verify & Continue',
                  isLoading: _isVerifying,
                  onPressed: _enteredOtp.length == 6 ? _verifyOtp : null,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}