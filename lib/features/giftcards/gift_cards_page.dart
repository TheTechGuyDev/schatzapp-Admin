import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sample_finance.dart';
import '../../theme/app_colors.dart';
import '../../widgets/adaptive_column.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Gift Cards (approved design): Schatz Gift Cards (internal value) and
/// brand gift cards bought through Reloadly, with the full life of each card.
class GiftCardsPage extends StatelessWidget {
  const GiftCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        const TileGrid(
          minTileWidth: 185,
          maxColumns: 5,
          gap: 18,
          allowedColumns: [1, 2, 3, 5],
          children: [
            StatCard(
              label: 'Total Gift Sales',
              value: 'SFZ 487,500',
              change: '18.6% vs last week',
              icon: Icons.card_giftcard_rounded,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [30, 34, 32, 38, 36, 42, 45, 48.75],
            ),
            StatCard(
              label: 'Total Orders',
              value: '3,842',
              change: '14.2% vs last week',
              icon: Icons.shopping_bag_outlined,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [2.8, 3.0, 3.1, 3.3, 3.2, 3.5, 3.7, 3.84],
            ),
            StatCard(
              label: 'Gift Cards Issued',
              value: '12,568',
              change: '12.7% vs last week',
              icon: Icons.credit_card_rounded,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              spark: [9, 9.5, 10, 10.6, 11, 11.6, 12.1, 12.57],
            ),
            StatCard(
              label: 'Loaded',
              value: '8,421',
              change: '16.3% vs last week',
              icon: Icons.verified_rounded,
              color: AppColors.info,
              background: AppColors.infoSoft,
              spark: [6, 6.4, 6.7, 7, 7.4, 7.8, 8.1, 8.42],
            ),
            StatCard(
              label: 'Not Loaded Yet',
              value: '4,147',
              change: '8.6% vs last week',
              icon: Icons.hourglass_empty_rounded,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
              spark: [3.4, 3.6, 3.5, 3.8, 3.9, 4.0, 4.1, 4.15],
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            const main = Column(
              children: [
                ResponsiveRow(
                  flex: [7, 5],
                  breakAt: 760,
                  gap: 18,
                  height: 330,
                  children: [_SalesCard(), _ByTypeCard()],
                ),
                SizedBox(height: 18),
                _GiftTable(),
              ],
            );
            const side = _Side();
            if (c.maxWidth < 960) {
              return const Column(children: [main, SizedBox(height: 18), side]);
            }
            return const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 49, child: main),
                SizedBox(width: 18),
                Expanded(flex: 16, child: side),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 18,
      child: AdaptiveColumn(
        top: const [
          CardHeader(
            title: 'Sales Overview',
            trailing: OutlineButtonBox(
              label: 'This Week',
              trailingChevron: true,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 18,
            children: [
              _Key(AppColors.brand, 'Sales (SFZ)'),
              _Key(AppColors.grey, 'Orders', dashed: true),
            ],
          ),
          SizedBox(height: 10),
        ],
        middle: LineChart(
          height: 220,
          labels: const [
            'Nov 18',
            'Nov 19',
            'Nov 20',
            'Nov 21',
            'Nov 22',
            'Nov 23',
            'Nov 24',
          ],
          series: [
            ChartSeries(
              name: 'Sales',
              color: AppColors.brand,
              values: const [42000, 78000, 92000, 76500, 61000, 88000, 70000],
              format: (v) => 'SFZ ${compactNumber(v)}',
            ),
            const ChartSeries(
              name: 'Orders',
              color: AppColors.grey,
              values: [210, 430, 520, 650, 340, 610, 420],
              dashed: true,
              secondary: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key(this.color, this.label, {this.dashed = false});
  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      dashed
          ? Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Container(
                    width: 5,
                    height: 2,
                    margin: const EdgeInsets.only(right: 2),
                    color: color,
                  ),
              ],
            )
          : Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 11.5, color: AppColors.navText),
      ),
    ],
  );
}

class _ByTypeCard extends StatelessWidget {
  const _ByTypeCard();

  @override
  Widget build(BuildContext context) {
    const data = [
      ('Schatz Gift Cards', 184500.0, AppColors.brand),
      ('E-Commerce', 126000.0, AppColors.success),
      ('Entertainment', 78500.0, AppColors.warning),
      ('Gaming', 54000.0, AppColors.danger),
      ('Others', 44500.0, AppColors.grey),
    ];
    final total = data.fold<double>(0, (a, b) => a + b.$2);
    return AppCard(
      padding: 18,
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 380;
          final donut = DonutChart(
            values: [for (final d in data) d.$2],
            colors: [for (final d in data) d.$3],
            centerTop: 'SFZ ${compactNumber(total)}',
            centerBottom: 'Total Sales',
            size: compact ? 118 : 146,
            stroke: compact ? 16 : 22,
            fontSize: compact ? 14 : 17,
          );
          final legend = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final d in data)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: d.$3,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.$1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.navText,
                          ),
                        ),
                      ),
                      Text(
                        compact
                            ? '${(d.$2 / total * 100).toStringAsFixed(1)}%'
                            : 'SFZ ${compactNumber(d.$2)} (${(d.$2 / total * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
          return AdaptiveColumn(
            top: [
              CardHeader(
                title: 'Sales by Gift Category',
                trailing: LinkText(
                  compact ? 'Report' : 'View Full Report',
                  onTap: () => context.go('/reports'),
                ),
              ),
              const SizedBox(height: 10),
            ],
            middle: c.maxWidth >= 280
                ? Row(
                    children: [
                      donut,
                      const SizedBox(width: 14),
                      Expanded(child: legend),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [donut, legend],
                  ),
          );
        },
      ),
    );
  }
}

ChipKind _kind(String s) => switch (s) {
  'Loaded' || 'Delivered' || 'Fully Used' => ChipKind.success,
  'Purchased – Not Loaded' || 'Partially Used' => ChipKind.warning,
  'Cancelled' || 'Expired' => ChipKind.danger,
  'Refunded' => ChipKind.info,
  _ => ChipKind.neutral,
};

const _statuses = [
  'All Status',
  'Purchased – Not Loaded',
  'Loaded',
  'Partially Used',
  'Fully Used',
  'Expired',
  'Cancelled',
  'Refunded',
  'Delivered',
];

class _GiftTable extends StatefulWidget {
  const _GiftTable();

  @override
  State<_GiftTable> createState() => _GiftTableState();
}

class _GiftTableState extends State<_GiftTable> {
  int _tab = 0;
  String _status = 'All Status';
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final kind = _tab == 0 ? 'Schatz' : 'Brand';
    final rows = SampleFinance.giftCards.where((g) {
      if (g.kind != kind) return false;
      if (_status != 'All Status' && g.status != _status) return false;
      if (_q.isEmpty) return true;
      final q = _q.toLowerCase();
      return [
        g.id,
        g.buyerAccount,
        g.loadedInto,
        g.txRef,
        g.buyer,
        g.owner,
      ].any((v) => v.toLowerCase().contains(q));
    }).toList();
    const cols = [
      Col('Gift card ID', 15),
      Col('Buyer', 18),
      Col('Value', 9),
      Col('Purchased', 13),
      Col('Current owner', 14),
      Col('Loaded into', 12),
      Col('Status', 15),
      Col('', 5, align: TextAlign.center),
    ];
    return AppCard(
      padding: 0,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 760;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Gift Card Records',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SearchBox(
                      hint:
                          'Gift card ID, buyer/recipient account or reference',
                      width: narrow ? c.maxWidth - 36 : 330,
                      onChanged: (v) => setState(() => _q = v.trim()),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) => setState(() => _status = v),
                      itemBuilder: (_) => [
                        for (final s in _statuses)
                          PopupMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                      child: OutlineButtonBox(
                        label: _status,
                        trailingChevron: true,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                child: UnderlineTabs(
                  labels: const [
                    'Schatz Gift Cards',
                    'Brand Gift Cards (Reloadly)',
                  ],
                  selected: _tab,
                  onSelect: (i) => setState(() {
                    _tab = i;
                    _status = 'All Status';
                  }),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              if (rows.isEmpty)
                const EmptyState('No gift cards match.')
              else if (narrow)
                for (final g in rows)
                  InkWell(
                    onTap: () => showGiftCardDetails(context, g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TwoLine(
                              '${g.id} · ${g.value}',
                              '${g.buyer} to ${g.owner}',
                            ),
                          ),
                          StatusChip(g.status, kind: _kind(g.status)),
                        ],
                      ),
                    ),
                  )
              else ...[
                const TableHead(cols: cols),
                for (final g in rows)
                  TableLine(
                    cols: cols,
                    onTap: () => showGiftCardDetails(context, g),
                    cells: [
                      TwoLine(g.id, g.name, topColor: AppColors.brand),
                      Row(
                        children: [
                          Avatar(name: g.buyer, size: 28),
                          const SizedBox(width: 8),
                          Expanded(child: TwoLine(g.buyer, g.buyerAccount)),
                        ],
                      ),
                      Text(
                        g.value,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        g.purchased.replaceAll(' · ', '\n'),
                        style: const TextStyle(fontSize: 11.5, height: 1.4),
                      ),
                      Text(g.owner, style: const TextStyle(fontSize: 12)),
                      Text(g.loadedInto, style: const TextStyle(fontSize: 12)),
                      StatusChip(g.status, kind: _kind(g.status)),
                      SquareIconButton(
                        icon: Icons.visibility_outlined,
                        tooltip: 'View gift card',
                        onTap: () => showGiftCardDetails(context, g),
                      ),
                    ],
                  ),
              ],
              PaginationBar(
                info: 'Showing 1 to ${rows.length} of 12,568 gift cards',
                lastPage: 1257,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Full life of one gift card: purchase, delivery, loading and later use.
void showGiftCardDetails(BuildContext context, GiftCardRecord g) {
  final schatz = g.kind == 'Schatz';
  final steps = <(IconData, Color, String, String, bool)>[
    (
      Icons.shopping_bag_outlined,
      AppColors.brand,
      'Purchased by ${g.buyer} (${g.buyerAccount})',
      '${g.purchased} · ${g.txRef}',
      true,
    ),
    (
      Icons.send_rounded,
      AppColors.info,
      'Delivered to ${g.owner}',
      schatz ? 'Delivery: ${g.delivery}' : 'Delivered by Reloadly (${g.id})',
      true,
    ),
    if (schatz)
      (
        Icons.account_balance_wallet_outlined,
        AppColors.success,
        g.loadedBy == '-'
            ? 'Not loaded yet'
            : 'Loaded by ${g.loadedBy} into ${g.loadedInto}',
        g.loadedBy == '-'
            ? 'Value is still held on the card'
            : '${g.loadedAmount} · ${g.loadedAt}',
        g.loadedBy != '-',
      ),
    if (schatz && g.loadedBy != '-')
      (
        Icons.account_tree_outlined,
        AppColors.warning,
        'Later use of the loaded value',
        'Follow it with Transaction Trace',
        true,
      ),
  ];
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconCircle(
                    icon: Icons.card_giftcard_rounded,
                    color: AppColors.brand,
                    background: AppColors.brandSoft,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: TwoLine(g.id, g.name)),
                  StatusChip(g.status, kind: _kind(g.status)),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  g.value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < steps.length; i++)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Column(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: steps[i].$5
                                    ? steps[i].$2.withValues(alpha: 0.12)
                                    : AppColors.background,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                steps[i].$1,
                                size: 16,
                                color: steps[i].$5
                                    ? steps[i].$2
                                    : AppColors.textMuted,
                              ),
                            ),
                            if (i < steps.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppColors.border,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16, top: 4),
                          child: TwoLine(steps[i].$3, steps[i].$4),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (g.status == 'Purchased – Not Loaded')
                    OutlineButtonBox(
                      label: 'Cancel Card',
                      icon: Icons.block_rounded,
                      onTap: () => toast(
                        ctx,
                        'Cancelling needs a reason and connects with the backend.',
                      ),
                    ),
                  PrimaryButton(
                    label: 'Trace Funds',
                    icon: Icons.account_tree_outlined,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/transactions/trace?ref=${g.id}');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Side extends StatelessWidget {
  const _Side();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.manage_search_rounded, 'Find Card', AppColors.brand),
      (Icons.account_tree_outlined, 'Trace Card', AppColors.info),
      (Icons.hourglass_empty_rounded, 'Not Loaded', AppColors.warning),
      (Icons.block_rounded, 'Cancel Card', AppColors.danger),
      (Icons.undo_rounded, 'Refund', AppColors.success),
      (Icons.file_download_outlined, 'Export', AppColors.textSecondary),
    ];
    const top = [
      ('Schatz Gift Card', 'S', AppColors.brand, 1845, 'SFZ 184,500', 1.0),
      ('Amazon eGift Card', 'a', Color(0xFF111827), 1245, 'SFZ 156,800', 0.85),
      ('Netflix Gift Card', 'N', Color(0xFFE50914), 987, 'SFZ 98,750', 0.54),
      ('Steam Wallet Card', 'S', Color(0xFF1B2838), 654, 'SFZ 65,400', 0.36),
      ('Google Play Card', 'G', Color(0xFF34A853), 345, 'SFZ 34,500', 0.19),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'Quick Actions'),
              const SizedBox(height: 12),
              TileGrid(
                minTileWidth: 60,
                maxColumns: 3,
                gap: 8,
                children: [
                  for (final a in actions)
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (a.$2 == 'Trace Card') {
                          context.go('/transactions/trace');
                        } else {
                          toast(context, '${a.$2} connects with the backend.');
                        }
                      },
                      child: Container(
                        height: 74,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconCircle(
                              icon: a.$1,
                              color: a.$3,
                              background: a.$3.withValues(alpha: 0.1),
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a.$2,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 10, height: 1.2),
                            ),
                          ],
                        ),
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
              CardHeader(
                title: 'Top Selling Gift Cards',
                trailing: LinkText('View All', onTap: () {}),
              ),
              const SizedBox(height: 8),
              for (final t in top)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: t.$3,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          t.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.$1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: t.$6,
                                minHeight: 5,
                                backgroundColor: const Color(0xFFF0EEF6),
                                color: AppColors.brand,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${t.$4}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            t.$5,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              CardHeader(
                title: 'Loading Overview',
                trailing: LinkText('View Report', onTap: () {}),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const DonutChart(
                    values: [8421, 4147, 312],
                    colors: [
                      AppColors.success,
                      AppColors.warning,
                      Color(0xFFD1D5DB),
                    ],
                    centerTop: '67%',
                    centerBottom: 'Loaded',
                    size: 104,
                    stroke: 11,
                    gap: 0,
                    fontSize: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: const [
                        LegendRow(
                          color: AppColors.success,
                          label: 'Loaded',
                          value: '8,421',
                        ),
                        LegendRow(
                          color: AppColors.warning,
                          label: 'Not loaded',
                          value: '4,147',
                        ),
                        LegendRow(
                          color: Color(0xFFD1D5DB),
                          label: 'Cancelled',
                          value: '312',
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
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFF4EFFF), Color(0xFFFBF9FF)],
            ),
            border: Border.all(color: const Color(0xFFE9E1FF)),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.redeem_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unloaded Gift Cards',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '4,147 cards worth SFZ 1.62M are bought but not loaded yet.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
