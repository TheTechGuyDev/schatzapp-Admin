import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/kit.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Roles & Permissions (approved design): the client's role set (Super
/// Administrator, Administrator and the specialised roles), a permission
/// matrix per role, admin accounts, and Super Admin promotion requests that
/// need two other Super Admins to approve.
class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _Role {
  const _Role(
    this.name,
    this.description,
    this.users,
    this.icon,
    this.color, {
    this.system = false,
    this.active = true,
    this.noFinance = false,
  });

  final String name;
  final String description;
  final int users;
  final IconData icon;
  final Color color;
  final bool system;
  final bool active;

  /// Never sees company-wide financial figures.
  final bool noFinance;
}

const _roles = [
  _Role(
    'Super Administrator',
    'Full control. Changes to Super Admins need two approvals.',
    2,
    Icons.shield_rounded,
    AppColors.brand,
    system: true,
  ),
  _Role(
    'Administrator',
    'Only the sections assigned by a Super Admin',
    5,
    Icons.admin_panel_settings_outlined,
    AppColors.info,
    system: true,
    noFinance: true,
  ),
  _Role(
    'User Management',
    'Users, search, account info and restrictions',
    4,
    Icons.manage_accounts_outlined,
    AppColors.teal,
    noFinance: true,
  ),
  _Role(
    'Customer Support',
    'Complaints, tickets and status updates',
    12,
    Icons.headset_mic_outlined,
    AppColors.warning,
    noFinance: true,
  ),
  _Role(
    'Investigation',
    'User transactions, devices, tracing and notes',
    3,
    Icons.manage_search_rounded,
    Color(0xFF7C3AED),
    noFinance: true,
  ),
  _Role(
    'Finance',
    'Financial reports, providers and reconciliation',
    4,
    Icons.account_balance_outlined,
    AppColors.success,
  ),
  _Role(
    'Gift Card',
    'Gift card purchases, loading and complaints',
    2,
    Icons.card_giftcard_rounded,
    AppColors.pink,
    noFinance: true,
  ),
  _Role(
    'KYC & Verification',
    'Review, approve or reject verifications',
    6,
    Icons.verified_user_outlined,
    AppColors.danger,
    noFinance: true,
  ),
  _Role(
    'Technical',
    'System health, API connections and errors',
    2,
    Icons.dns_outlined,
    AppColors.info,
    noFinance: true,
  ),
  _Role(
    'Compliance',
    'Compliance cases, legal holds and retention',
    2,
    Icons.gavel_rounded,
    AppColors.warning,
    noFinance: true,
  ),
  _Role(
    'Read-Only',
    'Views permitted sections only, changes nothing',
    7,
    Icons.visibility_outlined,
    AppColors.grey,
    system: true,
    active: false,
    noFinance: true,
  ),
];

/// Permission groups shown in the role editor (key, label, permissions).
const _permissionGroups = [
  (
    'User Management',
    AppColors.brand,
    [
      'View users',
      'Search users',
      'View user profiles',
      'Restrict accounts',
      'Suspend accounts',
      'Block accounts',
      'Flag for investigation',
      'Approve name changes',
      'View devices & logins',
      'Add investigation notes',
      'View investigation records',
      'Export user lists',
    ],
  ),
  (
    'Transactions',
    AppColors.info,
    [
      'View individual transactions',
      'Transaction Trace',
      'Restrict wallets',
      'Request wallet adjustment',
      'Approve wallet adjustment',
      'Confirm bank deposits',
      'View cards',
      'View airtime & data',
      'View gift cards',
      'View unloaded gift cards',
    ],
  ),
  (
    'Financial',
    AppColors.success,
    [
      'View company deposits',
      'View finance overview',
      'View funds flow',
      'Run reconciliation',
      'View providers',
      'Record provider funding',
      'View annual reports',
      'Change fees & limits',
    ],
  ),
  (
    'Content Management',
    AppColors.warning,
    [
      'Review reported content',
      'Remove content',
      'Handle disputes',
      'Handle support tickets',
      'Send notifications',
      'Manage templates',
    ],
  ),
  (
    'System Settings',
    AppColors.pink,
    [
      'View settings',
      'Change general settings',
      'Change security settings',
      'Manage countries',
      'Manage integrations',
      'Maintenance mode',
      'Legal holds & retention',
    ],
  ),
  (
    'Reports & Analytics',
    AppColors.teal,
    [
      'View dashboard',
      'View reports',
      'Export reports',
      'View audit logs',
      'Export audit logs',
    ],
  ),
];

class _RolesPageState extends State<RolesPage> {
  int _tab = 0;
  String _q = '';

  Future<void> _editRole(_Role? role) async {
    final name = TextEditingController(text: role?.name ?? '');
    final selected = <String>{
      if (role != null)
        for (final g in _permissionGroups)
          for (final (i, p) in g.$3.indexed)
            if (role.name == 'Super Administrator' ||
                (g.$1 == 'Financial' ? !role.noFinance : i.isEven))
              p,
    };
    final superRole = role?.name == 'Super Administrator';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text(
            role == null ? 'Create role' : 'Edit ${role.name}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 640,
            height: 520,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldBlock(
                  'Role name',
                  TextField(
                    controller: name,
                    enabled: role?.system != true,
                    style: const TextStyle(fontSize: 13),
                    decoration: fieldDecoration('e.g. Night Support'),
                  ),
                ),
                if (superRole)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: SampleNote(
                      'Super Administrator permissions cannot be edited. '
                      'Changes to Super Admins go through dual approval.',
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final g in _permissionGroups) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: g.$2,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                g.$1,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (g.$1 == 'Financial') ...[
                                const SizedBox(width: 8),
                                const TintTag(
                                  'Super Admin approval',
                                  AppColors.warning,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            for (final p in g.$3)
                              SizedBox(
                                width: 290,
                                child: CheckboxListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  activeColor: AppColors.brand,
                                  value: selected.contains(p),
                                  onChanged: superRole
                                      ? null
                                      : (v) => set(
                                          () => v == true
                                              ? selected.add(p)
                                              : selected.remove(p),
                                        ),
                                  title: Text(
                                    p,
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
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
            if (!superRole)
              PrimaryButton(
                label: role == null ? 'Create role' : 'Save changes',
                onTap: () {
                  if (name.text.trim().isNotEmpty) Navigator.pop(ctx, true);
                },
              ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      toast(context, role == null ? 'Role created' : 'Permissions updated');
    }
  }

  Future<void> _newAdmin() async {
    final name = TextEditingController();
    final email = TextEditingController();
    var role = 'Customer Support';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text(
            'Create administrator',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldBlock(
                  'Full name',
                  TextField(
                    controller: name,
                    style: const TextStyle(fontSize: 13),
                    decoration: fieldDecoration('Full name'),
                  ),
                ),
                FieldBlock(
                  'Work email',
                  TextField(
                    controller: email,
                    style: const TextStyle(fontSize: 13),
                    decoration: fieldDecoration('name@schatzapp.com'),
                  ),
                ),
                FieldBlock(
                  'Role',
                  DropField(
                    value: role,
                    options: [
                      for (final r in _roles)
                        if (r.name != 'Super Administrator') r.name,
                    ],
                    onChanged: (v) => set(() => role = v),
                  ),
                ),
                const SampleNote(
                  'They get an invite email, set a password and must enrol '
                  'an authenticator app before first sign-in. Super Admin '
                  'can never be given here: use a promotion request.',
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
              label: 'Send invite',
              onTap: () {
                if (name.text.trim().isNotEmpty && email.text.contains('@')) {
                  Navigator.pop(ctx, true);
                }
              },
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) toast(context, 'Invite sent');
  }

  Future<void> _requestPromotion(String who) async {
    final reason = await askReason(
      context,
      title: 'Request Super Admin promotion',
      message:
          '$who will become a Super Administrator only after two other '
          'Super Admins approve with their password and authenticator code. '
          'The request expires in 48 hours.',
      confirm: 'Continue',
    );
    if (reason == null || !mounted) return;
    final ok = await askSecurity(
      context,
      title: 'Verify it is you',
      message:
          'Your password and authenticator code are needed to create '
          'the request.',
    );
    if (ok && mounted) {
      toast(context, 'Promotion request sent to all Super Admins');
    }
  }

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
              label: 'Total Roles',
              value: '11',
              change: '3 system roles',
              icon: Icons.shield_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
            ),
            StatCard(
              label: 'Active Roles',
              value: '10',
              change: 'currently active',
              icon: Icons.person_outline_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
            ),
            StatCard(
              label: 'Total Permissions',
              value: '48',
              change: 'system permissions',
              icon: Icons.key_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
            ),
            StatCard(
              label: 'Admin Accounts',
              value: '49',
              change: '2 Super Admins',
              icon: Icons.badge_outlined,
              color: AppColors.info,
              background: AppColors.infoSoft,
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(
          main: switch (_tab) {
            1 => _admins(),
            2 => _requests(),
            _ => _rolesTable(),
          },
          side: SideStack(
            children: [
              const DonutCard(
                title: 'Permissions Overview',
                subtitle: 'System permission categories',
                centerTop: '48',
                centerBottom: 'Total',
                items: [
                  ('User Management', 12, AppColors.brand),
                  ('Transactions', 10, AppColors.info),
                  ('Financial', 8, AppColors.success),
                  ('Content Management', 6, AppColors.warning),
                  ('System Settings', 7, AppColors.pink),
                  ('Reports & Analytics', 5, AppColors.teal),
                ],
              ),
              const SizedBox(height: 18),
              AppCard(
                padding: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CardHeader(title: 'Recent Changes'),
                    const SizedBox(height: 6),
                    for (final c in const [
                      ('New role "Night Support" created', '2h ago'),
                      ('Permissions updated for Finance', '5h ago'),
                      ('Role "Read-Only" deactivated', '1d ago'),
                      ('Michael Uche moved to Investigation', '2d ago'),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            const TintIcon(
                              Icons.tune_rounded,
                              AppColors.brand,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: TwoLine(c.$1, 'by Kesta Wealth')),
                            Text(
                              c.$2,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlineButtonBox(
                      label: 'View Audit Logs',
                      icon: Icons.assignment_outlined,
                      onTap: () => context.go('/audit-logs'),
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

  static const _tabs = ['Roles', 'Admin Accounts', 'Super Admin Requests (1)'];

  Widget _rolesTable() {
    final rows = _roles
        .where((r) => _q.isEmpty || r.name.toLowerCase().contains(_q))
        .toList();
    return TableCard(
      tabs: _tabs,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      toolbar: [
        PrimaryButton(
          label: 'Create Role',
          icon: Icons.add,
          onTap: () => _editRole(null),
        ),
      ],
      filters: [
        SearchBox(
          hint: 'Search roles...',
          width: 260,
          onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
        ),
      ],
      checkbox: false,
      cols: const [
        Col('Role Name', 24),
        Col('Description', 26),
        Col('Users', 7),
        Col('Company finances', 12),
        Col('Status', 9),
        Col('Actions', 10, align: TextAlign.center),
      ],
      onRowTap: (i) => _editRole(rows[i]),
      rows: [
        for (final r in rows)
          [
            Row(
              children: [
                TintIcon(r.icon, r.color, size: 34),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    r.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                TintTag(
                  r.system ? 'System' : 'Custom',
                  r.system ? AppColors.brand : AppColors.warning,
                ),
              ],
            ),
            Text(
              r.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5),
            ),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text('${r.users}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            r.noFinance
                ? const TintTag('Hidden', AppColors.grey)
                : const TintTag('Allowed', AppColors.success),
            StatusChip(
              r.active ? 'Active' : 'Inactive',
              kind: r.active ? ChipKind.success : ChipKind.neutral,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit permissions',
                  onTap: () => _editRole(r),
                ),
                const SizedBox(width: 6),
                RowMenu(
                  items: [
                    ('users', 'View members', false),
                    if (!r.system) ('dup', 'Duplicate', false),
                    if (!r.system && r.users == 0)
                      ('delete', 'Delete role', true),
                    if (r.name != 'Super Administrator')
                      (
                        'toggle',
                        r.active ? 'Deactivate' : 'Activate',
                        r.active,
                      ),
                  ],
                  onSelected: (v) => v == 'users'
                      ? setState(() => _tab = 1)
                      : toast(context, 'Done'),
                ),
              ],
            ),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: TintIcon(rows[i].icon, rows[i].color),
        title: rows[i].name,
        subtitle: '${rows[i].users} admins',
        trailing: StatusChip(
          rows[i].active ? 'Active' : 'Inactive',
          kind: rows[i].active ? ChipKind.success : ChipKind.neutral,
        ),
      ),
      footerNote:
          'Permissions are enforced by the server. Hiding a menu item is '
          'never the only protection.',
      pageInfo: 'Showing 1 to ${rows.length} of ${_roles.length} roles',
    );
  }

  Widget _admins() {
    const admins = [
      (
        'Kesta Wealth',
        'kesta@schatzapp.com',
        'Super Administrator',
        'Online',
        'Authenticator + backup codes',
      ),
      (
        'Ada Nwosu',
        'ada@schatzapp.com',
        'Super Administrator',
        '2h ago',
        'Authenticator + security key',
      ),
      (
        'Michael Uche',
        'michael@schatzapp.com',
        'Investigation',
        '12m ago',
        'Authenticator',
      ),
      (
        'Sarah Johnson',
        'sarah@schatzapp.com',
        'Customer Support',
        'Online',
        'Authenticator',
      ),
      (
        'Linda Emmanuel',
        'linda@schatzapp.com',
        'Customer Support',
        '1h ago',
        'Authenticator',
      ),
      (
        'James Wilson',
        'james@schatzapp.com',
        'Finance',
        'Yesterday',
        'Authenticator',
      ),
      ('Bola Ade', 'bola@schatzapp.com', 'Technical', '3d ago', 'Not enrolled'),
    ];
    return TableCard(
      tabs: _tabs,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      toolbar: [
        PrimaryButton(
          label: 'Create Admin',
          icon: Icons.person_add_alt_1_outlined,
          onTap: _newAdmin,
        ),
      ],
      checkbox: false,
      cols: const [
        Col('Administrator', 24),
        Col('Role', 16),
        Col('Last active', 11),
        Col('Sign-in protection', 20),
        Col('', 6, align: TextAlign.center),
      ],
      rows: [
        for (final a in admins)
          [
            Row(
              children: [
                Avatar(name: a.$1, size: 30, online: a.$4 == 'Online'),
                const SizedBox(width: 8),
                Expanded(child: TwoLine(a.$1, a.$2)),
              ],
            ),
            TintTag(
              a.$3,
              a.$3 == 'Super Administrator' ? AppColors.brand : AppColors.info,
            ),
            Text(a.$4, style: const TextStyle(fontSize: 12)),
            Row(
              children: [
                Icon(
                  a.$5 == 'Not enrolled'
                      ? Icons.gpp_bad_outlined
                      : Icons.verified_user_outlined,
                  size: 15,
                  color: a.$5 == 'Not enrolled'
                      ? AppColors.danger
                      : AppColors.success,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(a.$5, style: const TextStyle(fontSize: 11.5)),
                ),
              ],
            ),
            RowMenu(
              items: [
                ('role', 'Change role', false),
                if (a.$3 != 'Super Administrator')
                  ('promote', 'Request Super Admin promotion', false),
                if (a.$3 == 'Super Administrator')
                  ('demote', 'Request Super Admin removal', true),
                ('reset', 'Reset authenticator', false),
                ('disable', 'Disable account', true),
              ],
              onSelected: (v) async {
                if (v == 'promote') {
                  _requestPromotion(a.$1);
                } else if (v == 'demote') {
                  final r = await askReason(
                    context,
                    title: 'Request Super Admin removal',
                    message:
                        'Removing ${a.$1} needs approval from two other '
                        'Super Admins.',
                    confirm: 'Create request',
                    danger: true,
                  );
                  if (r != null && mounted) toast(context, 'Request created');
                } else {
                  final r = await askReason(
                    context,
                    title: switch (v) {
                      'role' => 'Change role',
                      'reset' => 'Reset authenticator',
                      _ => 'Disable admin account',
                    },
                    message: '${a.$1} (${a.$3}).',
                    danger: v == 'disable',
                  );
                  if (r != null && mounted) toast(context, 'Done');
                }
              },
            ),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: Avatar(name: admins[i].$1, size: 36),
        title: admins[i].$1,
        subtitle: admins[i].$3,
        trailing: Text(admins[i].$4, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _requests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableCard(
          tabs: _tabs,
          tab: _tab,
          onTab: (i) => setState(() => _tab = i),
          checkbox: false,
          cols: const [
            Col('Request', 24),
            Col('Requested by', 14),
            Col('Approvals', 16),
            Col('Expires', 11),
            Col('Status', 12),
            Col('', 10, align: TextAlign.center),
          ],
          rows: [
            [
              const TwoLine('Promote Michael Uche', 'to Super Administrator'),
              const Text('Kesta Wealth', style: TextStyle(fontSize: 12)),
              const _ApprovalDots(done: 1, of: 2),
              const Text('in 41 hours', style: TextStyle(fontSize: 12)),
              const StatusChip('Pending', kind: ChipKind.warning),
              PrimaryButton(
                label: 'Review',
                onTap: () => context.go('/settings?tab=approvals'),
              ),
            ],
            const [
              TwoLine('Remove Super Admin', 'Former admin: Tunde Bakare'),
              Text('Ada Nwosu', style: TextStyle(fontSize: 12)),
              _ApprovalDots(done: 2, of: 2),
              Text('—', style: TextStyle(fontSize: 12)),
              StatusChip('Approved', kind: ChipKind.success),
              SizedBox(),
            ],
            const [
              TwoLine('Promote Bola Ade', 'to Super Administrator'),
              Text('Kesta Wealth', style: TextStyle(fontSize: 12)),
              _ApprovalDots(done: 0, of: 2),
              Text('Expired Nov 12', style: TextStyle(fontSize: 12)),
              StatusChip('Expired', kind: ChipKind.neutral),
              SizedBox(),
            ],
          ],
          narrowRow: (i) => NarrowRow(
            leading: const TintIcon(Icons.shield_rounded, AppColors.brand),
            title: const [
              'Promote Michael Uche',
              'Remove Super Admin',
              'Promote Bola Ade',
            ][i],
            subtitle: const ['1 of 2 approvals', 'Approved', 'Expired'][i],
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          footerNote:
              'Rules: two different Super Admins must approve, nobody can '
              'approve their own request or approve twice, requests expire '
              'after 48 hours, and every attempt (including failed ones) is '
              'logged.',
        ),
      ],
    );
  }
}

class _ApprovalDots extends StatelessWidget {
  const _ApprovalDots({required this.done, required this.of});

  final int done;
  final int of;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < of; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              i < done ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color: i < done ? AppColors.success : AppColors.grey,
            ),
          ),
        const SizedBox(width: 4),
        Text('$done of $of', style: const TextStyle(fontSize: 11.5)),
      ],
    );
  }
}
