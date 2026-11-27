import 'package:material_ui/material_ui.dart';

import '../../data/sample_support.dart';
import '../../theme/app_colors.dart';
import '../../widgets/kit.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Notifications (approved design): send push, in-app, email and SMS
/// messages to users or segments, schedule them, keep drafts and templates.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

(IconData, Color) _typeIcon(String t) => switch (t) {
  'User' => (Icons.group_outlined, AppColors.brand),
  'Transaction' => (Icons.account_balance_wallet_outlined, AppColors.success),
  'Product' => (Icons.card_giftcard_rounded, AppColors.warning),
  'Security' => (Icons.shield_outlined, AppColors.info),
  'System' => (Icons.campaign_outlined, AppColors.danger),
  'Marketing' => (Icons.redeem_outlined, AppColors.pink),
  _ => (Icons.notifications_none_rounded, AppColors.textSecondary),
};

class _NotificationsPageState extends State<NotificationsPage> {
  int _tab = 0;
  String _type = 'All Types';
  String _channel = 'All Channels';
  String _status = 'All Status';

  static const _tabs = [
    'All Notifications',
    'Scheduled',
    'Sent',
    'Drafts',
    'Templates',
  ];

  List<SentNotification> get _rows => SampleSupport.notifications.where((n) {
    final okTab = switch (_tab) {
      1 => n.status == 'Scheduled',
      2 => n.status != 'Scheduled',
      3 || 4 => false,
      _ => true,
    };
    if (!okTab) return false;
    if (_type != 'All Types' && n.type != _type) return false;
    if (_status != 'All Status' && n.status != _status) return false;
    if (_channel != 'All Channels') {
      final key = switch (_channel) {
        'Push' => 'push',
        'Email' => 'email',
        'SMS' => 'sms',
        _ => 'inapp',
      };
      if (!n.channels.contains(key)) return false;
    }
    return true;
  }).toList();

  Future<void> _compose() async {
    final title = TextEditingController();
    final body = TextEditingController();
    var type = 'User';
    var audience = 'All users';
    var schedule = false;
    final channels = <String>{'push', 'inapp'};
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          Widget channel(String key, String label, IconData icon) => FilterChip(
            selected: channels.contains(key),
            showCheckmark: false,
            avatar: Icon(icon, size: 16),
            label: Text(label, style: const TextStyle(fontSize: 12)),
            selectedColor: AppColors.brandSoft,
            side: const BorderSide(color: AppColors.border),
            onSelected: (v) =>
                set(() => v ? channels.add(key) : channels.remove(key)),
          );
          return AlertDialog(
            title: const Text(
              'Send notification',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FieldBlock(
                      'Title',
                      TextField(
                        controller: title,
                        maxLength: 60,
                        style: const TextStyle(fontSize: 13),
                        decoration: fieldDecoration('e.g. Weekend data bonus')
                            .copyWith(counterText: ''),
                      ),
                    ),
                    FieldBlock(
                      'Message',
                      TextField(
                        controller: body,
                        maxLines: 4,
                        maxLength: 240,
                        style: const TextStyle(fontSize: 13),
                        decoration: fieldDecoration('What should users see?'),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FieldBlock(
                            'Type',
                            DropField(
                              value: type,
                              options: const [
                                'User',
                                'Transaction',
                                'Product',
                                'Security',
                                'System',
                                'Marketing',
                              ],
                              onChanged: (v) => set(() => type = v),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FieldBlock(
                            'Audience',
                            DropField(
                              value: audience,
                              options: const [
                                'All users',
                                'Active users (30 days)',
                                'Users by country',
                                'KYC not completed',
                                'Users with unloaded gift cards',
                                'Single user',
                              ],
                              onChanged: (v) => set(() => audience = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                    FieldBlock(
                      'Channels',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          channel('push', 'Push', Icons.notifications_none),
                          channel(
                            'inapp',
                            'In-App',
                            Icons.phone_iphone_rounded,
                          ),
                          channel('email', 'Email', Icons.mail_outline_rounded),
                          channel('sms', 'SMS', Icons.sms_outlined),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        BrandSwitch(
                          value: schedule,
                          onChanged: (v) => set(() => schedule = v),
                        ),
                        const Text(
                          'Schedule for later',
                          style: TextStyle(fontSize: 12.5),
                        ),
                        if (schedule) ...[
                          const SizedBox(width: 10),
                          const Expanded(
                            child: OutlineButtonBox(
                              label: 'Nov 28, 2026 · 09:00 AM',
                              icon: Icons.event_outlined,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SampleNote(
                      'Private Chat Lock users get camouflaged notifications: '
                      'message previews from locked chats are never included.',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              OutlineButtonBox(
                label: 'Save draft',
                onTap: () => Navigator.pop(ctx, false),
              ),
              PrimaryButton(
                label: schedule ? 'Schedule' : 'Send now',
                icon: Icons.send_rounded,
                onTap: () {
                  if (title.text.trim().isNotEmpty &&
                      body.text.trim().isNotEmpty &&
                      channels.isNotEmpty) {
                    Navigator.pop(ctx, true);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
    if (ok == true && mounted) toast(context, 'Notification queued');
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
              label: 'Total Sent',
              value: '15,246',
              change: '18.6% from last month',
              icon: Icons.send_outlined,
              color: AppColors.brand,
              background: AppColors.brandSoft,
              spark: [3, 3.6, 3.4, 4, 4.6, 4.4, 5.2, 6],
            ),
            StatCard(
              label: 'Delivered',
              value: '14,032',
              change: '92.0% success rate',
              icon: Icons.mark_email_read_outlined,
              color: AppColors.success,
              background: AppColors.successSoft,
              spark: [3, 3.4, 3.6, 3.8, 4.2, 4.4, 4.8, 5.4],
            ),
            StatCard(
              label: 'Opened',
              value: '7,856',
              change: '56.0% open rate',
              icon: Icons.visibility_outlined,
              color: AppColors.warning,
              background: AppColors.warningSoft,
              spark: [3, 3.8, 3.4, 4, 3.6, 4.2, 3.8, 4],
            ),
            StatCard(
              label: 'Clicked',
              value: '2,341',
              change: '16.6% click rate',
              icon: Icons.touch_app_outlined,
              color: AppColors.info,
              background: AppColors.infoSoft,
              spark: [2, 2.4, 2.2, 2.8, 3, 2.9, 3.4, 3.6],
            ),
            StatCard(
              label: 'Failed',
              value: '1,214',
              change: '8.0% failure rate',
              icon: Icons.highlight_off_rounded,
              color: AppColors.danger,
              background: AppColors.dangerSoft,
              positive: false,
              spark: [3, 2.4, 2.8, 2.2, 2.6, 2.1, 2.4, 2],
            ),
          ],
        ),
        const SizedBox(height: 18),
        MainSideLayout(main: _main(), side: const _Side()),
      ],
    );
  }

  Widget _main() {
    if (_tab == 4) return _templates();
    final rows = _rows;
    const cols = [
      Col('Title', 26),
      Col('Type', 10),
      Col('Channel', 11),
      Col('Recipients', 11),
      Col('Status', 10),
      Col('Sent At', 11),
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
        PrimaryButton(
          label: 'Send Notification',
          icon: Icons.add,
          onTap: _compose,
        ),
      ],
      filters: [
        const FilterBox(
          label: 'Date Range',
          value: 'Nov 21 - Nov 27, 2026',
          options: ['Nov 21 - Nov 27, 2026', 'Last 30 days'],
          onChanged: _noop,
        ),
        FilterBox(
          label: 'Type',
          value: _type,
          options: const [
            'All Types',
            'User',
            'Transaction',
            'Product',
            'Security',
            'System',
            'Marketing',
          ],
          onChanged: (v) => setState(() => _type = v),
        ),
        FilterBox(
          label: 'Channel',
          value: _channel,
          options: const ['All Channels', 'Push', 'In-App', 'Email', 'SMS'],
          onChanged: (v) => setState(() => _channel = v),
        ),
        FilterBox(
          label: 'Status',
          value: _status,
          options: const [
            'All Status',
            'Delivered',
            'Sent',
            'Scheduled',
            'Failed',
          ],
          onChanged: (v) => setState(() => _status = v),
        ),
        OutlineButtonBox(
          label: 'Reset',
          icon: Icons.refresh_rounded,
          onTap: () => setState(() {
            _type = 'All Types';
            _channel = 'All Channels';
            _status = 'All Status';
          }),
        ),
      ],
      cols: cols,
      rows: [
        for (final n in rows)
          [
            Row(
              children: [
                TintIcon(_typeIcon(n.type).$1, _typeIcon(n.type).$2),
                const SizedBox(width: 10),
                Expanded(child: TwoLine(n.title, n.subtitle)),
              ],
            ),
            TintTag(n.type, _typeIcon(n.type).$2),
            Row(
              children: [
                for (final c in n.channels)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      switch (c) {
                        'push' => Icons.notifications_rounded,
                        'email' => Icons.mail_outline_rounded,
                        'sms' => Icons.sms_outlined,
                        _ => Icons.phone_iphone_rounded,
                      },
                      size: 16,
                      color: AppColors.brand,
                    ),
                  ),
              ],
            ),
            Text(n.recipients, style: const TextStyle(fontSize: 12)),
            TwoLine(
              '● ${n.status}',
              n.rate,
              topColor: switch (n.status) {
                'Delivered' => AppColors.success,
                'Sent' => AppColors.info,
                'Scheduled' => AppColors.warning,
                _ => AppColors.danger,
              },
            ),
            Text(n.sentAt, style: const TextStyle(fontSize: 11.5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SquareIconButton(
                  icon: Icons.bar_chart_rounded,
                  tooltip: 'Delivery report',
                ),
                const SizedBox(width: 6),
                RowMenu(
                  items: [
                    ('dup', 'Duplicate', false),
                    if (n.status == 'Scheduled') ('cancel', 'Cancel', true),
                    if (n.status == 'Failed') ('retry', 'Retry failed', false),
                  ],
                  onSelected: (v) => toast(context, switch (v) {
                    'dup' => 'Copied to drafts',
                    'cancel' => 'Scheduled notification cancelled',
                    _ => 'Retrying failed deliveries',
                  }),
                ),
              ],
            ),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: TintIcon(
          _typeIcon(rows[i].type).$1,
          _typeIcon(rows[i].type).$2,
        ),
        title: rows[i].title,
        subtitle:
            '${rows[i].recipients} · ${rows[i].sentAt.replaceAll('\n', ' ')}',
        trailing: TintTag(rows[i].status, AppColors.brand),
      ),
      empty: _tab == 3 ? 'No drafts saved.' : 'No notifications here.',
      pageInfo: 'Showing 1 to ${rows.length} of 1,246 notifications',
      lastPage: 156,
    );
  }

  Widget _templates() {
    const templates = [
      ('Welcome to SchatzApp', 'User', 'Sent automatically after sign-up'),
      (
        'Wallet top-up successful',
        'Transaction',
        'After every successful top-up',
      ),
      (
        'Schatz Gift Card received',
        'Product',
        'When someone sends a gift card',
      ),
      ('Gift card not loaded yet', 'Product', 'Reminder 3 days after delivery'),
      ('KYC reminder', 'Security', 'Weekly until KYC is complete'),
      ('Login from new device', 'Security', 'On every new device login'),
      (
        'Bank transfer confirmed',
        'Transaction',
        'When a bank deposit is approved',
      ),
    ];
    return TableCard(
      tabs: _tabs,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      toolbar: [
        PrimaryButton(
          label: 'New Template',
          icon: Icons.add,
          onTap: () => toast(context, 'Template editor opened'),
        ),
      ],
      checkbox: false,
      cols: const [
        Col('Template', 30),
        Col('Type', 12),
        Col('Trigger', 30),
        Col('', 6, align: TextAlign.center),
      ],
      rows: [
        for (final t in templates)
          [
            Row(
              children: [
                TintIcon(_typeIcon(t.$2).$1, _typeIcon(t.$2).$2),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.$1,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            TintTag(t.$2, _typeIcon(t.$2).$2),
            Text(t.$3, style: const TextStyle(fontSize: 12)),
            RowMenu(
              items: const [
                ('edit', 'Edit', false),
                ('test', 'Send test to me', false),
              ],
              onSelected: (v) => toast(
                context,
                v == 'edit' ? 'Template editor opened' : 'Test sent',
              ),
            ),
          ],
      ],
      narrowRow: (i) => NarrowRow(
        leading: TintIcon(
          _typeIcon(templates[i].$2).$1,
          _typeIcon(templates[i].$2).$2,
        ),
        title: templates[i].$1,
        subtitle: templates[i].$3,
        trailing: TintTag(templates[i].$2, AppColors.brand),
      ),
    );
  }
}

void _noop(String _) {}

class _Side extends StatelessWidget {
  const _Side();

  @override
  Widget build(BuildContext context) {
    return const SideStack(
      children: [
        DonutCard(
          title: 'Notification Channels',
          centerTop: '15,246',
          centerBottom: 'Total Sent',
          items: [
            ('Push Notifications', 9125, AppColors.brand),
            ('Email', 4856, AppColors.success),
            ('In-App', 987, AppColors.warning),
            ('SMS', 278, AppColors.info),
          ],
        ),
        SizedBox(height: 18),
        BarsCard(
          title: 'Notification Types',
          items: [
            ('Transaction', 0.385, '5,862', AppColors.success),
            ('Security', 0.213, '3,245', AppColors.info),
            ('Marketing', 0.187, '2,856', AppColors.pink),
            ('System', 0.141, '2,145', AppColors.danger),
            ('User', 0.074, '1,138', AppColors.brand),
          ],
        ),
        SizedBox(height: 18),
        ActivityCard(
          title: 'Recent Activity',
          items: [
            Act(
              Icons.group_outlined,
              AppColors.brand,
              'Welcome to SchatzApp! sent',
              '10:30 AM',
            ),
            Act(
              Icons.account_balance_wallet_outlined,
              AppColors.success,
              'Wallet Top Up Successful sent',
              '09:15 AM',
            ),
            Act(
              Icons.card_giftcard_rounded,
              AppColors.warning,
              'Schatz Gift Card Received sent',
              '08:20 AM',
            ),
            Act(
              Icons.shield_outlined,
              AppColors.danger,
              'KYC Reminder scheduled',
              '02:00 PM',
            ),
          ],
        ),
        SizedBox(height: 18),
        HelpCard('Learn how to create and manage notifications effectively.'),
      ],
    );
  }
}
