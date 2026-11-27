import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sample_support.dart';
import '../../data/sample_users.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/kit.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Complaints, Disputes & Investigations: every case with its reference,
/// user, category, assigned admin, attachments, notes, resolution and the
/// full history of admin actions on it.
class DisputesPage extends StatefulWidget {
  const DisputesPage({super.key});

  @override
  State<DisputesPage> createState() => _DisputesPageState();
}

const statuses = [
  'New',
  'Under Review',
  'Investigation',
  'Awaiting User Response',
  'Escalated',
  'Resolved',
  'Closed',
];

const categories = [
  'User Complaint',
  'Financial Dispute',
  'Payment Complaint',
  'Fraud Report',
  'Account Access',
  'Gift Card Complaint',
  'Reported User',
  'Admin Investigation',
];

ChipKind statusKind(String s) => switch (s) {
  'New' => ChipKind.info,
  'Under Review' => ChipKind.brand,
  'Investigation' => ChipKind.warning,
  'Awaiting User Response' => ChipKind.neutral,
  'Escalated' => ChipKind.danger,
  'Resolved' => ChipKind.success,
  _ => ChipKind.neutral,
};

Color categoryColor(String c) => switch (c) {
  'Financial Dispute' => AppColors.brand,
  'Payment Complaint' => AppColors.info,
  'Fraud Report' => AppColors.danger,
  'Account Access' => AppColors.teal,
  'Gift Card Complaint' => AppColors.pink,
  'Reported User' => AppColors.warning,
  'Admin Investigation' => const Color(0xFF7C3AED),
  _ => AppColors.textSecondary,
};

Color priorityColor(String p) => switch (p) {
  'High' => AppColors.danger,
  'Medium' => AppColors.warning,
  _ => AppColors.success,
};

class _DisputesPageState extends State<DisputesPage> {
  int _tab = 0;
  String _q = '';
  String _category = 'All Categories';
  String _priority = 'All Priority';
  String _assignee = 'All Admins';

  static const _tabs = ['All Cases', 'Open', 'Escalated', 'Resolved', 'Closed'];

  List<DisputeCase> get _rows => SampleSupport.disputes.where((d) {
    final okTab = switch (_tab) {
      1 => !['Resolved', 'Closed', 'Escalated'].contains(d.status),
      2 => d.status == 'Escalated',
      3 => d.status == 'Resolved',
      4 => d.status == 'Closed',
      _ => true,
    };
    if (!okTab) return false;
    if (_category != 'All Categories' && d.category != _category) return false;
    if (_priority != 'All Priority' && d.priority != _priority) return false;
    if (_assignee != 'All Admins' && d.assignee != _assignee) return false;
    if (_q.isEmpty) return true;
    final q = _q.toLowerCase();
    return d.ref.toLowerCase().contains(q) ||
        d.user.toLowerCase().contains(q) ||
        d.account.toLowerCase().contains(q) ||
        (d.txnRef ?? '').toLowerCase().contains(q) ||
        d.subject.toLowerCase().contains(q);
  }).toList();

  Future<void> _newCase() async {
    var cat = categories.first;
    var pri = 'Medium';
    final user = TextEditingController();
    final subject = TextEditingController();
    final ref = TextEditingController();
    final desc = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text(
            'Open a new case',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FieldBlock(
                    'User (account number, username, phone or email)',
                    TextField(
                      controller: user,
                      style: const TextStyle(fontSize: 13),
                      decoration: fieldDecoration('e.g. SCZ-1004-2231'),
                    ),
                  ),
                  FieldBlock(
                    'Category',
                    DropField(
                      value: cat,
                      options: categories,
                      onChanged: (v) => set(() => cat = v),
                    ),
                  ),
                  FieldBlock(
                    'Priority',
                    DropField(
                      value: pri,
                      options: const ['High', 'Medium', 'Low'],
                      onChanged: (v) => set(() => pri = v),
                    ),
                  ),
                  FieldBlock(
                    'Subject',
                    TextField(
                      controller: subject,
                      style: const TextStyle(fontSize: 13),
                      decoration: fieldDecoration('Short summary'),
                    ),
                  ),
                  FieldBlock(
                    'Related transaction or gift card reference (optional)',
                    TextField(
                      controller: ref,
                      style: const TextStyle(fontSize: 13),
                      decoration: fieldDecoration('TXN-..., GC-..., TOP-...'),
                    ),
                  ),
                  FieldBlock(
                    'Description',
                    TextField(
                      controller: desc,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 13),
                      decoration: fieldDecoration('What happened?'),
                    ),
                  ),
                  const OutlineButtonBox(
                    label: 'Attach documents',
                    icon: Icons.attach_file_rounded,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlineButtonBox(
              label: 'Cancel',
              onTap: () => Navigator.pop(ctx, false),
            ),
            PrimaryButton(
              label: 'Create case',
              onTap: () {
                if (user.text.trim().isNotEmpty &&
                    subject.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, true);
                }
              },
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) toast(context, 'Case DSP-2026-00413 created');
  }

  Future<void> _changeStatus(DisputeCase d) async {
    var to = d.status;
    final r = await askReason(
      context,
      title: 'Change status',
      message: '${d.ref}: currently ${d.status}.',
      confirm: 'Update status',
      extra: [
        StatefulBuilder(
          builder: (ctx, set) => FieldBlock(
            'New status',
            DropField(
              value: to,
              options: statuses,
              onChanged: (v) => set(() => to = v),
            ),
          ),
        ),
      ],
    );
    if (r != null && mounted) toast(context, 'Status changed to $to');
  }

  Future<void> _assign(DisputeCase d) async {
    var to = 'Michael Uche';
    final r = await askReason(
      context,
      title: 'Assign case',
      message: '${d.ref} is assigned to ${d.assignee}.',
      confirm: 'Assign',
      extra: [
        StatefulBuilder(
          builder: (ctx, set) => FieldBlock(
            'Assign to',
            DropField(
              value: to,
              options: const [
                'Michael Uche',
                'Sarah Johnson',
                'Linda Emmanuel',
                'James Wilson',
              ],
              onChanged: (v) => set(() => to = v),
            ),
          ),
        ),
      ],
    );
    if (r != null && mounted) toast(context, 'Case assigned to $to');
  }

  Future<void> _resolve(DisputeCase d) async {
    final r = await askReason(
      context,
      title: 'Resolve case',
      message:
          'Write the resolution the user will see. Any refund or ledger '
          'correction must be requested separately (it needs a second '
          'approval).',
      confirm: 'Mark resolved',
      hint: 'Resolution (required)',
    );
    if (r != null && mounted) toast(context, '${d.ref} resolved');
  }

  void _open(DisputeCase d) {
    final note = TextEditingController();
    showSidePanel<void>(
      context,
      title: d.ref,
      subtitle: d.subject,
      width: 600,
      body: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusChip(d.status, kind: statusKind(d.status)),
              TintTag(d.category, categoryColor(d.category)),
              TintTag('${d.priority} priority', priorityColor(d.priority)),
            ],
          ),
          const PanelSection('User account'),
          Row(
            children: [
              Avatar(name: d.user, size: 38),
              const SizedBox(width: 10),
              Expanded(child: TwoLine(d.user, '${d.email} · ${d.account}')),
              LinkText(
                'Open profile',
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/users/${SampleUsers.all.first.id}');
                },
              ),
            ],
          ),
          const PanelSection('Case details'),
          InfoLine('Reference', d.ref),
          InfoLine('Date submitted', d.submitted),
          InfoLine('Assigned administrator', d.assignee),
          InfoLine('Last updated', d.updated),
          if (d.amount != null) InfoLine('Amount', d.amount!),
          if (d.txnRef != null)
            InfoLine(
              'Related reference',
              d.txnRef!,
              valueWidget: Row(
                children: [
                  Text(
                    d.txnRef!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  LinkText(
                    'Trace funds',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/transactions/trace?ref=${d.txnRef}');
                    },
                  ),
                ],
              ),
            ),
          const PanelSection('Description'),
          Text(d.description, style: const TextStyle(fontSize: 12.5)),
          PanelSection('Attachments (${d.attachments.length})'),
          if (d.attachments.isEmpty)
            const Text(
              'No attachments.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in d.attachments)
                  OutlineButtonBox(label: a, icon: Icons.attach_file_rounded),
              ],
            ),
          if (d.resolution != null) ...[
            const PanelSection('Resolution'),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${d.resolution!}\nResolved on ${d.resolvedOn}',
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          ],
          const PanelSection('Investigation notes'),
          TextField(
            controller: note,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: fieldDecoration(
              'Add an internal note (only admins with investigation access '
              'see notes)',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Add note',
              icon: Icons.note_add_outlined,
              onTap: () {
                if (note.text.trim().isEmpty) return;
                note.clear();
                toast(context, 'Note added to ${d.ref}');
              },
            ),
          ),
          const PanelSection('Action history'),
          if (d.history.isEmpty)
            const Text(
              'No actions yet.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            )
          else
            for (var i = 0; i < d.history.length; i++)
              TimelineEntry(
                title: d.history[i].title,
                by: d.history[i].by,
                time: d.history[i].time,
                note: d.history[i].note,
                last: i == d.history.length - 1,
              ),
        ],
      ),
      actions: (ctx) => [
        OutlineButtonBox(
          label: 'Assign',
          icon: Icons.person_add_alt_outlined,
          onTap: () => _assign(d),
        ),
        OutlineButtonBox(
          label: 'Change status',
          icon: Icons.sync_alt_rounded,
          onTap: () => _changeStatus(d),
        ),
        OutlineButtonBox(
          label: 'Escalate',
          icon: Icons.priority_high_rounded,
          onTap: () async {
            final r = await askReason(
              context,
              title: 'Escalate case',
              message: 'Escalated cases go to Compliance and Super Admins.',
              confirm: 'Escalate',
            );
            if (r != null && mounted) toast(context, '${d.ref} escalated');
          },
        ),
        PrimaryButton(
          label: 'Resolve',
          icon: Icons.check_rounded,
          onTap: () => _resolve(d),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        const TileGrid(
          minTileWidth: 200,
          maxColumns: 5,
          gap: 18,
          children: [
            StatCard(
              label: 'Total Cases',
              value: '1,084',
              change: '9.2% from last month',
              icon: Icons.shield_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [6, 7, 7.4, 8, 8.2, 9, 9.6, 10.8],
            ),
            StatCard(
              label: 'New',
              value: '46',
              change: '12 today',
              icon: Icons.fiber_new_outlined,
              color: AppColors.info,
              background: AppColors.infoSoft,
            ),
            StatCard(
              label: 'Under Investigation',
              value: '128',
              change: '4.1% from last month',
              icon: Icons.manage_search_rounded,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              positive: false,
            ),
            StatCard(
              label: 'Escalated',
              value: '19',
              change: '3 this week',
              icon: Icons.priority_high_rounded,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
            ),
            StatCard(
              label: 'Resolved',
              value: '891',
              change: 'Avg 1d 6h to resolve',
              icon: Icons.task_alt_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [5, 5.4, 6.1, 6.3, 7, 7.8, 8.4, 8.9],
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(main: _table(), side: const _Side()),
      ],
    );
  }

  Widget _table() {
    final rows = _rows;
    const cols = [
      Col('Reference', 15),
      Col('User', 18),
      Col('Category', 14),
      Col('Subject', 18),
      Col('Priority', 8),
      Col('Status', 13),
      Col('Assigned to', 12),
      Col('', 5, align: TextAlign.center),
    ];
    return TableCard(
      tabs: _tabs,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      toolbar: [
        const OutlineButtonBox(
          label: 'Export',
          icon: Icons.file_download_outlined,
          trailingChevron: true,
        ),
        PrimaryButton(label: 'New Case', icon: Icons.add, onTap: _newCase),
      ],
      filters: [
        SearchBox(
          hint: 'Search ref, user, account or transaction',
          width: 280,
          onChanged: (v) => setState(() => _q = v.trim()),
        ),
        FilterBox(
          label: 'Category',
          value: _category,
          options: ['All Categories', ...categories],
          onChanged: (v) => setState(() => _category = v),
        ),
        FilterBox(
          label: 'Priority',
          value: _priority,
          width: 140,
          options: const ['All Priority', 'High', 'Medium', 'Low'],
          onChanged: (v) => setState(() => _priority = v),
        ),
        FilterBox(
          label: 'Assigned To',
          value: _assignee,
          options: const [
            'All Admins',
            'Michael Uche',
            'Sarah Johnson',
            'Linda Emmanuel',
            'James Wilson',
            'Unassigned',
          ],
          onChanged: (v) => setState(() => _assignee = v),
        ),
      ],
      cols: cols,
      onRowTap: (i) => _open(rows[i]),
      rows: [
        for (final d in rows)
          [
            TwoLine(d.ref, d.submitted, topColor: AppColors.brand),
            Row(
              children: [
                Avatar(name: d.user, size: 28),
                const SizedBox(width: 8),
                Expanded(child: TwoLine(d.user, d.account)),
              ],
            ),
            TintTag(d.category, categoryColor(d.category)),
            Text(
              d.subject,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            TintTag(d.priority, priorityColor(d.priority)),
            StatusChip(d.status, kind: statusKind(d.status)),
            Text(d.assignee, style: const TextStyle(fontSize: 12)),
            RowMenu(
              items: const [
                ('open', 'View case', false),
                ('assign', 'Assign', false),
                ('status', 'Change status', false),
                ('resolve', 'Resolve', false),
              ],
              onSelected: (v) => switch (v) {
                'assign' => _assign(d),
                'status' => _changeStatus(d),
                'resolve' => _resolve(d),
                _ => _open(d),
              },
            ),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: Avatar(name: rows[i].user, size: 36),
        title: '${rows[i].ref} · ${rows[i].user}',
        subtitle: rows[i].subject,
        trailing: StatusChip(rows[i].status, kind: statusKind(rows[i].status)),
      ),
      empty: 'No cases match these filters.',
      footerNote:
          'Investigation notes and attachments are visible only to admins '
          'with the investigation permission. Every view is logged.',
      pageInfo: 'Showing 1 to ${rows.length} of 1,084 cases',
      lastPage: 136,
    );
  }
}

class _Side extends StatelessWidget {
  const _Side();

  @override
  Widget build(BuildContext context) {
    return const SideStack(
      children: [
        DonutCard(
          title: 'Cases by Category',
          centerTop: '1,084',
          centerBottom: 'Cases',
          items: [
            ('Financial Dispute', 312, AppColors.brand),
            ('Payment Complaint', 228, AppColors.info),
            ('Fraud Report', 96, AppColors.danger),
            ('Account Access', 174, AppColors.teal),
            ('Gift Card', 118, AppColors.pink),
            ('Reported User', 156, AppColors.warning),
          ],
        ),
        SizedBox(height: 18),
        BarsCard(
          title: 'Cases by Status',
          items: [
            ('New', 0.05, '46', AppColors.info),
            ('Review', 0.12, '131', AppColors.brand),
            ('Investigate', 0.12, '128', AppColors.warning),
            ('Escalated', 0.02, '19', AppColors.danger),
            ('Resolved', 0.82, '891', AppColors.success),
          ],
        ),
        SizedBox(height: 18),
        ActivityCard(
          title: 'Recent Case Activity',
          items: [
            Act(
              Icons.manage_search_rounded,
              AppColors.warning,
              'DSP-00412 moved to Investigation',
              '12m',
              sub: 'by Michael Uche',
            ),
            Act(
              Icons.lock_outline_rounded,
              AppColors.danger,
              'Wallet restricted on DSP-00410',
              '1h',
              sub: 'by Sarah Johnson',
            ),
            Act(
              Icons.task_alt_rounded,
              AppColors.success,
              'DSP-00407 resolved',
              '1d',
              sub: 'by Linda Emmanuel',
            ),
          ],
        ),
        SizedBox(height: 18),
        HelpCard('How to investigate cases and request refunds.'),
      ],
    );
  }
}
