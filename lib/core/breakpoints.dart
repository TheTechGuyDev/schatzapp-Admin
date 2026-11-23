import 'package:material_ui/material_ui.dart';

enum ScreenSize { phone, tablet, desktop }

class Breakpoints {
  Breakpoints._();
  static const phone = 760.0;
  static const desktop = 1200.0;

  static ScreenSize of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < phone) return ScreenSize.phone;
    if (w < desktop) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }
}
