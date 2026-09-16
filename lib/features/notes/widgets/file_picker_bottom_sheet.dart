import 'package:flutter/material.dart';

class FilePickerBottomSheet extends StatelessWidget {
  final VoidCallback onPdfPick;
  final VoidCallback onImagePick;
  final VoidCallback onCameraPick;

  const FilePickerBottomSheet({
    super.key,
    required this.onPdfPick,
    required this.onImagePick,
    required this.onCameraPick,
  });

  void _handleOptionTap(BuildContext context, VoidCallback callback) {
    try {
      Navigator.pop(context);
      callback();
    } catch (e, stackTrace) {
      debugPrint('FilePickerBottomSheet error: $e\n$stackTrace');
      if (!context.mounted) return;

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
                  'An unexpected error occurred: ${e.toString()}',
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
  }

  @override
  Widget build(BuildContext context) {
    // Custom color scheme matching the design palette
    const Color sheetBgColor = Colors.white;
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color purpleGlow = Color(0xFFC084FC);
    const Color handleColor = Color(0xFFE2E8F0);

    // Color accents for option icons matching the app UI
    const Color pdfIconBg = Color(0xFFEFF6FF);
    const Color pdfIconColor = Color(0xFF3B82F6);
    
    const Color imageIconBg = Color(0xFFFBF1FF);
    const Color imageIconColor = Color(0xFFA855F7);

    const Color cameraIconBg = Color(0xFFFFF7ED);
    const Color cameraIconColor = Color(0xFFF97316);

    const borderRadius = BorderRadius.vertical(top: Radius.circular(28));

    return Container(
      decoration: BoxDecoration(
        color: sheetBgColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: purpleGlow.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern top drag handle indicator
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Import Note Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a method to extract text into your notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _buildPickerOption(
                context: context,
                icon: Icons.picture_as_pdf_rounded,
                iconBgColor: pdfIconBg,
                iconColor: pdfIconColor,
                title: 'Import PDF Document',
                subtitle: 'Extract text from PDF file',
                onTap: () => _handleOptionTap(context, onPdfPick),
              ),
              const SizedBox(height: 12),
              _buildPickerOption(
                context: context,
                icon: Icons.image_rounded,
                iconBgColor: imageIconBg,
                iconColor: imageIconColor,
                title: 'Pick Image from Gallery',
                subtitle: 'Extract text via OCR',
                onTap: () => _handleOptionTap(context, onImagePick),
              ),
              const SizedBox(height: 12),
              _buildPickerOption(
                context: context,
                icon: Icons.camera_alt_rounded,
                iconBgColor: cameraIconBg,
                iconColor: cameraIconColor,
                title: 'Capture with Camera',
                subtitle: 'Take a photo of printed text',
                onTap: () => _handleOptionTap(context, onCameraPick),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color optionBgColor = Color(0xFFF8FAFC);
    const Color splashColor = Color(0xFFC084FC);
    
    final optionRadius = BorderRadius.circular(18);

    return Material(
      color: optionBgColor,
      borderRadius: optionRadius,
      child: InkWell(
        borderRadius: optionRadius,
        splashColor: splashColor.withValues(alpha: 0.08),
        highlightColor: splashColor.withValues(alpha: 0.04),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}