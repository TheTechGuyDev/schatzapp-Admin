import 'package:material_ui/material_ui.dart';

import '../../data/sample_finance.dart';
import '../../theme/app_colors.dart';
import '../../widgets/adaptive_column.dart';
import '../../widgets/charts.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Airtime & Data (approved design, purple): sales, networks, orders,
/// provider (Reloadly) status and alerts.
class AirtimePage extends StatelessWidget {
  const AirtimePage({super.key});

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
              label: 'Airtime Sales',
              value: 'SFZ 284,500',
              change: '18.7% vs last week',
              icon: Icons.phone_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [20, 22, 21, 25, 24, 26, 27, 28.4],
            ),
            StatCard(
              label: 'Data Sales',
              value: 'SFZ 167,800',
              change: '16.3% vs last week',
              icon: Icons.wifi_rounded,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [12, 13, 12.5, 14, 14.5, 15, 16, 16.8],
            ),
            StatCard(
              label: 'Total Orders',
              value: '12,458',
              change: '14.2% vs last week',
              icon: Icons.shopping_cart_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              spark: [9, 9.6, 10, 10.4, 11, 11.5, 12, 12.46],
            ),
            StatCard(
              label: 'Successful Orders',
              value: '11,972',
              change: '15.0% vs last week',
              icon: Icons.verified_rounded,
              color: AppColors.info,
              background: AppColors.infoSoft,
              spark: [8.8, 9.2, 9.6, 10, 10.5, 11, 11.5, 11.97],
            ),
            StatCard(
              label: 'Failed Orders',
              value: '486',
              change: '6.8% vs last week',
              icon: Icons.cancel_outlined,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
              spark: [520, 510, 530, 500, 505, 495, 490, 486],
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
                  height: 380,
                  children: [_SalesCard(), _NetworksCard()],
                ),
                SizedBox(height: 18),
                _OrdersTable(),
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
    String fmt(double v) => 'SFZ ${compactNumber(v)}';
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
              _Key(AppColors.success, 'Airtime sales'),
              _Key(AppColors.brand, 'Data sales'),
            ],
          ),
          SizedBox(height: 10),
        ],
        middle: LineChart(
          height: 260,
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
              name: 'Airtime',
              color: AppColors.success,
              values: const [33000, 61000, 68000, 52000, 45000, 58000, 49000],
              format: fmt,
            ),
            ChartSeries(
              name: 'Data',
              color: AppColors.brand,
              values: const [17000, 32000, 38000, 26000, 23000, 30000, 27000],
              format: fmt,
            ),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 14, height: 3, color: color),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 11.5, color: AppColors.navText),
      ),
    ],
  );
}

const _networks = [
  ('MTN', 162500.0, Color(0xFFF5B800)),
  ('Airtel', 89200.0, Color(0xFFE11D48)),
  ('Glo', 24500.0, Color(0xFF16A34A)),
  ('Others', 8300.0, Color(0xFF111827)),
];

class _NetworksCard extends StatefulWidget {
  const _NetworksCard();

  @override
  State<_NetworksCard> createState() => _NetworksCardState();
}

class _NetworksCardState extends State<_NetworksCard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final factor = _tab == 0 ? 1.0 : 0.59;
    final total = _networks.fold<double>(0, (a, b) => a + b.$2) * factor;
    return AppCard(
      padding: 18,
      child: AdaptiveColumn(
        top: [
          const CardHeader(title: 'Top Networks by Sales'),
          UnderlineTabs(
            labels: const ['Airtime', 'Data'],
            selected: _tab,
            onSelect: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 8),
          for (final n in _networks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  NetworkBadge(n.$1, n.$3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(n.$1, style: const TextStyle(fontSize: 12)),
                  ),
                  Text(
                    'SFZ ${groupDigits(n.$2 * factor)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text(
                      '${(n.$2 * factor / total * 100).toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
        middle: Center(
          child: DonutChart(
            values: [for (final n in _networks) n.$2],
            colors: [for (final n in _networks) n.$3],
            centerTop: 'SFZ ${compactNumber(total)}',
            centerBottom: 'Total Sales',
            size: 120,
            stroke: 16,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class NetworkBadge extends StatelessWidget {
  const NetworkBadge(this.name, this.color, {super.key});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        name.substring(0, 1),
        style: TextStyle(
          color: name == 'MTN' ? Colors.black : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color networkColor(String n) => switch (n) {
  'MTN' => const Color(0xFFF5B800),
  'Airtel' => const Color(0xFFE11D48),
  'Glo' => const Color(0xFF16A34A),
  'Safaricom' => const Color(0xFF15803D),
  'Vodafone' => const Color(0xFFE60000),
  _ => AppColors.textSecondary,
};

class _OrdersTable extends StatelessWidget {
  const _OrdersTable();

  @override
  Widget build(BuildContext context) {
    const cols = [
      Col('Order ID', 16),
      Col('Type', 11),
      Col('Network', 12),
      Col('Phone number', 14),
      Col('Amount', 10),
      Col('Status', 12),
      Col('User', 13),
      Col('Date', 12),
    ];
    final rows = SampleFinance.airtime;
    return AppCard(
      padding: 0,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 760;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!narrow) const SizedBox(width: 40),
                    const OutlineButtonBox(
                      label: 'All Services',
                      trailingChevron: true,
                    ),
                    const OutlineButtonBox(
                      label: 'All Networks',
                      trailingChevron: true,
                    ),
                    const OutlineButtonBox(
                      label: 'Nov 18, 2026 - Nov 24, 2026',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),
              ),
              if (narrow)
                for (final o in rows)
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
                        NetworkBadge(o.network, networkColor(o.network)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TwoLine(
                            '${o.type} · ${o.network}',
                            '${o.id} · ${o.user}',
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              o.amount,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatusChip(
                              o.status,
                              kind: StatusChip.kindFor(o.status),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              else ...[
                const TableHead(cols: cols),
                for (final o in rows)
                  TableLine(
                    cols: cols,
                    cells: [
                      Text(
                        o.id,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(o.type, style: const TextStyle(fontSize: 12)),
                      Row(
                        children: [
                          NetworkBadge(o.network, networkColor(o.network)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              o.network,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Text(o.phone, style: const TextStyle(fontSize: 12)),
                      Text(
                        o.amount,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      StatusChip(o.status, kind: StatusChip.kindFor(o.status)),
                      Text(o.user, style: const TextStyle(fontSize: 12)),
                      TwoLine(o.date, o.time, bold: false),
                    ],
                  ),
              ],
              const PaginationBar(
                info: 'Showing 1 to 6 of 2,458 transactions',
                lastPage: 410,
                perPage: '5 / page',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.replay_rounded, 'Retry Failed', AppColors.success),
      (Icons.undo_rounded, 'Refund Order', AppColors.danger),
      (Icons.account_balance_outlined, 'Provider Balance', AppColors.brand),
      (Icons.sell_outlined, 'Price List', AppColors.warning),
      (Icons.cell_tower_rounded, 'Networks', AppColors.info),
      (Icons.file_download_outlined, 'Export', AppColors.textSecondary),
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
                      onTap: () =>
                          toast(context, '${a.$2} connects with the backend.'),
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
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Status',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'All systems operational',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.success,
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final s in const [
                'Airtime service',
                'Data service',
                'Reloadly API',
                'Auto processing',
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(s, style: const TextStyle(fontSize: 12)),
                      ),
                      const StatusChip('Operational', kind: ChipKind.success),
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
              const CardHeader(title: 'Recent Alerts'),
              const SizedBox(height: 6),
              for (final a in const [
                (
                  Icons.warning_amber_rounded,
                  AppColors.warning,
                  'High failure rate on MTN',
                  'Failure rate 8.5%',
                  '10m ago',
                ),
                (
                  Icons.info_outline_rounded,
                  AppColors.info,
                  'New data plan added',
                  'MTN 25GB monthly',
                  '1h ago',
                ),
                (
                  Icons.check_circle_outline_rounded,
                  AppColors.success,
                  'Bulk airtime completed',
                  '500 orders processed',
                  '2h ago',
                ),
                (
                  Icons.warning_amber_rounded,
                  AppColors.warning,
                  'Low provider balance',
                  'Reloadly balance below threshold',
                  '3h ago',
                ),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(a.$1, size: 18, color: a.$2),
                      const SizedBox(width: 10),
                      Expanded(child: TwoLine(a.$3, a.$4)),
                      Text(
                        a.$5,
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
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: "Today's Summary"),
              const SizedBox(height: 10),
              TileGrid(
                minTileWidth: 100,
                maxColumns: 2,
                gap: 12,
                children: [
                  for (final s in const [
                    (
                      Icons.phone_rounded,
                      AppColors.success,
                      'Airtime Sales',
                      'SFZ 42,500',
                    ),
                    (
                      Icons.wifi_rounded,
                      AppColors.brand,
                      'Data Sales',
                      'SFZ 29,800',
                    ),
                    (
                      Icons.shopping_cart_outlined,
                      AppColors.info,
                      'Orders',
                      '1,245',
                    ),
                    (
                      Icons.verified_rounded,
                      AppColors.success,
                      'Success Rate',
                      '96.2%',
                    ),
                  ])
                    Row(
                      children: [
                        IconCircle(
                          icon: s.$1,
                          color: s.$2,
                          background: s.$2.withValues(alpha: 0.1),
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: TwoLine(s.$4, s.$3)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
