import 'package:material_ui/material_ui.dart';

import '../data/sample_finance.dart';
import '../theme/app_colors.dart';

/// Icon and colour for a transaction type key.
(IconData, Color) txIcon(String key) => switch (key) {
  'transfer' => (Icons.swap_horiz_rounded, AppColors.brand),
  'airtime' => (Icons.phone_android_rounded, AppColors.warning),
  'data' => (Icons.wifi_rounded, AppColors.info),
  'topup' => (Icons.add_card_rounded, AppColors.success),
  'giftcard' => (Icons.card_giftcard_rounded, AppColors.pink),
  'withdrawal' => (Icons.account_balance_rounded, AppColors.danger),
  'card' => (Icons.redeem_rounded, AppColors.teal),
  _ => (Icons.receipt_long_rounded, AppColors.textSecondary),
};

/// Small label that says which kind of money moved (real vs internal).
class MoneyKindTag extends StatelessWidget {
  const MoneyKindTag(this.kind, {super.key});
  final MoneyKind kind;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (kind) {
      MoneyKind.fiatIn => (AppColors.success, AppColors.successSoft),
      MoneyKind.fiatOut => (AppColors.danger, AppColors.dangerSoft),
      MoneyKind.internal => (AppColors.brand, AppColors.brandSoft),
      MoneyKind.service => (AppColors.info, AppColors.infoSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        kind.label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// Generic dropdown-looking filter box with a label above it.
class FilterBox extends StatelessWidget {
  const FilterBox({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 170,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.navText),
          ),
          const SizedBox(height: 6),
          PopupMenuButton<String>(
            tooltip: label,
            onSelected: onChanged,
            itemBuilder: (_) => [
              for (final o in options)
                PopupMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 13)),
                ),
            ],
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Activity row: tinted icon, title, amount and time on the right.
class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.amount,
    required this.time,
    this.amountColor,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String amount;
  final String time;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: amountColor ?? AppColors.text,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
