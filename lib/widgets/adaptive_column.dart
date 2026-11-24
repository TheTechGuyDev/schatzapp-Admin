import 'package:material_ui/material_ui.dart';

/// Column whose `middle` child fills spare height when the parent gives a
/// fixed height (side-by-side cards) and sizes naturally when stacked.
class AdaptiveColumn extends StatelessWidget {
  const AdaptiveColumn({
    super.key,
    this.top = const [],
    required this.middle,
    this.bottom = const [],
  });

  final List<Widget> top;
  final Widget middle;
  final List<Widget> bottom;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final bounded = c.hasBoundedHeight;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            ...top,
            bounded ? Expanded(child: middle) : middle,
            ...bottom,
          ],
        );
      },
    );
  }
}
