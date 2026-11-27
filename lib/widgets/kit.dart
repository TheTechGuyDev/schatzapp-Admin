import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'charts.dart';
import 'table.dart';
import 'ui.dart';

/// Shared building blocks for the list pages (approved Admin Panel style):
/// a main column with a table card, a side column of summary cards, side
/// panels for details, and the reason / security confirmation dialogs.

/// Main content plus a side column; the side column drops below the main
/// one on narrower screens.
class MainSideLayout extends StatelessWidget {
  const MainSideLayout({
    super.key,
    required this.main,
    required this.side,
    this.breakAt = 1100,
  });

  final Widget main;
  final Widget side;
  final double breakAt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < breakAt) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [main, const SizedBox(height: 18), side],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 49, child: main),
            const SizedBox(width: 18),
            Expanded(flex: 18, child: side),
          ],
        );
      },
    );
  }
}

/// A row-menu item: value, label, and whether it is a destructive action.
typedef MenuEntry = (String value, String label, bool danger);

/// The square "..." actions button used at the end of table rows.
class RowMenu extends StatelessWidget {
  const RowMenu({super.key, required this.items, required this.onSelected});

  final List<MenuEntry> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final (v, l, d) in items)
          PopupMenuItem(
            value: v,
            height: 38,
            child: Text(
              l,
              style: TextStyle(
                fontSize: 13,
                color: d ? AppColors.danger : AppColors.text,
              ),
            ),
          ),
      ],
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Small tinted label (category / module / type tags in tables).
class TintTag extends StatelessWidget {
  const TintTag(this.label, this.color, {super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Table card: tabs, a toolbar, optional labelled filters, the table (or a
/// card list on narrow widths) and pagination.
class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    this.title,
    this.subtitle,
    this.tabs,
    this.tab = 0,
    this.onTab,
    this.toolbar = const [],
    this.filters = const [],
    required this.cols,
    required this.rows,
    required this.narrowRow,
    this.onRowTap,
    this.empty = 'Nothing to show here.',
    this.footerNote,
    this.pageInfo,
    this.lastPage = 1,
    this.checkbox = true,
  });

  final String? title;
  final String? subtitle;
  final List<String>? tabs;
  final int tab;
  final ValueChanged<int>? onTab;
  final List<Widget> toolbar;
  final List<Widget> filters;
  final List<Col> cols;
  final List<List<Widget>> rows;
  final Widget Function(int i) narrowRow;
  final ValueChanged<int>? onRowTap;
  final String empty;
  final String? footerNote;
  final String? pageInfo;
  final int lastPage;
  final bool checkbox;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 0,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 820;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                  child: CardHeader(title: title!, subtitle: subtitle),
                ),
              if (tabs != null || (toolbar.isNotEmpty && !narrow))
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: Row(
                    children: [
                      if (tabs != null)
                        Expanded(
                          child: UnderlineTabs(
                            labels: tabs!,
                            selected: tab,
                            onSelect: onTab ?? (_) {},
                          ),
                        )
                      else
                        const Spacer(),
                      if (!narrow && toolbar.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        for (var i = 0; i < toolbar.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          toolbar[i],
                        ],
                      ],
                    ],
                  ),
                ),
              if (tabs != null)
                const Divider(height: 1, color: AppColors.border),
              if (narrow && toolbar.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: Wrap(spacing: 8, runSpacing: 8, children: toolbar),
                ),
              if (filters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: filters,
                  ),
                ),
              const SizedBox(height: 10),
              if (rows.isEmpty)
                EmptyState(empty)
              else if (narrow)
                for (var i = 0; i < rows.length; i++)
                  InkWell(
                    onTap: onRowTap == null ? null : () => onRowTap!(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: narrowRow(i),
                    ),
                  )
              else ...[
                TableHead(cols: cols, checkbox: checkbox),
                for (var i = 0; i < rows.length; i++)
                  TableLine(
                    cols: cols,
                    checkbox: checkbox,
                    cells: rows[i],
                    onTap: onRowTap == null ? null : () => onRowTap!(i),
                  ),
              ],
              if (footerNote != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          footerNote!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (pageInfo != null)
                PaginationBar(info: pageInfo!, lastPage: lastPage)
              else
                const SizedBox(height: 14),
            ],
          );
        },
      ),
    );
  }
}

/// Narrow-screen row: avatar/leading, two lines, trailing widget.
class NarrowRow extends StatelessWidget {
  const NarrowRow({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const SizedBox(width: 10),
        Expanded(child: TwoLine(title, subtitle)),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}

/// Round tinted icon used as a row leading.
class TintIcon extends StatelessWidget {
  const TintIcon(this.icon, this.color, {super.key, this.size = 34});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size / 3.4),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// Donut with a legend ("Tickets Overview", "Logs by Module").
class DonutCard extends StatelessWidget {
  const DonutCard({
    super.key,
    required this.title,
    required this.items,
    required this.centerTop,
    required this.centerBottom,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<(String, double, Color)> items;
  final String centerTop;
  final String centerBottom;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (a, b) => a + b.$2);
    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, subtitle: subtitle, trailing: trailing),
          const SizedBox(height: 14),
          Row(
            children: [
              DonutChart(
                values: [for (final i in items) i.$2],
                colors: [for (final i in items) i.$3],
                centerTop: centerTop,
                centerBottom: centerBottom,
                size: 112,
                stroke: 12,
                fontSize: 17,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    for (final i in items)
                      LegendRow(
                        color: i.$3,
                        label: i.$1,
                        value: groupDigits(i.$2),
                        percent: total == 0
                            ? null
                            : '${(i.$2 / total * 100).toStringAsFixed(1)}%',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horizontal bars with a value ("Tickets by Priority", "Logs by Status").
class BarsCard extends StatelessWidget {
  const BarsCard({
    super.key,
    required this.title,
    required this.items,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  /// label, share (0..1), value text, colour
  final List<(String, double, String, Color)> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 10),
          for (final (label, share, value, color) in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: share.clamp(0, 1),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF0EEF6),
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 92,
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One line in an activity list.
class Act {
  const Act(this.icon, this.color, this.title, this.time, {this.sub});

  final IconData icon;
  final Color color;
  final String title;
  final String? sub;
  final String time;
}

/// "Recent Activity" style card.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.title,
    required this.items,
    this.viewAll = true,
    this.onViewAll,
  });

  final String title;
  final List<Act> items;
  final bool viewAll;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            trailing: viewAll ? LinkText('View All', onTap: onViewAll) : null,
          ),
          const SizedBox(height: 6),
          for (final a in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TintIcon(a.icon, a.color, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (a.sub != null)
                          Text(
                            a.sub!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    a.time,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "Need Help?" card at the bottom of side columns.
class HelpCard extends StatelessWidget {
  const HelpCard(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 16,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need Help?',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const OutlineButtonBox(
            label: 'View Guide',
            icon: Icons.menu_book_outlined,
          ),
        ],
      ),
    );
  }
}

/// Label + value line used inside detail panels.
class InfoLine extends StatelessWidget {
  const InfoLine(this.label, this.value, {super.key, this.valueWidget});

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child:
                valueWidget ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// Section title inside a panel.
class PanelSection extends StatelessWidget {
  const PanelSection(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Timeline entry (history of actions on a case, ticket or approval).
class TimelineEntry extends StatelessWidget {
  const TimelineEntry({
    super.key,
    required this.title,
    required this.by,
    required this.time,
    this.color = AppColors.brand,
    this.note,
    this.last = false,
  });

  final String title;
  final String by;
  final String time;
  final String? note;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 1.5, color: AppColors.border),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$by · $time',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        note!,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard text field style for forms and dialogs.
InputDecoration fieldDecoration(String hint, {Widget? prefix}) =>
    InputDecoration(
      hintText: hint,
      isDense: true,
      prefixIcon: prefix,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.brand),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );

/// A labelled form field block.
class FieldBlock extends StatelessWidget {
  const FieldBlock(this.label, this.child, {super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.navText,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

/// Simple dropdown field for forms.
class DropField extends StatelessWidget {
  const DropField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isDense: true,
      decoration: fieldDecoration(''),
      style: const TextStyle(fontSize: 13, color: AppColors.text),
      items: [
        for (final o in options) DropdownMenuItem(value: o, child: Text(o)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

/// Opens a details panel that slides in from the right (full screen on
/// phones).
Future<T?> showSidePanel<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget Function(BuildContext ctx) body,
  List<Widget> Function(BuildContext ctx)? actions,
  double width = 560,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x55111827),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, _, _) {
      final w = MediaQuery.sizeOf(ctx).width;
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.white,
          child: SizedBox(
            width: w < 640 ? w : width,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 10, 14),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                    child: body(ctx),
                  ),
                ),
                if (actions != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: actions(ctx),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, a, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0.15, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: a, child: child),
    ),
  );
}

/// Asks for a reason before an action (every admin action needs one).
/// Returns the reason, or null when cancelled.
Future<String?> askReason(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Confirm',
  bool danger = false,
  String hint = 'Reason (required, at least 10 characters)',
  List<Widget> extra = const [],
}) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) {
        final ok = ctrl.text.trim().length >= 10;
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ...extra,
                TextField(
                  controller: ctrl,
                  maxLines: 3,
                  onChanged: (_) => set(() {}),
                  style: const TextStyle(fontSize: 13),
                  decoration: fieldDecoration(hint),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This action is recorded in the audit log with your name, '
                  'the time and this reason.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          actions: [
            OutlineButtonBox(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
            Opacity(
              opacity: ok ? 1 : 0.5,
              child: danger
                  ? _DangerButton(
                      label: confirm,
                      onTap: ok ? () => Navigator.pop(ctx, ctrl.text) : null,
                    )
                  : PrimaryButton(
                      label: confirm,
                      onTap: ok ? () => Navigator.pop(ctx, ctrl.text) : null,
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.danger,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Red filled button for destructive actions.
class DangerButton extends StatelessWidget {
  const DangerButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      _DangerButton(label: label, onTap: onTap);
}

/// Re-authentication for sensitive actions: admin password plus the
/// 6-digit authenticator code. Returns true when both are entered (the
/// server verifies them in the backend phase).
Future<bool> askSecurity(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Verify and continue',
}) async {
  final pass = TextEditingController();
  final code = TextEditingController();
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) {
        final ok =
            pass.text.length >= 8 &&
            RegExp(r'^\d{6}$').hasMatch(code.text.trim());
        return AlertDialog(
          title: Row(
            children: [
              const TintIcon(Icons.verified_user_outlined, AppColors.brand),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                FieldBlock(
                  'Your admin password',
                  TextField(
                    controller: pass,
                    obscureText: true,
                    onChanged: (_) => set(() {}),
                    style: const TextStyle(fontSize: 13),
                    decoration: fieldDecoration('Password'),
                  ),
                ),
                FieldBlock(
                  'Authenticator code',
                  TextField(
                    controller: code,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => set(() {}),
                    style: const TextStyle(fontSize: 15, letterSpacing: 6),
                    decoration: fieldDecoration('000000')
                        .copyWith(counterText: ''),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlineButtonBox(
              label: 'Cancel',
              onTap: () => Navigator.pop(ctx, false),
            ),
            Opacity(
              opacity: ok ? 1 : 0.5,
              child: PrimaryButton(
                label: confirm,
                onTap: ok ? () => Navigator.pop(ctx, true) : null,
              ),
            ),
          ],
        );
      },
    ),
  );
  return r == true;
}

/// Settings-style row: tinted icon, title + description, control on the
/// right (stacks under on narrow widths).
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.control,
    this.last = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final Widget control;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final head = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TintIcon(icon, color, size: 34),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [head, const SizedBox(height: 10), control],
            );
          }
          return Row(
            children: [
              Expanded(flex: 5, child: head),
              const SizedBox(width: 16),
              Expanded(flex: 6, child: control),
            ],
          );
        },
      ),
    );
  }
}

/// Brand-coloured switch.
class BrandSwitch extends StatelessWidget {
  const BrandSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.brand,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFD5D9DE),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}

/// Little "Sample data" note shown on pages until the backend phase.
class SampleNote extends StatelessWidget {
  const SampleNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.brand,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.navText),
            ),
          ),
        ],
      ),
    );
  }
}
