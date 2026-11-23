import 'package:material_ui/material_ui.dart';

/// Admin Panel palette (client-approved light style: white side nav,
/// violet accents, soft tinted icon circles).
class AppColors {
  AppColors._();

  static const brand = Color(0xFF5B2BE0);
  static const brandDark = Color(0xFF4A1FC4);
  static const brandSoft = Color(0xFFF1ECFF);
  static const brandGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF5B2BE0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const background = Color(0xFFF7F7FB);
  static const card = Colors.white;
  static const sidebar = Colors.white;
  static const border = Color(0xFFEDEDF3);
  static const text = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const navText = Color(0xFF374151);
  static const hover = Color(0xFFF6F4FD);

  static const online = Color(0xFF22C55E);

  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFE8F7EE);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFFF5E1);
  static const danger = Color(0xFFE11D48);
  static const dangerSoft = Color(0xFFFDECEF);
  static const info = Color(0xFF3B82F6);
  static const infoSoft = Color(0xFFEAF1FF);
  static const teal = Color(0xFF14B8A6);
  static const tealSoft = Color(0xFFE6F7F5);
  static const pink = Color(0xFFEC4899);
  static const pinkSoft = Color(0xFFFDEAF4);
  static const grey = Color(0xFF9CA3AF);
}
