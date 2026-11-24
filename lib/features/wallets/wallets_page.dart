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

/// Wallets (approved design). Balances can't be edited: money is only moved
/// by ledger entries, and a correction is a request that needs approval.
class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

const _tabs = ['All Wallets', 'Active', 'Restricted', 'Suspended', 'Frozen'];

ChipKind _statusKind(String s) => switch (s) {
  'Active' => ChipKind.success,
  'Restricted' => ChipKind.warning,
  'Suspended' => ChipKind.brand,
  'Frozen' => ChipKind.danger,
  _ => ChipKind.neutral,
};

class _WalletsPageState extends State<WalletsPage> {
  int _tab = 0;
  int _page = 1;
  String _q = '';
  String _country = 'All Countries';

  List<WalletRow> get _rows => SampleFinance.wallets.where((w) {
    if (_tab > 0 && w.status != _tabs[_tab]) return false;
    if (_country != 'All Countries' && w.country != _country) return false;
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      return w.user.toLowerCase().contains(q) ||
          w.accountNo.toLowerCase().contains(q) ||
          w.email.toLowerCase().contains(q);
    }
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
              label: 'Total Wallet Balance',
              value: 'SFZ 2,856,452.50',
              change: '6.1% in all wallets',
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [2.2, 2.3, 2.35, 2.5, 2.55, 2.7, 2.75, 2.86],
            ),
            StatCard(
              label: 'Total Wallets',
              value: '9,874',
              change: '8.6% active wallets',
              icon: Icons.wallet_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [8.1, 8.4, 8.6, 8.9, 9.1, 9.4, 9.6, 9.87],
            ),
            StatCard(
              label: 'Credits (This Month)',
              value: 'SFZ 1,254,506.50',
              change: '12.4% from last month',
              icon: Icons.south_rounded,
              color: AppColors.info,
              background: AppColors.infoSoft,
              spark: [0.8, 0.9, 0.95, 1.0, 1.05, 1.1, 1.2, 1.25],
            ),
            StatCard(
              label: 'Debits (This Month)',
              value: 'SFZ 982,304.50',
              change: '9.7% from last month',
              icon: Icons.north_rounded,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              spark: [0.7, 0.75, 0.72, 0.8, 0.85, 0.88, 0.93, 0.98],
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final table = _table();
            final side = _WalletSide(
              onAdjust: () => showAdjustmentDialog(context),
            );
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
                Expanded(flex: 18, child: side),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _table() {
    const cols = [
      Col('User', 21),
      Col('Account no.', 13),
      Col('Balance', 16),
      Col('Country', 9),
      Col('Status', 11),
      Col('KYC', 11),
      Col('Last activity', 12),
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
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Wallets',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!narrow) ...[
                      const OutlineButtonBox(
                        label: 'Filter',
                        icon: Icons.filter_alt_outlined,
                      ),
                      const SizedBox(width: 10),
                      const OutlineButtonBox(
                        label: 'Export',
                        icon: Icons.file_download_outlined,
                        trailingChevron: true,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
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
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    SearchBox(
                      hint: 'Search wallet, account no. or user...',
                      width: narrow ? c.maxWidth - 36 : 260,
                      onChanged: (v) => setState(() => _q = v.trim()),
                    ),
                    _InlineFilter(
                      value: _country,
                      options: const [
                        'All Countries',
                        'NG',
                        'DE',
                        'GB',
                        'US',
                        'CA',
                      ],
                      onChanged: (v) => setState(() => _country = v),
                    ),
                    OutlineButtonBox(
                      label: 'Reset',
                      icon: Icons.refresh_rounded,
                      onTap: () => setState(() {
                        _country = 'All Countries';
                        _tab = 0;
                      }),
                    ),
                  ],
                ),
              ),
              if (rows.isEmpty)
                const EmptyState('No wallets match this list.')
              else if (narrow)
                for (final w in rows)
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
                        Avatar(name: w.user, size: 36),
                        const SizedBox(width: 10),
                        Expanded(child: TwoLine(w.user, w.accountNo)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              w.balance,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatusChip(w.status, kind: _statusKind(w.status)),
                          ],
                        ),
                      ],
                    ),
                  )
              else ...[
                const TableHead(cols: cols, checkbox: true),
                for (final w in rows)
                  TableLine(
                    cols: cols,
                    checkbox: true,
                    cells: [
                      Row(
                        children: [
                          Avatar(name: w.user, size: 30),
                          const SizedBox(width: 8),
                          Expanded(child: TwoLine(w.user, w.email)),
                        ],
                      ),
                      Text(w.accountNo, style: const TextStyle(fontSize: 12)),
                      TwoLine(w.balance, w.local),
                      Text(
                        w.country,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      StatusChip(w.status, kind: _statusKind(w.status)),
                      DotChip(w.kyc, kind: StatusChip.kindFor(w.kyc)),
                      TwoLine(w.lastActivity, w.lastTime, bold: false),
                      _WalletMenu(w),
                    ],
                  ),
              ],
              PaginationBar(
                info: 'Showing 1 to ${rows.length} of 9,874 wallets',
                lastPage: 988,
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

class _InlineFilter extends StatelessWidget {
  const _InlineFilter({
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final o in options)
          PopupMenuItem(
            value: o,
            child: Text(o, style: const TextStyle(fontSize: 13)),
          ),
      ],
      child: OutlineButtonBox(label: value, trailingChevron: true),
    );
  }
}

class _WalletMenu extends StatelessWidget {
  const _WalletMenu(this.w);
  final WalletRow w;

  @override
  Widget build(BuildContext context) {
    final frozen = w.status == 'Frozen';
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      onSelected: (v) {
        switch (v) {
          case 'statement':
            toast(
              context,
              'Statements download once the backend is connected.',
            );
          case 'freeze':
            showFreezeDialog(context, w.user, unfreeze: frozen);
          case 'adjust':
            showAdjustmentDialog(context, user: w.user);
          case 'user':
            context.go('/users');
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'statement',
          child: Text('View statement', style: TextStyle(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'freeze',
          child: Text(
            frozen ? 'Unfreeze wallet' : 'Freeze wallet',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const PopupMenuItem(
          value: 'adjust',
          child: Text('Request adjustment', style: TextStyle(fontSize: 13)),
        ),
        const PopupMenuItem(
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

Future<void> showFreezeDialog(
  BuildContext context,
  String user, {
  bool unfreeze = false,
}) async {
  final reason = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => _SimpleDialog(
      icon: unfreeze ? Icons.lock_open_rounded : Icons.ac_unit_rounded,
      color: unfreeze ? AppColors.success : AppColors.info,
      title: unfreeze ? 'Unfreeze wallet' : 'Freeze wallet',
      text: unfreeze
          ? '$user will be able to use the wallet again.'
          : 'All money movement in and out of $user\'s wallet stops. Chats and calls keep working.',
      confirm: 'Confirm',
      onConfirm: () => reason.text.trim().length >= 10,
      children: [_ReasonField(reason)],
    ),
  );
  if (ok == true && context.mounted) {
    toast(
      context,
      unfreeze ? 'Wallet unfrozen: $user' : 'Wallet frozen: $user',
    );
  }
}

/// Balance correction request: creates a new ledger entry only after a
/// second authorised admin approves it. Balances are never edited directly.
Future<void> showAdjustmentDialog(BuildContext context, {String? user}) async {
  final reason = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => _AdjustDialog(user: user, reason: reason),
  );
  if (ok == true && context.mounted) {
    toast(context, 'Adjustment request sent for second approval.');
  }
}

class _AdjustDialog extends StatefulWidget {
  const _AdjustDialog({required this.user, required this.reason});
  final String? user;
  final TextEditingController reason;

  @override
  State<_AdjustDialog> createState() => _AdjustDialogState();
}

class _AdjustDialogState extends State<_AdjustDialog> {
  bool _credit = true;

  @override
  Widget build(BuildContext context) {
    return _SimpleDialog(
      icon: Icons.tune_rounded,
      color: AppColors.warning,
      title: 'Request balance adjustment',
      text: 'This does not change the balance now. It creates a correction request that a second authorised admin must approve. The original entries stay unchanged.',
      confirm: 'Submit for Approval',
      onConfirm: () => widget.reason.text.trim().length >= 10,
      children: [
        _LabeledField('Wallet', widget.user ?? 'Account no. or user'),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              label: Text('Credit', style: TextStyle(fontSize: 12)),
            ),
            ButtonSegment(
              value: false,
              label: Text('Debit', style: TextStyle(fontSize: 12)),
            ),
          ],
          selected: {_credit},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _credit = s.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.brandSoft,
            selectedForegroundColor: AppColors.brand,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        const SizedBox(height: 12),
        const _LabeledField('Amount (SFZ)', '0.00'),
        const SizedBox(height: 12),
        const _LabeledField(
          'Related transaction / case reference',
          'TXN-… or DSP-…',
        ),
        const SizedBox(height: 12),
        _ReasonField(widget.reason),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField(this.label, this.hint);
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReasonField extends StatelessWidget {
  const _ReasonField(this.controller);
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Reason (required, at least 10 characters)',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Explain why',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shared dialog frame used by wallet and card actions.
class _SimpleDialog extends StatefulWidget {
  const _SimpleDialog({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
    required this.children,
    required this.confirm,
    required this.onConfirm,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;
  final List<Widget> children;
  final String confirm;
  final bool Function() onConfirm;

  @override
  State<_SimpleDialog> createState() => _SimpleDialogState();
}

class _SimpleDialogState extends State<_SimpleDialog> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 470),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconCircle(
                    icon: widget.icon,
                    color: widget.color,
                    background: widget.color.withValues(alpha: 0.1),
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.children,
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 12, color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlineButtonBox(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 10),
                  PrimaryButton(
                    label: widget.confirm,
                    onTap: () {
                      if (widget.onConfirm()) {
                        Navigator.pop(context, true);
                      } else {
                        setState(
                          () => _error = 'Please give a clear reason (at least 10 characters).',
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletSide extends StatelessWidget {
  const _WalletSide({required this.onAdjust});
  final VoidCallback onAdjust;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.ac_unit_rounded,
        'Freeze Wallet',
        AppColors.info,
        () => showFreezeDialog(context, 'a selected user'),
      ),
      (
        Icons.lock_open_rounded,
        'Unfreeze',
        AppColors.success,
        () => showFreezeDialog(context, 'a selected user', unfreeze: true),
      ),
      (
        Icons.receipt_long_outlined,
        'Statements',
        AppColors.brand,
        () => toast(
          context,
          'Statements download once the backend is connected.',
        ),
      ),
      (Icons.tune_rounded, 'Request Adjustment', AppColors.warning, onAdjust),
      (
        Icons.account_tree_outlined,
        'Trace Funds',
        AppColors.brand,
        () => context.go('/transactions/trace'),
      ),
      (
        Icons.file_download_outlined,
        'Export Balances',
        AppColors.textSecondary,
        () => toast(context, 'Export connects with the backend.'),
      ),
    ];
    const dist = [
      ('Nigeria', 62450.0, AppColors.brand),
      ('Germany', 18745.0, AppColors.success),
      ('United Kingdom', 9850.0, AppColors.info),
      ('United States', 5300.0, AppColors.warning),
      ('Others', 2400.0, AppColors.grey),
    ];
    final total = dist.fold<double>(0, (a, b) => a + b.$2);
    return SideStack(
      children: [
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'Wallet Actions'),
              const SizedBox(height: 12),
              TileGrid(
                minTileWidth: 60,
                maxColumns: 3,
                gap: 8,
                children: [
                  for (final a in actions)
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: a.$4,
                      child: Container(
                        height: 76,
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
              const SizedBox(height: 10),
              const Text(
                'Balances can never be edited directly. Adjustments need a second approval.',
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
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
              const CardHeader(title: 'Wallet Distribution'),
              const SizedBox(height: 14),
              Row(
                children: [
                  DonutChart(
                    values: [for (final d in dist) d.$2],
                    colors: [for (final d in dist) d.$3],
                    centerTop: '98,745',
                    centerBottom: 'Total',
                    size: 112,
                    stroke: 12,
                    fontSize: 17,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        for (final d in dist)
                          LegendRow(
                            color: d.$3,
                            label: d.$1,
                            value:
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
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(
                title: 'Recent Transactions',
                trailing: LinkText(
                  'View All',
                  onTap: () => context.go('/transactions'),
                ),
              ),
              const SizedBox(height: 6),
              const ActivityRow(
                icon: Icons.south_rounded,
                color: AppColors.success,
                title: 'Top-up to John Okafor wallet',
                amount: '+SFZ 5,000',
                time: '2 mins ago',
                amountColor: AppColors.success,
              ),
              const ActivityRow(
                icon: Icons.north_rounded,
                color: AppColors.danger,
                title: 'Transfer to Emily Johnson',
                amount: '-SFZ 2,500',
                time: '10 mins ago',
                amountColor: AppColors.danger,
              ),
              const ActivityRow(
                icon: Icons.north_rounded,
                color: AppColors.danger,
                title: 'Airtime purchase by Michael Uche',
                amount: '-SFZ 100',
                time: '30 mins ago',
                amountColor: AppColors.danger,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
