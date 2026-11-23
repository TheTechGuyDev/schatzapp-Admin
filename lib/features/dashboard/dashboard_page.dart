import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/adaptive_column.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/page_body.dart';
import '../../widgets/ui.dart';
import 'dashboard_sample.dart';

/// Dashboard laid out like the approved Admin Panel design:
/// 5 stat cards, then a main column (chart + donut, recent table) and a
/// right column (quick actions, rankings, overview ring, call to action).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBody(children: [
      const _HeadlineCards(),
      const SizedBox(height: 18),
      LayoutBuilder(builder: (context, c) {
        const main = _MainColumn();
        const side = _SideColumn();
        if (c.maxWidth < 960) {
          return const Column(children: [main, SizedBox(height: 18), side]);
        }
        return const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 49, child: main),
          SizedBox(width: 18),
          Expanded(flex: 16, child: side),
        ]);
      }),
      const SizedBox(height: 18),
      const _UserStatistics(),
      const SizedBox(height: 18),
      const ResponsiveRow(
        flex: [5, 3, 4],
        breakAt: 960,
        gap: 18,
        height: 380,
        children: [_GrowthCard(), _FeatureUsageCard(), _AttentionCard()],
      ),
      const SizedBox(height: 18),
      const ResponsiveRow(
        flex: [8, 4],
        gap: 18,
        height: 500,
        children: [_CountriesCard(), _AlertsCard()],
      ),
    ]);
  }
}

// ── Headline cards ──────────────────────────────────────────────────────────

class _HeadlineCards extends StatelessWidget {
  const _HeadlineCards();

  @override
  Widget build(BuildContext context) {
    return const TileGrid(
      minTileWidth: 185,
      maxColumns: 5,
      gap: 18,
      allowedColumns: [1, 2, 3, 5],
      children: [
        StatCard(
          label: 'Total Users',
          value: '12,480',
          change: '12.8% vs last week',
          icon: Icons.people_alt_rounded,
          color: AppColors.brand,
          background: AppColors.brandSoft,
          spark: [9, 9.8, 9.3, 10.4, 9.9, 11.2, 10.6, 12.48],
        ),
        StatCard(
          label: 'Active Today',
          value: '3,915',
          change: '1.8% vs yesterday',
          icon: Icons.bolt_rounded,
          color: AppColors.success,
          background: AppColors.successSoft,
          spark: [3.4, 3.6, 3.5, 3.88, 3.64, 3.79, 3.72, 3.91],
        ),
        StatCard(
          label: 'Total Transactions',
          value: '58,392',
          change: '18.7% vs last week',
          icon: Icons.swap_horiz_rounded,
          color: AppColors.warning,
          background: AppColors.warningSoft,
          spark: [40, 46, 43, 50, 45, 52, 49, 58],
        ),
        StatCard(
          label: 'Wallet Volume',
          value: '₦48,200,000',
          change: '9.1% vs last month',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.info,
          background: AppColors.infoSoft,
          spark: [38, 41, 39, 43, 42, 45, 44, 48.2],
        ),
        StatCard(
          label: 'Open Disputes',
          value: '9',
          change: '8.2% vs last week',
          icon: Icons.gpp_maybe_rounded,
          color: AppColors.danger,
          background: AppColors.dangerSoft,
          positive: false,
          spark: [14, 12, 13, 11, 12, 10, 11, 9],
        ),
      ],
    );
  }
}

// ── Main column ─────────────────────────────────────────────────────────────

class _MainColumn extends StatelessWidget {
  const _MainColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      ResponsiveRow(
        flex: [7, 5],
        breakAt: 760,
        gap: 18,
        height: 330,
        children: [_TransactionOverviewCard(), _CategoriesCard()],
      ),
      SizedBox(height: 18),
      _RecentTransactionsTable(),
    ]);
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _QuickActionsCard(),
      SizedBox(height: 18),
      _TopCountriesCard(),
      SizedBox(height: 18),
      _UsersRingCard(),
      SizedBox(height: 18),
      _KycPromoCard(),
    ]);
  }
}

Widget _periodDropdown(String label) =>
    OutlineButtonBox(label: label, trailingChevron: true);

class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label, this.dashed = false});
  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (dashed)
        Row(children: [
          for (var i = 0; i < 2; i++)
            Container(
              width: 5,
              height: 2,
              margin: const EdgeInsets.only(right: 2),
              color: color,
            ),
        ])
      else
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      const SizedBox(width: 7),
      Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.navText)),
    ]);
  }
}

// ── Transaction overview chart ──────────────────────────────────────────────

class _TransactionOverviewCard extends StatelessWidget {
  const _TransactionOverviewCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 18,
      child: AdaptiveColumn(
        top: [
          CardHeader(title: 'Transaction Overview', trailing: _periodDropdown('This Week')),
          const SizedBox(height: 10),
          const Wrap(spacing: 18, runSpacing: 6, children: [
            _Key(color: AppColors.brand, label: 'Amount (₦)'),
            _Key(color: AppColors.grey, label: 'Transactions', dashed: true),
          ]),
          const SizedBox(height: 10),
        ],
        middle: LineChart(
          height: 230,
          labels: DashboardSample.weekLabels,
          series: [
            ChartSeries(
              name: 'Amount',
              color: AppColors.brand,
              values: DashboardSample.volume,
              format: (v) => '₦${compactNumber(v)}',
            ),
            const ChartSeries(
              name: 'Transactions',
              color: AppColors.grey,
              values: DashboardSample.txCount,
              dashed: true,
              secondary: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Volume by category donut ────────────────────────────────────────────────

const _catColors = [
  AppColors.brand,
  AppColors.success,
  AppColors.warning,
  AppColors.danger,
  AppColors.grey,
];

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard();

  @override
  Widget build(BuildContext context) {
    final data = DashboardSample.txCategories;
    final total = data.fold<double>(0, (a, b) => a + b.$2);
    return AppCard(
      padding: 18,
      child: LayoutBuilder(builder: (context, c) {
        final compact = c.maxWidth < 380;
        final side = c.maxWidth >= 280;
        final donut = DonutChart(
          values: [for (final d in data) d.$2],
          colors: _catColors,
          centerTop: '₦${compactNumber(total)}',
          centerBottom: 'Total Volume',
          size: compact ? 118 : 146,
          stroke: compact ? 16 : 22,
          fontSize: compact ? 17 : 22,
        );
        final legend = Column(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < data.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                      color: _catColors[i], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(data[i].$1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.navText)),
                ),
                Text(
                    compact
                        ? '₦${compactNumber(data[i].$2)}'
                        : '₦${compactNumber(data[i].$2)} (${(data[i].$2 / total * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
        ]);
        return AdaptiveColumn(
          top: [
            CardHeader(
              title: 'Volume by Category',
              trailing: LinkText(compact ? 'View' : 'View Full Report',
                  onTap: () => context.go('/reports')),
            ),
            const SizedBox(height: 10),
          ],
          middle: side
              ? Row(children: [
                  donut,
                  const SizedBox(width: 14),
                  Expanded(child: legend),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  donut,
                  const SizedBox(height: 14),
                  legend,
                ]),
        );
      }),
    );
  }
}

// ── Recent transactions table ───────────────────────────────────────────────

const _txFlex = [15, 19, 15, 13, 11, 12, 6];

class _RecentTransactionsTable extends StatelessWidget {
  const _RecentTransactionsTable();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 0,
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 760;
        final filters = Wrap(spacing: 10, runSpacing: 10, children: const [
          OutlineButtonBox(
              label: 'All Status', icon: Icons.tune_rounded, trailingChevron: true),
          OutlineButtonBox(
              label: 'Nov 17, 2026 - Nov 23, 2026',
              icon: Icons.calendar_today_outlined),
          OutlineButtonBox(label: 'Filters', icon: Icons.filter_alt_outlined),
        ]);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: narrow
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Recent Transactions',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    filters,
                  ])
                : Row(children: [
                    const Expanded(
                      child: Text('Recent Transactions',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                    filters,
                  ]),
          ),
          if (!narrow) const _TxHeader(),
          for (final t in DashboardSample.transactions)
            narrow ? _TxTile(t) : _TxRowView(t),
          _Pagination(narrow: narrow),
        ]);
      }),
    );
  }
}

class _TxHeader extends StatelessWidget {
  const _TxHeader();

  @override
  Widget build(BuildContext context) {
    const labels = [
      'TRANSACTION ID', 'USER', 'TYPE', 'AMOUNT', 'STATUS', 'DATE', 'ACTIONS',
    ];
    return Container(
      color: const Color(0xFFFAFAFC),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            flex: _txFlex[i],
            child: Text(labels[i],
                textAlign: i == labels.length - 1 ? TextAlign.center : TextAlign.left,
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: AppColors.navText)),
          ),
      ]),
    );
  }
}

(IconData, Color) _kindIcon(String kind) => switch (kind) {
      'transfer' => (Icons.swap_horiz_rounded, AppColors.brand),
      'airtime' => (Icons.phone_android_rounded, AppColors.warning),
      'data' => (Icons.wifi_rounded, AppColors.info),
      'topup' => (Icons.add_card_rounded, AppColors.success),
      'giftcard' => (Icons.card_giftcard_rounded, AppColors.pink),
      _ => (Icons.receipt_long_rounded, AppColors.textSecondary),
    };

class _TxRowView extends StatelessWidget {
  const _TxRowView(this.t);
  final TxRow t;

  @override
  Widget build(BuildContext context) {
    final k = _kindIcon(t.kind);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Expanded(
          flex: _txFlex[0],
          child: Text(t.ref,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.brand, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: _txFlex[1],
          child: Row(children: [
            Avatar(name: t.user, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.user,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(t.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ]),
            ),
          ]),
        ),
        Expanded(
          flex: _txFlex[2],
          child: Row(children: [
            Icon(k.$1, size: 18, color: k.$2),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.type,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(t.detail,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ]),
            ),
          ]),
        ),
        Expanded(
          flex: _txFlex[3],
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.amount,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            Text('Fee: ${t.fee}',
                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          ]),
        ),
        Expanded(
          flex: _txFlex[4],
          child: Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(t.status, kind: StatusChip.kindFor(t.status)),
          ),
        ),
        Expanded(
          flex: _txFlex[5],
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.date, style: const TextStyle(fontSize: 11.5)),
            Text(t.time,
                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          ]),
        ),
        Expanded(
          flex: _txFlex[6],
          child: Center(
            child: Container(
              width: 30,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.more_horiz_rounded,
                  size: 16, color: AppColors.textSecondary),
            ),
          ),
        ),
      ]),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile(this.t);
  final TxRow t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Avatar(name: t.user, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.user,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${t.type} · ${t.ref}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(t.amount,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          StatusChip(t.status, kind: StatusChip.kindFor(t.status)),
        ]),
      ]),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.narrow});
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    Widget box(Widget child, {bool active = false}) => Container(
          constraints: const BoxConstraints(minWidth: 32),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.brand : Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: active ? AppColors.brand : AppColors.border),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : AppColors.text,
                fontWeight: FontWeight.w500),
            child: child,
          ),
        );
    final pages = Wrap(spacing: 8, runSpacing: 8, children: [
      box(const Icon(Icons.chevron_left_rounded, size: 16)),
      box(const Text('1'), active: true),
      box(const Text('2')),
      box(const Text('3')),
      box(const Text('...')),
      box(const Text('11,679')),
      box(const Icon(Icons.chevron_right_rounded, size: 16)),
    ]);
    const info = Text('Showing 1 to 5 of 58,392 transactions',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary));
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      child: narrow
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              info,
              const SizedBox(height: 10),
              pages,
            ])
          : Row(children: [
              const Expanded(child: info),
              pages,
              const SizedBox(width: 14),
              const OutlineButtonBox(label: '5 / page', trailingChevron: true),
            ]),
    );
  }
}

// ── Right column cards ──────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  static const _actions = [
    (Icons.person_add_alt_1_rounded, 'Add Admin', AppColors.brand, AppColors.brandSoft, '/roles'),
    (Icons.verified_user_rounded, 'Review KYC', AppColors.success, AppColors.successSoft, '/kyc'),
    (Icons.upload_rounded, 'Export Report', AppColors.info, AppColors.infoSoft, '/reports'),
    (Icons.campaign_rounded, 'Send Notification', AppColors.warning, AppColors.warningSoft, '/notifications'),
    (Icons.block_rounded, 'Restrict Account', AppColors.danger, AppColors.dangerSoft, '/users'),
    (Icons.description_rounded, 'Audit Logs', AppColors.brand, AppColors.brandSoft, '/audit-logs'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 16,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const CardHeader(title: 'Quick Actions'),
        const SizedBox(height: 14),
        TileGrid(
          minTileWidth: 60,
          maxColumns: 3,
          gap: 8,
          children: [
            for (final a in _actions)
              _ActionTile(
                icon: a.$1,
                label: a.$2,
                color: a.$3,
                background: a.$4,
                onTap: () => context.go(a.$5),
              ),
          ],
        ),
      ]),
    );
  }
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _hover ? AppColors.hover : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: _hover
                    ? AppColors.brand.withValues(alpha: 0.35)
                    : AppColors.border),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconCircle(
              icon: widget.icon,
              color: widget.color,
              background: widget.background,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w500, height: 1.2)),
          ]),
        ),
      ),
    );
  }
}

class _CountryCode extends StatelessWidget {
  const _CountryCode(this.code, {this.size = 32});
  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(code,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brand)),
    );
  }
}

class _TopCountriesCard extends StatelessWidget {
  const _TopCountriesCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 16,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardHeader(
          title: 'Top Countries',
          trailing: LinkText('View All', onTap: () => context.go('/users')),
        ),
        const SizedBox(height: 10),
        for (final c in DashboardSample.topCountries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(children: [
              _CountryCode(c.$1),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.$2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEF6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: c.$4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                child: Text(groupDigits(c.$3),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _UsersRingCard extends StatelessWidget {
  const _UsersRingCard();

  @override
  Widget build(BuildContext context) {
    const active = 7842.0, inactive = 4334.0, limited = 304.0;
    const total = active + inactive + limited;
    return AppCard(
      padding: 16,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardHeader(
          title: 'Users Overview',
          trailing: LinkText('View Report', onTap: () => context.go('/reports')),
        ),
        const SizedBox(height: 12),
        Row(children: [
          DonutChart(
            values: const [active, inactive, limited],
            colors: const [AppColors.success, AppColors.warning, Color(0xFFD1D5DB)],
            centerTop: '${(active / total * 100).round()}%',
            centerBottom: 'Active',
            size: 104,
            stroke: 11,
            gap: 0,
            fontSize: 18,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(children: [
              _ringLegend(AppColors.success, 'Active', active, total),
              _ringLegend(AppColors.warning, 'Inactive', inactive, total),
              _ringLegend(const Color(0xFFD1D5DB), 'Restricted', limited, total),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _ringLegend(Color color, String label, double v, double total) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Container(
            width: 9,
            height: 9,
            decoration:
                BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.navText)),
          ),
          Text('${groupDigits(v)} (${(v / total * 100).round()}%)',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _KycPromoCard extends StatelessWidget {
  const _KycPromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFF4EFFF), Color(0xFFFBF9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE9E1FF)),
      ),
      child: Row(children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Pending KYC Reviews',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('126 users are waiting for identity verification.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Material(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => context.go('/kyc'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  child: Text('Review Now',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── User statistics (10 metrics) ────────────────────────────────────────────

class _UserStatistics extends StatelessWidget {
  const _UserStatistics();

  static const _style = <(IconData, Color, Color)>[
    (Icons.people_alt_outlined, AppColors.brand, AppColors.brandSoft),
    (Icons.trending_up_rounded, AppColors.success, AppColors.successSoft),
    (Icons.today_rounded, AppColors.teal, AppColors.tealSoft),
    (Icons.date_range_rounded, AppColors.info, AppColors.infoSoft),
    (Icons.calendar_month_rounded, AppColors.brand, AppColors.brandSoft),
    (Icons.bedtime_outlined, AppColors.textSecondary, Color(0xFFF3F4F6)),
    (Icons.pause_circle_outline_rounded, AppColors.pink, AppColors.pinkSoft),
    (Icons.lock_outline_rounded, AppColors.warning, AppColors.warningSoft),
    (Icons.block_rounded, AppColors.danger, AppColors.dangerSoft),
    (Icons.delete_outline_rounded, AppColors.textSecondary, Color(0xFFF3F4F6)),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 18,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardHeader(
          title: 'User Statistics',
          subtitle:
              'Active means real use of the app (messages, calls, stories or wallet), not just a sign-in.',
          trailing: LinkText('View Users', onTap: () => context.go('/users')),
        ),
        const SizedBox(height: 16),
        TileGrid(
          minTileWidth: 150,
          maxColumns: 5,
          allowedColumns: const [2, 5],
          gap: 12,
          children: [
            for (var i = 0; i < DashboardSample.userStats.length; i++)
              _MiniStat(
                label: DashboardSample.userStats[i].$1,
                value: groupDigits(DashboardSample.userStats[i].$2),
                hint: DashboardSample.userStats[i].$3,
                style: _style[i],
              ),
          ],
        ),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.hint,
    required this.style,
  });

  final String label;
  final String value;
  final String hint;
  final (IconData, Color, Color) style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        IconCircle(icon: style.$1, color: style.$2, background: style.$3, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ]),
        ),
      ]),
    );
  }
}

// ── User growth chart ───────────────────────────────────────────────────────

class _GrowthCard extends StatelessWidget {
  const _GrowthCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 18,
      child: AdaptiveColumn(
        top: [
          CardHeader(title: 'User Growth & Activity', trailing: _periodDropdown('This Week')),
          const SizedBox(height: 10),
          const Wrap(spacing: 18, runSpacing: 6, children: [
            _Key(color: AppColors.brand, label: 'Daily active users'),
            _Key(color: AppColors.teal, label: 'New signups', dashed: true),
          ]),
          const SizedBox(height: 10),
        ],
        middle: const LineChart(
          height: 250,
          labels: DashboardSample.weekLabels,
          series: [
            ChartSeries(
              name: 'Daily active users',
              color: AppColors.brand,
              values: DashboardSample.dau,
              fill: true,
            ),
            ChartSeries(
              name: 'New signups',
              color: AppColors.teal,
              values: DashboardSample.signups,
              dashed: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feature usage ───────────────────────────────────────────────────────────

class _FeatureUsageCard extends StatelessWidget {
  const _FeatureUsageCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 18,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const CardHeader(
          title: 'Feature Usage',
          subtitle: 'Share of active users, last 7 days',
        ),
        const SizedBox(height: 18),
        for (final f in DashboardSample.featureUsage)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                    child: Text(f.$1,
                        style: const TextStyle(fontSize: 12, color: AppColors.navText))),
                Text('${(f.$2 * 100).round()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 7),
              Container(
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEF6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: f.$2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

// ── Needs attention ─────────────────────────────────────────────────────────

(IconData, Color, Color) _levelStyle(Level l) => switch (l) {
      Level.critical => (Icons.error_outline_rounded, AppColors.danger, AppColors.dangerSoft),
      Level.warning => (Icons.warning_amber_rounded, AppColors.warning, AppColors.warningSoft),
      Level.info => (Icons.info_outline_rounded, AppColors.info, AppColors.infoSoft),
      Level.normal => (Icons.check_circle_outline_rounded, AppColors.success, AppColors.successSoft),
    };

class _AttentionCard extends StatelessWidget {
  const _AttentionCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 18,
      child: AdaptiveColumn(
        top: const [
          CardHeader(title: 'Needs Attention', subtitle: 'Items waiting for an admin'),
          SizedBox(height: 6),
        ],
        middle: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [for (final a in DashboardSample.attention) _AttentionRow(a)],
        ),
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow(this.a);
  final AttentionItem a;

  @override
  Widget build(BuildContext context) {
    final st = _levelStyle(a.level);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.go(a.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          IconCircle(icon: st.$1, color: st.$2, background: st.$3, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(a.hint,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            ]),
          ),
          Text(groupDigits(a.count),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}

// ── Users by country (full table with search) ───────────────────────────────

class _CountriesCard extends StatefulWidget {
  const _CountriesCard();

  @override
  State<_CountriesCard> createState() => _CountriesCardState();
}

class _CountriesCardState extends State<_CountriesCard> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final rows = DashboardSample.countries
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
        .take(8)
        .toList();

    return AppCard(
      padding: 18,
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 620;
        final search = SearchBox(
          hint: 'Search country...',
          width: narrow ? c.maxWidth : 220,
          onChanged: (v) => setState(() => _query = v),
        );
        return AdaptiveColumn(
          top: [
            CardHeader(
              title: 'Users by Country',
              subtitle: 'Registered, active, inactive and restricted users',
              trailing: narrow ? null : search,
            ),
            if (narrow) ...[const SizedBox(height: 12), search],
            const SizedBox(height: 12),
            if (!narrow) const _CountryHeaderRow(),
          ],
          middle: rows.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No country matches your search.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    for (final r in rows) narrow ? _CountryTile(r) : _CountryRow(r),
                  ],
                ),
        );
      }),
    );
  }
}

const _countryFlex = [4, 2, 2, 2, 2, 2];

class _CountryHeaderRow extends StatelessWidget {
  const _CountryHeaderRow();

  @override
  Widget build(BuildContext context) {
    const labels = ['COUNTRY', 'REGISTERED', 'ACTIVE', 'INACTIVE', 'RESTRICTED', 'NEW (30D)'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            flex: _countryFlex[i],
            child: Text(labels[i],
                textAlign: i == 0 ? TextAlign.left : TextAlign.right,
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: AppColors.navText)),
          ),
      ]),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow(this.c);
  final CountryStat c;

  @override
  Widget build(BuildContext context) {
    Widget num(int v, int flex, {Color? color}) => Expanded(
          flex: flex,
          child: Text(groupDigits(v),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: color ?? AppColors.text)),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Expanded(
          flex: _countryFlex[0],
          child: Row(children: [
            _CountryCode(c.code, size: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text(c.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
        num(c.registered, _countryFlex[1]),
        num(c.active, _countryFlex[2], color: AppColors.success),
        num(c.inactive, _countryFlex[3], color: AppColors.textSecondary),
        num(c.restricted, _countryFlex[4], color: AppColors.danger),
        num(c.newThisMonth, _countryFlex[5], color: AppColors.brand),
      ]),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile(this.c);
  final CountryStat c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        _CountryCode(c.code),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(
              'Active ${groupDigits(c.active)} · Inactive ${groupDigits(c.inactive)} · Restricted ${c.restricted}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(groupDigits(c.registered),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          Text('+${c.newThisMonth} new',
              style: const TextStyle(fontSize: 10.5, color: AppColors.brand)),
        ]),
      ]),
    );
  }
}

// ── Recent alerts ───────────────────────────────────────────────────────────

class _AlertsCard extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 18,
      child: AdaptiveColumn(
        top: [
          CardHeader(
            title: 'Recent Alerts',
            trailing: LinkText('View All', onTap: () => context.go('/audit-logs')),
          ),
          const SizedBox(height: 6),
        ],
        middle: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            for (final a in DashboardSample.alerts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Builder(builder: (_) {
                    final st = _levelStyle(a.level);
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: st.$3,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(st.$1, color: st.$2, size: 17),
                    );
                  }),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.title,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(a.detail,
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textSecondary)),
                    ]),
                  ),
                  const SizedBox(width: 6),
                  Text(a.time,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
