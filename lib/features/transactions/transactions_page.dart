import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sample_finance.dart';
import '../../theme/app_colors.dart';
import '../../widgets/adaptive_column.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Transactions (approved design): stats, status tabs, filters, table with
/// money-kind labels, overview donut, trends chart and recent activity.
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

const _tabs = ['All', 'Successful', 'Pending', 'Failed', 'Reversed'];

class _TransactionsPageState extends State<TransactionsPage> {
  int _tab = 0;
  int _page = 1;
  String _type = 'All Types';
  String _money = 'All Money';
  String _channel = 'All Channels';

  List<Txn> get _rows => SampleFinance.txns.where((t) {
    if (_tab > 0 && t.status != _tabs[_tab]) return false;
    if (_type != 'All Types' && !t.type.startsWith(_type)) return false;
    if (_money != 'All Money' && t.kind.label != _money) return false;
    if (_channel != 'All Channels' && t.channel != _channel) return false;
    return true;
  }).toList();

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
              label: 'Total Volume (SFZ)',
              value: 'SFZ 2,454,000',
              change: '12.5% this month',
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [1.6, 1.8, 1.7, 2.0, 2.1, 2.2, 2.3, 2.45],
            ),
            StatCard(
              label: 'Total Transactions',
              value: '5,482',
              change: '8.3% this month',
              icon: Icons.swap_horiz_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [4.1, 4.4, 4.3, 4.8, 4.9, 5.1, 5.3, 5.48],
            ),
            StatCard(
              label: 'Successful',
              value: '4,896',
              change: '89.3% success rate',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
            ),
            StatCard(
              label: 'Failed',
              value: '586',
              change: '10.7% failure rate',
              icon: Icons.cancel_outlined,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final table = _table();
            const side = _TxSide();
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
      Col('Transaction ID', 15),
      Col('User', 17),
      Col('Type', 16),
      Col('Amount', 13),
      Col('Status', 11),
      Col('Channel', 12),
      Col('Date & time', 11),
      Col('Actions', 7, align: TextAlign.center),
    ];
    final rows = _rows;
    return AppCard(
      padding: 0,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 820;
          final tabs = UnderlineTabs(
            labels: _tabs,
            selected: _tab,
            onSelect: (i) => setState(() => _tab = i),
          );
          final tools = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              const OutlineButtonBox(
                label: 'Filters',
                icon: Icons.filter_alt_outlined,
              ),
              const OutlineButtonBox(
                label: 'Export',
                icon: Icons.file_download_outlined,
                trailingChevron: true,
              ),
              PrimaryButton(
                label: 'Trace',
                icon: Icons.account_tree_outlined,
                onTap: () => context.go('/transactions/trace'),
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: narrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [tabs, const SizedBox(height: 10), tools],
                      )
                    : Row(
                        children: [
                          Expanded(child: tabs),
                          tools,
                        ],
                      ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    const _DateBox(),
                    FilterBox(
                      label: 'Transaction Type',
                      value: _type,
                      options: const [
                        'All Types',
                        'Transfer',
                        'Wallet Top Up',
                        'Withdrawal',
                        'Airtime',
                        'Data Bundle',
                        'Gift Card',
                      ],
                      onChanged: (v) => setState(() => _type = v),
                    ),
                    FilterBox(
                      label: 'Money',
                      value: _money,
                      options: [
                        'All Money',
                        for (final k in MoneyKind.values) k.label,
                      ],
                      onChanged: (v) => setState(() => _money = v),
                    ),
                    FilterBox(
                      label: 'Channel',
                      value: _channel,
                      options: const [
                        'All Channels',
                        'SchatzApp',
                        'Card',
                        'Bank Transfer',
                        'Reloadly',
                      ],
                      onChanged: (v) => setState(() => _channel = v),
                    ),
                    OutlineButtonBox(
                      label: 'Reset',
                      icon: Icons.refresh_rounded,
                      onTap: () => setState(() {
                        _type = 'All Types';
                        _money = 'All Money';
                        _channel = 'All Channels';
                        _tab = 0;
                      }),
                    ),
                  ],
                ),
              ),
              if (rows.isEmpty)
                const EmptyState('No transactions match these filters.')
              else if (narrow)
                for (final t in rows)
                  InkWell(
                    onTap: () => showTxnDetails(context, t),
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
                      child: Row(
                        children: [
                          Avatar(name: t.user, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TwoLine(t.user, '${t.type} · ${t.id}'),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                t.amount,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DotChip(
                                t.status,
                                kind: StatusChip.kindFor(t.status),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
              else ...[
                const TableHead(cols: cols, checkbox: true),
                for (final t in rows)
                  TableLine(
                    cols: cols,
                    checkbox: true,
                    onTap: () => showTxnDetails(context, t),
                    cells: [
                      TwoLine(t.id, 'Ref: ${t.ref}'),
                      Row(
                        children: [
                          Avatar(name: t.user, size: 30),
                          const SizedBox(width: 8),
                          Expanded(child: TwoLine(t.user, t.email)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            txIcon(t.icon).$1,
                            size: 18,
                            color: txIcon(t.icon).$2,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.type,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                MoneyKindTag(t.kind),
                              ],
                            ),
                          ),
                        ],
                      ),
                      TwoLine(t.amount, 'Fee: ${t.fee}'),
                      DotChip(t.status, kind: StatusChip.kindFor(t.status)),
                      Text(t.channel, style: const TextStyle(fontSize: 12)),
                      TwoLine(t.date, t.time, bold: false),
                      _RowMenu(t),
                    ],
                  ),
              ],
              PaginationBar(
                info: 'Showing 1 to ${rows.length} of 5,482 transactions',
                lastPage: 549,
                page: _page,
                onPage: (p) => setState(() => _page = p),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range',
            style: TextStyle(fontSize: 11.5, color: AppColors.navText),
          ),
          SizedBox(height: 6),
          OutlineButtonBox(
            label: 'Nov 17, 2026 - Nov 24, 2026',
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }
}

class _RowMenu extends StatelessWidget {
  const _RowMenu(this.t);
  final Txn t;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      onSelected: (v) {
        if (v == 'view') showTxnDetails(context, t);
        if (v == 'trace') context.go('/transactions/trace?ref=${t.id}');
        if (v == 'user') context.go('/users');
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'view',
          child: Text('View details', style: TextStyle(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'trace',
          child: Text('Trace funds', style: TextStyle(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'user',
          child: Text('Open user', style: TextStyle(fontSize: 13)),
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

/// Read-only transaction details. Ledger entries are never edited: a
/// correction is a new, approved entry.
void showTxnDetails(BuildContext context, Txn t) {
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
                    icon: txIcon(t.icon).$1,
                    color: txIcon(t.icon).$2,
                    background: txIcon(t.icon).$2.withValues(alpha: 0.1),
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: TwoLine(t.type, t.id)),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  t.amount,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Wrap(
                  spacing: 8,
                  children: [
                    DotChip(t.status, kind: StatusChip.kindFor(t.status)),
                    MoneyKindTag(t.kind),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (final kv in [
                ('Transaction reference', '${t.id} · ${t.ref}'),
                ('Date and time', '${t.date} · ${t.time}'),
                ('Sender', t.user),
                ('Recipient', t.counterparty),
                ('Payment provider', t.channel),
                ('Provider reference', t.providerRef),
                ('Fee', t.fee),
                ('Description', t.detail),
              ])
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 160,
                        child: Text(
                          kv.$1,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SelectableText(
                          kv.$2,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              const Text(
                'Ledger entries cannot be edited or deleted. Corrections are new entries that need approval.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlineButtonBox(
                    label: 'Download Receipt',
                    icon: Icons.file_download_outlined,
                    onTap: () => toast(
                      ctx,
                      'Receipts download once the backend is connected.',
                    ),
                  ),
                  const SizedBox(width: 10),
                  PrimaryButton(
                    label: 'Trace Funds',
                    icon: Icons.account_tree_outlined,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/transactions/trace?ref=${t.id}');
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

class _TxSide extends StatelessWidget {
  const _TxSide();

  @override
  Widget build(BuildContext context) {
    const data = [
      ('Successful', 4896.0, AppColors.success),
      ('Pending', 586.0, AppColors.warning),
      ('Failed', 380.0, AppColors.danger),
      ('Reversed', 152.0, AppColors.info),
    ];
    final total = data.fold<double>(0, (a, b) => a + b.$2);
    return SideStack(
      children: [
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'Transaction Overview'),
              const SizedBox(height: 14),
              Row(
                children: [
                  DonutChart(
                    values: [for (final d in data) d.$2],
                    colors: [for (final d in data) d.$3],
                    centerTop: '5,482',
                    centerBottom: 'Total',
                    size: 112,
                    stroke: 12,
                    fontSize: 18,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        for (final d in data)
                          LegendRow(
                            color: d.$3,
                            label: d.$1,
                            value: groupDigits(d.$2),
                            percent:
                                '${(d.$2 / total * 100).toStringAsFixed(1)}%',
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
        SizedBox(
          height: 290,
          child: AppCard(
            padding: 16,
            child: AdaptiveColumn(
              top: const [
                CardHeader(
                  title: 'Transaction Trends',
                  trailing: OutlineButtonBox(
                    label: 'This Month',
                    trailingChevron: true,
                  ),
                ),
                SizedBox(height: 10),
              ],
              middle: LineChart(
                height: 200,
                smooth: true,
                labels: const [
                  'Nov 1',
                  'Nov 4',
                  'Nov 7',
                  'Nov 10',
                  'Nov 13',
                  'Nov 16',
                  'Nov 19',
                  'Nov 22',
                  'Nov 24',
                ],
                series: [
                  ChartSeries(
                    name: 'Volume',
                    color: AppColors.brand,
                    values: const [
                      1.2e5,
                      2.1e5,
                      1.8e5,
                      3.1e5,
                      2.6e5,
                      3.9e5,
                      3.4e5,
                      4.2e5,
                      3.7e5,
                    ],
                    fill: true,
                    format: (v) => 'SFZ ${compactNumber(v)}',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(
                title: 'Recent Activity',
                trailing: LinkText('View All', onTap: () {}),
              ),
              const SizedBox(height: 6),
              const ActivityRow(
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                title: 'Transfer to Chinedu Okafor',
                amount: 'SFZ 2,500',
                time: '2 mins ago',
              ),
              const ActivityRow(
                icon: Icons.schedule_rounded,
                color: AppColors.warning,
                title: 'Data bundle for Sarah Collins',
                amount: 'SFZ 200',
                time: '15 mins ago',
              ),
              const ActivityRow(
                icon: Icons.cancel_outlined,
                color: AppColors.danger,
                title: 'Withdrawal failed',
                amount: 'SFZ 15,000',
                time: '23 mins ago',
                amountColor: AppColors.danger,
              ),
              const ActivityRow(
                icon: Icons.add_card_rounded,
                color: AppColors.success,
                title: 'Wallet top up from card',
                amount: 'SFZ 5,000',
                time: '35 mins ago',
                amountColor: AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
