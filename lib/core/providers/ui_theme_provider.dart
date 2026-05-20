import 'package:flutter/material.dart';
import 'package:chat_app/core/constants/colors.dart';

class UiThemePreset {
  final String id;
  final String name;
  final List<Color> backgroundGradient;
  final Color mineBubbleColor;
  final Color otherBubbleColor;
  final Color primaryAccent;
  final bool isDark;

  UiThemePreset({
    required this.id,
    required this.name,
    required this.backgroundGradient,
    required this.mineBubbleColor,
    required this.otherBubbleColor,
    required this.primaryAccent,
    required this.isDark,
  });
}

class UiThemeProvider extends ChangeNotifier {
  final List<UiThemePreset> presets = [
    // 1. yCHAT Rose Glass (Default Red & White)
    UiThemePreset(
      id: 'rose_glass',
      name: 'yCHAT Rose Glass',
      backgroundGradient: [
        const Color(0xFFFFF5F5),
        const Color(0xFFFFFFFF),
      ],
      mineBubbleColor: const Color(0xFFE53935),
      otherBubbleColor: const Color(0xFFEEEEEE),
      primaryAccent: const Color(0xFFE53935),
      isDark: false,
    ),
    // 2. Warm Mocha (Screenshot Aesthetic)
    UiThemePreset(
      id: 'warm_mocha',
      name: 'Warm Mocha',
      backgroundGradient: [
        const Color(0xFF3E2723),
        const Color(0xFF1A0C08),
      ],
      mineBubbleColor: const Color(0xFFD84315),
      otherBubbleColor: const Color(0xFF4E342E),
      primaryAccent: const Color(0xFFFF5722),
      isDark: true,
    ),
    // 3. Amoled Crimson
    UiThemePreset(
      id: 'amoled_crimson',
      name: 'Amoled Crimson',
      backgroundGradient: [
        const Color(0xFF000000),
        const Color(0xFF0F0000),
      ],
      mineBubbleColor: const Color(0xFFC62828),
      otherBubbleColor: const Color(0xFF212121),
      primaryAccent: const Color(0xFFD32F2F),
      isDark: true,
    ),
  ];

  late UiThemePreset _activePreset;

  UiThemeProvider() {
    _activePreset = presets[0]; // Default is yCHAT Rose Glass
  }

  UiThemePreset get activePreset => _activePreset;

  void selectPreset(String id) {
    final found = presets.firstWhere((p) => p.id == id, orElse: () => presets[0]);
    if (_activePreset.id != found.id) {
      _activePreset = found;
      notifyListeners();
    }
  }
}
