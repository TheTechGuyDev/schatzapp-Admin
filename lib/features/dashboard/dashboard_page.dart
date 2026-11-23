import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/breakpoints.dart';
import '../../core/session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/adaptive_column.dart';
import '../../widgets/charts.dart';
import '../../widgets/page_body.dart';
import '../../widgets/ui.dart';
import 'dashboard_sample.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Breakpoints.of(context);
    final phone = size == ScreenSize.phone;
    final s = AdminSession.instance;

    void notReady() => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export becomes available when the backend is connected.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

    return PageBody(children: [
      PageHeader(
        title: 'Dashboard',
        subtitle:
            'Welcome back, ${s.firstName}. Here is what is happening on SchatzApp today.',
        actions: [
          SearchBox(
            hint: 'Search users, transactions, tickets',
            width: phone ? MediaQuery.sizeOf(context).width - 32 : 300,
          ),
          if (!phone) const IconBoxButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            badge: 12,
          ),
          const OutlineButtonBox(
            label: 'Last 30 days',
            icon: Icons.calendar_today_outlined,
          ),
          PrimaryButton(
            label: 'Export report',
            icon: Icons.file_download_outlined,
            onTap: notReady,
          ),
        ],
      ),
      const SizedBox(height: 26),
      const _HeadlineCards(),
      const SizedBox(height: 20),
      const _UserStatistics(),
      const SizedBox(height: 20),
      const ResponsiveRow(
        flex: [7, 4],
        height: 400,
        children: [_GrowthCard(), _FeatureUsageCard()],
      ),
      const SizedBox(height: 20),
      const ResponsiveRow(
        flex: [7, 4],
        height: 520,
        children: [_CountriesCard(), _StatusCard()],
      ),
      const SizedBox(height: 20),
      const ResponsiveRow(
        flex: [7, 5],
        height: 480,
        children: [_TransactionsCard(), _AttentionCard()],
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
      minTileWidth: 240,
      maxColumns: 4,
      allowedColumns: [1, 2, 4],
      children: [
        StatCard(
          label: 'Total users',
          value: '12,480',
          delta: '+4.2% this week',
          icon: Icons.people_outline,
          spark: [9, 10, 10.4, 11, 11.2, 11.8, 12.48],
        ),
        StatCard(
          label: 'Active today',
          value: '3,915',
          delta: '+1.8% vs yesterday',
          icon: Icons.bolt_rounded,
          spark: [3.5, 3.6, 3.7, 3.65, 3.8, 3.85, 3.91],
        ),
        StatCard(
          label: 'Wallet volume (30d)',
          value: '₦48.2M',
          delta: '+9.1% vs last month',
          icon: Icons.account_balance_wallet_outlined,
          spark: [38, 40, 41, 43, 44, 46, 48.2],
        ),
        StatCard(
          label: 'Pending KYC',
          value: '126',
          delta: '+14 since yesterday',
          icon: Icons.verified_user_outlined,
          positive: false,
          spark: [90, 96, 101, 108, 112, 118, 126],
        ),
      ],
    );
  }
}

// ── User statistics (10 metrics) ────────────────────────────────────────────

class _UserStatistics extends StatelessWidget {
  const _UserStatistics();

  static const _colors = <Color>[
    AppColors.brand,
    AppColors.success,
    AppColors.teal,
    AppColors.info,
    AppColors.magenta,
    AppColors.textSecondary,
    AppColors.warning,
    Color(0xFFF59E0B),
    AppColors.danger,
    Color(0xFF6B7280),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const CardHeader(
          title: 'User statistics',
          subtitle:
              'Active means real use of the app (messages, calls, stories or wallet), not just a sign-in.',
        ),
        const SizedBox(height: 18),
        TileGrid(
          minTileWidth: 140,
          maxColumns: 5,
          gap: 14,
          children: [
            for (var i = 0; i < DashboardSample.userStats.length; i++)
              _MiniStat(
                label: DashboardSample.userStats[i].$1,
                value: groupDigits(DashboardSample.userStats[i].$2),
                hint: DashboardSample.userStats[i].$3,
                color: _colors[i],
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
    required this.color,
  });

  final String label;
  final String value;
  final String hint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(hint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
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
      child: AdaptiveColumn(
        top: const [
          CardHeader(
            title: 'User growth and activity',
            subtitle: 'New signups and daily active users, last 30 days',
          ),
          SizedBox(height: 16),
        ],
        middle: LineChart(
          height: 260,
          labels: DashboardSample.last30Labels,
          series: const [
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
            ),
          ],
        ),
        bottom: const [
          SizedBox(height: 12),
          Row(children: [
            _Legend(color: AppColors.brand, label: 'Daily active users'),
            Spacer(),
            _Legend(color: AppColors.teal, label: 'New signups'),
          ]),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Text(label, style: TextStyle(fontSize: 13, color: color)),
    ]);
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
          title: 'Feature usage',
          subtitle: 'Share of active users, last 7 days',
        ),
        const SizedBox(height: 18),
        for (final f in DashboardSample.featureUsage)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(child: Text(f.$1, style: const TextStyle(fontSize: 13.5))),
                Text('${(f.$2 * 100).round()}%',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 7),
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
      height: 9,
      decoration: BoxDecoration(
        color: const Color(0xFFECE9F1),
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
          hint: 'Search country',
          width: narrow ? c.maxWidth : 220,
          onChanged: (v) => setState(() => _query = v),
        );
        return AdaptiveColumn(
          top: [
            CardHeader(
              title: 'Users by country',
              subtitle: 'Registered, active, inactive and restricted users',
              trailing: narrow ? null : search,
            ),
            if (narrow) ...[const SizedBox(height: 14), search],
            const SizedBox(height: 16),
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
                    for (final r in rows)
                      narrow ? _CountryTile(r) : _CountryRow(r),
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
    const labels = ['Country', 'Registered', 'Active', 'Inactive', 'Restricted', 'New (30d)'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            flex: _countryFlex[i],
            child: Text(labels[i],
                textAlign: i == 0 ? TextAlign.left : TextAlign.right,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
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
      width: 34,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(code,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brandDark)),
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
              style: TextStyle(fontSize: 13.5, color: color ?? AppColors.text)),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
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
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
        num(c.registered, _countryFlex[1]),
        num(c.active, _countryFlex[2], color: AppColors.success),
        num(c.inactive, _countryFlex[3], color: AppColors.textSecondary),
        num(c.restricted, _countryFlex[4], color: AppColors.danger),
        num(c.newThisMonth, _countryFlex[5], color: AppColors.brandDark),
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(
              'Active ${groupDigits(c.active)} · Inactive ${groupDigits(c.inactive)} · Restricted ${c.restricted}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(groupDigits(c.registered),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          Text('+${c.newThisMonth} new',
              style: const TextStyle(fontSize: 11.5, color: AppColors.brandDark)),
        ]),
      ]),
    );
  }
}

// ── Account status donut ────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  static const _colors = [
    AppColors.success,
    Color(0xFFB8AFC6),
    Color(0xFFF59E0B),
    AppColors.magenta,
    AppColors.danger,
    Color(0xFF6B7280),
  ];

  @override
  Widget build(BuildContext context) {
    final data = DashboardSample.statusSplit;
    final total = data.fold<double>(0, (a, b) => a + b.$2);
    return AppCard(
      child: AdaptiveColumn(
        top: const [
          CardHeader(
            title: 'Account status',
            subtitle: 'All registered accounts by status',
          ),
          SizedBox(height: 20),
        ],
        middle: Center(
          child: DonutChart(
            values: [for (final d in data) d.$2],
            colors: _colors,
            centerTop: groupDigits(total),
            centerBottom: 'Accounts',
            size: 180,
          ),
        ),
        bottom: [
          const SizedBox(height: 20),
          for (var i = 0; i < data.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: _colors[i], borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(data[i].$1, style: const TextStyle(fontSize: 13.5))),
                Text(groupDigits(data[i].$2),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                SizedBox(
                  width: 58,
                  child: Text('${(data[i].$2 / total * 100).toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textSecondary)),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

// ── Recent transactions ─────────────────────────────────────────────────────

const _txFlex = [3, 3, 3, 3, 3];

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 560;
        return AdaptiveColumn(
          top: [
            CardHeader(
              title: 'Recent transactions',
              subtitle: 'Latest wallet activity',
              trailing: TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('View all'),
              ),
            ),
            const SizedBox(height: 12),
            if (!narrow) const _TxHeaderRow(),
          ],
          middle: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              for (final t in DashboardSample.transactions)
                narrow ? _TxTile(t) : _TxRow(t),
            ],
          ),
        );
      }),
    );
  }
}

class _TxHeaderRow extends StatelessWidget {
  const _TxHeaderRow();

  @override
  Widget build(BuildContext context) {
    const labels = ['Reference', 'User', 'Type', 'Amount', 'Status'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            flex: _txFlex[i],
            child: Text(labels[i],
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
      ]),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow(this.t);
  final TxRow t;

  @override
  Widget build(BuildContext context) {
    Widget cell(String v, int flex, {FontWeight w = FontWeight.w400}) => Expanded(
          flex: flex,
          child: Text(v,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.5, fontWeight: w)),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        cell(t.ref, _txFlex[0], w: FontWeight.w500),
        cell(t.user, _txFlex[1]),
        cell(t.type, _txFlex[2]),
        cell(t.amount, _txFlex[3], w: FontWeight.w600),
        Expanded(
          flex: _txFlex[4],
          child: Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(t.status, kind: StatusChip.kindFor(t.status)),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${t.user} · ${t.type}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text('${t.ref} · ${t.time}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(t.amount,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          StatusChip(t.status, kind: StatusChip.kindFor(t.status)),
        ]),
      ]),
    );
  }
}

// ── Needs attention ─────────────────────────────────────────────────────────

class _AttentionCard extends StatelessWidget {
  const _AttentionCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AdaptiveColumn(
        top: const [
          CardHeader(
            title: 'Needs attention',
            subtitle: 'Items waiting for an admin',
          ),
          SizedBox(height: 12),
        ],
        middle: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            for (final a in DashboardSample.attention) _AttentionRow(a),
          ],
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
    final color = a.urgent ? AppColors.danger : AppColors.brand;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.go(a.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.label, style: const TextStyle(fontSize: 13.5)),
              const SizedBox(height: 2),
              Text(a.hint,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ]),
          ),
          Text(groupDigits(a.count),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}
