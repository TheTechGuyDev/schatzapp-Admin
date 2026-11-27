import 'package:material_ui/material_ui.dart';

import '../../data/sample_finance.dart' show MoneyKind;
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/kit.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Deposits & Top-ups (wallet_topups): card and bank-transfer top-ups that
/// turn real money into Schatz. Bank transfers are confirmed by two admins
/// before Schatz is credited. Shows the bank account users pay into
/// (bank_transfer_settings).
class DepositsPage extends StatefulWidget {
  const DepositsPage({super.key});

  @override
  State<DepositsPage> createState() => _DepositsPageState();
}

class _Topup {
  const _Topup(
    this.ref,
    this.user,
    this.method,
    this.paid,
    this.schatz,
    this.status,
    this.time, {
    this.proof = false,
    this.firstApprover,
  });

  final String ref;
  final String user;
  final String method;
  final String paid;
  final String schatz;
  final String status;
  final String time;
  final bool proof;
  final String? firstApprover;
}

const _rows = [
  _Topup(
    'TOP-2026-55210',
    'John Okafor',
    'Bank transfer',
    '₦50,000',
    'SFZ 50,000',
    'Awaiting confirmation',
    '10 mins ago',
    proof: true,
  ),
  _Topup(
    'TOP-2026-55209',
    'Emily Johnson',
    'Bank transfer',
    '₦120,000',
    'SFZ 120,000',
    'Awaiting 2nd approval',
    '25 mins ago',
    proof: true,
    firstApprover: 'Michael Uche',
  ),
  _Topup(
    'TOP-2026-55208',
    'David Brown',
    'Card',
    '₦5,000',
    'SFZ 5,000',
    'Successful',
    '32 mins ago',
  ),
  _Topup(
    'TOP-2026-55207',
    'Sarah Collins',
    'Card',
    '₦5,000',
    'SFZ 5,000',
    'Failed',
    '1 hour ago',
  ),
  _Topup(
    'TOP-2026-55206',
    'Olivia Anderson',
    'Gift card',
    '—',
    'SFZ 25,000',
    'Successful',
    '2 hours ago',
  ),
  _Topup(
    'TOP-2026-55205',
    'Temi Adeyemi',
    'Bank transfer',
    '₦30,000',
    'SFZ 30,000',
    'Rejected',
    '3 hours ago',
  ),
  _Topup(
    'TOP-2026-55204',
    'James Wilson',
    'Card',
    '₦10,000',
    'SFZ 10,000',
    'Successful',
    '5 hours ago',
  ),
];

ChipKind _kind(String s) => switch (s) {
  'Successful' => ChipKind.success,
  'Failed' || 'Rejected' => ChipKind.danger,
  'Awaiting 2nd approval' => ChipKind.brand,
  _ => ChipKind.warning,
};

class _DepositsPageState extends State<DepositsPage> {
  int _tab = 0;

  static const _tabs = [
    'All Top-ups',
    'Awaiting Confirmation (2)',
    'Successful',
    'Failed / Rejected',
  ];

  List<_Topup> get _list => _rows.where((t) {
    return switch (_tab) {
      1 => t.status.startsWith('Awaiting'),
      2 => t.status == 'Successful',
      3 => t.status == 'Failed' || t.status == 'Rejected',
      _ => true,
    };
  }).toList();

  void _open(_Topup t) {
    showSidePanel<void>(
      context,
      title: t.ref,
      subtitle: '${t.method} top-up by ${t.user}',
      body: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              StatusChip(t.status, kind: _kind(t.status)),
              const MoneyKindTag(MoneyKind.fiatIn),
            ],
          ),
          const PanelSection('Payment'),
          InfoLine('Amount paid (real money)', t.paid),
          InfoLine('Schatz to credit', t.schatz),
          InfoLine('Method', t.method),
          InfoLine('Submitted', t.time),
          if (t.method == 'Bank transfer') ...[
            const InfoLine('Paid into', 'Providus Bank · SchatzApp Ltd'),
            const InfoLine('Sender name', 'JOHN OKAFOR'),
            const InfoLine('Bank narration', 'SCZ-1004-2231'),
          ],
          if (t.proof) ...[
            const PanelSection('Proof of payment'),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 34,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'transfer_receipt.jpg',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const PanelSection('Approvals'),
          TimelineEntry(title: 'Top-up submitted', by: t.user, time: t.time),
          if (t.firstApprover != null)
            TimelineEntry(
              title: 'First approval: money seen in bank account',
              by: t.firstApprover!,
              time: '15 mins ago',
              color: AppColors.success,
              last: true,
            )
          else
            const TimelineEntry(
              title: 'Waiting for the first approval',
              by: 'Finance',
              time: 'now',
              color: AppColors.warning,
              last: true,
            ),
        ],
      ),
      actions: t.status.startsWith('Awaiting')
          ? (ctx) => [
              OutlineButtonBox(
                label: 'Reject',
                onTap: () async {
                  final r = await askReason(
                    context,
                    title: 'Reject top-up',
                    message:
                        'No Schatz will be credited. The user is told why.',
                    confirm: 'Reject',
                    danger: true,
                  );
                  if (r != null && mounted) toast(context, 'Top-up rejected');
                },
              ),
              PrimaryButton(
                label: t.firstApprover == null
                    ? 'Confirm money received'
                    : 'Give 2nd approval and credit',
                icon: Icons.check_rounded,
                onTap: () async {
                  final ok = await askSecurity(
                    context,
                    title: 'Confirm bank deposit',
                    message: t.firstApprover == null
                        ? 'Confirm ${t.paid} arrived in the bank account. A '
                              'second admin must also approve before '
                              '${t.schatz} is credited.'
                        : 'Second approval: ${t.schatz} will be credited to '
                              '${t.user}. You cannot approve a top-up you '
                              'confirmed yourself.',
                  );
                  if (ok && mounted) {
                    toast(
                      context,
                      t.firstApprover == null
                          ? 'First approval recorded'
                          : '${t.schatz} credited',
                    );
                  }
                },
              ),
            ]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _list;
    return PageBody(
      children: [
        const TileGrid(
          minTileWidth: 200,
          maxColumns: 4,
          gap: 18,
          allowedColumns: [1, 2, 4],
          children: [
            StatCard(
              label: 'Top-ups Today',
              value: '₦3.18M',
              change: '412 top-ups',
              icon: Icons.add_card_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [2, 2.4, 2.8, 3, 2.9, 3.4, 3.8, 4.2],
            ),
            StatCard(
              label: 'Awaiting Confirmation',
              value: '2',
              change: '₦170,000 pending',
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              positive: false,
            ),
            StatCard(
              label: 'Card Success Rate',
              value: '96.9%',
              change: '0.6% better',
              icon: Icons.credit_score_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
            ),
            StatCard(
              label: 'Failed / Rejected',
              value: '38',
              change: 'today',
              icon: Icons.money_off_rounded,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(
          main: TableCard(
            tabs: _tabs,
            tab: _tab,
            onTab: (i) => setState(() => _tab = i),
            toolbar: const [
              OutlineButtonBox(
                label: 'Export',
                icon: Icons.file_download_outlined,
                trailingChevron: true,
              ),
            ],
            filters: const [
              SearchBox(
                hint: 'Search reference, user or narration',
                width: 280,
              ),
            ],
            cols: const [
              Col('Reference', 15),
              Col('User', 17),
              Col('Method', 12),
              Col('Paid', 11),
              Col('Schatz', 12),
              Col('Status', 15),
              Col('Time', 10),
            ],
            onRowTap: (i) => _open(rows[i]),
            rows: [
              for (final t in rows)
                [
                  Text(
                    t.ref,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand,
                    ),
                  ),
                  Row(
                    children: [
                      Avatar(name: t.user, size: 26),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.user,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  TintTag(t.method, switch (t.method) {
                    'Card' => AppColors.brand,
                    'Bank transfer' => AppColors.info,
                    _ => AppColors.pink,
                  }),
                  Text(
                    t.paid,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  Text(t.schatz, style: const TextStyle(fontSize: 12)),
                  StatusChip(t.status, kind: _kind(t.status)),
                  Text(t.time, style: const TextStyle(fontSize: 11.5)),
                ],
            ],
            narrowRow: (i) => NarrowRow(
              leading: Avatar(name: rows[i].user, size: 36),
              title: '${rows[i].user} · ${rows[i].paid}',
              subtitle: '${rows[i].method} · ${rows[i].ref}',
              trailing: StatusChip(rows[i].status, kind: _kind(rows[i].status)),
            ),
            footerNote:
                'Bank transfers need two different admins: one confirms the '
                'money arrived, a second approves the credit.',
            pageInfo: 'Showing 1 to ${rows.length} of 18,214 top-ups',
            lastPage: 1822,
          ),
          side: SideStack(
            children: [
              AppCard(
                padding: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CardHeader(
                      title: 'Bank Transfer Account',
                      subtitle: 'Shown to users in the app',
                      trailing: LinkText(
                        'Edit',
                        onTap: () => askSecurity(
                          context,
                          title: 'Change bank account',
                          message:
                              'Changing where users send money is a critical '
                              'setting. A second Super Admin must approve it.',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const InfoLine('Account name', 'SchatzApp Ltd'),
                    const InfoLine('Bank', 'Providus Bank'),
                    const InfoLine('Account / IBAN', '•••• 4410'),
                    const InfoLine('Currency', 'NGN'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const DonutCard(
                title: 'Top-ups by Method',
                centerTop: '₦88.2M',
                centerBottom: 'November',
                items: [
                  ('Card', 52.4, AppColors.brand),
                  ('Bank transfer', 28.1, AppColors.info),
                  ('Gift card', 7.7, AppColors.pink),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
