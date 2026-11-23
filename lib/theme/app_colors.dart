import 'package:material_ui/material_ui.dart';

/// Approved admin palette (matches the mobile app's admin side nav).
class AppColors {
  AppColors._();

  static const sidebar = Color(0xFF2C0951);
  static const sidebarHover = Color(0xFF3A1466);
  static const brand = Color(0xFF935CCC);
  static const brandDark = Color(0xFF7A43B6);
  static const magenta = Color(0xFFD239EF);
  static const teal = Color(0xFF39D2C0);
  static const online = Color(0xFF2FFB4B);

  static const background = Color(0xFFF6F4F9);
  static const card = Colors.white;
  static const border = Color(0xFFECE8F2);
  static const text = Color(0xFF111B21);
  static const textSecondary = Color(0xFF667781);
  static const muted = Color(0xFFEFEAF5);

  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFE7F7EE);
  static const warning = Color(0xFFD97706);
  static const warningBg = Color(0xFFFFF4DB);
  static const danger = Color(0xFFE11D48);
  static const dangerBg = Color(0xFFFDE8EC);
  static const info = Color(0xFF3B82F6);
  static const infoBg = Color(0xFFE8F0FE);

  static const brandGradient = LinearGradient(
    colors: [brand, magenta],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
