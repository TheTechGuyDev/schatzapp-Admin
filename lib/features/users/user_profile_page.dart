import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/session.dart';
import '../../data/sample_users.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import 'user_widgets.dart';

/// Administrative profile of one user, with investigation tabs.
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.userId});
  final String userId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

const _tabLabels = [
  'Overview',
  'Devices & Logins',
  'Transactions',
  'Investigation',
  'Admin History',
];

class _UserProfilePageState extends State<UserProfilePage> {
  int _tab = 0;
  final _notes = <InvestigationNote>[
    InvestigationNote(
      'Two users reported unexpected transfer requests. Waiting for chat evidence.',
      'Daniel Ade',
      'Nov 19, 2026 · 15:02',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final u = SampleUsers.byId(widget.userId);
    if (u == null) {
      return PageBody(
        children: [
          AppCard(
            child: Column(
              children: [
                const EmptyState(
                  'This user could not be found.',
                  icon: Icons.person_off_outlined,
                ),
                OutlineButtonBox(
                  label: 'Back to Users',
                  onTap: () => context.go('/users'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      );
    }
    SampleUsers.ensureHistory(u);
    return PageBody(
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => context.go('/users'),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: AppColors.brand,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Users',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              '  /  User Profile',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.infoSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: AppColors.info),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Access to this profile is logged. Sensitive records are only shown to authorised roles.',
                  style: TextStyle(fontSize: 12, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Header(user: u, onChanged: () => setState(() {})),
        const SizedBox(height: 18),
        AppCard(
          padding: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: UnderlineTabs(
                  labels: _tabLabels,
                  selected: _tab,
                  onSelect: (i) => setState(() => _tab = i),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              switch (_tab) {
                0 => _Overview(user: u),
                1 => _Devices(user: u),
                2 => _Transactions(user: u),
                3 => _Investigation(
                  user: u,
                  notes: _notes,
                  onAddNote: (t) => setState(
                    () => _notes.insert(
                      0,
                      InvestigationNote(
                        t,
                        AdminSession.instance.name,
                        'Just now',
                      ),
                    ),
                  ),
                ),
                _ => _History(user: u),
              },
            ],
          ),
        ),
      ],
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.user, required this.onChanged});
  final AdminUser user;
  final VoidCallback onChanged;

  Future<void> _act(BuildContext context, AccountActionKind a) async {
    final ok = await showAccountActionDialog(context, user, a);
    if (ok && context.mounted) {
      onChanged();
      toast(context, '${a.label}: ${user.name}');
    }
  }

  Future<void> _wallet(BuildContext context) async {
    final ok = await showWalletRestrictionDialog(context, user);
    if (ok && context.mounted) {
      onChanged();
      toast(context, 'Wallet settings updated for ${user.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = user;
    final ids = Wrap(
      spacing: 18,
      runSpacing: 6,
      children: [
        _CopyField('User ID', u.id),
        _CopyField('Account no.', u.accountNo),
        _CopyField('SFZ no.', u.sfzNo),
      ],
    );
    final buttons = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (u.status != AccountStatus.deleted)
          OutlineButtonBox(
            label: u.walletRestricted
                ? 'Lift Wallet Restriction'
                : 'Restrict Wallet',
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => _wallet(context),
          ),
        PopupMenuButton<AccountActionKind>(
          tooltip: 'Account actions',
          onSelected: (a) => _act(context, a),
          itemBuilder: (_) => [
            for (final a in actionsFor(u))
              PopupMenuItem(
                value: a,
                child: Row(
                  children: [
                    Icon(
                      a.icon,
                      size: 18,
                      color: a == AccountActionKind.block
                          ? AppColors.danger
                          : AppColors.navText,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      a.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: a == AccountActionKind.block
                            ? AppColors.danger
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.manage_accounts_outlined,
                  size: 17,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Account Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
    return AppCard(
      padding: 20,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 860;
          final info = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(name: u.name, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          u.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        StatusTag(u.status),
                        DotChip('KYC ${u.kyc}', kind: kycKind(u.kyc)),
                        if (u.walletRestricted)
                          const DotChip(
                            'Wallet restricted',
                            kind: ChipKind.warning,
                          ),
                        if (u.flagged)
                          const DotChip(
                            'Under investigation',
                            kind: ChipKind.danger,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${u.username} · ${u.phone}${u.email.isEmpty ? '' : ' · ${u.email}'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ids,
                  ],
                ),
              ),
            ],
          );
          return narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [info, const SizedBox(height: 16), buttons],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 16),
                    buttons,
                  ],
                );
        },
      ),
    );
  }
}

class _CopyField extends StatelessWidget {
  const _CopyField(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        toast(context, '$label copied');
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value.length > 18 ? '${value.substring(0, 18)}…' : value,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.copy_rounded, size: 13, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

// ── Overview ────────────────────────────────────────────────────────────────

class _Overview extends StatelessWidget {
  const _Overview({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final u = user;
    final fields = [
      ('User ID', u.id),
      ('Full name', u.name),
      ('Username', u.username),
      ('Phone number', u.phone),
      ('Email address', u.email.isEmpty ? 'Not provided' : u.email),
      ('Country', u.country),
      ('Registration date', u.joined),
      ('Account status', u.status.label),
      ('Verification status', u.kyc),
      ('Last login', u.lastLogin),
      ('Last active', u.lastActive),
    ];
    final personal = _Section(
      title: 'Personal Account Information',
      child: TileGrid(
        minTileWidth: 220,
        maxColumns: 3,
        gap: 14,
        children: [
          for (final f in fields)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.$1,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  f.$2,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
    final wallet = _Section(
      title: 'Wallet Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            u.balance,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const Text(
            'Schatz balance (internal currency)',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          _kv(
            'Wallet status',
            u.walletRestricted ? 'Restricted' : 'Open',
            color: u.walletRestricted ? AppColors.warning : AppColors.success,
          ),
          _kv('Money in (30d)', 'SFZ 16,750'),
          _kv('Money out (30d)', 'SFZ 17,000'),
          _kv('Failed / reversed (30d)', '2'),
          _kv('Open cases', '1'),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ResponsiveRow(
        flex: const [2, 1],
        gap: 18,
        breakAt: 900,
        children: [personal, wallet],
      ),
    );
  }
}

Widget _kv(String k, String v, {Color? color}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    children: [
      Expanded(
        child: Text(
          k,
          style: const TextStyle(fontSize: 12.5, color: AppColors.navText),
        ),
      ),
      Text(
        v,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.text,
        ),
      ),
    ],
  ),
);

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, trailing: trailing),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Devices & logins ────────────────────────────────────────────────────────

class _Devices extends StatelessWidget {
  const _Devices({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    const cols = [
      Col('Device', 22),
      Col('Operating system', 13),
      Col('App version', 10),
      Col('Device identifier', 14),
      Col('Registered', 12),
      Col('Last login', 13),
      Col('Last logout', 13),
    ];
    final devices = SampleUsers.devices(user);
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Section(
            title: 'Devices',
            trailing: const Text(
              'Identifiers shown only where lawfully collected',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            child: LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth < 760) {
                  return Column(
                    children: [
                      for (final d in devices)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            d.type == 'Web'
                                ? Icons.laptop_rounded
                                : Icons.phone_android_rounded,
                            color: AppColors.brand,
                          ),
                          title: Text(
                            d.model,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            '${d.os} · last login ${d.lastLogin}',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ),
                    ],
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    children: [
                      const TableHead(cols: cols),
                      for (final d in devices)
                        TableLine(
                          cols: cols,
                          cells: [
                            Row(
                              children: [
                                Icon(
                                  d.type == 'Web'
                                      ? Icons.laptop_rounded
                                      : Icons.phone_android_rounded,
                                  size: 18,
                                  color: AppColors.brand,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: TwoLine(d.model, d.type)),
                                if (d.current)
                                  const StatusChip(
                                    'Current',
                                    kind: ChipKind.success,
                                  ),
                              ],
                            ),
                            Text(d.os, style: const TextStyle(fontSize: 12)),
                            Text(
                              d.appVersion,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              d.deviceId,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              d.firstSeen,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              d.lastLogin,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              d.lastLogout,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Login & Security Records',
            child: Column(
              children: [
                for (final l in SampleUsers.logins)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconCircle(
                          icon: l.ok
                              ? Icons.login_rounded
                              : Icons.error_outline_rounded,
                          color: l.ok ? AppColors.success : AppColors.danger,
                          background: l.ok
                              ? AppColors.successSoft
                              : AppColors.dangerSoft,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TwoLine(
                            l.event,
                            '${l.device} · ${l.ip} · ${l.location}',
                          ),
                        ),
                        Text(
                          l.when,
                          style: const TextStyle(
                            fontSize: 11.5,
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
      ),
    );
  }
}

// ── Transactions ────────────────────────────────────────────────────────────

class _Transactions extends StatefulWidget {
  const _Transactions({required this.user});
  final AdminUser user;

  @override
  State<_Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<_Transactions> {
  String _filter = 'All';

  static const _filters = [
    'All',
    'Deposits',
    'Withdrawals',
    'Schatz transfers',
    'Gift cards',
    'Airtime & Data',
    'Pending',
    'Failed',
    'Reversed',
  ];

  bool _keep(UserTx t) => switch (_filter) {
    'Deposits' => t.type == 'Deposit',
    'Withdrawals' => t.type == 'Withdrawal',
    'Schatz transfers' => t.type == 'Schatz transfer',
    'Gift cards' => t.type.startsWith('Gift card'),
    'Airtime & Data' =>
      t.type.startsWith('Airtime') || t.type.startsWith('Data'),
    'Pending' || 'Failed' || 'Reversed' => t.status == _filter,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    const cols = [
      Col('Reference', 14),
      Col('Date & time', 14),
      Col('Type', 14),
      Col('Sender / recipient', 19),
      Col('Provider', 11),
      Col('Amount', 12),
      Col('Status', 10),
      Col('', 7, align: TextAlign.center),
    ];
    final rows = SampleUsers.transactions.where(_keep).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in _filters)
                ChoiceChip(
                  label: Text(f, style: const TextStyle(fontSize: 12)),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppColors.brandSoft,
                  showCheckmark: false,
                  side: const BorderSide(color: AppColors.border),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 15,
                  color: Color(0xFFB45309),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Individual history for investigations only. Company-wide totals are in Reports (Finance roles).',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFFB45309)),
                  ),
                ),
              ],
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, c) {
            if (rows.isEmpty) {
              return const EmptyState('No transactions of this type.');
            }
            if (c.maxWidth < 860) {
              return Column(
                children: [
                  for (final t in rows)
                    Container(
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
                          _DirIcon(t.direction),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TwoLine(t.type, '${t.ref} · ${t.when}'),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _signed(t),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: t.direction == 'in'
                                      ? AppColors.success
                                      : AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              StatusChip(
                                t.status,
                                kind: StatusChip.kindFor(t.status),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }
            return Column(
              children: [
                const TableHead(cols: cols),
                for (final t in rows)
                  TableLine(
                    cols: cols,
                    cells: [
                      Text(
                        t.ref,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(t.when, style: const TextStyle(fontSize: 11.5)),
                      Row(
                        children: [
                          _DirIcon(t.direction),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TwoLine(t.type, t.description, bold: false),
                          ),
                        ],
                      ),
                      Text(
                        t.counterparty,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      Text(t.provider, style: const TextStyle(fontSize: 11.5)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _signed(t),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: t.direction == 'in'
                                  ? AppColors.success
                                  : AppColors.text,
                            ),
                          ),
                          Text(
                            'Fee ${t.fee}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      StatusChip(t.status, kind: StatusChip.kindFor(t.status)),
                      SquareIconButton(
                        icon: Icons.account_tree_outlined,
                        tooltip: 'Trace this transaction',
                        color: AppColors.brand,
                        onTap: () => toast(
                          context,
                          'Transaction Trace opens in Phase 3.',
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
        PaginationBar(
          info: 'Showing 1 to ${rows.length} of ${rows.length} transactions',
          lastPage: 1,
        ),
      ],
    );
  }

  String _signed(UserTx t) => '${t.direction == 'in' ? '+' : '-'}${t.amount}';
}

class _DirIcon extends StatelessWidget {
  const _DirIcon(this.direction);
  final String direction;

  @override
  Widget build(BuildContext context) {
    final incoming = direction == 'in';
    return IconCircle(
      icon: incoming ? Icons.south_west_rounded : Icons.north_east_rounded,
      color: incoming ? AppColors.success : AppColors.danger,
      background: incoming ? AppColors.successSoft : AppColors.dangerSoft,
      size: 28,
    );
  }
}

// ── Investigation ───────────────────────────────────────────────────────────

class _Investigation extends StatefulWidget {
  const _Investigation({
    required this.user,
    required this.notes,
    required this.onAddNote,
  });

  final AdminUser user;
  final List<InvestigationNote> notes;
  final ValueChanged<String> onAddNote;

  @override
  State<_Investigation> createState() => _InvestigationState();
}

class _InvestigationState extends State<_Investigation> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restrictions = widget.user.history
        .where((h) => h.from != '-' && h.to != '-')
        .toList();
    final cases = _Section(
      title: 'Complaints & Disputes',
      trailing: LinkText('Open Disputes', onTap: () => context.go('/disputes')),
      child: Column(
        children: [
          for (final c in SampleUsers.cases)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconCircle(
                    icon: c.kind == 'Dispute'
                        ? Icons.gavel_rounded
                        : Icons.forum_outlined,
                    color: AppColors.brand,
                    background: AppColors.brandSoft,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TwoLine(
                      '${c.ref} · ${c.category}',
                      '${c.kind} · opened ${c.opened} · ${c.assignee}',
                    ),
                  ),
                  StatusChip(
                    c.status,
                    kind: c.status == 'Resolved' || c.status == 'Closed'
                        ? ChipKind.success
                        : ChipKind.warning,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    final previous = _Section(
      title: 'Previous Restrictions & Suspensions',
      child: restrictions.isEmpty
          ? const EmptyState(
              'No previous restrictions.',
              icon: Icons.verified_outlined,
            )
          : Column(
              children: [
                for (final h in restrictions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TwoLine(h.action, '${h.when} · ${h.admin}'),
                        ),
                        Text(
                          '${h.from} → ${h.to}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
    final alerts = _Section(
      title: 'Security Alerts',
      child: Column(
        children: [
          for (final a in SampleUsers.alerts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    a.critical
                        ? Icons.error_outline_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: a.critical ? AppColors.danger : AppColors.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: TwoLine(a.title, a.detail)),
                  Text(
                    a.when,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    final notes = _Section(
      title: 'Investigation Notes',
      trailing: const Text(
        'Notes cannot be edited or deleted',
        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _note,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Add an investigation note',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Add Note',
              icon: Icons.note_add_outlined,
              onTap: () {
                final t = _note.text.trim();
                if (t.isEmpty) return;
                widget.onAddNote(t);
                _note.clear();
              },
            ),
          ),
          const SizedBox(height: 8),
          for (final n in widget.notes)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.text, style: const TextStyle(fontSize: 12.5)),
                  const SizedBox(height: 6),
                  Text(
                    '${n.author} · ${n.when}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          ResponsiveRow(
            flex: const [1, 1],
            gap: 18,
            breakAt: 900,
            children: [cases, alerts],
          ),
          const SizedBox(height: 18),
          ResponsiveRow(
            flex: const [1, 1],
            gap: 18,
            breakAt: 900,
            children: [previous, notes],
          ),
        ],
      ),
    );
  }
}

// ── Admin history ───────────────────────────────────────────────────────────

class _History extends StatelessWidget {
  const _History({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    const cols = [
      Col('Date & time', 13),
      Col('Administrator', 15),
      Col('Action', 18),
      Col('Previous → new', 18),
      Col('Reason', 26),
    ];
    final rows = user.history;
    return LayoutBuilder(
      builder: (context, c) {
        if (rows.isEmpty) {
          return const EmptyState('No administrative actions yet.');
        }
        if (c.maxWidth < 860) {
          return Column(
            children: [
              for (final h in rows)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.action,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${h.when} · ${h.admin} (${h.role})',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(h.reason, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
            ],
          );
        }
        return Column(
          children: [
            const TableHead(cols: cols),
            for (final h in rows)
              TableLine(
                cols: cols,
                cells: [
                  Text(h.when, style: const TextStyle(fontSize: 11.5)),
                  TwoLine(h.admin, h.role),
                  Text(
                    h.action,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${h.from} → ${h.to}',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  Text(
                    h.reason,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.navText,
                    ),
                  ),
                ],
              ),
            const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'History is permanent. Admins cannot edit or delete entries.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
