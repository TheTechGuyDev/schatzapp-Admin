import 'package:material_ui/material_ui.dart';

import '../core/breakpoints.dart';
import '../theme/app_colors.dart';
import 'charts.dart';

/// White rounded card used for every panel.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = 20});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A2C0951), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

/// Card title + subtitle with an optional trailing action.
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ]),
      ),
      if (trailing != null) ...[const SizedBox(width: 12), trailing!],
    ]);
  }
}

/// Headline metric card (matches the approved dashboard cards).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    this.positive = true,
    this.spark,
  });

  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final bool positive;
  final List<double>? spark;

  @override
  Widget build(BuildContext context) {
    final deltaColor = positive ? AppColors.success : AppColors.danger;
    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            ),
            const SizedBox(height: 8),
            Text(delta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: deltaColor)),
          ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.brand, size: 21),
          ),
          if (spark != null) ...[
            const SizedBox(height: 18),
            Sparkline(values: spark!, color: deltaColor, width: 70, height: 28),
          ],
        ]),
      ]),
    );
  }
}

enum ChipKind { success, warning, danger, info, neutral, brand }

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.kind = ChipKind.neutral});

  final String label;
  final ChipKind kind;

  static ChipKind kindFor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'successful':
      case 'active':
      case 'verified':
        return ChipKind.success;
      case 'pending':
      case 'under review':
        return ChipKind.warning;
      case 'failed':
      case 'blocked':
      case 'rejected':
        return ChipKind.danger;
      case 'reversed':
      case 'refunded':
        return ChipKind.info;
      default:
        return ChipKind.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (kind) {
      ChipKind.success => (AppColors.success, AppColors.successBg),
      ChipKind.warning => (AppColors.warning, AppColors.warningBg),
      ChipKind.danger => (AppColors.danger, AppColors.dangerBg),
      ChipKind.info => (AppColors.info, AppColors.infoBg),
      ChipKind.brand => (AppColors.brandDark, AppColors.muted),
      ChipKind.neutral => (AppColors.textSecondary, const Color(0xFFF1F1F4)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// Page title row with actions; wraps on small screens.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final phone = Breakpoints.of(context) == ScreenSize.phone;
    final heading = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: TextStyle(
              fontSize: phone ? 22 : 27,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4)),
      const SizedBox(height: 4),
      Text(subtitle,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
    ]);
    if (phone || actions.isEmpty || MediaQuery.sizeOf(context).width < 1280) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        heading,
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: actions),
        ],
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: heading),
      const SizedBox(width: 16),
      Wrap(spacing: 10, runSpacing: 10, children: actions),
    ]);
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    required this.hint,
    this.width = 300,
    this.onChanged,
  });

  final String hint;
  final double width;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 42,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 19, color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.brand, width: 1.4),
          ),
        ),
      ),
    );
  }
}

/// Square white icon button with an optional badge count.
class IconBoxButton extends StatelessWidget {
  const IconBoxButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final int? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () {},
          child: SizedBox(
            width: 42,
            height: 42,
            child: Stack(clipBehavior: Clip.none, children: [
              Center(child: Icon(icon, size: 20, color: AppColors.text)),
              if (badge != null && badge! > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: AppColors.magenta,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text('$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () {},
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ]),
        ),
      ),
    );
  }
}

class OutlineButtonBox extends StatelessWidget {
  const OutlineButtonBox({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () {},
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: AppColors.text),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5)),
          ]),
        ),
      ),
    );
  }
}

/// Lays children in a row on wide screens and stacks them on narrow ones.
/// `flex` gives each child's share of the row.
class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    required this.flex,
    this.breakAt = 980,
    this.gap = 20,
    this.height,
  });

  final List<Widget> children;
  final List<int> flex;
  final double breakAt;
  final double gap;

  /// Shared row height on wide screens so side-by-side cards line up.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < breakAt) {
        return Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ]);
      }
      final row = Row(
        crossAxisAlignment:
            height == null ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(flex: flex[i], child: children[i]),
          ],
        ],
      );
      return height == null ? row : SizedBox(height: height, child: row);
    });
  }
}

/// Grid of equal-width tiles whose column count depends on width.
class TileGrid extends StatelessWidget {
  const TileGrid({
    super.key,
    required this.children,
    required this.minTileWidth,
    this.gap = 20,
    this.maxColumns = 6,
    this.allowedColumns,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double gap;
  final int maxColumns;

  /// Optional whitelist (e.g. [1, 2, 4]) so cards never leave a lonely row.
  final List<int>? allowedColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      var cols = ((c.maxWidth + gap) / (minTileWidth + gap)).floor();
      cols = cols.clamp(1, maxColumns);
      if (allowedColumns != null) {
        cols = allowedColumns!.where((a) => a <= cols).fold(1, (a, b) => b > a ? b : a);
      }
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    });
  }
}
