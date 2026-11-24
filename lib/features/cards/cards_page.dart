import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sample_finance.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Cards: payment cards users saved for wallet top-ups (saved_cards).
/// Only the brand and last four digits are ever stored or shown.
class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

const _tabs = ['All Cards', 'Active', 'Flagged', 'Removed'];

ChipKind _kind(String s) => switch (s) {
  'Active' => ChipKind.success,
  'Flagged' => ChipKind.warning,
  'Removed' => ChipKind.neutral,
  _ => ChipKind.neutral,
};

Color _brandColor(String b) => switch (b) {
  'Visa' => const Color(0xFF1A1F71),
  'Mastercard' => const Color(0xFFEB001B),
  'Verve' => const Color(0xFF00A651),
  'Amex' => const Color(0xFF2E77BB),
  _ => AppColors.textSecondary,
};

class _CardsPageState extends State<CardsPage> {
  int _tab = 0;
  String _q = '';

  List<SavedCard> get _rows => SampleFinance.cards.where((c) {
    if (_tab > 0 && c.status != _tabs[_tab]) return false;
    if (_q.isEmpty) return true;
    final q = _q.toLowerCase();
    return c.user.toLowerCase().contains(q) || c.last4.contains(q);
  }).toList();

  Future<void> _action(SavedCard card, String action) async {
    final reason = TextEditingController();
    final remove = action == 'remove';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          remove ? 'Remove saved card' : 'Flag card for review',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${card.brand} •••• ${card.last4} belonging to ${card.user}. '
                '${remove ? 'The user will need to add it again to top up.' : 'Top-ups with this card will be held for review.'}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reason,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Reason (required)',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
          PrimaryButton(
            label: 'Confirm',
            onTap: () {
              if (reason.text.trim().length >= 10) Navigator.pop(ctx, true);
            },
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      toast(context, remove ? 'Card removed' : 'Card flagged for review');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        const TileGrid(
          minTileWidth: 220,
          maxColumns: 4,
          gap: 18,
          allowedColumns: [1, 2, 4],
          children: [
            StatCard(
              label: 'Saved Cards',
              value: '6,214',
              change: '5.4% this month',
              icon: Icons.credit_card_rounded,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [5.1, 5.3, 5.4, 5.6, 5.8, 5.9, 6.1, 6.21],
            ),
            StatCard(
              label: 'Card Top-ups (Month)',
              value: 'SFZ 842,300',
              change: '11.2% from last month',
              icon: Icons.add_card_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [0.6, 0.62, 0.66, 0.7, 0.72, 0.77, 0.8, 0.84],
            ),
            StatCard(
              label: 'Failed Card Payments',
              value: '214',
              change: '3.1% failure rate',
              icon: Icons.credit_card_off_outlined,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
            ),
            StatCard(
              label: 'Flagged Cards',
              value: '17',
              change: '4 new this week',
              icon: Icons.flag_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              positive: false,
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final table = _table();
            const side = _CardsSide();
            if (c.maxWidth < 1100) {
              return Column(
                children: [table, const SizedBox(height: 18), side],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 49, child: table),
                const SizedBox(width: 18),
                const Expanded(flex: 18, child: side),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _table() {
    const cols = [
      Col('User', 22),
      Col('Card', 15),
      Col('Billing country', 14),
      Col('Default', 8),
      Col('Added', 12),
      Col('Top-ups', 8),
      Col('Status', 10),
      Col('Actions', 7, align: TextAlign.center),
    ];
    final rows = _rows;
    return AppCard(
      padding: 0,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 820;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: UnderlineTabs(
                  labels: _tabs,
                  selected: _tab,
                  onSelect: (i) => setState(() => _tab = i),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SearchBox(
                      hint: 'Search by user or last 4 digits',
                      width: narrow ? c.maxWidth - 36 : 280,
                      onChanged: (v) => setState(() => _q = v.trim()),
                    ),
                    const OutlineButtonBox(
                      label: 'Filters',
                      icon: Icons.filter_alt_outlined,
                    ),
                    const OutlineButtonBox(
                      label: 'Export',
                      icon: Icons.file_download_outlined,
                      trailingChevron: true,
                    ),
                  ],
                ),
              ),
              if (rows.isEmpty)
                const EmptyState('No cards in this list.')
              else if (narrow)
                for (final s in rows)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Avatar(name: s.user, size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TwoLine(s.user, '${s.brand} •••• ${s.last4}'),
                        ),
                        StatusChip(s.status, kind: _kind(s.status)),
                      ],
                    ),
                  )
              else ...[
                const TableHead(cols: cols, checkbox: true),
                for (final s in rows)
                  TableLine(
                    cols: cols,
                    checkbox: true,
                    cells: [
                      Row(
                        children: [
                          Avatar(name: s.user, size: 30),
                          const SizedBox(width: 8),
                          Expanded(child: TwoLine(s.user, s.email)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _brandColor(s.brand)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s.brand,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _brandColor(s.brand),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•••• ${s.last4}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        s.billingCountry,
                        style: const TextStyle(fontSize: 12),
                      ),
                      s.isDefault
                          ? const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AppColors.success,
                            )
                          : const Text(
                              '-',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                      Text(s.added, style: const TextStyle(fontSize: 12)),
                      Text(
                        '${s.topups}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      StatusChip(s.status, kind: _kind(s.status)),
                      PopupMenuButton<String>(
                        tooltip: 'Actions',
                        onSelected: (v) {
                          if (v == 'user') {
                            context.go('/users');
                          } else {
                            _action(s, v);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'user',
                            child: Text(
                              'Open user',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'flag',
                            child: Text(
                              'Flag for review',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: Text(
                              'Remove card',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.danger,
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
                      ),
                    ],
                  ),
              ],
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Full card numbers are never stored. Payments are handled by the payment provider.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PaginationBar(
                info: 'Showing 1 to ${rows.length} of 6,214 cards',
                lastPage: 622,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CardsSide extends StatelessWidget {
  const _CardsSide();

  @override
  Widget build(BuildContext context) {
    const brands = [
      ('Visa', 2890.0, Color(0xFF1A1F71)),
      ('Mastercard', 2110.0, Color(0xFFEB001B)),
      ('Verve', 960.0, Color(0xFF00A651)),
      ('Amex', 254.0, Color(0xFF2E77BB)),
    ];
    final total = brands.fold<double>(0, (a, b) => a + b.$2);
    return SideStack(
      children: [
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'Card Brands'),
              const SizedBox(height: 14),
              Row(
                children: [
                  DonutChart(
                    values: [for (final b in brands) b.$2],
                    colors: [for (final b in brands) b.$3],
                    centerTop: '6,214',
                    centerBottom: 'Cards',
                    size: 112,
                    stroke: 12,
                    fontSize: 17,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        for (final b in brands)
                          LegendRow(
                            color: b.$3,
                            label: b.$1,
                            value:
                                '${(b.$2 / total * 100).toStringAsFixed(1)}%',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'Top-up Success Rate'),
              const SizedBox(height: 12),
              for (final r in const [
                ('Visa', 0.97),
                ('Mastercard', 0.95),
                ('Verve', 0.91),
                ('Amex', 0.88),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.$1,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            '${(r.$2 * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: r.$2,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF0EEF6),
                          color: AppColors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: 'Recent Card Activity'),
              SizedBox(height: 6),
              ActivityRow(
                icon: Icons.add_card_rounded,
                color: AppColors.success,
                title: 'Michael Uche topped up with Verve •••• 0193',
                amount: 'SFZ 5,000',
                time: '3 mins ago',
              ),
              ActivityRow(
                icon: Icons.credit_card_off_outlined,
                color: AppColors.danger,
                title: 'Card declined for Sarah Collins',
                amount: 'SFZ 2,000',
                time: '40 mins ago',
                amountColor: AppColors.danger,
              ),
              ActivityRow(
                icon: Icons.credit_card_rounded,
                color: AppColors.brand,
                title: 'Temi Adeyemi saved a new Visa card',
                amount: '-',
                time: '2 hours ago',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
