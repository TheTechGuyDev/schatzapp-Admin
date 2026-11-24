import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// KYC Verification (approved design): stats, tabs, submissions table,
/// completion ring, requirements and recent activity. Review opens a panel
/// with documents and Approve / Reject / Escalate.
class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class KycSubmission {
  KycSubmission(
    this.ref,
    this.name,
    this.email,
    this.cc,
    this.country,
    this.status,
    this.submitted,
    this.updated,
    this.docType,
    this.docNumber,
    this.dob,
    this.address, {
    this.userId,
  });

  final String ref;
  final String name;
  final String email;
  final String cc;
  final String country;
  String status;
  final String submitted;
  String updated;
  final String docType;
  final String docNumber;
  final String dob;
  final String address;
  final String? userId;
  String? decisionNote;
  String? reviewer;
}

final _submissions = <KycSubmission>[
  KycSubmission(
    'KYC-2026-0001',
    'Abiola Martins',
    'abiola.martins@example.com',
    'NG',
    'Nigeria',
    'Pending',
    'Nov 24, 2026\n10:30 AM',
    'Nov 24, 2026\n10:30 AM',
    'National ID (NIN)',
    'NIN •••• •••• 4471',
    '12 Mar 1994',
    '14 Admiralty Way, Lekki, Lagos',
  ),
  KycSubmission(
    'KYC-2026-0002',
    'Chinedu Okafor',
    'chinedu.okafor@example.com',
    'NG',
    'Nigeria',
    'Verified',
    'Nov 23, 2026\n02:15 PM',
    'Nov 23, 2026\n03:45 PM',
    'International passport',
    'A•••••812',
    '02 Jul 1990',
    '7 Allen Avenue, Ikeja, Lagos',
  ),
  KycSubmission(
    'KYC-2026-0003',
    'Sarah Collins',
    'sarah.collins@example.com',
    'GB',
    'United Kingdom',
    'Pending',
    'Nov 23, 2026\n11:20 AM',
    'Nov 23, 2026\n11:20 AM',
    'Driving licence',
    'COLLI•••••SC',
    '19 Sep 1996',
    '22 Baker Street, London',
  ),
  KycSubmission(
    'KYC-2026-0004',
    'Michael Uche',
    'michael.uche@example.com',
    'NG',
    'Nigeria',
    'Verified',
    'Nov 22, 2026\n09:10 AM',
    'Nov 22, 2026\n09:42 AM',
    'Voter card',
    'VIN •••• 2290',
    '30 Jan 1988',
    '3 Okpara Avenue, Enugu',
  ),
  KycSubmission(
    'KYC-2026-0005',
    'Olivia Anderson',
    'olivia.anderson@example.com',
    'US',
    'United States',
    'Rejected',
    'Nov 22, 2026\n08:20 AM',
    'Nov 22, 2026\n10:05 AM',
    'Passport',
    '5••••••47',
    '05 May 1993',
    '1200 K St NW, Washington DC',
  ),
  KycSubmission(
    'KYC-2026-0006',
    'Temi Adeyemi',
    'temi.adeyemi@example.com',
    'NG',
    'Nigeria',
    'Verified',
    'Nov 21, 2026\n04:50 PM',
    'Nov 21, 2026\n05:20 PM',
    'National ID (NIN)',
    'NIN •••• •••• 2365',
    '11 Nov 1997',
    '9 Ring Road, Ibadan',
  ),
  KycSubmission(
    'KYC-2026-0007',
    'James Wilson',
    'james.wilson@example.com',
    'CA',
    'Canada',
    'Pending',
    'Nov 21, 2026\n01:30 PM',
    'Nov 21, 2026\n01:30 PM',
    'Driving licence',
    'W••••-•••-132',
    '23 Aug 1985',
    '88 Queen St W, Toronto',
  ),
  KycSubmission(
    'KYC-2026-0008',
    'Amina Yusuf',
    'amina.yusuf@example.com',
    'KE',
    'Kenya',
    'Escalated',
    'Nov 20, 2026\n09:05 AM',
    'Nov 21, 2026\n08:15 AM',
    'National ID',
    'ID ••••5018',
    '14 Feb 1999',
    'Westlands, Nairobi',
  ),
];

const _tabNames = ['All', 'Pending', 'Verified', 'Rejected', 'Escalated'];

ChipKind _kind(String s) => switch (s) {
  'Verified' => ChipKind.success,
  'Pending' => ChipKind.warning,
  'Rejected' => ChipKind.danger,
  'Escalated' => ChipKind.brand,
  _ => ChipKind.neutral,
};

class _KycPageState extends State<KycPage> {
  int _tab = 0;
  int _page = 1;

  int _count(String t) => t == 'All'
      ? _submissions.length
      : _submissions.where((s) => s.status == t).length;

  Future<void> _review(KycSubmission s) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _ReviewDialog(sub: s),
    );
    if (changed == true && mounted) {
      setState(() {});
      toast(context, '${s.ref}: ${s.status}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _tab == 0
        ? _submissions
        : _submissions.where((s) => s.status == _tabNames[_tab]).toList();
    return PageBody(
      children: [
        const TileGrid(
          minTileWidth: 220,
          maxColumns: 4,
          gap: 18,
          allowedColumns: [1, 2, 4],
          children: [
            StatCard(
              label: 'Total Verifications',
              value: '1,248',
              change: '6.2% vs last month',
              icon: Icons.description_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [800, 860, 900, 960, 1010, 1090, 1160, 1248],
            ),
            StatCard(
              label: 'Pending Review',
              value: '86',
              change: '14 since yesterday',
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              positive: false,
              spark: [60, 66, 62, 70, 74, 72, 80, 86],
            ),
            StatCard(
              label: 'Verified',
              value: '1,012',
              change: '12.5% this month',
              icon: Icons.verified_user_outlined,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [700, 740, 790, 820, 870, 920, 960, 1012],
            ),
            StatCard(
              label: 'Rejected',
              value: '150',
              change: '4.3% this month',
              icon: Icons.gpp_bad_outlined,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
              spark: [170, 166, 162, 160, 158, 155, 152, 150],
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final table = _table(rows);
            const side = _KycSide();
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

  Widget _table(List<KycSubmission> rows) {
    const cols = [
      Col('User', 24),
      Col('KYC ID', 13),
      Col('Country', 14),
      Col('Status', 12),
      Col('Submitted', 12),
      Col('Updated', 12),
      Col('Actions', 10, align: TextAlign.center),
    ];
    return AppCard(
      padding: 0,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 820;
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
                label: 'Add Manual KYC',
                icon: Icons.add_rounded,
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const _ManualKycDialog(),
                ),
              ),
            ],
          );
          final tabs = UnderlineTabs(
            labels: [for (final t in _tabNames) '$t (${_count(t)})'],
            selected: _tab,
            onSelect: (i) => setState(() => _tab = i),
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
              if (rows.isEmpty)
                const EmptyState('No submissions in this list.')
              else if (narrow)
                for (final s in rows)
                  InkWell(
                    onTap: () => _review(s),
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
                          Avatar(name: s.name, size: 38),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TwoLine(s.name, '${s.ref} · ${s.country}'),
                          ),
                          DotChip(s.status, kind: _kind(s.status)),
                        ],
                      ),
                    ),
                  )
              else ...[
                const TableHead(cols: cols, checkbox: true),
                for (final s in rows)
                  TableLine(
                    cols: cols,
                    checkbox: true,
                    onTap: () => _review(s),
                    cells: [
                      Row(
                        children: [
                          Avatar(name: s.name, size: 34),
                          const SizedBox(width: 10),
                          Expanded(child: TwoLine(s.name, s.email)),
                        ],
                      ),
                      Text(s.ref, style: const TextStyle(fontSize: 12)),
                      CountryTag(s.cc, s.country),
                      DotChip(s.status, kind: _kind(s.status)),
                      Text(
                        s.submitted,
                        style: const TextStyle(fontSize: 11.5, height: 1.4),
                      ),
                      Text(
                        s.updated,
                        style: const TextStyle(fontSize: 11.5, height: 1.4),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SquareIconButton(
                            icon: Icons.visibility_outlined,
                            tooltip: 'Review',
                            onTap: () => _review(s),
                          ),
                          const SizedBox(width: 6),
                          s.status == 'Verified'
                              ? SquareIconButton(
                                  icon: Icons.file_download_outlined,
                                  tooltip: 'Download KYC record',
                                  onTap: () => toast(
                                    context,
                                    'Downloads become available when the backend is connected.',
                                  ),
                                )
                              : SquareIconButton(
                                  icon: Icons.more_vert_rounded,
                                  tooltip: 'More',
                                  onTap: () => _review(s),
                                ),
                        ],
                      ),
                    ],
                  ),
              ],
              PaginationBar(
                info: 'Showing 1 to ${rows.length} of 1,248 results',
                lastPage: 125,
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

class _KycSide extends StatelessWidget {
  const _KycSide();

  @override
  Widget build(BuildContext context) {
    const data = [
      ('Verified', 1012.0, AppColors.success),
      ('Pending', 86.0, AppColors.warning),
      ('Rejected', 150.0, AppColors.danger),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'KYC Completion Rate'),
              const SizedBox(height: 14),
              Row(
                children: [
                  DonutChart(
                    values: [for (final d in data) d.$2],
                    colors: [for (final d in data) d.$3],
                    centerTop: '81%',
                    centerBottom: 'Completed',
                    size: 112,
                    stroke: 12,
                    fontSize: 19,
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
              const CardHeader(title: 'KYC Requirements'),
              const SizedBox(height: 8),
              for (final r in const [
                (
                  Icons.badge_outlined,
                  'Identity Document',
                  'Government issued ID',
                  true,
                ),
                (
                  Icons.face_retouching_natural_outlined,
                  'Selfie / Biometric',
                  'Live photo verification',
                  true,
                ),
                (
                  Icons.home_work_outlined,
                  'Proof of Address',
                  'Utility bill or bank statement',
                  false,
                ),
                (
                  Icons.receipt_long_outlined,
                  'Proof of Income',
                  'Payslip or bank statement',
                  false,
                ),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      IconCircle(
                        icon: r.$1,
                        color: AppColors.brand,
                        background: AppColors.brandSoft,
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: TwoLine(r.$2, r.$3)),
                      r.$4
                          ? const StatusChip('Required', kind: ChipKind.success)
                          : const StatusChip('Conditional'),
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
              CardHeader(
                title: 'Recent Activity',
                trailing: LinkText(
                  'View All',
                  onTap: () => context.go('/audit-logs'),
                ),
              ),
              const SizedBox(height: 8),
              for (final a in const [
                (
                  Icons.check_circle_outline_rounded,
                  AppColors.success,
                  "Chinedu Okafor's KYC verified",
                  '2m ago',
                ),
                (
                  Icons.schedule_rounded,
                  AppColors.warning,
                  'New submission from Abiola Martins',
                  '10m ago',
                ),
                (
                  Icons.cancel_outlined,
                  AppColors.danger,
                  "Olivia Anderson's KYC rejected",
                  '1h ago',
                ),
                (
                  Icons.file_download_outlined,
                  AppColors.info,
                  'KYC record downloaded',
                  '2h ago',
                ),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      IconCircle(
                        icon: a.$1,
                        color: a.$2,
                        background: a.$2.withValues(alpha: 0.1),
                        size: 30,
                      ),
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

// ── Review dialog ───────────────────────────────────────────────────────────

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.sub});
  final KycSubmission sub;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _note = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _decide(String status) {
    final note = _note.text.trim();
    if (status != 'Verified' && note.length < 10) {
      setState(
        () => _error = 'Add a reason (at least 10 characters) to $status.',
      );
      return;
    }
    final s = widget.sub;
    s.status = status;
    s.decisionNote = note.isEmpty ? null : note;
    s.reviewer = AdminSession.instance.name;
    s.updated = 'Just now';
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sub;
    final open = s.status == 'Pending' || s.status == 'Escalated';
    final details = [
      ('Full name', s.name),
      ('Date of birth', s.dob),
      ('Country', s.country),
      ('Document', s.docType),
      ('Document number', s.docNumber),
      ('Address', s.address),
      ('Email', s.email),
      ('Submitted', s.submitted.replaceAll('\n', ' · ')),
    ];
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Avatar(name: s.name, size: 44),
                  const SizedBox(width: 12),
                  Expanded(child: TwoLine(s.name, '${s.ref} · ${s.country}')),
                  DotChip(s.status, kind: _kind(s.status)),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Documents',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TileGrid(
                minTileWidth: 200,
                maxColumns: 3,
                gap: 12,
                children: [
                  _DocTile(Icons.badge_outlined, '${s.docType} (front)'),
                  _DocTile(Icons.badge_outlined, '${s.docType} (back)'),
                  const _DocTile(
                    Icons.face_retouching_natural_outlined,
                    'Selfie / liveness',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Submitted details',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TileGrid(
                minTileWidth: 220,
                maxColumns: 2,
                gap: 12,
                children: [
                  for (final d in details)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.$1,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          d.$2,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _Check('Name matches the account', true),
                  _Check('Face matches the document', true),
                  _Check('Document not expired', true),
                  _Check('No duplicate account found', true),
                ],
              ),
              if (s.decisionNote != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${s.reviewer}: ${s.decisionNote}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
              if (open) ...[
                const SizedBox(height: 18),
                const Text(
                  'Review note (required to reject or escalate)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  decoration: InputDecoration(
                    hintText: 'For example: document photo is blurred, please resubmit',
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
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlineButtonBox(
                      label: 'Escalate',
                      icon: Icons.outlined_flag_rounded,
                      onTap: () => _decide('Escalated'),
                    ),
                    _ColorButton(
                      'Reject',
                      Icons.close_rounded,
                      AppColors.danger,
                      () => _decide('Rejected'),
                    ),
                    _ColorButton(
                      'Approve',
                      Icons.check_rounded,
                      AppColors.success,
                      () => _decide('Verified'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Click to enlarge',
            style: TextStyle(fontSize: 10.5, color: AppColors.brand),
          ),
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check(this.label, this.ok);
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) =>
      DotChip(label, kind: ok ? ChipKind.success : ChipKind.danger);
}

class _ColorButton extends StatelessWidget {
  const _ColorButton(this.label, this.icon, this.color, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualKycDialog extends StatelessWidget {
  const _ManualKycDialog();

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
    Widget field(String label, String hint) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            style: const TextStyle(fontSize: 13),
            decoration: deco(hint),
          ),
        ],
      ),
    );
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Manual KYC',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              field('User', 'Account no., phone or user ID'),
              field('Document type', 'National ID, passport, driving licence'),
              field('Document number', 'As written on the document'),
              Container(
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: AppColors.brand),
                    SizedBox(height: 4),
                    Text(
                      'Upload document images',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlineButtonBox(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  PrimaryButton(
                    label: 'Submit for Review',
                    onTap: () {
                      Navigator.pop(context);
                      toast(
                        context,
                        'Manual KYC saving connects in the backend phase.',
                      );
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
