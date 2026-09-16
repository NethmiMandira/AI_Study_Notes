import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search notes...',
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  // To handle the clear icon visibility without needing external rebuilds
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  // Premium design details inspired by the image provided.
  static const Color accentBlue = Color(0xFF38BDF8); // Taken from 'Hours' card number
  static const Color premiumGlow = Color(0xFFC084FC); // Purple base glow
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    // Technique used: Outer BoxDecoration for premium background,
    // and inner InputDecoration with transparent background for alignment.
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // From light list background
        borderRadius: borderRadius,
        // Soft ambient 'spread' shadow based on the lesson details header technique
        boxShadow: [
          BoxShadow(
            color: premiumGlow.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          // Subtle defined edge shadow like list items
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        // Match standard typography
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          // Muted grey hint text and muted grey prefix icon
          hintStyle: const TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Icon(Icons.search_rounded, color: textMuted, size: 22),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: accentBlue, size: 22), // Blue accent for clear action
                  onPressed: () {
                    widget.controller.clear();
                    if (widget.onClear != null) widget.onClear!();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent, // Controlled by the Container above
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          // No visible borders for a premium flat feel
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}