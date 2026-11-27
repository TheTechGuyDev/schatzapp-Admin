import 'package:material_ui/material_ui.dart';

import '../../data/sample_finance.dart' show MoneyKind;
import '../../theme/app_colors.dart';
import '../../widgets/charts.dart';
import '../../widgets/kit.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Reports: platform reports (approved design) plus the Super Admin /
/// Finance-only views: Finance Overview, Funds Flow & Reconciliation, the
/// Schatz ecosystem (internal currency kept apart from real money) and
/// Third-Party Providers.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _naira(double v) => '₦${compactNumber(v)}';
String _sfz(double v) => 'SFZ ${compactNumber(v)}';

class _ReportsPageState extends State<ReportsPage> {
  int _view = 0;

  static const _views = [
    'Overview',
    'Finance Overview',
    'Funds Flow & Reconciliation',
    'Schatz Ecosystem',
    'Third-Party Providers',
  ];

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        Row(
          children: [
            Expanded(
              child: UnderlineTabs(
                labels: _views,
                selected: _view,
                onSelect: (i) => setState(() => _view = i),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (_view > 0) ...[
          const _RestrictedBanner(),
          const SizedBox(height: 14),
        ] else
          const SizedBox(height: 12),
        switch (_view) {
          1 => const _FinanceOverview(),
          2 => const _FundsFlow(),
          3 => const _Ecosystem(),
          4 => const _Providers(),
          _ => const _Overview(),
        },
      ],
    );
  }
}

class _RestrictedBanner extends StatelessWidget {
  const _RestrictedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFFB45309)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Super Admin and Finance only. Company-wide figures are hidden '
              'from other roles by the server, and every view is logged.',
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overview (approved Reports design) ──────────────────────────────────────

class _Overview extends StatefulWidget {
  const _Overview();

  @override
  State<_Overview> createState() => _OverviewState();
}

class _OverviewState extends State<_Overview> {
  int _tab = 0;

  static const _tabs = [
    'All Reports',
    'User Reports',
    'Transaction Reports',
    'Financial Reports',
    'Compliance Reports',
    'System Reports',
  ];

  static const _reports = [
    (
      'User Registration Report',
      'User Reports',
      'Summary of user registrations and verifications',
      Icons.group_outlined,
      AppColors.brand,
    ),
    (
      'Transaction Summary',
      'Transaction Reports',
      'Overview of all transactions and volumes',
      Icons.swap_horiz_rounded,
      AppColors.success,
    ),
    (
      'Revenue & Fees Report',
      'Financial Reports',
      'Platform fees and revenue breakdown',
      Icons.account_balance_wallet_outlined,
      AppColors.warning,
    ),
    (
      'KYC Verification Report',
      'Compliance Reports',
      'KYC verification status and analytics',
      Icons.verified_user_outlined,
      AppColors.danger,
    ),
    (
      'Schatz Gift Card Report',
      'Transaction Reports',
      'Purchased, loaded and unloaded gift cards',
      Icons.card_giftcard_rounded,
      AppColors.pink,
    ),
    (
      'Suspicious Activity Report',
      'Compliance Reports',
      'Flagged accounts, fraud reports and actions taken',
      Icons.gpp_maybe_outlined,
      AppColors.danger,
    ),
    (
      'System Activity Report',
      'System Reports',
      'System activities and audit logs',
      Icons.dns_outlined,
      AppColors.info,
    ),
  ];

  Future<void> _custom() async {
    var type = 'Transaction Summary';
    var format = 'PDF';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text(
            'Generate report',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldBlock(
                  'Report',
                  DropField(
                    value: type,
                    options: [for (final r in _reports) r.$1],
                    onChanged: (v) => set(() => type = v),
                  ),
                ),
                const FieldBlock(
                  'Date range',
                  OutlineButtonBox(
                    label: 'Nov 1 - Nov 27, 2026',
                    icon: Icons.date_range_outlined,
                  ),
                ),
                FieldBlock(
                  'Format',
                  DropField(
                    value: format,
                    options: const ['PDF', 'Excel', 'CSV'],
                    onChanged: (v) => set(() => format = v),
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
              label: 'Generate',
              onTap: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      toast(context, '$type ($format) is being prepared');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _reports
        .where((r) => _tab == 0 || r.$2 == _tabs[_tab])
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TileGrid(
          minTileWidth: 220,
          maxColumns: 4,
          gap: 18,
          allowedColumns: [1, 2, 4],
          children: [
            StatCard(
              label: 'Total Users',
              value: '12,548',
              change: '8.6% from last week',
              icon: Icons.group_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [3, 3.4, 3.2, 4, 4.4, 4.6, 5.2, 5.8],
            ),
            StatCard(
              label: 'Total Transactions',
              value: '45,862',
              change: '12.4% from last week',
              icon: Icons.swap_horiz_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [3, 3.2, 3.8, 3.6, 4.2, 4.8, 5, 5.6],
            ),
            StatCard(
              label: 'Total Volume (SFZ)',
              value: 'SFZ 245.4M',
              change: '15.3% from last week',
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.info,
              background: AppColors.infoSoft,
              spark: [3, 3.6, 3.4, 4.2, 4, 4.8, 5.4, 6],
            ),
            StatCard(
              label: 'Total Fees Earned',
              value: '₦5,245,000',
              change: '9.7% from last week',
              icon: Icons.savings_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              spark: [3, 3.2, 3, 3.6, 3.8, 4.4, 4.2, 4.8],
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CardHeader(
                      title: 'Overview',
                      subtitle:
                          'Summary of key metrics for the selected period',
                      trailing: OutlineButtonBox(
                        label: 'Daily',
                        trailingChevron: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LineChart(
                      height: 250,
                      smooth: true,
                      labels: const [
                        'Nov 21',
                        'Nov 22',
                        'Nov 23',
                        'Nov 24',
                        'Nov 25',
                        'Nov 26',
                        'Nov 27',
                      ],
                      series: [
                        const ChartSeries(
                          name: 'Transactions',
                          color: AppColors.brand,
                          values: [2000, 3600, 3700, 4500, 5200, 4100, 3800],
                        ),
                        ChartSeries(
                          name: 'Volume (SFZ)',
                          color: AppColors.success,
                          fill: true,
                          secondary: true,
                          values: const [
                            30e6,
                            44e6,
                            40e6,
                            52e6,
                            68e6,
                            50e6,
                            42e6,
                          ],
                          format: _sfz,
                        ),
                        const ChartSeries(
                          name: 'Fees (₦)',
                          color: AppColors.warning,
                          values: [400, 520, 500, 460, 560, 470, 430],
                        ),
                        const ChartSeries(
                          name: 'New Users',
                          color: AppColors.info,
                          values: [1200, 1800, 1700, 1650, 2300, 1900, 1850],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TableCard(
                title: 'Reports',
                subtitle: 'Detailed reports and analytics',
                tabs: _tabs,
                tab: _tab,
                onTab: (i) => setState(() => _tab = i),
                toolbar: [
                  PrimaryButton(
                    label: 'Generate Report',
                    icon: Icons.add,
                    onTap: _custom,
                  ),
                ],
                checkbox: false,
                cols: const [
                  Col('Report Name', 22),
                  Col('Category', 14),
                  Col('Description', 22),
                  Col('Date Range', 13),
                  Col('Generated', 13),
                  Col('Actions', 9, align: TextAlign.center),
                ],
                rows: [
                  for (final r in rows)
                    [
                      Row(
                        children: [
                          TintIcon(r.$4, r.$5),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r.$1,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TintTag(r.$2, r.$5),
                      Text(
                        r.$3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      const Text(
                        'Nov 21 - Nov 27',
                        style: TextStyle(fontSize: 11.5),
                      ),
                      const TwoLine(
                        'Kesta Wealth',
                        'Nov 27, 10:30 AM',
                        bold: false,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SquareIconButton(
                            icon: Icons.file_download_outlined,
                            tooltip: 'Download',
                            onTap: () => toast(context, 'Downloading ${r.$1}'),
                          ),
                          const SizedBox(width: 6),
                          RowMenu(
                            items: const [
                              ('schedule', 'Schedule weekly', false),
                              ('share', 'Share with role', false),
                            ],
                            onSelected: (v) => toast(context, 'Saved'),
                          ),
                        ],
                      ),
                    ],
                ],
                narrowRow: (i) => NarrowRow(
                  leading: TintIcon(rows[i].$4, rows[i].$5),
                  title: rows[i].$1,
                  subtitle: rows[i].$2,
                  trailing: const Icon(
                    Icons.file_download_outlined,
                    size: 18,
                    color: AppColors.brand,
                  ),
                ),
                pageInfo: 'Showing 1 to ${rows.length} of 25 reports',
                lastPage: 5,
              ),
            ],
          ),
          side: SideStack(
            children: [
              AppCard(
                padding: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CardHeader(title: 'Report Categories'),
                    const SizedBox(height: 8),
                    for (final c in const [
                      (
                        'User Reports',
                        8,
                        Icons.group_outlined,
                        AppColors.brand,
                      ),
                      (
                        'Transaction Reports',
                        12,
                        Icons.swap_horiz_rounded,
                        AppColors.success,
                      ),
                      (
                        'Financial Reports',
                        7,
                        Icons.account_balance_wallet_outlined,
                        AppColors.warning,
                      ),
                      (
                        'Compliance Reports',
                        6,
                        Icons.verified_user_outlined,
                        AppColors.danger,
                      ),
                      ('System Reports', 5, Icons.dns_outlined, AppColors.info),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            TintIcon(c.$3, c.$4, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c.$1,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                            Text(
                              '${c.$2}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                    const CardHeader(title: 'Quick Reports'),
                    const SizedBox(height: 6),
                    for (final q in const [
                      ('Daily Summary', "Overview of today's activities"),
                      ('Weekly Summary', "Overview of this week's activities"),
                      (
                        'Monthly Summary',
                        "Overview of this month's activities",
                      ),
                      ('Custom Report', 'Build a custom report'),
                    ])
                      InkWell(
                        onTap: _custom,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              const TintIcon(
                                Icons.event_note_outlined,
                                AppColors.brand,
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: TwoLine(q.$1, q.$2)),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const ActivityCard(
                title: 'Recent Reports',
                items: [
                  Act(
                    Icons.swap_horiz_rounded,
                    AppColors.success,
                    'Transaction Summary (PDF)',
                    '10:15 AM',
                  ),
                  Act(
                    Icons.group_outlined,
                    AppColors.brand,
                    'User Registration Report (PDF)',
                    '10:10 AM',
                  ),
                  Act(
                    Icons.account_balance_wallet_outlined,
                    AppColors.warning,
                    'Revenue & Fees Report (Excel)',
                    '10:00 AM',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const HelpCard('Learn how to generate and customize reports.'),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Finance Overview ─────────────────────────────────────────────────────────

class _FinanceOverview extends StatefulWidget {
  const _FinanceOverview();

  @override
  State<_FinanceOverview> createState() => _FinanceOverviewState();
}

class _FinanceOverviewState extends State<_FinanceOverview> {
  String _year = '2026';
  String _compare = '2025';

  static const _deposits2026 = [
    41e6,
    46e6,
    52e6,
    49e6,
    58e6,
    63e6,
    61e6,
    70e6,
    74e6,
    81e6,
    88e6,
    0.0,
  ];
  static const _deposits2025 = [
    22e6,
    25e6,
    27e6,
    30e6,
    33e6,
    35e6,
    38e6,
    40e6,
    43e6,
    47e6,
    51e6,
    58e6,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TileGrid(
          minTileWidth: 200,
          maxColumns: 5,
          gap: 18,
          children: [
            StatCard(
              label: 'Total Deposits (All Time)',
              value: '₦1.24B',
              change: 'Real money via providers',
              icon: Icons.account_balance_rounded,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [3, 3.4, 3.8, 4.2, 4.6, 5.2, 5.8, 6.4],
            ),
            StatCard(
              label: 'Deposits Today',
              value: '₦3.18M',
              change: '6.1% vs yesterday',
              icon: Icons.today_outlined,
              color: AppColors.success,
              background: AppColors.successSoft,
            ),
            StatCard(
              label: 'This Week',
              value: '₦21.4M',
              change: '9.4% vs last week',
              icon: Icons.date_range_outlined,
              color: AppColors.info,
              background: AppColors.infoSoft,
            ),
            StatCard(
              label: 'This Month',
              value: '₦88.2M',
              change: '8.9% vs October',
              icon: Icons.calendar_month_outlined,
              color: AppColors.teal,
              background: AppColors.tealSoft,
            ),
            StatCard(
              label: 'This Year',
              value: '₦683.6M',
              change: '71% vs 2025',
              icon: Icons.event_available_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CardHeader(
                      title: 'Monthly Deposits',
                      subtitle:
                          'Real money deposited through payment providers. '
                          'Internal Schatz transfers are not included.',
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          FilterBox(
                            label: 'Year',
                            value: _year,
                            width: 100,
                            options: const ['2026', '2025', '2024'],
                            onChanged: (v) => setState(() => _year = v),
                          ),
                          FilterBox(
                            label: 'Compare with',
                            value: _compare,
                            width: 120,
                            options: const ['2025', '2024', 'None'],
                            onChanged: (v) => setState(() => _compare = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LineChart(
                      height: 250,
                      labels: _months,
                      series: [
                        ChartSeries(
                          name: _year,
                          color: AppColors.brand,
                          fill: true,
                          values: _year == '2026'
                              ? _deposits2026
                              : _deposits2025,
                          format: _naira,
                        ),
                        if (_compare != 'None')
                          ChartSeries(
                            name: _compare,
                            color: AppColors.grey,
                            dashed: true,
                            values: _deposits2025,
                            format: _naira,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _AnnualTable(),
            ],
          ),
          side: const SideStack(
            children: [
              BarsCard(
                title: 'Deposit Status (This Month)',
                items: [
                  ('Successful', 0.93, '₦88.2M', AppColors.success),
                  ('Pending', 0.04, '₦3.9M', AppColors.warning),
                  ('Failed', 0.03, '₦2.7M', AppColors.danger),
                ],
              ),
              SizedBox(height: 18),
              DonutCard(
                title: 'Deposits by Method',
                centerTop: '₦88.2M',
                centerBottom: 'November',
                items: [
                  ('Card', 52.4, AppColors.brand),
                  ('Bank transfer', 28.1, AppColors.info),
                  ('Gift card sales', 7.7, AppColors.pink),
                ],
              ),
              SizedBox(height: 18),
              HelpCard(
                'Totals come from provider settlement records, then are '
                'reconciled against the Schatz ledger.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnnualTable extends StatelessWidget {
  const _AnnualTable();

  @override
  Widget build(BuildContext context) {
    const years = [
      (
        '2026 (YTD)',
        '₦683.6M',
        '₦412.9M',
        'SFZ 2.91B',
        '₦12.4M',
        '₦96.2M',
        '₦3.1M',
        '₦1.4M',
      ),
      (
        '2025',
        '₦449.0M',
        '₦301.2M',
        'SFZ 1.88B',
        '₦8.2M',
        '₦61.5M',
        '₦2.4M',
        '₦0.9M',
      ),
      (
        '2024',
        '₦112.3M',
        '₦70.4M',
        'SFZ 0.41B',
        '₦1.9M',
        '₦14.8M',
        '₦0.6M',
        '₦0.2M',
      ),
    ];
    return TableCard(
      title: 'Annual Financial Report',
      subtitle: 'Real money in and out, separate from Schatz volume',
      checkbox: false,
      toolbar: const [
        OutlineButtonBox(label: 'Export', icon: Icons.file_download_outlined),
      ],
      cols: const [
        Col('Year', 10),
        Col('Deposits', 11),
        Col('Outgoing funds', 12),
        Col('Schatz volume', 12),
        Col('Payment fees', 11),
        Col('3rd-party costs', 12),
        Col('Refunds', 9),
        Col('Reversals', 9),
      ],
      rows: [
        for (final y in years)
          [
            Text(
              y.$1,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Text(
              y.$2,
              style: const TextStyle(fontSize: 12, color: AppColors.success),
            ),
            Text(
              y.$3,
              style: const TextStyle(fontSize: 12, color: AppColors.danger),
            ),
            Text(
              y.$4,
              style: const TextStyle(fontSize: 12, color: AppColors.brand),
            ),
            Text(y.$5, style: const TextStyle(fontSize: 12)),
            Text(y.$6, style: const TextStyle(fontSize: 12)),
            Text(y.$7, style: const TextStyle(fontSize: 12)),
            Text(y.$8, style: const TextStyle(fontSize: 12)),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: const TintIcon(Icons.calendar_month_outlined, AppColors.brand),
        title: years[i].$1,
        subtitle: 'In ${years[i].$2} · Out ${years[i].$3}',
        trailing: Text(
          years[i].$4,
          style: const TextStyle(fontSize: 11.5, color: AppColors.brand),
        ),
      ),
    );
  }
}

// ── Funds Flow & Reconciliation ──────────────────────────────────────────────

class _FundsFlow extends StatelessWidget {
  const _FundsFlow();

  @override
  Widget build(BuildContext context) {
    const flows = [
      (
        'Funds coming in (deposits)',
        '₦88.2M',
        MoneyKind.fiatIn,
        Icons.south_west_rounded,
      ),
      (
        'Funds leaving (withdrawals, payouts)',
        '₦41.7M',
        MoneyKind.fiatOut,
        Icons.north_east_rounded,
      ),
      (
        'Internal Schatz transfers',
        'SFZ 318.4M',
        MoneyKind.internal,
        Icons.swap_horiz_rounded,
      ),
      (
        'Third-party service payments',
        '₦22.9M',
        MoneyKind.service,
        Icons.storefront_outlined,
      ),
      (
        'External settlements',
        '₦18.8M',
        MoneyKind.fiatOut,
        Icons.account_balance_outlined,
      ),
      ('Refunds', '₦1.1M', MoneyKind.fiatOut, Icons.undo_rounded),
    ];
    const recon = [
      ('Card (Paystack)', '₦52,401,200', '₦52,401,200', '₦0', 'Matched'),
      ('Bank transfer', '₦28,114,000', '₦28,064,000', '₦50,000', 'Pending'),
      ('Reloadly float', '₦9,880,450', '₦9,874,950', '₦5,500', 'Mismatch'),
      ('Gift card sales', '₦7,702,000', '₦7,702,000', '₦0', 'Matched'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TileGrid(
          minTileWidth: 240,
          maxColumns: 3,
          gap: 18,
          children: [
            for (final f in flows)
              AppCard(
                padding: 16,
                child: Row(
                  children: [
                    TintIcon(f.$4, switch (f.$3) {
                      MoneyKind.fiatIn => AppColors.success,
                      MoneyKind.fiatOut => AppColors.danger,
                      MoneyKind.internal => AppColors.brand,
                      MoneyKind.service => AppColors.info,
                    }, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.$1,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f.$2,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          MoneyKindTag(f.$3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(
          main: TableCard(
            title: 'Reconciliation (November)',
            subtitle:
                'Provider records compared with the Schatz ledger. Any '
                'difference must be explained before month close.',
            checkbox: false,
            toolbar: [
              PrimaryButton(
                label: 'Run reconciliation',
                icon: Icons.sync_rounded,
                onTap: () => toast(context, 'Reconciliation started'),
              ),
            ],
            cols: const [
              Col('Source', 18),
              Col('Provider record', 15),
              Col('Schatz ledger', 15),
              Col('Difference', 12),
              Col('Status', 11),
              Col('', 5),
            ],
            rows: [
              for (final r in recon)
                [
                  Text(
                    r.$1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(r.$2, style: const TextStyle(fontSize: 12)),
                  Text(r.$3, style: const TextStyle(fontSize: 12)),
                  Text(
                    r.$4,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: r.$4 == '₦0'
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ),
                  StatusChip(
                    r.$5,
                    kind: switch (r.$5) {
                      'Matched' => ChipKind.success,
                      'Pending' => ChipKind.warning,
                      _ => ChipKind.danger,
                    },
                  ),
                  RowMenu(
                    items: const [
                      ('view', 'View line items', false),
                      ('case', 'Open investigation', false),
                    ],
                    onSelected: (v) => toast(
                      context,
                      v == 'case' ? 'Investigation opened' : 'Opening items',
                    ),
                  ),
                ],
            ],
            narrowRow: (i) => NarrowRow(
              leading: const TintIcon(Icons.balance_rounded, AppColors.brand),
              title: recon[i].$1,
              subtitle: 'Diff ${recon[i].$4}',
              trailing: TintTag(recon[i].$5, AppColors.brand),
            ),
            footerNote:
                'Corrections are new ledger entries that need a second '
                'approval. Ledger entries are never edited or deleted.',
          ),
          side: const SideStack(
            children: [
              BarsCard(
                title: 'Failed & Pending (This Month)',
                items: [
                  ('Failed', 0.3, '1,214 txns', AppColors.danger),
                  ('Pending', 0.12, '486 txns', AppColors.warning),
                  ('Reversed', 0.05, '118 txns', AppColors.info),
                ],
              ),
              SizedBox(height: 18),
              HelpCard(
                'Internal Schatz transfers never count as new money. Only '
                'provider-confirmed deposits do.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Schatz Ecosystem ─────────────────────────────────────────────────────────

class _Ecosystem extends StatelessWidget {
  const _Ecosystem();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TileGrid(
          minTileWidth: 200,
          maxColumns: 5,
          gap: 18,
          children: [
            StatCard(
              label: 'Schatz Issued',
              value: 'SFZ 1.31B',
              change: 'Backed by deposits',
              icon: Icons.add_circle_outline_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
            ),
            StatCard(
              label: 'Transferred (Users)',
              value: 'SFZ 318.4M',
              change: 'Internal, not new money',
              icon: Icons.swap_horiz_rounded,
              color: AppColors.brand,
              background: AppColors.brandSoft,
            ),
            StatCard(
              label: 'Spent on Services',
              value: 'SFZ 96.2M',
              change: 'Airtime, data, gift cards',
              icon: Icons.storefront_outlined,
              color: AppColors.info,
              background: AppColors.infoSoft,
            ),
            StatCard(
              label: 'Redeemed via Partners',
              value: 'SFZ 41.7M',
              change: 'Withdrawals & payouts',
              icon: Icons.output_rounded,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
            ),
            StatCard(
              label: 'Schatz in Wallets',
              value: 'SFZ 1.17B',
              change: 'Must equal ledger balance',
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(
          main: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(
                  title: 'Schatz Movement',
                  subtitle: 'Issued vs transferred vs spent, last 12 weeks',
                ),
                const SizedBox(height: 16),
                LineChart(
                  height: 260,
                  smooth: true,
                  labels: const [
                    'W1',
                    'W2',
                    'W3',
                    'W4',
                    'W5',
                    'W6',
                    'W7',
                    'W8',
                    'W9',
                    'W10',
                    'W11',
                    'W12',
                  ],
                  series: const [
                    ChartSeries(
                      name: 'Issued',
                      color: AppColors.success,
                      fill: true,
                      values: [
                        80,
                        84,
                        90,
                        92,
                        95,
                        101,
                        104,
                        110,
                        112,
                        118,
                        121,
                        126,
                      ],
                      format: _m,
                    ),
                    ChartSeries(
                      name: 'Transferred',
                      color: AppColors.brand,
                      values: [20, 22, 24, 23, 25, 27, 28, 29, 30, 31, 33, 34],
                      format: _m,
                    ),
                    ChartSeries(
                      name: 'Spent on services',
                      color: AppColors.info,
                      values: [
                        6,
                        7,
                        7,
                        7.4,
                        7.8,
                        8,
                        8.1,
                        8.4,
                        8.6,
                        8.8,
                        9,
                        9.4,
                      ],
                      format: _m,
                    ),
                    ChartSeries(
                      name: 'Redeemed',
                      color: AppColors.danger,
                      dashed: true,
                      values: [
                        2,
                        2.4,
                        2.6,
                        3,
                        3.1,
                        3.2,
                        3.4,
                        3.4,
                        3.6,
                        3.8,
                        3.9,
                        4,
                      ],
                      format: _m,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MoneyKindTag(MoneyKind.fiatIn),
                    MoneyKindTag(MoneyKind.internal),
                    MoneyKindTag(MoneyKind.service),
                    MoneyKindTag(MoneyKind.fiatOut),
                  ],
                ),
              ],
            ),
          ),
          side: const SideStack(
            children: [
              DonutCard(
                title: 'Schatz Gift Cards',
                centerTop: 'SFZ 184.5K',
                centerBottom: 'This month',
                items: [
                  ('Loaded', 121.2, AppColors.success),
                  ('Purchased, not loaded', 48.3, AppColors.warning),
                  ('Expired / refunded', 15.0, AppColors.grey),
                ],
              ),
              SizedBox(height: 18),
              BarsCard(
                title: 'Where Schatz is Spent',
                items: [
                  ('Airtime', 0.44, 'SFZ 42.3M', AppColors.warning),
                  ('Data', 0.31, 'SFZ 29.8M', AppColors.info),
                  ('Gift cards', 0.18, 'SFZ 17.3M', AppColors.pink),
                  ('Other', 0.07, 'SFZ 6.8M', AppColors.grey),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _m(double v) => 'SFZ ${v.toStringAsFixed(1)}M';

// ── Third-Party Providers ────────────────────────────────────────────────────

class _Providers extends StatelessWidget {
  const _Providers();

  static const _rows = [
    (
      'Reloadly',
      'Airtime, data, gift cards',
      '₦48.0M',
      '₦38.1M',
      '₦9.9M',
      '18,204',
      '212',
      '14',
      '₦312K',
      'Operational',
    ),
    (
      'Paystack',
      'Card payments',
      '—',
      '—',
      'Settles T+1',
      '24,880',
      '418',
      '61',
      '₦1.92M',
      'Operational',
    ),
    (
      'Bank partner (Providus)',
      'Bank transfers, payouts',
      '₦25.0M',
      '₦21.3M',
      '₦3.7M',
      '6,422',
      '38',
      '9',
      '₦98K',
      'Degraded',
    ),
    (
      'Agora',
      'Voice & video calls',
      '\$2,000',
      '\$1,412',
      '\$588',
      '—',
      '—',
      '—',
      '—',
      'Operational',
    ),
    (
      'Crypto partner',
      'Planned',
      '—',
      '—',
      '—',
      '—',
      '—',
      '—',
      '—',
      'Not connected',
    ),
  ];

  void _open(BuildContext context, int i) {
    final p = _rows[i];
    showSidePanel<void>(
      context,
      title: p.$1,
      subtitle: p.$2,
      width: 640,
      body: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelSection('Balances'),
          InfoLine('Total funded', p.$3),
          InfoLine('Total consumed', p.$4),
          InfoLine('Remaining provider balance', p.$5),
          InfoLine('Successful transactions', p.$6),
          InfoLine('Failed transactions', p.$7),
          InfoLine('Pending', p.$8),
          InfoLine('Fees', p.$9),
          const PanelSection('Compare transactions'),
          for (final t in const [
            ('RLD-88310021', 'AIR-2026-90114', '₦2,000', '₦2,000', true),
            ('RLD-88310019', 'DAT-2026-44120', '₦5,500', '₦5,500', true),
            ('RLD-88310014', 'GC-2026-11902', '₦25,000', '—', false),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: t.$5 ? AppColors.border : AppColors.danger,
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: TwoLine(t.$1, 'Provider ref · ${t.$3}')),
                  Expanded(child: TwoLine(t.$2, 'SchatzApp ref · ${t.$4}')),
                  StatusChip(
                    t.$5 ? 'Matched' : 'Missing in ledger',
                    kind: t.$5 ? ChipKind.success : ChipKind.danger,
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: (ctx) => [
        OutlineButtonBox(
          label: 'Download statement',
          icon: Icons.file_download_outlined,
          onTap: () => toast(context, 'Statement downloading'),
        ),
        PrimaryButton(
          label: 'Record top-up of float',
          icon: Icons.add,
          onTap: () => askReason(
            context,
            title: 'Record provider funding',
            message:
                'Records money sent to ${p.$1}. Needs a second Finance '
                'approval before it counts.',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainSideLayout(
      main: TableCard(
        title: 'Third-Party Service Providers',
        subtitle: 'Money moving between SchatzApp and each provider',
        checkbox: false,
        cols: const [
          Col('Provider', 20),
          Col('Funded', 10),
          Col('Consumed', 10),
          Col('Balance', 11),
          Col('Success', 8),
          Col('Failed', 7),
          Col('Pending', 7),
          Col('Fees', 8),
          Col('Status', 12),
        ],
        onRowTap: (i) => _open(context, i),
        rows: [
          for (final p in _rows)
            [
              TwoLine(p.$1, p.$2),
              Text(p.$3, style: const TextStyle(fontSize: 12)),
              Text(p.$4, style: const TextStyle(fontSize: 12)),
              Text(
                p.$5,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(p.$6, style: const TextStyle(fontSize: 12)),
              Text(
                p.$7,
                style: const TextStyle(fontSize: 12, color: AppColors.danger),
              ),
              Text(p.$8, style: const TextStyle(fontSize: 12)),
              Text(p.$9, style: const TextStyle(fontSize: 12)),
              DotChip(
                p.$10,
                kind: switch (p.$10) {
                  'Operational' => ChipKind.success,
                  'Degraded' => ChipKind.warning,
                  _ => ChipKind.neutral,
                },
              ),
            ],
        ],
        narrowRow: (i) => NarrowRow(
          leading: const TintIcon(Icons.hub_outlined, AppColors.brand),
          title: _rows[i].$1,
          subtitle: 'Balance ${_rows[i].$5}',
          trailing: TintTag(_rows[i].$10, AppColors.brand),
        ),
        footerNote: 'Open a provider to compare its records with SchatzApp.',
      ),
      side: const SideStack(
        children: [
          ActivityCard(
            title: 'Provider Alerts',
            items: [
              Act(
                Icons.warning_amber_rounded,
                AppColors.danger,
                'Reloadly: 1 order missing in ledger',
                '1h',
              ),
              Act(
                Icons.speed_rounded,
                AppColors.warning,
                'Providus responding slowly',
                '3h',
              ),
              Act(
                Icons.account_balance_wallet_outlined,
                AppColors.info,
                'Reloadly float below ₦10M',
                '1d',
              ),
            ],
          ),
          SizedBox(height: 18),
          HelpCard('How provider reconciliation works.'),
        ],
      ),
    );
  }
}
