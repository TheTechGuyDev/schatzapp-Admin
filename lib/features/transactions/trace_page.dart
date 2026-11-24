import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sample_finance.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/money.dart';
import '../../widgets/page_body.dart';
import '../../widgets/ui.dart';
import '../users/user_widgets.dart' show toast;

/// Transaction Trace: follows a chain of ledger movements from the original
/// funding source to the final use, using transaction references.
class TracePage extends StatefulWidget {
  const TracePage({super.key, this.initialRef});
  final String? initialRef;

  @override
  State<TracePage> createState() => _TracePageState();
}

class _Hop {
  const _Hop({
    required this.title,
    required this.kind,
    required this.from,
    required this.to,
    required this.amount,
    required this.ref,
    required this.provider,
    required this.when,
    required this.icon,
    this.note,
  });

  final String title;
  final MoneyKind kind;
  final String from;
  final String to;
  final String amount;
  final String ref;
  final String provider;
  final String when;
  final String icon;
  final String? note;
}

const _chain = <_Hop>[
  _Hop(
    title: 'Funding source: wallet top-up by card',
    kind: MoneyKind.fiatIn,
    from: 'Visa •••• 4417 (David Brown)',
    to: 'David Brown · SA-1000244',
    amount: '₦50,500 paid, SFZ 5,050 credited',
    ref: 'TXN-2026-112001',
    provider: 'Paystack · PSK-T0901772',
    when: 'Nov 20, 2026 · 08:40',
    icon: 'topup',
    note: 'Real money entered SchatzApp here.',
  ),
  _Hop(
    title: 'Schatz Gift Card purchased',
    kind: MoneyKind.internal,
    from: 'David Brown · SA-1000244',
    to: 'Gift card GC-8F2A-19D4',
    amount: 'SFZ 5,000 (fee SFZ 50)',
    ref: 'TXN-2026-112010',
    provider: 'SchatzApp ledger',
    when: 'Nov 20, 2026 · 09:02',
    icon: 'giftcard',
  ),
  _Hop(
    title: 'Gift card loaded',
    kind: MoneyKind.internal,
    from: 'Gift card GC-8F2A-19D4',
    to: 'Abiola Martins · SA-1000231',
    amount: 'SFZ 5,000',
    ref: 'TXN-2026-112131',
    provider: 'SchatzApp ledger',
    when: 'Nov 20, 2026 · 09:12',
    icon: 'giftcard',
  ),
  _Hop(
    title: 'Schatz transfer',
    kind: MoneyKind.internal,
    from: 'Abiola Martins · SA-1000231',
    to: 'Chinedu Okafor · SA-1000232',
    amount: 'SFZ 2,500',
    ref: 'TXN-2026-112301',
    provider: 'SchatzApp ledger',
    when: 'Nov 23, 2026 · 10:30',
    icon: 'transfer',
    note: 'SFZ 2,500 from this card stays in Abiola Martins\' wallet.',
  ),
  _Hop(
    title: 'Final use: airtime purchase',
    kind: MoneyKind.service,
    from: 'Chinedu Okafor · SA-1000232',
    to: 'MTN Nigeria 0806 •••• 934',
    amount: 'SFZ 300',
    ref: 'TXN-2026-112322',
    provider: 'Reloadly · RLD-88412093',
    when: 'Nov 23, 2026 · 11:02',
    icon: 'airtime',
    note: 'Value left SchatzApp to a third-party provider here.',
  ),
];

class _TracePageState extends State<TracePage> {
  late final _search = TextEditingController(
    text: widget.initialRef ?? 'GC-8F2A-19D4',
  );
  bool _forward = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hops = _forward ? _chain : _chain.reversed.toList();
    return PageBody(
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => context.go('/transactions'),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: AppColors.brand,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              '  /  Transaction Trace',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: 18,
          child: LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 760;
              final field = SizedBox(
                width: narrow ? c.maxWidth : 420,
                child: SearchBox(
                  controller: _search,
                  hint: 'Transaction reference, gift card ID or account no.',
                  width: narrow ? c.maxWidth : 420,
                ),
              );
              final toggle = SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text(
                      'Where it went',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(
                      'Where it came from',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                selected: {_forward},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _forward = s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.brandSoft,
                  selectedForegroundColor: AppColors.brand,
                  side: const BorderSide(color: AppColors.border),
                ),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader(
                    title: 'Trace funds',
                    subtitle: 'Follow money from its original source through each ledger movement to its final use.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      field,
                      toggle,
                      PrimaryButton(
                        label: 'Trace',
                        icon: Icons.account_tree_outlined,
                        onTap: () => toast(
                          context,
                          'Showing the sample chain for ${_search.text}.',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        const TileGrid(
          minTileWidth: 200,
          maxColumns: 4,
          gap: 18,
          allowedColumns: [1, 2, 4],
          children: [
            _Summary(
              Icons.login_rounded,
              AppColors.success,
              'Original source',
              '₦50,500 by card',
              'Paystack · real money in',
            ),
            _Summary(
              Icons.route_rounded,
              AppColors.brand,
              'Ledger movements',
              '5 steps',
              '3 internal, 1 in, 1 service',
            ),
            _Summary(
              Icons.people_alt_outlined,
              AppColors.info,
              'Accounts involved',
              '3 users',
              'David, Abiola, Chinedu',
            ),
            _Summary(
              Icons.logout_rounded,
              AppColors.warning,
              'Final use',
              'Airtime (MTN)',
              'Reloadly · SFZ 300',
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(
                title: 'Fund flow',
                subtitle: _forward
                    ? 'From funding source to final use'
                    : 'From final use back to funding source',
                trailing: Wrap(
                  spacing: 10,
                  children: [
                    OutlineButtonBox(
                      label: 'Add to Case',
                      icon: Icons.gavel_rounded,
                      onTap: () => toast(context, 'Cases connect in Phase 5.'),
                    ),
                    OutlineButtonBox(
                      label: 'Export',
                      icon: Icons.file_download_outlined,
                      onTap: () =>
                          toast(context, 'Export connects with the backend.'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < hops.length; i++)
                _HopTile(
                  hop: hops[i],
                  step: _forward ? i + 1 : hops.length - i,
                  last: i == hops.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary(this.icon, this.color, this.label, this.value, this.sub);
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 16,
      child: Row(
        children: [
          IconCircle(
            icon: icon,
            color: color,
            background: color.withValues(alpha: 0.1),
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HopTile extends StatelessWidget {
  const _HopTile({required this.hop, required this.step, required this.last});
  final _Hop hop;
  final int step;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final ic = txIcon(hop.icon);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ic.$2.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: ic.$2.withValues(alpha: 0.4)),
                  ),
                  child: Icon(ic.$1, size: 18, color: ic.$2),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: last ? 0 : 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Step $step',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        hop.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      MoneyKindTag(hop.kind),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Party(hop.from),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      _Party(hop.to),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 18,
                    runSpacing: 6,
                    children: [
                      _Meta('Amount', hop.amount, bold: true),
                      _Meta('Reference', hop.ref, color: AppColors.brand),
                      _Meta('Provider', hop.provider),
                      _Meta('Time', hop.when),
                    ],
                  ),
                  if (hop.note != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              hop.note!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.navText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Party extends StatelessWidget {
  const _Party(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final name = text.split('·').first.trim();
    final isPerson =
        !name.startsWith('Gift') &&
        !name.startsWith('Visa') &&
        !name.startsWith('MTN');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPerson) ...[
            Avatar(name: name, size: 22),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.label, this.value, {this.bold = false, this.color});
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? AppColors.text,
          ),
        ),
      ],
    );
  }
}
