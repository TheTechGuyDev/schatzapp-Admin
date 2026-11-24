import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'ui.dart';

/// Underlined tabs with counts ("All (1,248)", "Pending (86)").
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            InkWell(
              onTap: () => onSelect(i),
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                margin: const EdgeInsets.only(right: 22),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == selected
                          ? AppColors.brand
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: i == selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: i == selected ? AppColors.brand : AppColors.navText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Column definition for [TableHead] / [TableLine].
class Col {
  const Col(this.label, this.flex, {this.align = TextAlign.left});
  final String label;
  final int flex;
  final TextAlign align;
}

/// Grey header row with uppercase labels.
class TableHead extends StatelessWidget {
  const TableHead({super.key, required this.cols, this.checkbox = false});

  final List<Col> cols;
  final bool checkbox;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFC),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          if (checkbox) const _Box(),
          for (final c in cols)
            Expanded(
              flex: c.flex,
              child: Text(
                c.label.toUpperCase(),
                textAlign: c.align,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: AppColors.navText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One table row; `cells` line up with the [Col] flexes.
class TableLine extends StatefulWidget {
  const TableLine({
    super.key,
    required this.cols,
    required this.cells,
    this.checkbox = false,
    this.onTap,
  });

  final List<Col> cols;
  final List<Widget> cells;
  final bool checkbox;
  final VoidCallback? onTap;

  @override
  State<TableLine> createState() => _TableLineState();
}

class _TableLineState extends State<TableLine> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _hover && widget.onTap != null
                ? const Color(0xFFFBFAFE)
                : null,
            border: const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              if (widget.checkbox) const _Box(),
              for (var i = 0; i < widget.cols.length; i++)
                Expanded(
                  flex: widget.cols[i].flex,
                  child: Align(
                    alignment: switch (widget.cols[i].align) {
                      TextAlign.right => Alignment.centerRight,
                      TextAlign.center => Alignment.center,
                      _ => Alignment.centerLeft,
                    },
                    child: widget.cells[i],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.4),
      ),
    );
  }
}

/// Bold name over a grey second line.
class TwoLine extends StatelessWidget {
  const TwoLine(
    this.top,
    this.bottom, {
    super.key,
    this.topColor,
    this.bold = true,
  });
  final String top;
  final String bottom;
  final Color? topColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          top,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: topColor ?? AppColors.text,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          bottom,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Small bordered square icon button (eye, download, more).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap ?? () {},
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

/// Country code chip + name (flags need an emoji font, so codes are used).
class CountryTag extends StatelessWidget {
  const CountryTag(this.code, this.name, {super.key});
  final String code;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.brand,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

/// Status chip with a leading dot icon (as in the KYC design).
class DotChip extends StatelessWidget {
  const DotChip(this.label, {super.key, required this.kind});
  final String label;
  final ChipKind kind;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, icon) = switch (kind) {
      ChipKind.success => (
        AppColors.success,
        AppColors.successSoft,
        Icons.check_circle_outline_rounded,
      ),
      ChipKind.warning => (
        const Color(0xFFD97706),
        AppColors.warningSoft,
        Icons.schedule_rounded,
      ),
      ChipKind.danger => (
        AppColors.danger,
        AppColors.dangerSoft,
        Icons.cancel_outlined,
      ),
      ChipKind.info => (
        AppColors.info,
        AppColors.infoSoft,
        Icons.info_outline_rounded,
      ),
      ChipKind.brand => (
        AppColors.brand,
        AppColors.brandSoft,
        Icons.flag_outlined,
      ),
      ChipKind.neutral => (
        AppColors.textSecondary,
        const Color(0xFFF3F4F6),
        Icons.remove_circle_outline_rounded,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Showing 1 to 7 of 1,248 results" + page buttons + page size.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.info,
    required this.lastPage,
    this.page = 1,
    this.onPage,
    this.perPage = '10 / page',
  });

  final String info;
  final int lastPage;
  final int page;
  final ValueChanged<int>? onPage;
  final String perPage;

  @override
  Widget build(BuildContext context) {
    Widget box(Widget child, {bool active = false, VoidCallback? onTap}) =>
        InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 32),
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.brand : Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: active ? AppColors.brand : AppColors.border,
              ),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : AppColors.text,
                fontWeight: FontWeight.w500,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: active ? Colors.white : AppColors.text,
                ),
                child: child,
              ),
            ),
          ),
        );
    final shown = <int>{1, 2, 3, lastPage}.where((p) => p <= lastPage).toList()
      ..sort();
    final pages = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        box(
          const Icon(Icons.chevron_left_rounded, size: 16),
          onTap: page > 1 ? () => onPage?.call(page - 1) : null,
        ),
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0 && shown[i] - shown[i - 1] > 1) box(const Text('...')),
          box(
            Text('${shown[i]}'),
            active: shown[i] == page,
            onTap: () => onPage?.call(shown[i]),
          ),
        ],
        box(
          const Icon(Icons.chevron_right_rounded, size: 16),
          onTap: page < lastPage ? () => onPage?.call(page + 1) : null,
        ),
      ],
    );
    final infoText = Text(
      info,
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
    );
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 640;
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [infoText, const SizedBox(height: 10), pages],
                )
              : Row(
                  children: [
                    Expanded(child: infoText),
                    pages,
                    const SizedBox(width: 14),
                    OutlineButtonBox(label: perPage, trailingChevron: true),
                  ],
                ),
        );
      },
    );
  }
}

/// Empty state used inside tables and lists.
class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key, this.icon = Icons.inbox_outlined});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
