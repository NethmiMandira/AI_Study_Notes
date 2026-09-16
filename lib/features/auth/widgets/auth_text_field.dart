import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16);

    // Custom Color Definitions (Adapt these as needed)
    final Color backgroundColor = enabled
        ? Colors.grey.shade100 // Example: very light grey
        : Colors.grey.shade200; // Example: slightly darker grey for disabled

    final Color inputTextColor = enabled
        ? Colors.black87 // Example: dark text
        : Colors.black38; // Example: muted text for disabled

    const Color activeBorderColor = Colors.deepPurple; // Example: purple when focused
    final Color inactiveBorderColor = Colors.grey.shade300; // Example: subtle grey border

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: inputTextColor,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        floatingLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled
              ? activeBorderColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 22,
          color: enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        // Modern rounded borders
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: inactiveBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: activeBorderColor,
            width: 2,
          ),
        ),
        // Visual exception & error handling styling
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        errorStyle: TextStyle(
          color: theme.colorScheme.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 2,
      ),
      validator: (value) {
        if (validator == null) return null;
        try {
          return validator!(value);
        } catch (e) {
          // Exception safety fallback in case custom validation logic crashes
          return 'Invalid input format';
        }
      },
    );
  }
}