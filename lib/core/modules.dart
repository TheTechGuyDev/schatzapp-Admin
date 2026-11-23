import 'package:material_ui/material_ui.dart';

import '../features/dashboard/dashboard_page.dart';
import '../features/placeholder/coming_soon_page.dart';

/// Side nav sections, in display order.
enum NavSection {
  main('MAIN'),
  communication('COMMUNICATION'),
  system('SYSTEM');

  const NavSection(this.label);
  final String label;
}

/// One admin module. New products or sections are added by appending a
/// module here: the shell, routes and side nav pick it up automatically.
/// `permission` is the key the backend role system will check (later phase).
class AdminModule {
  const AdminModule({
    required this.id,
    required this.label,
    required this.icon,
    required this.section,
    required this.permission,
    required this.builder,
    this.subtitle = '',
  });

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final NavSection section;
  final String permission;
  final WidgetBuilder builder;

  String get path => '/$id';
}

Widget _soon(String title, String phase) =>
    ComingSoonPage(title: title, phase: phase);

final List<AdminModule> adminModules = [
  AdminModule(
    id: 'dashboard',
    label: 'Dashboard',
    icon: Icons.space_dashboard_outlined,
    section: NavSection.main,
    permission: 'dashboard.view',
    builder: (_) => const DashboardPage(),
  ),
  AdminModule(
    id: 'users',
    label: 'Users',
    icon: Icons.people_outline,
    section: NavSection.main,
    permission: 'users.view',
    builder: (_) => _soon('Users', 'Phase 3'),
  ),
  AdminModule(
    id: 'roles',
    label: 'Role & Permissions',
    icon: Icons.admin_panel_settings_outlined,
    section: NavSection.main,
    permission: 'roles.view',
    builder: (_) => _soon('Role & Permissions', 'Phase 11'),
  ),
  AdminModule(
    id: 'kyc',
    label: 'KYC Verification',
    icon: Icons.verified_user_outlined,
    section: NavSection.main,
    permission: 'kyc.view',
    builder: (_) => _soon('KYC Verification', 'Phase 5'),
  ),
  AdminModule(
    id: 'transactions',
    label: 'Transactions',
    icon: Icons.swap_horiz_rounded,
    section: NavSection.main,
    permission: 'transactions.view',
    builder: (_) => _soon('Transactions', 'Phase 6'),
  ),
  AdminModule(
    id: 'wallets',
    label: 'Wallets',
    icon: Icons.account_balance_wallet_outlined,
    section: NavSection.main,
    permission: 'wallets.view',
    builder: (_) => _soon('Wallets', 'Phase 6'),
  ),
  AdminModule(
    id: 'airtime-data',
    label: 'Airtime & Data',
    icon: Icons.cell_tower_rounded,
    section: NavSection.main,
    permission: 'airtime.view',
    builder: (_) => _soon('Airtime & Data', 'Phase 6'),
  ),
  AdminModule(
    id: 'gift-cards',
    label: 'Gift Cards',
    icon: Icons.card_giftcard_outlined,
    section: NavSection.main,
    permission: 'giftcards.view',
    builder: (_) => _soon('Gift Cards', 'Phase 7'),
  ),
  AdminModule(
    id: 'reports',
    label: 'Reports',
    icon: Icons.bar_chart_rounded,
    section: NavSection.main,
    permission: 'reports.view',
    builder: (_) => _soon('Reports', 'Phase 10'),
  ),
  AdminModule(
    id: 'disputes',
    label: 'Disputes',
    icon: Icons.gavel_rounded,
    section: NavSection.main,
    permission: 'disputes.view',
    builder: (_) => _soon('Disputes', 'Phase 8'),
  ),
  AdminModule(
    id: 'notifications',
    label: 'Notifications',
    icon: Icons.notifications_none_rounded,
    section: NavSection.communication,
    permission: 'notifications.view',
    builder: (_) => _soon('Notifications', 'Phase 9'),
  ),
  AdminModule(
    id: 'support',
    label: 'Support Tickets',
    icon: Icons.support_agent_rounded,
    section: NavSection.communication,
    permission: 'support.view',
    builder: (_) => _soon('Support Tickets', 'Phase 8'),
  ),
  AdminModule(
    id: 'audit-logs',
    label: 'Audit Logs',
    icon: Icons.fact_check_outlined,
    section: NavSection.system,
    permission: 'audit.view',
    builder: (_) => _soon('Audit Logs', 'Phase 11'),
  ),
  AdminModule(
    id: 'settings',
    label: 'System Settings',
    icon: Icons.settings_outlined,
    section: NavSection.system,
    permission: 'settings.view',
    builder: (_) => _soon('System Settings', 'Phase 12'),
  ),
];

/// Counts shown as small badges on nav items (sample values for the UI phase).
const Map<String, int> navBadges = {'notifications': 12, 'support': 38};
