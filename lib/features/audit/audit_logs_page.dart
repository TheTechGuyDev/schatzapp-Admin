import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/kit.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Audit Logs (approved design): every admin action with who, role, what,
/// when, IP, device, previous and new value, reason and related records.
/// Append-only: nobody (Super Admin included) can edit or delete entries,
/// and each entry is chained to the previous one so tampering is visible.
class AuditLogsPage extends StatefulWidget {
  const AuditLogsPage({super.key});

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _Log {
  const _Log({
    required this.time,
    required this.admin,
    required this.role,
    required this.action,
    required this.actionSub,
    required this.icon,
    required this.color,
    required this.module,
    required this.description,
    required this.detail,
    required this.ip,
    required this.location,
    required this.device,
    required this.status,
    this.before,
    this.after,
    this.reason,
    this.user,
    this.txn,
  });

  final String time;
  final String admin;
  final String role;
  final String action;
  final String actionSub;
  final IconData icon;
  final Color color;
  final String module;
  final String description;
  final String detail;
  final String ip;
  final String location;
  final String device;
  final String status;
  final String? before;
  final String? after;
  final String? reason;
  final String? user;
  final String? txn;
}

const _logs = [
  _Log(
    time: 'Nov 27, 2026 10:30:45 AM',
    admin: 'Kesta Wealth',
    role: 'Super Administrator',
    action: 'Created Admin',
    actionSub: 'New admin invited',
    icon: Icons.person_add_alt_outlined,
    color: AppColors.success,
    module: 'Roles & Permissions',
    description: 'Invited "Bola Ade" as Technical',
    detail: 'Admin ID: ADM-000124',
    ip: '197.210.45.12',
    location: 'Lagos, NG',
    device: 'Chrome 131 · Windows 11',
    status: 'Success',
    after: 'role = Technical',
    reason: 'New hire for infrastructure monitoring',
  ),
  _Log(
    time: 'Nov 27, 2026 10:15:22 AM',
    admin: 'Emily Johnson',
    role: 'KYC & Verification',
    action: 'Updated KYC Status',
    actionSub: 'User KYC approved',
    icon: Icons.verified_outlined,
    color: AppColors.success,
    module: 'KYC Verification',
    description: 'Approved KYC for "David Brown"',
    detail: 'KYC ID: KYC-000987',
    ip: '41.88.23.67',
    location: 'Abuja, NG',
    device: 'Edge 131 · Windows 10',
    status: 'Success',
    before: 'kyc_status = pending',
    after: 'kyc_status = verified',
    reason: 'ID and selfie match, address proof valid',
    user: 'SCZ-1003-9921',
  ),
  _Log(
    time: 'Nov 27, 2026 09:58:11 AM',
    admin: 'Michael Uche',
    role: 'Investigation',
    action: 'Viewed Investigation',
    actionSub: 'Opened investigation profile',
    icon: Icons.manage_search_rounded,
    color: AppColors.brand,
    module: 'Users',
    description: 'Opened investigation tab of "John Okafor"',
    detail: 'Case: DSP-2026-00412',
    ip: '105.112.45.89',
    location: 'Abuja, NG',
    device: 'Chrome 131 · macOS',
    status: 'Success',
    user: 'SCZ-1004-2231',
  ),
  _Log(
    time: 'Nov 27, 2026 09:32:08 AM',
    admin: 'Linda Emmanuel',
    role: 'Customer Support',
    action: 'Requested Adjustment',
    actionSub: 'Wallet credit requested',
    icon: Icons.account_balance_wallet_outlined,
    color: AppColors.warning,
    module: 'Wallets',
    description: 'Requested SFZ 2,000 refund for "James Wilson"',
    detail: 'Awaiting Finance approval',
    ip: '197.210.45.12',
    location: 'Lagos, NG',
    device: 'Chrome 131 · Windows 11',
    status: 'Pending',
    after: 'adjustment_request = +SFZ 2,000',
    reason: 'Airtime failed at Reloadly (RLD-88310021)',
    user: 'SCZ-1000-8812',
    txn: 'AIR-2026-90114',
  ),
  _Log(
    time: 'Nov 27, 2026 09:10:55 AM',
    admin: 'James Wilson',
    role: 'Finance',
    action: 'Viewed Finance Report',
    actionSub: 'Finance Overview opened',
    icon: Icons.insert_chart_outlined_rounded,
    color: AppColors.info,
    module: 'Reports',
    description: 'Viewed November Finance Overview',
    detail: 'Company-wide figures',
    ip: '102.88.15.90',
    location: 'Port Harcourt, NG',
    device: 'Safari 18 · macOS',
    status: 'Success',
  ),
  _Log(
    time: 'Nov 27, 2026 08:45:31 AM',
    admin: 'Sarah Johnson',
    role: 'Customer Support',
    action: 'Restricted Wallet',
    actionSub: 'Outgoing transfers blocked',
    icon: Icons.lock_outline_rounded,
    color: AppColors.danger,
    module: 'Wallets',
    description: 'Restricted wallet of "David Brown"',
    detail: 'Wallet ID: WAL-000321',
    ip: '41.89.23.67',
    location: 'London, UK',
    device: 'Chrome 131 · Windows 11',
    status: 'Success',
    before: 'wallet_status = active',
    after: 'wallet_status = restricted_out',
    reason: 'Suspected account takeover (DSP-2026-00410)',
    user: 'SCZ-1003-9921',
  ),
  _Log(
    time: 'Nov 27, 2026 08:21:44 AM',
    admin: 'Unknown',
    role: '—',
    action: 'Failed Login Attempt',
    actionSub: 'Invalid authenticator code',
    icon: Icons.gpp_bad_outlined,
    color: AppColors.danger,
    module: 'Security',
    description: 'Failed admin login for "ada@schatzapp.com"',
    detail: 'Reason: wrong 6-digit code (3rd try)',
    ip: '177.54.12.33',
    location: 'New York, US',
    device: 'Firefox 132 · Linux',
    status: 'Failed',
  ),
  _Log(
    time: 'Nov 27, 2026 07:59:03 AM',
    admin: 'Kesta Wealth',
    role: 'Super Administrator',
    action: 'Approved Promotion',
    actionSub: '1st approval given',
    icon: Icons.shield_rounded,
    color: AppColors.brand,
    module: 'Roles & Permissions',
    description: 'Approved promotion of "Michael Uche" (1 of 2)',
    detail: 'Request: SAR-0007',
    ip: '197.210.45.12',
    location: 'Lagos, NG',
    device: 'Chrome 131 · Windows 11',
    status: 'Success',
    reason: 'Leads investigations, needs full access',
  ),
  _Log(
    time: 'Nov 27, 2026 06:47:55 AM',
    admin: 'System',
    role: 'Automated',
    action: 'Retention Job',
    actionSub: 'Anonymised expired records',
    icon: Icons.auto_delete_outlined,
    color: AppColors.textSecondary,
    module: 'System',
    description: 'Anonymised 214 device logs older than 2 years',
    detail: '4 records skipped (legal hold)',
    ip: 'Internal',
    location: '—',
    device: 'pg_cron',
    status: 'Success',
  ),
];

class _AuditLogsPageState extends State<AuditLogsPage> {
  int _tab = 0;
  String _module = 'All Modules';
  String _status = 'All Status';

  static const _tabs = [
    'All Logs',
    'Admin Activities',
    'User Management',
    'Transactions',
    'Security',
    'System',
  ];

  List<_Log> get _rows => _logs.where((l) {
    final okTab = switch (_tab) {
      1 => l.admin != 'System' && l.module != 'Security',
      2 => l.module == 'Users' || l.module == 'KYC Verification',
      3 => l.module == 'Wallets' || l.module == 'Reports',
      4 => l.module == 'Security' || l.module == 'Roles & Permissions',
      5 => l.module == 'System',
      _ => true,
    };
    if (!okTab) return false;
    if (_module != 'All Modules' && l.module != _module) return false;
    if (_status != 'All Status' && l.status != _status) return false;
    return true;
  }).toList();

  void _open(_Log l) {
    showSidePanel<void>(
      context,
      title: l.action,
      subtitle: l.time,
      body: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              StatusChip(
                l.status,
                kind: switch (l.status) {
                  'Success' => ChipKind.success,
                  'Pending' => ChipKind.warning,
                  _ => ChipKind.danger,
                },
              ),
              TintTag(l.module, l.color),
              const TintTag('Read-only record', AppColors.grey),
            ],
          ),
          const PanelSection('Who'),
          InfoLine('Administrator', l.admin),
          InfoLine('Role', l.role),
          InfoLine('IP address', '${l.ip} · ${l.location}'),
          InfoLine('Device', l.device),
          const PanelSection('What'),
          InfoLine('Action', l.description),
          InfoLine('Details', l.detail),
          if (l.reason != null) InfoLine('Reason', l.reason!),
          if (l.user != null) InfoLine('Related user account', l.user!),
          if (l.txn != null) InfoLine('Related transaction', l.txn!),
          if (l.before != null || l.after != null) ...[
            const PanelSection('Change'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ValueBox(
                    'Previous value',
                    l.before ?? '—',
                    AppColors.dangerSoft,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ValueBox(
                    'New value',
                    l.after ?? '—',
                    AppColors.successSoft,
                  ),
                ),
              ],
            ),
          ],
          const PanelSection('Integrity'),
          const InfoLine('Entry hash', '9f3a…c21e'),
          const InfoLine('Previous hash', '41b0…8d7a'),
          const InfoLine(
            'Chain check',
            '',
            valueWidget: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                SizedBox(width: 6),
                Text(
                  'Unbroken',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Audit entries cannot be edited or deleted by anyone, including '
            'Super Admins. Viewing this entry was also logged.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    return PageBody(
      children: [
        const TileGrid(
          minTileWidth: 200,
          maxColumns: 5,
          gap: 18,
          children: [
            StatCard(
              label: 'Total Logs',
              value: '24,856',
              change: '18.6% from last month',
              icon: Icons.assignment_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [3, 3.4, 3.6, 4.2, 4, 4.8, 5.2, 6],
            ),
            StatCard(
              label: 'Admin Actions',
              value: '9,245',
              change: '14.3% from last month',
              icon: Icons.person_outline_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [3, 3.2, 3.8, 3.6, 4.2, 4.6, 4.4, 5],
            ),
            StatCard(
              label: 'User Changes',
              value: '6,374',
              change: '9.7% from last month',
              icon: Icons.manage_accounts_outlined,
              color: AppColors.info,
              background: AppColors.infoSoft,
              spark: [3, 3.4, 3.2, 3.8, 3.6, 4.2, 4.6, 4.8],
            ),
            StatCard(
              label: 'Security Events',
              value: '1,285',
              change: '22.1% from last month',
              icon: Icons.shield_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              spark: [2, 2.6, 2.4, 3, 3.4, 3.2, 3.8, 4.2],
            ),
            StatCard(
              label: 'Failed Actions',
              value: '487',
              change: '6.5% from last month',
              icon: Icons.highlight_off_rounded,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              spark: [4, 3.6, 3.8, 3.2, 3.4, 3, 3.1, 2.8],
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(
          main: TableCard(
            tabs: _tabs,
            tab: _tab,
            onTab: (i) => setState(() => _tab = i),
            toolbar: [
              OutlineButtonBox(
                label: 'Export',
                icon: Icons.file_download_outlined,
                trailingChevron: true,
                onTap: () => toast(context, 'Export prepared (logged)'),
              ),
              const OutlineButtonBox(
                label: 'Filter',
                icon: Icons.filter_alt_outlined,
              ),
            ],
            filters: [
              const FilterBox(
                label: 'Date Range',
                value: 'Nov 21 - Nov 27, 2026',
                options: ['Nov 21 - Nov 27, 2026', 'Last 30 days', 'This year'],
                onChanged: _noop,
              ),
              const FilterBox(
                label: 'User',
                value: 'All Users',
                options: ['All Users'],
                onChanged: _noop,
              ),
              const FilterBox(
                label: 'Action',
                value: 'All Actions',
                options: ['All Actions'],
                onChanged: _noop,
              ),
              FilterBox(
                label: 'Module',
                value: _module,
                options: const [
                  'All Modules',
                  'Users',
                  'KYC Verification',
                  'Wallets',
                  'Reports',
                  'Roles & Permissions',
                  'Security',
                  'System',
                ],
                onChanged: (v) => setState(() => _module = v),
              ),
              FilterBox(
                label: 'Status',
                value: _status,
                width: 140,
                options: const ['All Status', 'Success', 'Pending', 'Failed'],
                onChanged: (v) => setState(() => _status = v),
              ),
              OutlineButtonBox(
                label: 'Reset',
                icon: Icons.refresh_rounded,
                onTap: () => setState(() {
                  _module = 'All Modules';
                  _status = 'All Status';
                }),
              ),
            ],
            checkbox: false,
            cols: const [
              Col('Timestamp', 13),
              Col('User', 16),
              Col('Action', 17),
              Col('Module', 12),
              Col('Description', 20),
              Col('IP Address', 11),
              Col('Status', 8),
            ],
            onRowTap: (i) => _open(rows[i]),
            rows: [
              for (final l in rows)
                [
                  Text(l.time, style: const TextStyle(fontSize: 11.5)),
                  Row(
                    children: [
                      Avatar(name: l.admin, size: 28),
                      const SizedBox(width: 8),
                      Expanded(child: TwoLine(l.admin, l.role)),
                    ],
                  ),
                  Row(
                    children: [
                      TintIcon(l.icon, l.color, size: 30),
                      const SizedBox(width: 8),
                      Expanded(child: TwoLine(l.action, l.actionSub)),
                    ],
                  ),
                  TintTag(l.module, l.color),
                  TwoLine(l.description, l.detail, bold: false),
                  TwoLine(l.ip, l.location, bold: false),
                  StatusChip(
                    l.status,
                    kind: switch (l.status) {
                      'Success' => ChipKind.success,
                      'Pending' => ChipKind.warning,
                      _ => ChipKind.danger,
                    },
                  ),
                ],
            ],
            narrowRow: (i) => NarrowRow(
              leading: TintIcon(rows[i].icon, rows[i].color),
              title: rows[i].action,
              subtitle: '${rows[i].admin} · ${rows[i].time}',
              trailing: TintTag(rows[i].status, rows[i].color),
            ),
            footerNote:
                'Append-only and hash-chained. No one can edit or delete '
                'audit entries, including their own.',
            pageInfo: 'Showing 1 to ${rows.length} of 24,856 logs',
            lastPage: 2486,
          ),
          side: const SideStack(
            children: [
              DonutCard(
                title: 'Logs by Module',
                centerTop: '24,856',
                centerBottom: 'Total',
                items: [
                  ('Users', 7245, AppColors.brand),
                  ('Transactions', 6374, AppColors.success),
                  ('KYC Verification', 3856, AppColors.info),
                  ('Wallets', 2984, AppColors.warning),
                  ('System', 2397, AppColors.danger),
                  ('Others', 2000, AppColors.grey),
                ],
              ),
              SizedBox(height: 18),
              BarsCard(
                title: 'Logs by Status',
                items: [
                  ('Success', 0.814, '20,245 (81.4%)', AppColors.success),
                  ('Failed', 0.049, '1,214 (4.9%)', AppColors.danger),
                  ('Warning', 0.115, '2,856 (11.5%)', AppColors.warning),
                  ('Info', 0.022, '541 (2.2%)', AppColors.info),
                ],
              ),
              SizedBox(height: 18),
              ActivityCard(
                title: 'Recent Critical Activities',
                items: [
                  Act(
                    Icons.warning_amber_rounded,
                    AppColors.danger,
                    'Failed login attempt for admin',
                    '10:21 AM',
                  ),
                  Act(
                    Icons.warning_amber_rounded,
                    AppColors.danger,
                    'Unauthorized access blocked',
                    '09:58 AM',
                  ),
                  Act(
                    Icons.warning_amber_rounded,
                    AppColors.danger,
                    'Permission escalation attempt',
                    '08:47 AM',
                  ),
                ],
              ),
              SizedBox(height: 18),
              HelpCard('Learn more about audit logs and system monitoring.'),
            ],
          ),
        ),
      ],
    );
  }
}

void _noop(String _) {}

class _ValueBox extends StatelessWidget {
  const _ValueBox(this.label, this.value, this.bg);

  final String label;
  final String value;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
