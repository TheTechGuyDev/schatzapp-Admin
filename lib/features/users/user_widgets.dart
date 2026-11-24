import 'package:material_ui/material_ui.dart';

import '../../core/session.dart';
import '../../data/sample_users.dart';
import '../../theme/app_colors.dart';
import '../../widgets/table.dart';
import '../../widgets/ui.dart';

ChipKind statusKind(AccountStatus s) => switch (s) {
  AccountStatus.active => ChipKind.success,
  AccountStatus.inactive => ChipKind.neutral,
  AccountStatus.restricted => ChipKind.warning,
  AccountStatus.suspended => ChipKind.brand,
  AccountStatus.blocked => ChipKind.danger,
  AccountStatus.deleted => ChipKind.neutral,
};

ChipKind kycKind(String kyc) => switch (kyc) {
  'Verified' => ChipKind.success,
  'Pending' => ChipKind.warning,
  'Rejected' => ChipKind.danger,
  _ => ChipKind.neutral,
};

class StatusTag extends StatelessWidget {
  const StatusTag(this.status, {super.key});
  final AccountStatus status;

  @override
  Widget build(BuildContext context) =>
      StatusChip(status.label, kind: statusKind(status));
}

/// The account actions an admin can take, with their resulting status.
enum AccountActionKind {
  restrict(
    'Restrict account',
    Icons.lock_outline_rounded,
    AccountStatus.restricted,
  ),
  suspend(
    'Suspend temporarily',
    Icons.pause_circle_outline_rounded,
    AccountStatus.suspended,
  ),
  block('Block permanently', Icons.block_rounded, AccountStatus.blocked),
  restore('Restore account', Icons.lock_open_rounded, AccountStatus.active),
  reactivate(
    'Reactivate account',
    Icons.play_circle_outline_rounded,
    AccountStatus.active,
  ),
  unblock(
    'Lift block',
    Icons.settings_backup_restore_rounded,
    AccountStatus.active,
  ),
  flag('Flag for investigation', Icons.flag_outlined, null),
  unflag('Remove investigation flag', Icons.outlined_flag_rounded, null);

  const AccountActionKind(this.label, this.icon, this.result);
  final String label;
  final IconData icon;
  final AccountStatus? result;

  bool get dangerous => this == block || this == suspend || this == restrict;
}

/// Actions that make sense for the user's current state.
List<AccountActionKind> actionsFor(AdminUser u) {
  final s = u.status;
  return [
    if (s == AccountStatus.active || s == AccountStatus.inactive)
      AccountActionKind.restrict,
    if (s == AccountStatus.active ||
        s == AccountStatus.inactive ||
        s == AccountStatus.restricted)
      AccountActionKind.suspend,
    if (s != AccountStatus.blocked && s != AccountStatus.deleted)
      AccountActionKind.block,
    if (s == AccountStatus.restricted) AccountActionKind.restore,
    if (s == AccountStatus.suspended) AccountActionKind.reactivate,
    if (s == AccountStatus.blocked) AccountActionKind.unblock,
    u.flagged ? AccountActionKind.unflag : AccountActionKind.flag,
  ];
}

String _now() {
  final d = DateTime.now();
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  String two(int v) => v.toString().padLeft(2, '0');
  return '${m[d.month - 1]} ${two(d.day)}, ${d.year} · ${two(d.hour)}:${two(d.minute)}';
}

/// Account action dialog: reason required, shows previous and new status.
/// Returns true when the action was applied.
Future<bool> showAccountActionDialog(
  BuildContext context,
  AdminUser user,
  AccountActionKind action,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => _ActionDialog(user: user, action: action),
  );
  return ok == true;
}

class _ActionDialog extends StatefulWidget {
  const _ActionDialog({required this.user, required this.action});
  final AdminUser user;
  final AccountActionKind action;

  @override
  State<_ActionDialog> createState() => _ActionDialogState();
}

class _ActionDialogState extends State<_ActionDialog> {
  final _reason = TextEditingController();
  String _duration = '7 days';
  bool _confirmed = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _reason.text.trim();
    if (reason.length < 10) {
      setState(
        () => _error = 'Please give a clear reason (at least 10 characters).',
      );
      return;
    }
    if (widget.action == AccountActionKind.block && !_confirmed) {
      setState(() => _error = 'Tick the box to confirm a permanent block.');
      return;
    }
    final u = widget.user;
    final a = widget.action;
    final before = u.status.label + (u.flagged ? ' · Flagged' : '');
    if (a.result != null) u.status = a.result!;
    if (a == AccountActionKind.flag) u.flagged = true;
    if (a == AccountActionKind.unflag) u.flagged = false;
    final after = u.status.label + (u.flagged ? ' · Flagged' : '');
    final s = AdminSession.instance;
    u.history.insert(
      0,
      AdminAction(
        action: a == AccountActionKind.suspend
            ? '${a.label} ($_duration)'
            : a.label,
        reason: reason,
        admin: s.name,
        role: s.role,
        when: _now(),
        from: before,
        to: after,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final a = widget.action;
    final newStatus = a.result ?? u.status;
    final danger = a.dangerous;
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
                  IconCircle(
                    icon: a.icon,
                    color: danger ? AppColors.danger : AppColors.brand,
                    background: danger
                        ? AppColors.dangerSoft
                        : AppColors.brandSoft,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      a.label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TwoLine(u.name, '${u.accountNo} · ${u.phone}'),
                    ),
                    if (a.result != null) ...[
                      StatusTag(u.status),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      StatusTag(newStatus),
                    ],
                  ],
                ),
              ),
              if (a == AccountActionKind.suspend) ...[
                const SizedBox(height: 16),
                const Text(
                  'Suspension period',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final d in [
                      '24 hours',
                      '7 days',
                      '14 days',
                      '30 days',
                    ])
                      ChoiceChip(
                        label: Text(d, style: const TextStyle(fontSize: 12)),
                        selected: _duration == d,
                        onSelected: (_) => setState(() => _duration = d),
                        selectedColor: AppColors.brandSoft,
                        showCheckmark: false,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Reason (required)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reason,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  hintText: 'Explain why this action is being taken',
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
              if (a == AccountActionKind.block) ...[
                const SizedBox(height: 10),
                CheckboxListTile(
                  value: _confirmed,
                  onChanged: (v) => setState(() => _confirmed = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I understand this permanently blocks the account. Records are kept.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 12, color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: AppColors.info,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recorded in the audit log with your name, role, time, previous and new status.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.info),
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
                    onTap: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: danger ? AppColors.danger : AppColors.brand,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        child: Text(
                          'Confirm',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
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

/// Financial restriction dialog, separate from account restrictions: the user
/// keeps access to chat and support while selected wallet actions are blocked.
Future<bool> showWalletRestrictionDialog(
  BuildContext context,
  AdminUser user,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => _WalletDialog(user: user),
  );
  return ok == true;
}

class _WalletDialog extends StatefulWidget {
  const _WalletDialog({required this.user});
  final AdminUser user;

  @override
  State<_WalletDialog> createState() => _WalletDialogState();
}

class _WalletDialogState extends State<_WalletDialog> {
  final _reason = TextEditingController();
  final _blocked = <String>{'Schatz transfers', 'Withdrawals'};
  String? _error;

  static const _options = [
    'Schatz transfers',
    'Withdrawals',
    'Wallet top-ups',
    'Gift card purchases',
    'Airtime & data purchases',
  ];

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final lifting = widget.user.walletRestricted;
    if (_reason.text.trim().length < 10) {
      setState(
        () => _error = 'Please give a clear reason (at least 10 characters).',
      );
      return;
    }
    if (!lifting && _blocked.isEmpty) {
      setState(() => _error = 'Choose at least one wallet action to restrict.');
      return;
    }
    final u = widget.user;
    final s = AdminSession.instance;
    u.history.insert(
      0,
      AdminAction(
        action: lifting
            ? 'Wallet restriction lifted'
            : 'Wallet restricted: ${_blocked.join(', ')}',
        reason: _reason.text.trim(),
        admin: s.name,
        role: s.role,
        when: _now(),
        from: lifting ? 'Wallet: Restricted' : 'Wallet: Open',
        to: lifting ? 'Wallet: Open' : 'Wallet: Restricted',
      ),
    );
    u.walletRestricted = !lifting;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final lifting = widget.user.walletRestricted;
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
                  IconCircle(
                    icon: Icons.account_balance_wallet_outlined,
                    color: lifting ? AppColors.success : AppColors.warning,
                    background: lifting
                        ? AppColors.successSoft
                        : AppColors.warningSoft,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lifting ? 'Lift wallet restriction' : 'Restrict wallet',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                lifting
                    ? 'All wallet actions will be available to ${widget.user.name} again.'
                    : '${widget.user.name} keeps access to chats, calls and support. Only the selected wallet actions are blocked.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              if (!lifting) ...[
                const SizedBox(height: 14),
                for (final o in _options)
                  CheckboxListTile(
                    value: _blocked.contains(o),
                    onChanged: (v) => setState(() {
                      v == true ? _blocked.add(o) : _blocked.remove(o);
                    }),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(o, style: const TextStyle(fontSize: 13)),
                  ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Reason (required)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reason,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Explain why',
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
                  style: const TextStyle(fontSize: 12, color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlineButtonBox(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 10),
                  PrimaryButton(label: 'Confirm', onTap: _submit),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}
