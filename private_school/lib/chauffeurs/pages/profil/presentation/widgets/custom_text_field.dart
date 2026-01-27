import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9CA3AF),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2E3192),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}