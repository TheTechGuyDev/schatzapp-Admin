import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/kit.dart';
import '../../widgets/table.dart';
import '../../widgets/page_body.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// System Settings (approved design) with the Super Admin protections:
/// dual-approval requests, data retention schedule and legal holds, plus
/// security, payments & limits, KYC, countries, integrations, messaging,
/// maintenance and system health (Technical role).
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

const _tabs = [
  ('general', 'General', Icons.settings_outlined),
  ('security', 'Security', Icons.shield_outlined),
  ('approvals', 'Super Admin Approvals', Icons.how_to_reg_outlined),
  ('retention', 'Retention & Legal Hold', Icons.gavel_rounded),
  ('payments', 'Payments & Limits', Icons.payments_outlined),
  ('kyc', 'KYC', Icons.verified_user_outlined),
  ('countries', 'Countries', Icons.public_rounded),
  ('messaging', 'Email & SMS', Icons.mail_outline_rounded),
  ('integrations', 'Integrations', Icons.extension_outlined),
  ('health', 'System Health', Icons.monitor_heart_outlined),
  ('maintenance', 'Maintenance', Icons.handyman_outlined),
];

class _SettingsPageState extends State<SettingsPage> {
  int _tab = 0;
  bool _readQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_readQuery) return;
    _readQuery = true;
    final want = GoRouterState.of(context).uri.queryParameters['tab'];
    final i = _tabs.indexWhere((t) => t.$1 == want);
    if (i >= 0) _tab = i;
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                InkWell(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: i == _tab
                              ? AppColors.brand
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _tabs[i].$3,
                          size: 16,
                          color: i == _tab
                              ? AppColors.brand
                              : AppColors.navText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tabs[i].$2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: i == _tab
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: i == _tab
                                ? AppColors.brand
                                : AppColors.navText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 18),
        MainSideLayout(
          main: switch (_tabs[_tab].$1) {
            'security' => const _Security(),
            'approvals' => const _Approvals(),
            'retention' => const _Retention(),
            'payments' => const _Payments(),
            'kyc' => const _Kyc(),
            'countries' => const _Countries(),
            'messaging' => const _Messaging(),
            'integrations' => const _Integrations(),
            'health' => const _Health(),
            'maintenance' => const _Maintenance(),
            _ => const _General(),
          },
          side: const _Side(),
        ),
      ],
    );
  }
}

/// White card with a title, "Save Changes" button and settings rows.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.children,
    this.critical = false,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  /// Saving needs a second Super Admin.
  final bool critical;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            subtitle: subtitle,
            trailing: PrimaryButton(
              label: critical ? 'Request change' : 'Save Changes',
              onTap: () async {
                if (critical) {
                  final ok = await askSecurity(
                    context,
                    title: 'Critical setting',
                    message:
                        'This change needs approval from a second '
                        'Super Admin before it takes effect.',
                    confirm: 'Create request',
                  );
                  if (ok && context.mounted) {
                    toast(context, 'Sent for second approval');
                  }
                } else {
                  toast(context, 'Settings saved');
                }
              },
            ),
          ),
          if (critical) ...[
            const SizedBox(height: 10),
            const SampleNote(
              'Critical settings: changes need your password, authenticator '
              'code and approval from a second Super Admin.',
            ),
          ],
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

Widget _input(String value) => TextFormField(
  initialValue: value,
  style: const TextStyle(fontSize: 13),
  decoration: fieldDecoration(''),
);

Widget _drop(String value, List<String> options) =>
    DropField(value: value, options: options, onChanged: (_) {});

class _Toggle extends StatefulWidget {
  const _Toggle(this.initial, {this.note});

  final bool initial;
  final String? note;

  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  late bool _on = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BrandSwitch(value: _on, onChanged: (v) => setState(() => _on = v)),
        if (widget.note != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.note!,
                style: const TextStyle(fontSize: 11.5, color: AppColors.danger),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── General ─────────────────────────────────────────────────────────────────

class _General extends StatelessWidget {
  const _General();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'General Settings',
      subtitle: 'Configure general system settings and preferences',
      children: [
        SettingRow(
          icon: Icons.public_rounded,
          color: AppColors.success,
          title: 'Site Name',
          description: 'The name of your platform displayed to users.',
          control: _input('SchatzApp'),
        ),
        SettingRow(
          icon: Icons.sell_outlined,
          color: AppColors.brand,
          title: 'Site Tagline',
          description: 'Short description of your platform.',
          control: _input('Chat. Pay. Gift. All in one.'),
        ),
        SettingRow(
          icon: Icons.image_outlined,
          color: AppColors.warning,
          title: 'Logo',
          description: 'Upload your platform logo.',
          control: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/logo_white.png',
                  height: 26,
                  color: AppColors.brand,
                ),
              ),
              const Spacer(),
              const OutlineButtonBox(label: 'Change Logo'),
            ],
          ),
        ),
        SettingRow(
          icon: Icons.schedule_rounded,
          color: AppColors.success,
          title: 'Default Timezone',
          description: 'Set the default timezone for the system.',
          control: _drop('(UTC+01:00) West Africa Time (Lagos)', const [
            '(UTC+01:00) West Africa Time (Lagos)',
            '(UTC+00:00) London',
            '(UTC+01:00) Berlin',
          ]),
        ),
        SettingRow(
          icon: Icons.calendar_today_outlined,
          color: AppColors.brand,
          title: 'Date Format',
          description: 'Set the default date format.',
          control: _drop('Nov 27, 2026 (MMM DD, YYYY)', const [
            'Nov 27, 2026 (MMM DD, YYYY)',
            '27/11/2026 (DD/MM/YYYY)',
          ]),
        ),
        SettingRow(
          icon: Icons.access_time_rounded,
          color: AppColors.warning,
          title: 'Time Format',
          description: 'Set the default time format.',
          control: _drop('12 Hour (hh:mm A)', const [
            '12 Hour (hh:mm A)',
            '24 Hour (HH:mm)',
          ]),
        ),
        SettingRow(
          icon: Icons.translate_rounded,
          color: AppColors.info,
          title: 'System Language',
          description: 'Set the default language for the system.',
          control: _drop('English', const ['English', 'German', 'French']),
        ),
        SettingRow(
          icon: Icons.format_list_numbered_rounded,
          color: AppColors.teal,
          title: 'Items Per Page',
          description: 'Number of items to display per page in lists.',
          control: _drop('20', const ['10', '20', '50', '100']),
        ),
        const SettingRow(
          icon: Icons.handyman_outlined,
          color: AppColors.danger,
          title: 'Enable Maintenance Mode',
          description: 'Put the system in maintenance mode.',
          control: _Toggle(
            false,
            note: 'When enabled, only administrators can access the system.',
          ),
          last: true,
        ),
        const SizedBox(height: 8),
        const Text(
          'Last updated: Nov 27, 2026 10:30 AM by Kesta Wealth',
          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Security ────────────────────────────────────────────────────────────────

class _Security extends StatelessWidget {
  const _Security();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Security',
      subtitle: 'Admin sign-in, sessions and access rules',
      critical: true,
      children: [
        const SettingRow(
          icon: Icons.phonelink_lock_outlined,
          color: AppColors.brand,
          title: 'Authenticator for all admins',
          description:
              'Every admin needs a 6-digit authenticator code at sign-in. '
              'Always on for Super Admins.',
          control: _Toggle(true),
        ),
        SettingRow(
          icon: Icons.key_outlined,
          color: AppColors.info,
          title: 'Second factor for Super Admins',
          description:
              'An independent factor besides the authenticator app, plus '
              'recovery codes kept offline.',
          control: _drop('Security key (FIDO2) + backup codes', const [
            'Security key (FIDO2) + backup codes',
            'Backup codes only',
          ]),
        ),
        SettingRow(
          icon: Icons.timer_outlined,
          color: AppColors.warning,
          title: 'Session timeout',
          description: 'Sign admins out after this much inactivity.',
          control: _drop('30 minutes', const [
            '15 minutes',
            '30 minutes',
            '1 hour',
          ]),
        ),
        SettingRow(
          icon: Icons.password_rounded,
          color: AppColors.success,
          title: 'Password policy',
          description: 'Minimum length and rotation for admin passwords.',
          control: _drop('12+ characters, change every 90 days', const [
            '12+ characters, change every 90 days',
            '16+ characters, change every 60 days',
          ]),
        ),
        SettingRow(
          icon: Icons.lock_clock_outlined,
          color: AppColors.danger,
          title: 'Lock after failed attempts',
          description: 'Lock an admin account after repeated failures.',
          control: _drop('5 attempts, 30 minute lock', const [
            '3 attempts, 1 hour lock',
            '5 attempts, 30 minute lock',
          ]),
        ),
        SettingRow(
          icon: Icons.lan_outlined,
          color: AppColors.teal,
          title: 'IP allowlist (optional)',
          description: 'Only allow admin sign-in from these networks.',
          control: _input('197.210.45.0/24, 41.88.23.0/24'),
        ),
        const SettingRow(
          icon: Icons.visibility_outlined,
          color: AppColors.pink,
          title: 'Log sensitive data access',
          description:
              'Record every view of investigation records, retained '
              'records and company finances.',
          control: _Toggle(true),
          last: true,
        ),
      ],
    );
  }
}

// ── Super Admin Approvals ───────────────────────────────────────────────────

class _Approvals extends StatelessWidget {
  const _Approvals();

  Future<void> _review(BuildContext context) async {
    await showSidePanel<void>(
      context,
      title: 'SAR-0007 · Promote to Super Admin',
      subtitle: 'Requested by Kesta Wealth · expires in 41 hours',
      body: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelSection('Person being promoted'),
          Row(
            children: [
              Avatar(name: 'Michael Uche', size: 44),
              const SizedBox(width: 12),
              const Expanded(
                child: TwoLine(
                  'Michael Uche',
                  'michael@schatzapp.com · Investigation · admin since Mar 2026',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const InfoLine('Identity check', 'Verified staff ID SCZ-EMP-0031'),
          const InfoLine('Authenticator', 'Enrolled Mar 4, 2026'),
          const InfoLine(
            'Reason given',
            'Leads investigations, needs full access',
          ),
          const PanelSection('Approvals (2 needed)'),
          const TimelineEntry(
            title: 'Approved',
            by: 'Kesta Wealth (password + code verified)',
            time: 'Nov 27, 07:59 AM',
            color: AppColors.success,
          ),
          const TimelineEntry(
            title: 'Waiting for a second Super Admin',
            by: 'Ada Nwosu',
            time: 'pending',
            color: AppColors.warning,
            last: true,
          ),
          const PanelSection('Rules'),
          for (final r in const [
            'Two different Super Admin accounts must approve.',
            'You cannot approve twice or approve your own promotion.',
            'Each approver enters their password and authenticator code.',
            'The request expires after 48 hours.',
            'Every attempt, including failed ones, is logged.',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(r, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: (ctx) => [
        OutlineButtonBox(
          label: 'Reject',
          onTap: () async {
            final r = await askReason(
              context,
              title: 'Reject request',
              message: 'The request is closed and everyone is notified.',
              confirm: 'Reject',
              danger: true,
            );
            if (r != null && context.mounted) {
              toast(context, 'Request rejected');
            }
          },
        ),
        PrimaryButton(
          label: 'Approve',
          icon: Icons.verified_user_outlined,
          onTap: () async {
            final ok = await askSecurity(
              context,
              title: 'Approve promotion',
              message:
                  'You confirm you reviewed Michael Uche\'s identity and '
                  'approve the promotion.',
              confirm: 'Approve',
            );
            if (ok && context.mounted) {
              toast(context, 'Approved. Michael Uche is now a Super Admin.');
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      (
        'SAR-0007',
        'Promote Michael Uche to Super Admin',
        'Kesta Wealth',
        '1 of 2',
        'Pending',
        'in 41h',
      ),
      (
        'SAR-0006',
        'Change audit retention from 7 to 5 years',
        'Ada Nwosu',
        '0 of 1',
        'Pending',
        'in 12h',
      ),
      (
        'SAR-0005',
        'Remove Super Admin Tunde Bakare',
        'Ada Nwosu',
        '2 of 2',
        'Approved',
        '—',
      ),
      (
        'SAR-0004',
        'Disable wallet adjustment dual approval',
        'Kesta Wealth',
        '0 of 1',
        'Rejected',
        '—',
      ),
      (
        'SAR-0003',
        'Promote Bola Ade to Super Admin',
        'Kesta Wealth',
        '0 of 2',
        'Expired',
        '—',
      ),
    ];
    return TableCard(
      title: 'Super Admin Approvals',
      subtitle:
          'Promotions, removals and critical setting changes waiting for '
          'other Super Admins',
      checkbox: false,
      cols: const [
        Col('Request', 10),
        Col('Change', 28),
        Col('Requested by', 13),
        Col('Approvals', 9),
        Col('Status', 10),
        Col('Expires', 8),
      ],
      onRowTap: (i) {
        if (i == 0) _review(context);
      },
      rows: [
        for (final r in rows)
          [
            Text(
              r.$1,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brand,
              ),
            ),
            Text(
              r.$2,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(r.$3, style: const TextStyle(fontSize: 12)),
            Text(r.$4, style: const TextStyle(fontSize: 12)),
            StatusChip(
              r.$5,
              kind: switch (r.$5) {
                'Pending' => ChipKind.warning,
                'Approved' => ChipKind.success,
                'Rejected' => ChipKind.danger,
                _ => ChipKind.neutral,
              },
            ),
            Text(r.$6, style: const TextStyle(fontSize: 12)),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: const TintIcon(Icons.how_to_reg_outlined, AppColors.brand),
        title: rows[i].$2,
        subtitle: '${rows[i].$1} · ${rows[i].$4}',
        trailing: TintTag(rows[i].$5, AppColors.brand),
      ),
      footerNote:
          'Super Admin rights are never granted through an ordinary role '
          'change. Every approval record is immutable.',
    );
  }
}

// ── Retention & Legal Hold ──────────────────────────────────────────────────

class _Retention extends StatelessWidget {
  const _Retention();

  Future<void> _newHold(BuildContext context) async {
    final r = await askReason(
      context,
      title: 'Place legal hold',
      message:
          'Records linked to the account or case are kept beyond their '
          'normal retention period until the hold is released.',
      confirm: 'Place hold',
      hint: 'Legal basis and request reference (required)',
      extra: [
        FieldBlock(
          'Account or case',
          TextField(
            style: const TextStyle(fontSize: 13),
            decoration: fieldDecoration('SCZ-... or DSP-...'),
          ),
        ),
      ],
    );
    if (r != null && context.mounted) toast(context, 'Legal hold placed');
  }

  @override
  Widget build(BuildContext context) {
    const schedule = [
      (
        'Wallet ledger & transactions',
        '7 years',
        'Keep, then anonymise',
        'Financial records',
      ),
      (
        'Deposits, payments & provider records',
        '7 years',
        'Keep, then anonymise',
        'Financial records',
      ),
      (
        'Gift card records',
        '7 years',
        'Keep, then anonymise',
        'Financial records',
      ),
      (
        'Complaints & disputes',
        '5 years',
        'Delete personal data',
        'Case closed date',
      ),
      ('KYC documents', '5 years after closure', 'Secure delete', 'NDPA / AML'),
      ('Admin audit logs', '7 years', 'Never edited', 'Compliance'),
      ('Device & login logs', '2 years', 'Anonymise', 'Security'),
      (
        'Messages & media',
        'Not retained by admin',
        'User controlled',
        'Privacy',
      ),
    ];
    const holds = [
      (
        'HOLD-0004',
        'Kunle Ojo · SCZ-1000-0715',
        'Police request LAG/22/119',
        'Compliance · Nov 12',
      ),
      (
        'HOLD-0003',
        'Case DSP-2026-00405',
        'Internal fraud investigation',
        'Sarah Johnson · Nov 21',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableCard(
          title: 'Retention Schedule',
          subtitle:
              'Per record type, guided by the NDPA and financial record '
              'rules. Changes are critical (second Super Admin approval).',
          checkbox: false,
          toolbar: [
            OutlineButtonBox(
              label: 'Request change',
              icon: Icons.edit_outlined,
              onTap: () => askSecurity(
                context,
                title: 'Change retention',
                message:
                    'Retention changes need a second Super Admin approval.',
              ),
            ),
          ],
          cols: const [
            Col('Record type', 26),
            Col('Kept for', 14),
            Col('After expiry', 16),
            Col('Basis', 14),
          ],
          rows: [
            for (final s in schedule)
              [
                Text(
                  s.$1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(s.$2, style: const TextStyle(fontSize: 12)),
                Text(s.$3, style: const TextStyle(fontSize: 12)),
                Text(
                  s.$4,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
          ],
          narrowRow: (i) => NarrowRow(
            leading: const TintIcon(
              Icons.inventory_2_outlined,
              AppColors.brand,
            ),
            title: schedule[i].$1,
            subtitle: schedule[i].$3,
            trailing: Text(
              schedule[i].$2,
              style: const TextStyle(fontSize: 11.5),
            ),
          ),
          footerNote:
              'Deleted accounts are marked deleted, not destroyed. Records are '
              'minimised and anonymised when their period ends.',
        ),
        const SizedBox(height: 18),
        TableCard(
          title: 'Legal Holds',
          subtitle: 'Records preserved beyond normal retention',
          checkbox: false,
          toolbar: [
            PrimaryButton(
              label: 'Place Hold',
              icon: Icons.add,
              onTap: () => _newHold(context),
            ),
          ],
          cols: const [
            Col('Hold', 10),
            Col('Subject', 20),
            Col('Legal basis', 20),
            Col('Placed by', 14),
            Col('', 6),
          ],
          rows: [
            for (final h in holds)
              [
                Text(
                  h.$1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand,
                  ),
                ),
                Text(h.$2, style: const TextStyle(fontSize: 12)),
                Text(h.$3, style: const TextStyle(fontSize: 12)),
                Text(h.$4, style: const TextStyle(fontSize: 12)),
                RowMenu(
                  items: const [
                    ('access', 'View access log', false),
                    ('release', 'Release hold', true),
                  ],
                  onSelected: (v) async {
                    if (v == 'release') {
                      final ok = await askSecurity(
                        context,
                        title: 'Release legal hold',
                        message:
                            'Released records return to the normal schedule.',
                      );
                      if (ok && context.mounted) {
                        toast(context, 'Hold released');
                      }
                    } else {
                      toast(context, 'Opening access log');
                    }
                  },
                ),
              ],
          ],
          narrowRow: (i) => NarrowRow(
            leading: const TintIcon(Icons.gavel_rounded, AppColors.warning),
            title: holds[i].$2,
            subtitle: holds[i].$3,
            trailing: Text(holds[i].$1, style: const TextStyle(fontSize: 11)),
          ),
          footerNote: 'All access to retained records is logged.',
        ),
      ],
    );
  }
}

// ── Payments & Limits ───────────────────────────────────────────────────────

class _Payments extends StatelessWidget {
  const _Payments();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Payments & Limits',
      subtitle: 'Fees, exchange rate and limits per KYC tier',
      critical: true,
      children: [
        SettingRow(
          icon: Icons.currency_exchange_rounded,
          color: AppColors.brand,
          title: 'Schatz rate',
          description: 'Real money per 1 SFZ when topping up.',
          control: _input('₦1.00 = SFZ 1'),
        ),
        SettingRow(
          icon: Icons.percent_rounded,
          color: AppColors.success,
          title: 'Card top-up fee',
          description: 'Charged on top of the amount.',
          control: _input('1.5% (max ₦2,000)'),
        ),
        SettingRow(
          icon: Icons.swap_horiz_rounded,
          color: AppColors.info,
          title: 'Schatz transfer fee',
          description: 'Between SchatzApp users.',
          control: _input('Free'),
        ),
        SettingRow(
          icon: Icons.card_giftcard_rounded,
          color: AppColors.pink,
          title: 'Schatz Gift Card values',
          description: 'Values users can buy.',
          control: _input('5,000 · 10,000 · 25,000 · 50,000 · 100,000'),
        ),
        SettingRow(
          icon: Icons.event_busy_outlined,
          color: AppColors.warning,
          title: 'Gift card expiry',
          description: 'Unloaded Schatz Gift Cards expire after.',
          control: _drop('12 months', const ['6 months', '12 months', 'Never']),
        ),
        SettingRow(
          icon: Icons.speed_rounded,
          color: AppColors.danger,
          title: 'Daily limit: Tier 1 (no KYC)',
          description: 'Maximum sent per day.',
          control: _input('SFZ 50,000'),
        ),
        SettingRow(
          icon: Icons.speed_rounded,
          color: AppColors.warning,
          title: 'Daily limit: Tier 2 (ID verified)',
          description: 'Maximum sent per day.',
          control: _input('SFZ 500,000'),
        ),
        SettingRow(
          icon: Icons.speed_rounded,
          color: AppColors.success,
          title: 'Daily limit: Tier 3 (full KYC)',
          description: 'Maximum sent per day.',
          control: _input('SFZ 5,000,000'),
        ),
        const SettingRow(
          icon: Icons.rule_rounded,
          color: AppColors.brand,
          title: 'Dual approval for wallet adjustments',
          description:
              'Every manual credit or debit needs a second admin. Turning '
              'this off is a critical change.',
          control: _Toggle(true),
          last: true,
        ),
      ],
    );
  }
}

// ── KYC ─────────────────────────────────────────────────────────────────────

class _Kyc extends StatelessWidget {
  const _Kyc();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'KYC Settings',
      subtitle: 'What users must submit and when',
      children: [
        SettingRow(
          icon: Icons.badge_outlined,
          color: AppColors.brand,
          title: 'Accepted ID documents',
          description: 'Shown to users during verification.',
          control: _input(
            'NIN slip, Passport, Driver\'s licence, Voter\'s card',
          ),
        ),
        const SettingRow(
          icon: Icons.face_retouching_natural_outlined,
          color: AppColors.info,
          title: 'Selfie with liveness check',
          description: 'Required for Tier 2 and above.',
          control: _Toggle(true),
        ),
        const SettingRow(
          icon: Icons.home_work_outlined,
          color: AppColors.warning,
          title: 'Proof of address',
          description: 'Required for Tier 3.',
          control: _Toggle(true),
        ),
        SettingRow(
          icon: Icons.timer_outlined,
          color: AppColors.success,
          title: 'Review target',
          description: 'Show a warning when a review waits longer.',
          control: _drop('24 hours', const [
            '12 hours',
            '24 hours',
            '48 hours',
          ]),
        ),
        const SettingRow(
          icon: Icons.groups_2_outlined,
          color: AppColors.danger,
          title: 'Second review for rejections',
          description: 'A second KYC admin confirms every rejection.',
          control: _Toggle(false),
          last: true,
        ),
      ],
    );
  }
}

// ── Countries ───────────────────────────────────────────────────────────────

class _Countries extends StatefulWidget {
  const _Countries();

  @override
  State<_Countries> createState() => _CountriesState();
}

class _CountriesState extends State<_Countries> {
  final _active = {
    'NG': true,
    'GB': true,
    'DE': true,
    'GH': true,
    'US': false,
    'CA': false,
  };

  static const _list = [
    ('NG', 'Nigeria', '+234', 'NGN', '9,812 users'),
    ('GB', 'United Kingdom', '+44', 'GBP', '1,204 users'),
    ('DE', 'Germany', '+49', 'EUR', '842 users'),
    ('GH', 'Ghana', '+233', 'GHS', '690 users'),
    ('US', 'United States', '+1', 'USD', '90 waiting'),
    ('CA', 'Canada', '+1', 'CAD', '45 waiting'),
  ];

  @override
  Widget build(BuildContext context) {
    return TableCard(
      title: 'Supported Countries',
      subtitle:
          'Users can only register with a phone number from an active country',
      checkbox: false,
      toolbar: [
        PrimaryButton(
          label: 'Add Country',
          icon: Icons.add,
          onTap: () => toast(context, 'Country form opened'),
        ),
      ],
      cols: const [
        Col('Country', 22),
        Col('Dial code', 10),
        Col('Currency', 10),
        Col('Users', 14),
        Col('Active', 10),
      ],
      rows: [
        for (final c in _list)
          [
            CountryTag(c.$1, c.$2),
            Text(c.$3, style: const TextStyle(fontSize: 12)),
            Text(c.$4, style: const TextStyle(fontSize: 12)),
            Text(c.$5, style: const TextStyle(fontSize: 12)),
            Align(
              alignment: Alignment.centerLeft,
              child: BrandSwitch(
                value: _active[c.$1]!,
                onChanged: (v) async {
                  final r = await askReason(
                    context,
                    title: v ? 'Enable ${c.$2}' : 'Disable ${c.$2}',
                    message: v
                        ? 'New users from ${c.$2} can register.'
                        : 'No new sign-ups from ${c.$2}. Existing users keep '
                              'their accounts.',
                  );
                  if (r != null && mounted) setState(() => _active[c.$1] = v);
                },
              ),
            ),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: const TintIcon(Icons.public_rounded, AppColors.brand),
        title: _list[i].$2,
        subtitle: '${_list[i].$3} · ${_list[i].$4}',
        trailing: TintTag(
          _active[_list[i].$1]! ? 'Active' : 'Off',
          AppColors.brand,
        ),
      ),
    );
  }
}

// ── Email & SMS ─────────────────────────────────────────────────────────────

class _Messaging extends StatelessWidget {
  const _Messaging();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Email & SMS',
      subtitle: 'Senders used for OTPs and notifications',
      children: [
        SettingRow(
          icon: Icons.mail_outline_rounded,
          color: AppColors.brand,
          title: 'Sender email',
          description: 'From address for emails.',
          control: _input('no-reply@schatzapp.com'),
        ),
        SettingRow(
          icon: Icons.sms_outlined,
          color: AppColors.info,
          title: 'SMS sender ID',
          description: 'Name shown on OTP messages.',
          control: _input('SchatzApp'),
        ),
        SettingRow(
          icon: Icons.speed_rounded,
          color: AppColors.warning,
          title: 'OTP rate limit',
          description: 'Per phone number (otp_rate_limit).',
          control: _drop('5 per hour', const [
            '3 per hour',
            '5 per hour',
            '10 per hour',
          ]),
        ),
        const SettingRow(
          icon: Icons.visibility_off_outlined,
          color: AppColors.pink,
          title: 'Camouflage Private Chat Lock notifications',
          description:
              'Locked chats never show the sender or message in a '
              'notification.',
          control: _Toggle(true),
          last: true,
        ),
      ],
    );
  }
}

// ── Integrations ────────────────────────────────────────────────────────────

class _Integrations extends StatelessWidget {
  const _Integrations();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Supabase',
        'Database, auth, storage',
        'Connected',
        Icons.storage_rounded,
        AppColors.success,
      ),
      (
        'Reloadly',
        'Airtime, data and brand gift cards',
        'Connected',
        Icons.phone_android_rounded,
        AppColors.warning,
      ),
      (
        'Paystack',
        'Card top-ups',
        'Connected',
        Icons.credit_card_rounded,
        AppColors.info,
      ),
      (
        'Providus Bank',
        'Bank transfers & payouts',
        'Degraded',
        Icons.account_balance_outlined,
        AppColors.brand,
      ),
      (
        'Agora',
        'Voice and video calls',
        'Connected',
        Icons.videocam_outlined,
        AppColors.teal,
      ),
      (
        'Firebase Cloud Messaging',
        'Push notifications',
        'Connected',
        Icons.notifications_none_rounded,
        AppColors.danger,
      ),
      (
        'Crypto partner',
        'Planned',
        'Not connected',
        Icons.currency_bitcoin_rounded,
        AppColors.grey,
      ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader(
            title: 'Integrations',
            subtitle:
                'Keys live in Supabase secrets, never in this app. Rotating '
                'a key is a critical change.',
          ),
          const SizedBox(height: 8),
          for (final (i, it) in items.indexed)
            SettingRow(
              icon: it.$4,
              color: it.$5,
              title: it.$1,
              description: it.$2,
              last: i == items.length - 1,
              control: Row(
                children: [
                  DotChip(
                    it.$3,
                    kind: switch (it.$3) {
                      'Connected' => ChipKind.success,
                      'Degraded' => ChipKind.warning,
                      _ => ChipKind.neutral,
                    },
                  ),
                  const Spacer(),
                  OutlineButtonBox(
                    label: it.$3 == 'Not connected' ? 'Connect' : 'Test',
                    onTap: () => toast(context, '${it.$1}: test started'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── System Health (Technical) ───────────────────────────────────────────────

class _Health extends StatelessWidget {
  const _Health();

  @override
  Widget build(BuildContext context) {
    const services = [
      ('API (Edge Functions)', 'Operational', '142 ms'),
      ('Database', 'Operational', '18 ms'),
      ('Realtime', 'Operational', '64 ms'),
      ('Storage', 'Operational', '95 ms'),
      ('Push notifications', 'Operational', '—'),
      ('Bank transfers', 'Degraded', '2.4 s'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(
                title: 'Services',
                subtitle: 'Live status of SchatzApp services and providers',
              ),
              const SizedBox(height: 8),
              for (final s in services)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.$1,
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                      Text(
                        s.$3,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      DotChip(
                        s.$2,
                        kind: s.$2 == 'Operational'
                            ? ChipKind.success
                            : ChipKind.warning,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(
                title: 'Errors & Crashes',
                subtitle: 'Last 7 days',
              ),
              const SizedBox(height: 14),
              const LineChart(
                height: 200,
                labels: [
                  'Nov 21',
                  'Nov 22',
                  'Nov 23',
                  'Nov 24',
                  'Nov 25',
                  'Nov 26',
                  'Nov 27',
                ],
                series: [
                  ChartSeries(
                    name: 'API errors',
                    color: AppColors.danger,
                    values: [42, 38, 51, 47, 33, 29, 24],
                  ),
                  ChartSeries(
                    name: 'App crashes',
                    color: AppColors.warning,
                    values: [12, 9, 14, 11, 8, 7, 6],
                  ),
                  ChartSeries(
                    name: 'Failed integrations',
                    color: AppColors.info,
                    dashed: true,
                    values: [18, 16, 22, 30, 21, 17, 15],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final e in const [
                ('topup-webhook', 'Timeout calling Providus', '14 today'),
                ('reloadly-order', '409 duplicate order', '3 today'),
                ('Android 1.4.2', 'NullPointer in chat_thread', '6 today'),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const TintIcon(
                        Icons.bug_report_outlined,
                        AppColors.danger,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: TwoLine(e.$1, e.$2)),
                      Text(e.$3, style: const TextStyle(fontSize: 11.5)),
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

// ── Maintenance ─────────────────────────────────────────────────────────────

class _Maintenance extends StatelessWidget {
  const _Maintenance();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Maintenance',
      subtitle: 'Planned downtime and app versions',
      children: [
        const SettingRow(
          icon: Icons.handyman_outlined,
          color: AppColors.danger,
          title: 'Maintenance mode',
          description: 'Users see a maintenance screen. Admins keep access.',
          control: _Toggle(false, note: 'Wallet transfers pause while on.'),
        ),
        SettingRow(
          icon: Icons.campaign_outlined,
          color: AppColors.warning,
          title: 'Maintenance message',
          description: 'Shown in the app.',
          control: _input('We are improving SchatzApp. Back soon.'),
        ),
        SettingRow(
          icon: Icons.system_update_rounded,
          color: AppColors.brand,
          title: 'Minimum app version',
          description: 'Older apps must update (forced update).',
          control: _input('Android 1.4.0 · iOS 1.4.0'),
        ),
        SettingRow(
          icon: Icons.web_rounded,
          color: AppColors.info,
          title: 'Web app',
          description: 'web.schatzapp.com sign-in.',
          control: _drop('Enabled', const ['Enabled', 'Disabled']),
          last: true,
        ),
      ],
    );
  }
}

// ── Side column ─────────────────────────────────────────────────────────────

class _Side extends StatelessWidget {
  const _Side();

  @override
  Widget build(BuildContext context) {
    return SideStack(
      children: [
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'Quick Actions'),
              const SizedBox(height: 6),
              for (final q in const [
                (
                  'Clear Cache',
                  'Remove system cache and temporary files',
                  Icons.cleaning_services_outlined,
                  AppColors.info,
                ),
                (
                  'Backup Database',
                  'Create a new database backup',
                  Icons.backup_outlined,
                  AppColors.success,
                ),
                (
                  'System Maintenance',
                  'Run system maintenance tasks',
                  Icons.handyman_outlined,
                  AppColors.brand,
                ),
                (
                  'View System Info',
                  'View detailed system information',
                  Icons.info_outline_rounded,
                  AppColors.info,
                ),
              ])
                InkWell(
                  onTap: () => toast(context, '${q.$1} started'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        TintIcon(q.$3, q.$4, size: 32),
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
        const AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: 'System Information'),
              SizedBox(height: 6),
              InfoLine('System Version', 'v1.0.0'),
              InfoLine(
                'Environment',
                '',
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: TintTag('Production', AppColors.success),
                ),
              ),
              InfoLine('Server Time', 'Nov 27, 2026 10:30 AM'),
              InfoLine('Database', 'PostgreSQL 17 (Supabase)'),
              InfoLine('Hosting', 'GitHub Pages + Supabase'),
              InfoLine('Uptime', '15d 7h 24m'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const DonutCard(
          title: 'Storage Usage',
          centerTop: '65%',
          centerBottom: 'Used',
          items: [
            ('Used (GB)', 65.2, AppColors.brand),
            ('Available (GB)', 34.8, Color(0xFF86E3C8)),
          ],
        ),
        const SizedBox(height: 18),
        const HelpCard('Learn more about system settings and configuration.'),
      ],
    );
  }
}
