import 'package:flutter/material.dart';

/// Centralized color palette for FieldOps.
/// Deep navy/indigo primary with a professional blue accent,
/// used consistently across light and dark themes.
class AppColors {
  AppColors._();

  // Brand
  static const Color navy = Color(0xFF0F1B3D);
  static const Color indigo = Color(0xFF1E2A5E);
  static const Color accentBlue = Color(0xFF2F6FED);
  static const Color accentBlueLight = Color(0xFF5B8DF6);

  // Neutrals - light
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE3E6EE);
  static const Color lightTextPrimary = Color(0xFF14172B);
  static const Color lightTextSecondary = Color(0xFF6B7080);

  // Neutrals - dark
  static const Color darkBackground = Color(0xFF0B0E1A);
  static const Color darkSurface = Color(0xFF151A2E);
  static const Color darkBorder = Color(0xFF262C45);
  static const Color darkTextPrimary = Color(0xFFF3F4F8);
  static const Color darkTextSecondary = Color(0xFF9AA0B4);

  // Semantic
  static const Color success = Color(0xFF1E9E6B);
  static const Color warning = Color(0xFFDB8A1F);
  static const Color error = Color(0xFFD64545);
  static const Color pending = Color(0xFF8A8FA3);
  static const Color inProgress = Color(0xFF2F6FED);

  // Priority
  static const Color priorityLow = Color(0xFF1E9E6B);
  static const Color priorityMedium = Color(0xFFDB8A1F);
  static const Color priorityHigh = Color(0xFFE0632E);
  static const Color priorityUrgent = Color(0xFFD64545);
}
