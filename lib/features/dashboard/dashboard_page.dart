import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/adaptive_column.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/page_body.dart';
import '../../widgets/ui.dart';
import 'dashboard_sample.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    void notReady() => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export becomes available when the backend is connected.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

    return PageBody(children: [
      Wrap(
        alignment: WrapAlignment.end,
        spacing: 10,
        runSpacing: 10,
        children: [
          const OutlineButtonBox(
            label: 'Oct 25, 2026 - Nov 23, 2026',
            icon: Icons.calendar_today_outlined,
            trailingChevron: true,
          ),
          PrimaryButton(
            label: 'Export Report',
            icon: Icons.file_download_outlined,
            onTap: notReady,
          ),
        ],
      ),
      const SizedBox(height: 18),
      const _HeadlineCards(),
      const SizedBox(height: 20),
      const ResponsiveRow(
        flex: [5, 3, 3],
        breakAt: 1100,
        height: 450,
        children: [_GrowthCard(), _UsersOverviewCard(), _QuickActionsCard()],
      ),
      const SizedBox(height: 20),
      const _UserStatistics(),
      const SizedBox(height: 20),
      const ResponsiveRow(
        flex: [5, 3, 3],
        breakAt: 1100,
        height: 410,
        children: [_TransactionOverviewCard(), _CategoriesCard(), _FeatureUsageCard()],
      ),
      const SizedBox(height: 20),
      const ResponsiveRow(
        flex: [7, 4],
        height: 500,
        children: [_CountriesCard(), _AttentionCard()],
      ),
      const SizedBox(height: 20),
      const ResponsiveRow(
        flex: [4, 3, 3],
        breakAt: 1100,
        height: 450,
        children: [_TransactionsCard(), _AlertsCard(), _SummaryCard()],
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
      minTileWidth: 215,
      maxColumns: 5,
      allowedColumns: [1, 2, 3, 5],
      children: [
        StatCard(
          label: 'Total Users',
          value: '12,480',
          change: '12.8% from last week',
          icon: Icons.people_alt_rounded,
          color: AppColors.success,
          background: AppColors.successSoft,
          spark: [9, 9.6, 9.4, 10.2, 10.8, 11.1, 11.9, 12.48],
        ),
        StatCard(
          label: 'Active Users (Today)',
          value: '3,915',
          change: '1.8% vs yesterday',
          icon: Icons.bolt_rounded,
          color: AppColors.brand,
          background: AppColors.brandSoft,
          spark: [3.4, 3.6, 3.5, 3.88, 3.64, 3.79, 3.72, 3.91],
        ),
        StatCard(
          label: 'Total Transactions',
          value: '58,392',
          change: '18.7% from last week',
          icon: Icons.swap_horiz_rounded,
          color: AppColors.info,
          background: AppColors.infoSoft,
          spark: [40, 44, 43, 48, 47, 52, 55, 58],
        ),
        StatCard(
          label: 'Wallet Volume (30d)',
          value: '₦48.2M',
          change: '9.1% vs last month',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.warning,
          background: AppColors.warningSoft,
          spark: [38, 40, 39, 43, 44, 43, 46, 48.2],
        ),
        StatCard(
          label: 'Open Disputes',
          value: '9',
          change: '8.2% from last week',
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

Widget _periodDropdown(String label) =>
    OutlineButtonBox(label: label, trailingChevron: true);

// ── User growth chart ───────────────────────────────────────────────────────

class _GrowthCard extends StatelessWidget {
  const _GrowthCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AdaptiveColumn(
        top: [
          CardHeader(title: 'User Growth & Activity', trailing: _periodDropdown('This Week')),
          const SizedBox(height: 14),
          const Wrap(spacing: 18, runSpacing: 6, children: [
            _Key(color: AppColors.brand, label: 'Daily active users'),
            _Key(color: AppColors.teal, label: 'New signups', dashed: true),
          ]),
          const SizedBox(height: 12),
        ],
        middle: const LineChart(
          height: 270,
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
          for (var i = 0; i < 3; i++)
            Container(
              width: 4,
              height: 2,
              margin: const EdgeInsets.only(right: 2),
              color: color,
            ),
        ])
      else
        Container(
          width: 14,
          height: 3,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      const SizedBox(width: 7),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.navText)),
    ]);
  }
}

// ── Users overview (account status donut) ───────────────────────────────────

const _statusColors = [
  AppColors.success,
  AppColors.brand,
  AppColors.warning,
  AppColors.pink,
  AppColors.danger,
  AppColors.grey,
];

class _UsersOverviewCard extends StatelessWidget {
  const _UsersOverviewCard();

  @override
  Widget build(BuildContext context) {
    final data = DashboardSample.statusSplit;
    final total = data.fold<double>(0, (a, b) => a + b.$2);
    return AppCard(
      child: AdaptiveColumn(
        top: [
          CardHeader(
            title: 'Users Overview',
            trailing: LinkText('View All', onTap: () => context.go('/users')),
          ),
          const SizedBox(height: 16),
        ],
        middle: Center(
          child: DonutChart(
            values: [for (final d in data) d.$2],
            colors: _statusColors,
            centerTop: groupDigits(total),
            centerBottom: 'Total Users',
            size: 150,
          ),
        ),
        bottom: [
          const SizedBox(height: 14),
          for (var i = 0; i < data.length; i++)
            LegendRow(
              color: _statusColors[i],
              label: data[i].$1,
              value: groupDigits(data[i].$2),
              percent: '${(data[i].$2 / total * 100).toStringAsFixed(1)}%',
            ),
        ],
      ),
    );
  }
}

// ── Quick actions ───────────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  static const _actions = [
    (Icons.person_add_alt_1_rounded, 'Add Admin', AppColors.success, AppColors.successSoft, '/roles'),
    (Icons.verified_user_rounded, 'Review KYC', AppColors.brand, AppColors.brandSoft, '/kyc'),
    (Icons.block_rounded, 'Restrict Account', AppColors.danger, AppColors.dangerSoft, '/users'),
    (Icons.campaign_rounded, 'Send Notification', AppColors.info, AppColors.infoSoft, '/notifications'),
    (Icons.description_rounded, 'Generate Report', AppColors.warning, AppColors.warningSoft, '/reports'),
    (Icons.settings_rounded, 'System Settings', AppColors.textSecondary, Color(0xFFF3F4F6), '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const CardHeader(title: 'Quick Actions'),
        const SizedBox(height: 14),
        TileGrid(
          minTileWidth: 92,
          maxColumns: 3,
          allowedColumns: const [2, 3],
          gap: 10,
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
        const SizedBox(height: 16),
        const Row(children: [
          Expanded(
            child: Text('System Status',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          ),
          Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
          SizedBox(width: 4),
          Text('All systems operational',
              style: TextStyle(fontSize: 11.5, color: AppColors.success)),
        ]),
        const SizedBox(height: 6),
        for (final st in DashboardSample.systemStatus)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Expanded(
                child: Text(st.$1,
                    style: const TextStyle(fontSize: 12, color: AppColors.navText)),
              ),
              StatusChip(st.$2,
                  kind: st.$2 == 'Operational' ? ChipKind.success : ChipKind.warning),
            ]),
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
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: _hover ? AppColors.hover : Colors.white,
            borderRadius: BorderRadius.circular(10),
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
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardHeader(
          title: 'User Statistics',
          subtitle:
              'Active means real use of the app (messages, calls, stories or wallet), not just a sign-in.',
          trailing: LinkText('View Users', onTap: () => context.go('/users')),
        ),
        const SizedBox(height: 18),
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
        IconCircle(icon: style.$1, color: style.$2, background: style.$3, size: 38),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          ]),
        ),
      ]),
    );
  }
}

// ── Transaction overview chart ──────────────────────────────────────────────

class _TransactionOverviewCard extends StatelessWidget {
  const _TransactionOverviewCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AdaptiveColumn(
        top: [
          CardHeader(title: 'Transaction Overview', trailing: _periodDropdown('This Week')),
          const SizedBox(height: 14),
          const Wrap(spacing: 18, runSpacing: 6, children: [
            _Key(color: AppColors.success, label: 'Amount (₦)'),
            _Key(color: AppColors.grey, label: 'Transactions', dashed: true),
          ]),
          const SizedBox(height: 12),
        ],
        middle: LineChart(
          height: 260,
          labels: DashboardSample.weekLabels,
          series: [
            ChartSeries(
              name: 'Amount',
              color: AppColors.success,
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

// ── Top transaction categories ──────────────────────────────────────────────

const _catColors = [
  AppColors.success,
  AppColors.brand,
  AppColors.warning,
  AppColors.info,
  AppColors.grey,
];

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard();

  @override
  Widget build(BuildContext context) {
    final data = DashboardSample.txCategories;
    final total = data.fold<double>(0, (a, b) => a + b.$2);
    return AppCard(
      child: AdaptiveColumn(
        top: [
          CardHeader(
            title: 'Top Transaction Categories',
            trailing: LinkText('View Report', onTap: () => context.go('/reports')),
          ),
          const SizedBox(height: 16),
        ],
        middle: Center(
          child: DonutChart(
            values: [for (final d in data) d.$2],
            colors: _catColors,
            centerTop: '₦${compactNumber(total)}',
            centerBottom: 'Total Volume',
            size: 150,
          ),
        ),
        bottom: [
          const SizedBox(height: 14),
          for (var i = 0; i < data.length; i++)
            LegendRow(
              color: _catColors[i],
              label: data[i].$1,
              value: '₦${compactNumber(data[i].$2)}',
              percent: '${(data[i].$2 / total * 100).toStringAsFixed(1)}%',
            ),
        ],
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const CardHeader(
          title: 'Feature Usage',
          subtitle: 'Share of active users, last 7 days',
        ),
        const SizedBox(height: 20),
        for (final f in DashboardSample.featureUsage)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                    child: Text(f.$1,
                        style: const TextStyle(fontSize: 13, color: AppColors.navText))),
                Text('${(f.$2 * 100).round()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              _Bar(value: f.$2),
            ]),
          ),
      ]),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEF6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

// ── Users by country ────────────────────────────────────────────────────────

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
            if (narrow) ...[const SizedBox(height: 14), search],
            const SizedBox(height: 14),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: AppColors.textSecondary)),
          ),
      ]),
    );
  }
}

class _CountryCode extends StatelessWidget {
  const _CountryCode(this.code);
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(code,
          style: const TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.brand)),
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
              style: TextStyle(fontSize: 13, color: color ?? AppColors.text)),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Expanded(
          flex: _countryFlex[0],
          child: Row(children: [
            _CountryCode(c.code),
            const SizedBox(width: 10),
            Flexible(
              child: Text(c.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        _CountryCode(c.code),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(
              'Active ${groupDigits(c.active)} · Inactive ${groupDigits(c.inactive)} · Restricted ${c.restricted}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(groupDigits(c.registered),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          Text('+${c.newThisMonth} new',
              style: const TextStyle(fontSize: 11, color: AppColors.brand)),
        ]),
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
      child: AdaptiveColumn(
        top: const [
          CardHeader(title: 'Needs Attention', subtitle: 'Items waiting for an admin'),
          SizedBox(height: 10),
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
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.go(a.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          IconCircle(icon: st.$1, color: st.$2, background: st.$3, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(a.hint,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ]),
          ),
          Text(groupDigits(a.count),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}

// ── Recent transactions ─────────────────────────────────────────────────────

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AdaptiveColumn(
        top: [
          CardHeader(
            title: 'Recent Transactions',
            trailing: LinkText('View All', onTap: () => context.go('/transactions')),
          ),
          const SizedBox(height: 8),
        ],
        middle: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [for (final t in DashboardSample.transactions) _TxTile(t)],
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile(this.t);
  final TxRow t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Avatar(name: t.user, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.user,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(t.type,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(t.amount,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            StatusChip(t.status, kind: StatusChip.kindFor(t.status)),
            const SizedBox(width: 8),
            Text(t.time,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ]),
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
      child: AdaptiveColumn(
        top: [
          CardHeader(
            title: 'Recent Alerts',
            trailing: LinkText('View All', onTap: () => context.go('/audit-logs')),
          ),
          const SizedBox(height: 8),
        ],
        middle: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [for (final a in DashboardSample.alerts) _AlertRow(a)],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow(this.a);
  final AlertItem a;

  @override
  Widget build(BuildContext context) {
    final st = _levelStyle(a.level);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: st.$3,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(st.$1, color: st.$2, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(a.detail,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(a.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]),
    );
  }
}

// ── Platform summary ────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  static const _icons = [
    (Icons.account_balance_wallet_outlined, AppColors.success),
    (Icons.card_giftcard_outlined, AppColors.brand),
    (Icons.hourglass_empty_rounded, AppColors.warning),
    (Icons.call_outlined, AppColors.pink),
    (Icons.headset_mic_outlined, AppColors.info),
    (Icons.admin_panel_settings_outlined, AppColors.brand),
    (Icons.verified_outlined, AppColors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AdaptiveColumn(
        top: const [
          CardHeader(title: 'Platform Summary'),
          SizedBox(height: 8),
        ],
        middle: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            for (var i = 0; i < DashboardSample.summary.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(children: [
                  Icon(_icons[i].$1, size: 19, color: _icons[i].$2),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(DashboardSample.summary[i].$1,
                        style: const TextStyle(fontSize: 13, color: AppColors.navText)),
                  ),
                  Text(DashboardSample.summary[i].$2,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
              ),
          ],
        ),
        bottom: [
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: LinkText('View Full Report', onTap: () => context.go('/reports')),
          ),
        ],
      ),
    );
  }
}
