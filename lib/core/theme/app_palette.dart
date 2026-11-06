import 'package:flutter/material.dart';

/// One palette = one complete theme. Every widget reads colors from the
/// resulting ColorScheme, so all 7 themes stay consistent automatically.
class AppPalette {
  final String id;
  final String name;
  final Brightness brightness;
  final Color bg, surface, primary, secondary, text, muted;

  const AppPalette({
    required this.id,
    required this.name,
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.text,
    required this.muted,
  });

  Color get onPrimary =>
      ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
          ? Colors.white
          : const Color(0xFF111111);

  LinearGradient get gradient => LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const midnight = AppPalette(
    id: 'midnight', name: 'Midnight', brightness: Brightness.dark,
    bg: Color(0xFF0B1020), surface: Color(0xFF151C33),
    primary: Color(0xFF5B8CFF), secondary: Color(0xFF8E6BFF),
    text: Color(0xFFF2F5FF), muted: Color(0xFF8D97B8),
  );
  static const blackGold = AppPalette(
    id: 'black_gold', name: 'Black & Gold', brightness: Brightness.dark,
    bg: Color(0xFF0A0A0A), surface: Color(0xFF1A1A1A),
    primary: Color(0xFFD4AF37), secondary: Color(0xFFF5D76E),
    text: Color(0xFFF7F3E8), muted: Color(0xFF9C9684),
  );
  static const purple = AppPalette(
    id: 'purple', name: 'Purple', brightness: Brightness.dark,
    bg: Color(0xFF160B2B), surface: Color(0xFF23123F),
    primary: Color(0xFFA855F7), secondary: Color(0xFFEC4899),
    text: Color(0xFFF6EEFF), muted: Color(0xFFA78FC8),
  );
  static const ocean = AppPalette(
    id: 'ocean', name: 'Ocean', brightness: Brightness.dark,
    bg: Color(0xFF06202B), surface: Color(0xFF0C3140),
    primary: Color(0xFF22D3EE), secondary: Color(0xFF3B82F6),
    text: Color(0xFFEAFBFF), muted: Color(0xFF7FB0BF),
  );
  static const sunset = AppPalette(
    id: 'sunset', name: 'Sunset', brightness: Brightness.dark,
    bg: Color(0xFF241018), surface: Color(0xFF361A24),
    primary: Color(0xFFFF7A45), secondary: Color(0xFFFF4D8D),
    text: Color(0xFFFFF1EA), muted: Color(0xFFC59A96),
  );
  static const nature = AppPalette(
    id: 'nature', name: 'Nature', brightness: Brightness.dark,
    bg: Color(0xFF0D1F16), surface: Color(0xFF16301F),
    primary: Color(0xFF4ADE80), secondary: Color(0xFFA3E635),
    text: Color(0xFFEFFBF2), muted: Color(0xFF86AC93),
  );
  static const light = AppPalette(
    id: 'light', name: 'Light', brightness: Brightness.light,
    bg: Color(0xFFF7F8FC), surface: Color(0xFFFFFFFF),
    primary: Color(0xFF4F6BFF), secondary: Color(0xFF8B5CF6),
    text: Color(0xFF12162B), muted: Color(0xFF6B7391),
  );

  static const all = [midnight, blackGold, purple, ocean, sunset, nature, light];

  static AppPalette byId(String? id) =>
      all.firstWhere((p) => p.id == id, orElse: () => midnight);
}
