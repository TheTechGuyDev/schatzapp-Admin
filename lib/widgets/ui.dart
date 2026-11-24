import 'package:material_ui/material_ui.dart';

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08111827),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Card title + optional subtitle and trailing widget.
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

/// Small violet text link ("View All", "View Report").
class LinkText extends StatelessWidget {
  const LinkText(this.label, {super.key, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.brand,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Soft tinted circle with an icon.
class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 52,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

/// Headline metric card: tinted icon, label, value, change and sparkline.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.background,
    this.positive = true,
    this.spark,
    this.note,
  });

  final String label;
  final String value;

  /// e.g. "12.8% vs last week" (first word coloured). Empty = none.
  final String change;

  /// Grey text before the change, e.g. "This month" or "All time".
  final String? note;
  final IconData icon;
  final Color color;
  final Color background;
  final bool positive;
  final List<double>? spark;

  @override
  Widget build(BuildContext context) {
    final changeColor = positive ? AppColors.success : AppColors.danger;
    return AppCard(
      padding: 0,
      child: SizedBox(
        height: 132,
        child: Stack(
          children: [
            if (spark != null)
              Positioned(
                right: 14,
                bottom: 10,
                child: Sparkline(
                  values: spark!,
                  color: color,
                  width: 84,
                  height: 30,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconCircle(
                    icon: icon,
                    color: color,
                    background: background,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.navText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (note != null) ...[
                              Flexible(
                                child: Text(
                                  note!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (change.isNotEmpty) const SizedBox(width: 6),
                            ],
                            if (change.isNotEmpty) ...[
                              Icon(
                                positive
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 12,
                                color: changeColor,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: change.split(' ').first,
                                        style: TextStyle(
                                          color: changeColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: change.contains(' ')
                                            ? change.substring(
                                                change.indexOf(' '),
                                              )
                                            : '',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
      case 'operational':
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
      ChipKind.success => (AppColors.success, AppColors.successSoft),
      ChipKind.warning => (const Color(0xFFD97706), AppColors.warningSoft),
      ChipKind.danger => (AppColors.danger, AppColors.dangerSoft),
      ChipKind.info => (AppColors.info, AppColors.infoSoft),
      ChipKind.brand => (AppColors.brand, AppColors.brandSoft),
      ChipKind.neutral => (AppColors.textSecondary, const Color(0xFFF3F4F6)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
      height: 38,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.brand, width: 1.3),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ?? () {},
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White outlined button; with `trailingChevron` it reads as a dropdown.
class OutlineButtonBox extends StatelessWidget {
  const OutlineButtonBox({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.trailingChevron = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool trailingChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ?? () {},
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.text),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (trailingChevron) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays children in a row on wide screens and stacks them on narrow ones.
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
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < breakAt) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                children[i],
              ],
            ],
          );
        }
        final row = Row(
          crossAxisAlignment: height == null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(flex: flex[i], child: children[i]),
            ],
          ],
        );
        return height == null ? row : SizedBox(height: height, child: row);
      },
    );
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
    return LayoutBuilder(
      builder: (context, c) {
        var cols = ((c.maxWidth + gap) / (minTileWidth + gap)).floor();
        cols = cols.clamp(1, maxColumns);
        if (allowedColumns != null) {
          cols = allowedColumns!
              .where((a) => a <= cols)
              .fold(1, (a, b) => b > a ? b : a);
        }
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final ch in children) SizedBox(width: w, child: ch)],
        );
      },
    );
  }
}

/// Coloured square + label + value + optional percentage (chart legends).
class LegendRow extends StatelessWidget {
  const LegendRow({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    this.percent,
  });

  final Color color;
  final String label;
  final String value;
  final String? percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: AppColors.navText),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          if (percent != null)
            SizedBox(
              width: 54,
              child: Text(
                percent!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
