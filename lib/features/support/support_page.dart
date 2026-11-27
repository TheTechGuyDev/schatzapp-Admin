import 'package:material_ui/material_ui.dart';

import '../../data/sample_support.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/charts.dart';
import '../../widgets/kit.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Support Tickets (approved design): customer enquiries with priority,
/// category, SLA, assignment, a reply thread and internal notes.
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

ChipKind _statusKind(String s) => switch (s) {
  'Open' => ChipKind.warning,
  'In Progress' => ChipKind.info,
  'Resolved' => ChipKind.success,
  _ => ChipKind.neutral,
};

Color _catColor(String c) => switch (c) {
  'Transactions' => AppColors.brand,
  'KYC Verification' => AppColors.success,
  'Cards' => AppColors.info,
  'Wallet' => AppColors.warning,
  'Airtime & Data' => AppColors.teal,
  'Disputes' => AppColors.danger,
  'Gift Cards' => AppColors.pink,
  _ => AppColors.textSecondary,
};

Color _priColor(String p) => switch (p) {
  'High' => AppColors.danger,
  'Medium' => AppColors.warning,
  _ => AppColors.success,
};

class _SupportPageState extends State<SupportPage> {
  int _tab = 0;
  String _status = 'All Status';
  String _priority = 'All Priority';
  String _category = 'All Category';
  String _agent = 'All Agents';

  static const _tabs = [
    'All Tickets (1,256)',
    'Open (316)',
    'In Progress (238)',
    'Resolved (642)',
    'Closed (382)',
    'SLA Breached (28)',
  ];

  List<Ticket> get _rows => SampleSupport.tickets.where((t) {
    final okTab = switch (_tab) {
      1 => t.status == 'Open',
      2 => t.status == 'In Progress',
      3 => t.status == 'Resolved',
      4 => t.status == 'Closed',
      5 => t.slaBreached,
      _ => true,
    };
    if (!okTab) return false;
    if (_status != 'All Status' && t.status != _status) return false;
    if (_priority != 'All Priority' && t.priority != _priority) return false;
    if (_category != 'All Category' && t.category != _category) return false;
    if (_agent != 'All Agents' && t.assignee != _agent) return false;
    return true;
  }).toList();

  void _reset() => setState(() {
    _status = 'All Status';
    _priority = 'All Priority';
    _category = 'All Category';
    _agent = 'All Agents';
  });

  Future<void> _newTicket() async {
    final user = TextEditingController();
    final subject = TextEditingController();
    final msg = TextEditingController();
    var cat = 'Account';
    var pri = 'Medium';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text(
            'New ticket',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldBlock(
                  'User',
                  TextField(
                    controller: user,
                    style: const TextStyle(fontSize: 13),
                    decoration: fieldDecoration(
                      'Account number, phone or email',
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: FieldBlock(
                        'Category',
                        DropField(
                          value: cat,
                          options: const [
                            'Account',
                            'Transactions',
                            'Wallet',
                            'Cards',
                            'Gift Cards',
                            'Airtime & Data',
                            'KYC Verification',
                            'Disputes',
                          ],
                          onChanged: (v) => set(() => cat = v),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FieldBlock(
                        'Priority',
                        DropField(
                          value: pri,
                          options: const ['High', 'Medium', 'Low'],
                          onChanged: (v) => set(() => pri = v),
                        ),
                      ),
                    ),
                  ],
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
                  'Message',
                  TextField(
                    controller: msg,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 13),
                    decoration: fieldDecoration('Details'),
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
            PrimaryButton(
              label: 'Create ticket',
              onTap: () {
                if (subject.text.trim().isNotEmpty) Navigator.pop(ctx, true);
              },
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) toast(context, 'Ticket TKT-2026-001257 created');
  }

  void _open(Ticket t) {
    final reply = TextEditingController();
    var internal = false;
    showSidePanel<void>(
      context,
      title: t.id,
      subtitle: t.subject,
      width: 600,
      body: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(t.status, kind: _statusKind(t.status)),
                TintTag(t.category, _catColor(t.category)),
                TintTag('${t.priority} priority', _priColor(t.priority)),
                if (t.slaBreached)
                  const TintTag('SLA breached', AppColors.danger),
              ],
            ),
            const PanelSection('Customer'),
            Row(
              children: [
                Avatar(name: t.user, size: 38),
                const SizedBox(width: 10),
                Expanded(child: TwoLine(t.user, t.email)),
              ],
            ),
            const PanelSection('Ticket'),
            InfoLine('Created', t.created),
            InfoLine('Assigned to', t.assignee),
            InfoLine('Last updated', t.updated),
            const PanelSection('Conversation'),
            for (final (fromUser, name, text, time) in t.thread)
              Align(
                alignment: fromUser
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: fromUser
                        ? AppColors.background
                        : AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name · $time',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(text, style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: reply,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: fieldDecoration(
                internal
                    ? 'Internal note (customer will not see this)'
                    : 'Reply to the customer',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                BrandSwitch(
                  value: internal,
                  onChanged: (v) => set(() => internal = v),
                ),
                const Text('Internal note', style: TextStyle(fontSize: 12)),
                const Spacer(),
                PrimaryButton(
                  label: internal ? 'Add note' : 'Send reply',
                  icon: Icons.send_rounded,
                  onTap: () {
                    if (reply.text.trim().isEmpty) return;
                    reply.clear();
                    toast(context, internal ? 'Note added' : 'Reply sent');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: (ctx) => [
        OutlineButtonBox(
          label: 'Convert to dispute',
          icon: Icons.shield_outlined,
          onTap: () async {
            final r = await askReason(
              context,
              title: 'Convert to dispute',
              message:
                  'A dispute case will be opened with this ticket attached.',
              confirm: 'Open dispute',
            );
            if (r != null && mounted) toast(context, 'Dispute case opened');
          },
        ),
        OutlineButtonBox(
          label: 'Escalate',
          icon: Icons.priority_high_rounded,
          onTap: () => toast(context, 'Escalated to Technical team'),
        ),
        PrimaryButton(
          label: 'Mark resolved',
          icon: Icons.check_rounded,
          onTap: () {
            Navigator.pop(ctx);
            toast(context, '${t.id} resolved');
          },
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
              label: 'Total Tickets',
              value: '1,256',
              change: '12.6% from last month',
              icon: Icons.mail_outline_rounded,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [3, 4, 3.6, 4.8, 5, 5.4, 6.2, 7],
            ),
            StatCard(
              label: 'Open Tickets',
              value: '316',
              change: '8.3% from last month',
              icon: Icons.drafts_outlined,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [2, 3, 2.6, 3.4, 3.2, 3.8, 4.4, 4.8],
            ),
            StatCard(
              label: 'In Progress',
              value: '238',
              change: '5.7% from last month',
              icon: Icons.mark_email_unread_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              spark: [3, 3.4, 3.2, 3.8, 4.2, 3.9, 4.4, 4.6],
            ),
            StatCard(
              label: 'Resolved',
              value: '642',
              change: '18.9% from last month',
              icon: Icons.mark_email_read_outlined,
              color: AppColors.info,
              background: AppColors.infoSoft,
              spark: [2, 2.6, 3, 3.4, 3.2, 4, 4.6, 5.2],
            ),
            StatCard(
              label: 'Closed',
              value: '382',
              change: '10.1% from last month',
              icon: Icons.unsubscribe_outlined,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              spark: [5, 4.4, 4.8, 4, 3.6, 3.8, 3.2, 3],
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
      Col('Ticket ID', 14),
      Col('Subject', 15),
      Col('User', 17),
      Col('Category', 12),
      Col('Priority', 8),
      Col('Status', 10),
      Col('Assigned To', 13),
      Col('Updated At', 10),
      Col('Actions', 8, align: TextAlign.center),
    ];
    return TableCard(
      tabs: _tabs,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      toolbar: [
        const OutlineButtonBox(
          label: 'Filters',
          icon: Icons.filter_alt_outlined,
        ),
        const OutlineButtonBox(
          label: 'Export',
          icon: Icons.file_download_outlined,
          trailingChevron: true,
        ),
        PrimaryButton(label: 'New Ticket', icon: Icons.add, onTap: _newTicket),
      ],
      filters: [
        const FilterBox(
          label: 'Date Range',
          value: 'Nov 21 - Nov 27, 2026',
          options: ['Nov 21 - Nov 27, 2026', 'Last 30 days', 'This year'],
          onChanged: _noop,
        ),
        FilterBox(
          label: 'Status',
          value: _status,
          width: 150,
          options: const [
            'All Status',
            'Open',
            'In Progress',
            'Resolved',
            'Closed',
          ],
          onChanged: (v) => setState(() => _status = v),
        ),
        FilterBox(
          label: 'Priority',
          value: _priority,
          width: 140,
          options: const ['All Priority', 'High', 'Medium', 'Low'],
          onChanged: (v) => setState(() => _priority = v),
        ),
        FilterBox(
          label: 'Category',
          value: _category,
          options: const [
            'All Category',
            'Account',
            'Transactions',
            'Wallet',
            'Cards',
            'Gift Cards',
            'Airtime & Data',
            'KYC Verification',
            'Disputes',
          ],
          onChanged: (v) => setState(() => _category = v),
        ),
        FilterBox(
          label: 'Assigned To',
          value: _agent,
          options: const [
            'All Agents',
            'Sarah Johnson',
            'Michael Uche',
            'Linda Emmanuel',
            'James Wilson',
          ],
          onChanged: (v) => setState(() => _agent = v),
        ),
        OutlineButtonBox(
          label: 'Reset',
          icon: Icons.refresh_rounded,
          onTap: _reset,
        ),
      ],
      cols: cols,
      onRowTap: (i) => _open(rows[i]),
      rows: [
        for (final t in rows)
          [
            TwoLine(t.id, 'Created: ${t.created}', topColor: AppColors.brand),
            Text(
              t.subject,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Avatar(name: t.user, size: 28),
                const SizedBox(width: 8),
                Expanded(child: TwoLine(t.user, t.email)),
              ],
            ),
            TintTag(t.category, _catColor(t.category)),
            TintTag(t.priority, _priColor(t.priority)),
            StatusChip(t.status, kind: _statusKind(t.status)),
            Row(
              children: [
                Avatar(name: t.assignee, size: 24),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.assignee,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            Text(t.updated, style: const TextStyle(fontSize: 11.5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareIconButton(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View',
                  onTap: () => _open(t),
                ),
                const SizedBox(width: 6),
                RowMenu(
                  items: const [
                    ('assign', 'Reassign', false),
                    ('resolve', 'Mark resolved', false),
                    ('close', 'Close ticket', true),
                  ],
                  onSelected: (v) => toast(
                    context,
                    v == 'assign'
                        ? 'Ticket reassigned'
                        : v == 'resolve'
                        ? 'Ticket resolved'
                        : 'Ticket closed',
                  ),
                ),
              ],
            ),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: Avatar(name: rows[i].user, size: 36),
        title: rows[i].subject,
        subtitle: '${rows[i].id} · ${rows[i].user}',
        trailing: StatusChip(rows[i].status, kind: _statusKind(rows[i].status)),
      ),
      empty: 'No tickets match these filters.',
      pageInfo: 'Showing 1 to ${rows.length} of 1,256 tickets',
      lastPage: 157,
    );
  }
}

void _noop(String _) {}

class _Side extends StatelessWidget {
  const _Side();

  @override
  Widget build(BuildContext context) {
    return SideStack(
      children: [
        const DonutCard(
          title: 'Tickets Overview',
          centerTop: '1,256',
          centerBottom: 'Total',
          items: [
            ('Open', 316, AppColors.warning),
            ('In Progress', 238, AppColors.info),
            ('Resolved', 642, AppColors.success),
            ('Closed', 382, AppColors.grey),
            ('SLA Breached', 28, AppColors.danger),
          ],
        ),
        const SizedBox(height: 18),
        const BarsCard(
          title: 'Tickets by Priority',
          items: [
            ('High', 0.363, '456 (36.3%)', AppColors.danger),
            ('Medium', 0.40, '502 (40.0%)', AppColors.warning),
            ('Low', 0.237, '298 (23.7%)', AppColors.success),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CardHeader(title: 'Response Time (Average)'),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2h 45m',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '↓ 12.4% from last month',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Sparkline(
                    values: const [5, 4.6, 4.9, 4.2, 3.8, 3.4, 3.6, 3],
                    color: AppColors.brand,
                    width: 120,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const ActivityCard(
          title: 'Recent Activities',
          items: [
            Act(
              Icons.mark_email_unread_outlined,
              AppColors.brand,
              'Ticket TKT-001255 updated',
              '5 mins ago',
              sub: 'by Michael Uche',
            ),
            Act(
              Icons.check_circle_outline_rounded,
              AppColors.success,
              'Ticket TKT-001252 resolved',
              '25 mins ago',
              sub: 'by Sarah Johnson',
            ),
            Act(
              Icons.add_comment_outlined,
              AppColors.info,
              'New ticket TKT-001256 created',
              '1 hour ago',
              sub: 'by John Okafor',
            ),
            Act(
              Icons.person_add_alt_outlined,
              AppColors.warning,
              'TKT-001253 assigned to Linda',
              '2 hours ago',
            ),
          ],
        ),
        const SizedBox(height: 18),
        const HelpCard('Learn how to manage support tickets effectively.'),
      ],
    );
  }
}
