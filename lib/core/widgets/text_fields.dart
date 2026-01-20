import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const SearchTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textHint,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
