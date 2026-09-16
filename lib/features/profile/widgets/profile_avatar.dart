import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String firstName;
  final String lastName;

  const ProfileAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  String get _initials {
    final initials = '${firstName.trim().isNotEmpty ? firstName.trim()[0] : ''}'
        '${lastName.trim().isNotEmpty ? lastName.trim()[0] : ''}';
    return initials.isEmpty ? '?' : initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    const Color purpleGlow = Color(0xFF8B5CF6);
    const Color deepPurple = Color(0xFF6D28D9);

    try {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: purpleGlow.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(3.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFA78BFA),
                purpleGlow,
                deepPurple,
              ],
            ),
          ),
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    purpleGlow.withValues(alpha: 0.12),
                    purpleGlow.withValues(alpha: 0.04),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: deepPurple,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error rendering ProfileAvatar: $e\n$stackTrace');
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFEF2F2),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
        ),
        child: const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 32,
          ),
        ),
      );
    }
  }
}