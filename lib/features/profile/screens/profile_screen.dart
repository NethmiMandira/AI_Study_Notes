import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ai_study_notes/features/auth/providers/auth_provider.dart';
import 'package:ai_study_notes/features/profile/screens/edit_profile_screen.dart';
import 'package:ai_study_notes/features/profile/widgets/profile_avatar.dart';
import 'package:ai_study_notes/features/profile/widgets/profile_detail_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _profileValue(AuthProvider authProvider, String key, String fallback) {
    try {
      final value = authProvider.userProfile?[key]?.toString().trim() ?? '';
      return value.isNotEmpty ? value : fallback;
    } catch (e, stackTrace) {
      debugPrint('Error retrieving profile value for $key: $e\n$stackTrace');
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF0F172A);
    const Color textSecondary = Color(0xFF64748B);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color deepPurple = Color(0xFF6D28D9);

    try {
      final authProvider = context.watch<AuthProvider>();
      final user = authProvider.user;
      final displayName = (user?.displayName ?? '').trim().split(' ');
      final firstName = _profileValue(
        authProvider,
        'firstName',
        displayName.isNotEmpty ? displayName.first : '',
      );
      final lastName = _profileValue(
        authProvider,
        'lastName',
        displayName.length > 1 ? displayName.sublist(1).join(' ') : '',
      );
      final email = _profileValue(authProvider, 'email', user?.email ?? '');

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Profile',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Centered Avatar Header Section
                Center(
                  child: Column(
                    children: [
                      ProfileAvatar(
                        firstName: firstName,
                        lastName: lastName,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$firstName $lastName'.trim().isEmpty
                            ? 'User Profile'
                            : '$firstName $lastName'.trim(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Profile details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Details Tiles
                ProfileDetailTile(
                  icon: Icons.person_outline_rounded,
                  label: 'First name',
                  value: firstName,
                ),
                ProfileDetailTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Last name',
                  value: lastName,
                ),
                ProfileDetailTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email,
                ),
                const SizedBox(height: 32),

                // Modern Action Button
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        primaryPurple,
                        deepPurple,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      } catch (e, stackTrace) {
                        debugPrint('Navigation error: $e\n$stackTrace');
                      }
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Update profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error rendering ProfileScreen: $e\n$stackTrace');
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Profile'),
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
                    'Failed to load profile screen: ${e.toString()}',
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