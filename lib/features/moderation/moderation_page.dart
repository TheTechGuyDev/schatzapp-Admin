import 'package:material_ui/material_ui.dart';

import '../../data/sample_support.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/kit.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Content & Safety: what users reported in the app (messages, Stories,
/// For You posts, profiles, groups). Admins only ever see reported content,
/// never private chats, and Private Chat Lock content is never shown.
class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

(IconData, Color) _kindIcon(String k) => switch (k) {
  'Message' => (Icons.chat_bubble_outline_rounded, AppColors.brand),
  'Story' => (Icons.amp_stories_outlined, AppColors.pink),
  'For You post' => (Icons.play_circle_outline_rounded, AppColors.warning),
  'Profile' => (Icons.person_outline_rounded, AppColors.info),
  'Group' => (Icons.groups_outlined, AppColors.teal),
  _ => (Icons.flag_outlined, AppColors.textSecondary),
};

ChipKind _statusKind(String s) => switch (s) {
  'Pending' => ChipKind.warning,
  'Under Review' => ChipKind.info,
  'Action Taken' => ChipKind.success,
  _ => ChipKind.neutral,
};

class _ModerationPageState extends State<ModerationPage> {
  int _tab = 0;
  String _reason = 'All Reasons';

  static const _tabs = [
    'All Reports',
    'Messages',
    'Stories',
    'For You Posts',
    'Profiles',
    'Groups',
  ];

  List<ReportedItem> get _rows => SampleSupport.reported.where((r) {
    final okTab = switch (_tab) {
      1 => r.kind == 'Message',
      2 => r.kind == 'Story',
      3 => r.kind == 'For You post',
      4 => r.kind == 'Profile',
      5 => r.kind == 'Group',
      _ => true,
    };
    if (!okTab) return false;
    return _reason == 'All Reasons' || r.reason == _reason;
  }).toList();

  Future<void> _act(ReportedItem r, String action) async {
    final (title, msg, danger) = switch (action) {
      'remove' => (
        'Remove content',
        'The ${r.kind.toLowerCase()} is hidden for everyone and kept for '
            'the retention period as evidence.',
        true,
      ),
      'warn' => (
        'Warn user',
        '${r.reported} gets an in-app warning about the community rules.',
        false,
      ),
      'suspend' => (
        'Suspend account',
        '${r.reported} cannot use SchatzApp until the suspension ends. '
            'Their wallet stays intact.',
        true,
      ),
      'dispute' => (
        'Open a case',
        'A Reported User case is opened in Disputes with this report attached.',
        false,
      ),
      _ => (
        'Dismiss report',
        'The report is closed with no action against ${r.reported}.',
        false,
      ),
    };
    final reason = await askReason(
      context,
      title: title,
      message: msg,
      confirm: title,
      danger: danger,
    );
    if (reason != null && mounted) toast(context, '$title: done');
  }

  void _open(ReportedItem r) {
    showSidePanel<void>(
      context,
      title: r.id,
      subtitle: '${r.kind} reported for ${r.reason.toLowerCase()}',
      body: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              StatusChip(r.status, kind: _statusKind(r.status)),
              TintTag(r.kind, _kindIcon(r.kind).$2),
              if (r.count > 1) TintTag('${r.count} reports', AppColors.danger),
            ],
          ),
          const PanelSection('Reported content'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(r.preview, style: const TextStyle(fontSize: 12.5)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Only the reported item is shown. Admins cannot open the rest of '
            'the chat, and Private Chat Lock content is never available here.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const PanelSection('People'),
          InfoLine(
            'Reported account',
            r.reported,
            valueWidget: Row(
              children: [
                Avatar(name: r.reported, size: 24),
                const SizedBox(width: 6),
                Text(
                  r.reported,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InfoLine('Reported by', r.reporter),
          InfoLine('Reason', r.reason),
          InfoLine('Reported', r.time),
          const PanelSection('Previous reports on this account'),
          const TimelineEntry(
            title: 'Warned for spam',
            by: 'Linda Emmanuel',
            time: 'Oct 30, 2026',
          ),
          const TimelineEntry(
            title: 'Report dismissed',
            by: 'Michael Uche',
            time: 'Sep 12, 2026',
            last: true,
          ),
        ],
      ),
      actions: (ctx) => [
        OutlineButtonBox(label: 'Dismiss', onTap: () => _act(r, 'dismiss')),
        OutlineButtonBox(label: 'Warn user', onTap: () => _act(r, 'warn')),
        OutlineButtonBox(label: 'Open case', onTap: () => _act(r, 'dispute')),
        DangerButton(label: 'Remove content', onTap: () => _act(r, 'remove')),
      ],
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
              label: 'Open Reports',
              value: '73',
              change: '14 new today',
              icon: Icons.flag_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              positive: false,
            ),
            StatCard(
              label: 'Reported Messages',
              value: '41',
              change: '6.2% from last week',
              icon: Icons.chat_bubble_outline_rounded,
              color: AppColors.brand,
              background: AppColors.brandSoft,
            ),
            StatCard(
              label: 'Stories & For You',
              value: '22',
              change: '3 removed today',
              icon: Icons.play_circle_outline_rounded,
              color: AppColors.pink,
              background: AppColors.pinkSoft,
            ),
            StatCard(
              label: 'Accounts Actioned',
              value: '18',
              change: 'this month',
              icon: Icons.gpp_maybe_outlined,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
            ),
            StatCard(
              label: 'Avg Review Time',
              value: '47m',
              change: '9.8% faster',
              icon: Icons.timer_outlined,
              color: AppColors.success,
              background: AppColors.successSoft,
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
            filters: [
              const SearchBox(
                hint: 'Search report, user or username',
                width: 280,
              ),
              FilterBox(
                label: 'Reason',
                value: _reason,
                options: const [
                  'All Reasons',
                  'Scam or fraud',
                  'Harassment',
                  'Hate speech',
                  'Nudity or sexual content',
                  'Impersonating SchatzApp',
                  'Spam',
                ],
                onChanged: (v) => setState(() => _reason = v),
              ),
            ],
            cols: const [
              Col('Report', 22),
              Col('Reported account', 15),
              Col('Reason', 15),
              Col('Reports', 7),
              Col('Reported by', 13),
              Col('Status', 11),
              Col('', 5, align: TextAlign.center),
            ],
            onRowTap: (i) => _open(rows[i]),
            rows: [
              for (final r in rows)
                [
                  Row(
                    children: [
                      TintIcon(_kindIcon(r.kind).$1, _kindIcon(r.kind).$2),
                      const SizedBox(width: 10),
                      Expanded(child: TwoLine('${r.kind} · ${r.id}', r.time)),
                    ],
                  ),
                  Text(
                    r.reported,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(r.reason, style: const TextStyle(fontSize: 12)),
                  Text(
                    '${r.count}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: r.count > 2 ? AppColors.danger : AppColors.text,
                    ),
                  ),
                  Text(r.reporter, style: const TextStyle(fontSize: 12)),
                  StatusChip(r.status, kind: _statusKind(r.status)),
                  RowMenu(
                    items: const [
                      ('open', 'Review', false),
                      ('warn', 'Warn user', false),
                      ('suspend', 'Suspend account', true),
                      ('remove', 'Remove content', true),
                      ('dismiss', 'Dismiss', false),
                    ],
                    onSelected: (v) => v == 'open' ? _open(r) : _act(r, v),
                  ),
                ],
            ],
            narrowRow: (i) => NarrowRow(
              leading: TintIcon(
                _kindIcon(rows[i].kind).$1,
                _kindIcon(rows[i].kind).$2,
              ),
              title: '${rows[i].kind}: ${rows[i].reported}',
              subtitle: rows[i].reason,
              trailing: StatusChip(
                rows[i].status,
                kind: _statusKind(rows[i].status),
              ),
            ),
            footerNote:
                'Admins only see the item that was reported. Private chats '
                'and Private Chat Lock content are never visible here.',
            pageInfo: 'Showing 1 to ${rows.length} of 73 open reports',
            lastPage: 8,
          ),
          side: const SideStack(
            children: [
              DonutCard(
                title: 'Reports by Reason',
                centerTop: '312',
                centerBottom: 'This month',
                items: [
                  ('Scam or fraud', 118, AppColors.danger),
                  ('Spam', 74, AppColors.warning),
                  ('Harassment', 52, AppColors.brand),
                  ('Impersonation', 38, AppColors.info),
                  ('Sexual content', 30, AppColors.pink),
                ],
              ),
              SizedBox(height: 18),
              BarsCard(
                title: 'Private Groups (metadata only)',
                subtitle: 'From the private group audit trail',
                items: [
                  ('Created', 0.6, '214', AppColors.brand),
                  ('Converted', 0.3, '96', AppColors.info),
                  ('Removed', 0.12, '38', AppColors.danger),
                ],
              ),
              SizedBox(height: 18),
              ActivityCard(
                title: 'Recent Actions',
                items: [
                  Act(
                    Icons.delete_outline_rounded,
                    AppColors.danger,
                    'For You post removed',
                    '20m',
                    sub: 'Nudity · by Linda Emmanuel',
                  ),
                  Act(
                    Icons.gpp_maybe_outlined,
                    AppColors.warning,
                    'quickcash_ng suspended 30 days',
                    '1h',
                    sub: 'Scam · by Sarah Johnson',
                  ),
                  Act(
                    Icons.check_circle_outline_rounded,
                    AppColors.success,
                    'Report RPT-88407 dismissed',
                    '2d',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
