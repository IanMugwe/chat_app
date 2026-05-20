import 'package:flutter/material.dart';

class YChatAuthColors {
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFDFD);
  static const glass = Color(0xFFFFFFFF);
  static const red = Color(0xFFE53935); // Premium primary red
  static const redDark = Color(0xFFC62828); // Dark accent red
  static const white = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1F2937); // Dark gray for high contrast text
  static const textMuted = Color(0xFF6B7280); // Muted gray
  static const border = Color(0xFFE5E7EB); // Soft gray border
  static const errorSoft = Color(0xFFFEE2E2); // Soft red background for errors
  static const errorText = Color(0xFFB91C1C); // Deep red text for errors
  static const inputFill = Color(0xFFF9FAFB); // Elegant off-white input fill
}

ThemeData yChatLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: YChatAuthColors.background,
    primaryColor: YChatAuthColors.red,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: YChatAuthColors.red,
      secondary: YChatAuthColors.redDark,
      surface: YChatAuthColors.surface,
      error: YChatAuthColors.red,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: YChatAuthColors.red,
      selectionColor: Color(0x33E53935),
      selectionHandleColor: YChatAuthColors.red,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: YChatAuthColors.inputFill,
      prefixIconColor: YChatAuthColors.textMuted,
      suffixIconColor: YChatAuthColors.textMuted,
      labelStyle: const TextStyle(color: YChatAuthColors.textMuted, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: YChatAuthColors.red, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(color: YChatAuthColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YChatAuthColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YChatAuthColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YChatAuthColors.red, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YChatAuthColors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YChatAuthColors.redDark, width: 1.8),
      ),
    ),
  );
}

ThemeData yChatDarkTheme() => yChatLightTheme();

