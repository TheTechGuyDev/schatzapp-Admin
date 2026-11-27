import 'package:material_ui/material_ui.dart';

import '../../data/sample_support.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/kit.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Account Requests from the app that need an admin: name changes
/// (name_change_requests), sign-ups from unsupported countries and account
/// closures (records are kept for the retention period).
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

ChipKind _kind(String s) => switch (s) {
  'Pending' || 'Pending wallet check' => ChipKind.warning,
  'Approved' || 'Closed' => ChipKind.success,
  'Rejected' => ChipKind.danger,
  _ => ChipKind.info,
};

class _RequestsPageState extends State<RequestsPage> {
  int _tab = 0;

  static const _tabs = [
    'Name Changes (3)',
    'Unsupported Countries',
    'Account Closures',
  ];

  Future<void> _decide(NameChange n, bool approve) async {
    final r = await askReason(
      context,
      title: approve ? 'Approve name change' : 'Reject name change',
      message:
          '"${n.current}" to "${n.requested}". The user is notified either '
          'way.',
      confirm: approve ? 'Approve' : 'Reject',
      danger: !approve,
      hint: 'Admin note (required, saved on the request)',
    );
    if (r != null && mounted) {
      toast(context, approve ? 'Name change approved' : 'Name change rejected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        const TileGrid(
          minTileWidth: 200,
          maxColumns: 4,
          gap: 18,
          allowedColumns: [1, 2, 4],
          children: [
            StatCard(
              label: 'Pending Name Changes',
              value: '3',
              change: 'Oldest 5 hours ago',
              icon: Icons.badge_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
            ),
            StatCard(
              label: 'Unsupported Sign-ups',
              value: '214',
              change: 'Top: United States',
              icon: Icons.public_off_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
            ),
            StatCard(
              label: 'Closure Requests',
              value: '12',
              change: 'this month',
              icon: Icons.no_accounts_outlined,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
            ),
            StatCard(
              label: 'Records on Legal Hold',
              value: '4',
              change: 'Closed accounts',
              icon: Icons.gavel_rounded,
              color: AppColors.info,
              background: AppColors.infoSoft,
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(
          main: switch (_tab) {
            1 => _unsupported(),
            2 => _closures(),
            _ => _names(),
          },
          side: const SideStack(
            children: [
              BarsCard(
                title: 'Unsupported Sign-ups by Country',
                subtitle: 'Helps decide where to launch next',
                items: [
                  ('United States', 0.42, '90', AppColors.brand),
                  ('Canada', 0.21, '45', AppColors.info),
                  ('India', 0.16, '34', AppColors.warning),
                  ('France', 0.12, '26', AppColors.teal),
                  ('Others', 0.09, '19', AppColors.grey),
                ],
              ),
              SizedBox(height: 18),
              HelpCard(
                'Closed accounts are marked deleted. Their financial records '
                'stay for the retention period unless on legal hold.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _names() {
    const rows = SampleSupport.nameChanges;
    return TableCard(
      tabs: _tabs,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      checkbox: false,
      cols: const [
        Col('Request', 12),
        Col('User', 16),
        Col('Current name', 16),
        Col('Requested name', 18),
        Col('Status', 10),
        Col('Requested', 11),
        Col('Actions', 14, align: TextAlign.center),
      ],
      rows: [
        for (final n in rows)
          [
            Text(
              n.id,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brand,
              ),
            ),
            Row(
              children: [
                Avatar(name: n.user, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(n.user, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            Text(n.current, style: const TextStyle(fontSize: 12)),
            Text(
              n.requested,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            StatusChip(n.status, kind: _kind(n.status)),
            Text(n.time, style: const TextStyle(fontSize: 11.5)),
            n.status == 'Pending'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareIconButton(
                        icon: Icons.check_rounded,
                        tooltip: 'Approve',
                        color: AppColors.success,
                        onTap: () => _decide(n, true),
                      ),
                      const SizedBox(width: 6),
                      SquareIconButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Reject',
                        color: AppColors.danger,
                        onTap: () => _decide(n, false),
                      ),
                    ],
                  )
                : Text(
                    n.note ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: Avatar(name: rows[i].user, size: 36),
        title: rows[i].requested,
        subtitle: 'from ${rows[i].current} · ${rows[i].time}',
        trailing: StatusChip(rows[i].status, kind: _kind(rows[i].status)),
      ),
      onRowTap: (i) {
        if (rows[i].status == 'Pending') _decide(rows[i], true);
      },
    );
  }

  Widget _unsupported() {
    const rows = SampleSupport.unsupportedSignups;
    return TableCard(
      tabs: _tabs,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      checkbox: false,
      toolbar: const [
        OutlineButtonBox(label: 'Export', icon: Icons.file_download_outlined),
      ],
      cols: const [
        Col('Phone number', 22),
        Col('Dial code', 10),
        Col('Country', 22),
        Col('Attempted', 14),
      ],
      rows: [
        for (final r in rows)
          [
            Text(r.$1, style: const TextStyle(fontSize: 12)),
            Text(r.$2, style: const TextStyle(fontSize: 12)),
            Text(
              r.$3,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(r.$4, style: const TextStyle(fontSize: 11.5)),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: const TintIcon(Icons.public_off_outlined, AppColors.warning),
        title: rows[i].$3,
        subtitle: '${rows[i].$1} · ${rows[i].$4}',
        trailing: const SizedBox(),
      ),
      footerNote:
          'Phone numbers are masked. Enable a country in System Settings > '
          'Countries to let these users register.',
    );
  }

  Widget _closures() {
    const rows = SampleSupport.closures;
    return TableCard(
      tabs: _tabs,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      checkbox: false,
      cols: const [
        Col('User', 18),
        Col('Account', 15),
        Col('Requested', 13),
        Col('Status', 16),
        Col('Records kept until', 14),
      ],
      rows: [
        for (final r in rows)
          [
            Row(
              children: [
                Avatar(name: r.$1, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(r.$1, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            Text(r.$2, style: const TextStyle(fontSize: 12)),
            Text(r.$3, style: const TextStyle(fontSize: 12)),
            StatusChip(r.$4, kind: _kind(r.$4)),
            Text(r.$5, style: const TextStyle(fontSize: 12)),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: Avatar(name: rows[i].$1, size: 36),
        title: rows[i].$1,
        subtitle: rows[i].$2,
        trailing: StatusChip(rows[i].$4, kind: _kind(rows[i].$4)),
      ),
      footerNote:
          'A wallet must have a zero balance (or a settled refund) before an '
          'account is closed. Financial records are retained, not deleted.',
    );
  }
}
