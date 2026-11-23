import 'package:material_ui/material_ui.dart';

import '../core/breakpoints.dart';

/// Scrollable page content with padding that adapts to the screen size.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final pad = switch (Breakpoints.of(context)) {
      ScreenSize.phone => const EdgeInsets.fromLTRB(16, 18, 16, 28),
      ScreenSize.tablet => const EdgeInsets.fromLTRB(24, 26, 24, 32),
      ScreenSize.desktop => const EdgeInsets.fromLTRB(36, 30, 36, 40),
    };
    return SingleChildScrollView(
      padding: pad,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
