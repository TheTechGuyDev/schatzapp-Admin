import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sample_users.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import 'user_widgets.dart';

/// Users: separate lists per account status, search by account number,
/// SFZ number, username, email, phone or user ID.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

const _tabs = <AccountStatus?>[
  null,
  AccountStatus.active,
  AccountStatus.inactive,
  AccountStatus.blocked,
  AccountStatus.restricted,
  AccountStatus.suspended,
  AccountStatus.deleted,
];

const _searchFields = [
  'All fields',
  'SchatzApp account no.',
  'SFZ account no.',
  'Username',
  'Email',
  'Phone number',
  'User ID',
];

class _UsersPageState extends State<UsersPage> {
  int _tab = 0;
  String _q = '';
  String _field = _searchFields.first;
  int _page = 1;

  List<AdminUser> get _rows {
    final status = _tabs[_tab];
    return SampleUsers.all.where((u) {
      if (status != null && u.status != status) return false;
      if (_q.isEmpty) return true;
      final q = _q.toLowerCase();
      return switch (_field) {
        'SchatzApp account no.' => u.accountNo.toLowerCase().contains(q),
        'SFZ account no.' => u.sfzNo.toLowerCase().contains(q),
        'Username' => u.username.toLowerCase().contains(q),
        'Email' => u.email.toLowerCase().contains(q),
        'Phone number' =>
          u.phone.replaceAll(' ', '').contains(q.replaceAll(' ', '')),
        'User ID' => u.id.toLowerCase().contains(q),
        _ => u.matches(q),
      };
    }).toList();
  }

  int _count(AccountStatus? s) => s == null
      ? SampleUsers.all.length
      : SampleUsers.all.where((u) => u.status == s).length;

  Future<void> _act(AdminUser u, AccountActionKind a) async {
    final ok = await showAccountActionDialog(context, u, a);
    if (ok && mounted) {
      setState(() {});
      toast(context, '${a.label}: ${u.name}');
    }
  }

  Future<void> _wallet(AdminUser u) async {
    final ok = await showWalletRestrictionDialog(context, u);
    if (ok && mounted) {
      setState(() {});
      toast(context, 'Wallet settings updated for ${u.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        const _UserStatCards(),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final table = _tableCard();
            const side = _UsersSide();
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
                const Expanded(flex: 16, child: side),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _tableCard() {
    final rows = _rows;
    return AppCard(
      padding: 0,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 820;
          final search = SizedBox(
            width: narrow ? c.maxWidth - 36 : 420,
            child: Row(
              children: [
                PopupMenuButton<String>(
                  tooltip: 'Search by',
                  onSelected: (v) => setState(() => _field = v),
                  itemBuilder: (_) => [
                    for (final f in _searchFields)
                      PopupMenuItem(
                        value: f,
                        child: Text(f, style: const TextStyle(fontSize: 13)),
                      ),
                  ],
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _field == _searchFields.first
                              ? 'All fields'
                              : _field.split(' ').first,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      onChanged: (v) => setState(() {
                        _q = v.trim();
                        _page = 1;
                      }),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: _field == _searchFields.first
                            ? 'Name, account no., SFZ, phone, email or ID'
                            : 'Search by $_field',
                        hintStyle: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(8),
                          ),
                          borderSide: BorderSide(
                            color: AppColors.brand,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          const tools = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlineButtonBox(
                label: 'Filters',
                icon: Icons.filter_alt_outlined,
              ),
              OutlineButtonBox(
                label: 'Export',
                icon: Icons.file_download_outlined,
                trailingChevron: true,
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: UnderlineTabs(
                  labels: [
                    for (final t in _tabs)
                      '${t == null ? 'All' : t.label} (${_count(t)})',
                  ],
                  selected: _tab,
                  onSelect: (i) => setState(() {
                    _tab = i;
                    _page = 1;
                  }),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.all(18),
                child: narrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [search, const SizedBox(height: 12), tools],
                      )
                    : Row(children: [search, const Spacer(), tools]),
              ),
              if (rows.isEmpty)
                const EmptyState(
                  'No users match this list or search.',
                  icon: Icons.person_search_outlined,
                )
              else if (narrow)
                for (final u in rows) _UserTile(u, onOpen: () => _open(u))
              else ...[
                const TableHead(cols: _cols, checkbox: true),
                for (final u in rows)
                  TableLine(
                    cols: _cols,
                    checkbox: true,
                    onTap: () => _open(u),
                    cells: [
                      Row(
                        children: [
                          Avatar(name: u.name, size: 34),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TwoLine(
                              u.name,
                              u.email.isEmpty ? u.username : u.email,
                            ),
                          ),
                        ],
                      ),
                      TwoLine(u.accountNo, u.sfzNo, bold: false),
                      Text(u.phone, style: const TextStyle(fontSize: 12)),
                      CountryTag(u.countryCode, u.country),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          StatusTag(u.status),
                          if (u.walletRestricted)
                            const Tooltip(
                              message: 'Wallet restricted',
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 16,
                                color: AppColors.warning,
                              ),
                            ),
                          if (u.flagged)
                            const Tooltip(
                              message: 'Flagged for investigation',
                              child: Icon(
                                Icons.flag_rounded,
                                size: 16,
                                color: AppColors.danger,
                              ),
                            ),
                        ],
                      ),
                      DotChip(u.kyc, kind: kycKind(u.kyc)),
                      TwoLine(u.lastActive, 'Joined ${u.joined}', bold: false),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SquareIconButton(
                            icon: Icons.visibility_outlined,
                            tooltip: 'View profile',
                            onTap: () => _open(u),
                          ),
                          const SizedBox(width: 6),
                          _ActionsMenu(
                            user: u,
                            onAction: _act,
                            onWallet: _wallet,
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
              PaginationBar(
                info: 'Showing 1 to ${rows.length} of ${rows.length} results',
                lastPage: 1,
                page: _page,
                onPage: (p) => setState(() => _page = p),
              ),
            ],
          );
        },
      ),
    );
  }

  void _open(AdminUser u) => context.go('/users/${u.id}');
}

const _cols = [
  Col('User', 24),
  Col('Account no.', 14),
  Col('Phone', 14),
  Col('Country', 12),
  Col('Status', 12),
  Col('KYC', 10),
  Col('Last active', 12),
  Col('Actions', 9, align: TextAlign.center),
];

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({
    required this.user,
    required this.onAction,
    required this.onWallet,
  });

  final AdminUser user;
  final Future<void> Function(AdminUser, AccountActionKind) onAction;
  final Future<void> Function(AdminUser) onWallet;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Object>(
      tooltip: 'More actions',
      onSelected: (v) {
        if (v is AccountActionKind) onAction(user, v);
        if (v == 'wallet') onWallet(user);
        if (v == 'open') context.go('/users/${user.id}');
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'open',
          child: _MenuRow(Icons.person_outline, 'View profile'),
        ),
        const PopupMenuDivider(),
        for (final a in actionsFor(user))
          PopupMenuItem(
            value: a,
            child: _MenuRow(
              a.icon,
              a.label,
              color: a == AccountActionKind.block ? AppColors.danger : null,
            ),
          ),
        if (user.status != AccountStatus.deleted)
          PopupMenuItem(
            value: 'wallet',
            child: _MenuRow(
              Icons.account_balance_wallet_outlined,
              user.walletRestricted
                  ? 'Lift wallet restriction'
                  : 'Restrict wallet',
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

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label, {this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.navText),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: color ?? AppColors.text),
        ),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile(this.u, {required this.onOpen});
  final AdminUser u;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Avatar(name: u.name, size: 38),
            const SizedBox(width: 10),
            Expanded(child: TwoLine(u.name, '${u.accountNo} · ${u.country}')),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusTag(u.status),
                const SizedBox(height: 4),
                Text(
                  u.lastActive,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserStatCards extends StatelessWidget {
  const _UserStatCards();

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
          label: 'Active (30d)',
          value: '7,842',
          change: '4.1% vs last month',
          icon: Icons.bolt_rounded,
          color: AppColors.success,
          background: AppColors.successSoft,
          spark: [6.9, 7.1, 7.0, 7.3, 7.4, 7.6, 7.7, 7.84],
        ),
        StatCard(
          label: 'Restricted',
          value: '87',
          change: '3.2% vs last week',
          icon: Icons.lock_outline_rounded,
          color: AppColors.warning,
          background: AppColors.warningSoft,
          positive: false,
          spark: [70, 74, 72, 79, 81, 80, 84, 87],
        ),
        StatCard(
          label: 'Suspended',
          value: '42',
          change: '1.5% vs last week',
          icon: Icons.pause_circle_outline_rounded,
          color: AppColors.pink,
          background: AppColors.pinkSoft,
          positive: false,
          spark: [38, 40, 39, 41, 40, 43, 41, 42],
        ),
        StatCard(
          label: 'Blocked',
          value: '19',
          change: '0.0% vs last week',
          icon: Icons.block_rounded,
          color: AppColors.danger,
          background: AppColors.dangerSoft,
          spark: [19, 19, 18, 19, 19, 19, 19, 19],
        ),
      ],
    );
  }
}

class _UsersSide extends StatelessWidget {
  const _UsersSide();

  @override
  Widget build(BuildContext context) {
    const data = [
      ('Active', 7842.0, AppColors.success),
      ('Inactive', 4334.0, AppColors.grey),
      ('Restricted', 87.0, AppColors.warning),
      ('Suspended', 42.0, AppColors.pink),
      ('Blocked', 19.0, AppColors.danger),
      ('Deleted', 156.0, Color(0xFFD1D5DB)),
    ];
    final total = data.fold<double>(0, (a, b) => a + b.$2);
    return SideStack(
      children: [
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'Account Status'),
              const SizedBox(height: 14),
              Center(
                child: DonutChart(
                  values: [for (final d in data) d.$2],
                  colors: [for (final d in data) d.$3],
                  centerTop: '${(data.first.$2 / total * 100).round()}%',
                  centerBottom: 'Active',
                  size: 130,
                  stroke: 14,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              for (final d in data)
                LegendRow(color: d.$3, label: d.$1, value: groupDigits(d.$2)),
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
                title: 'Recent Account Actions',
                trailing: LinkText(
                  'View All',
                  onTap: () => context.go('/audit-logs'),
                ),
              ),
              const SizedBox(height: 8),
              for (final a in const [
                (
                  Icons.lock_outline_rounded,
                  AppColors.warning,
                  'Sarah Collins wallet restricted',
                  '2h ago',
                ),
                (
                  Icons.pause_circle_outline_rounded,
                  AppColors.pink,
                  'Olivia Anderson suspended',
                  '1d ago',
                ),
                (
                  Icons.flag_outlined,
                  AppColors.danger,
                  'Kwame Mensah flagged',
                  '3d ago',
                ),
                (
                  Icons.lock_open_rounded,
                  AppColors.success,
                  'Ada Obi restored',
                  '4d ago',
                ),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(a.$1, size: 18, color: a.$2),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a.$3,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        a.$4,
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
      ],
    );
  }
}
