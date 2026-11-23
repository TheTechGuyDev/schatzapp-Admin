import 'package:material_ui/material_ui.dart';

import '../features/dashboard/dashboard_page.dart';
import '../features/placeholder/coming_soon_page.dart';

/// Side nav sections, in display order.
enum NavSection {
  main('MAIN'),
  support('SUPPORT'),
  reports('REPORTS'),
  system('SYSTEM');

  const NavSection(this.label);
  final String label;
}

/// One admin module. New products or sections are added by appending a
/// module here: the shell, routes, top bar and side nav pick it up.
/// `permission` is the key the backend role system will check (later phase).
class AdminModule {
  const AdminModule({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.section,
    required this.permission,
    required this.builder,
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

AdminModule _soon({
  required String id,
  required String label,
  required String subtitle,
  required IconData icon,
  required NavSection section,
  required String permission,
  required String phase,
}) =>
    AdminModule(
      id: id,
      label: label,
      subtitle: subtitle,
      icon: icon,
      section: section,
      permission: permission,
      builder: (_) => ComingSoonPage(title: label, phase: phase),
    );

final List<AdminModule> adminModules = [
  AdminModule(
    id: 'dashboard',
    label: 'Dashboard',
    subtitle: 'Monitor users, transactions and activity across SchatzApp',
    icon: Icons.home_outlined,
    section: NavSection.main,
    permission: 'dashboard.view',
    builder: (_) => const DashboardPage(),
  ),
  _soon(
    id: 'users',
    label: 'Users',
    subtitle: 'Search, monitor and investigate user accounts',
    icon: Icons.people_alt_outlined,
    section: NavSection.main,
    permission: 'users.view',
    phase: 'Phase 3',
  ),
  _soon(
    id: 'roles',
    label: 'Roles & Permissions',
    subtitle: 'Manage admin roles and their access permissions',
    icon: Icons.manage_accounts_outlined,
    section: NavSection.main,
    permission: 'roles.view',
    phase: 'Phase 11',
  ),
  _soon(
    id: 'kyc',
    label: 'KYC Verification',
    subtitle: 'Verify user identities and manage KYC compliance',
    icon: Icons.fact_check_outlined,
    section: NavSection.main,
    permission: 'kyc.view',
    phase: 'Phase 5',
  ),
  _soon(
    id: 'transactions',
    label: 'Transactions',
    subtitle: 'Monitor and trace every wallet transaction',
    icon: Icons.swap_horiz_rounded,
    section: NavSection.main,
    permission: 'transactions.view',
    phase: 'Phase 6',
  ),
  _soon(
    id: 'wallets',
    label: 'Wallets',
    subtitle: 'Manage user wallets and balances',
    icon: Icons.account_balance_wallet_outlined,
    section: NavSection.main,
    permission: 'wallets.view',
    phase: 'Phase 6',
  ),
  _soon(
    id: 'cards',
    label: 'Cards',
    subtitle: 'Saved payment cards and card top-ups',
    icon: Icons.credit_card_outlined,
    section: NavSection.main,
    permission: 'cards.view',
    phase: 'Phase 6',
  ),
  _soon(
    id: 'gift-cards',
    label: 'Gift Cards',
    subtitle: 'Manage gift cards, orders and redemptions',
    icon: Icons.card_giftcard_outlined,
    section: NavSection.main,
    permission: 'giftcards.view',
    phase: 'Phase 7',
  ),
  _soon(
    id: 'airtime-data',
    label: 'Airtime & Data',
    subtitle: 'Airtime and data purchases, networks and vendors',
    icon: Icons.cell_tower_rounded,
    section: NavSection.main,
    permission: 'airtime.view',
    phase: 'Phase 6',
  ),
  _soon(
    id: 'disputes',
    label: 'Disputes',
    subtitle: 'Complaints, disputes and investigations',
    icon: Icons.shield_outlined,
    section: NavSection.support,
    permission: 'disputes.view',
    phase: 'Phase 8',
  ),
  _soon(
    id: 'support',
    label: 'Support Tickets',
    subtitle: 'Manage and resolve customer support requests',
    icon: Icons.headset_mic_outlined,
    section: NavSection.support,
    permission: 'support.view',
    phase: 'Phase 8',
  ),
  _soon(
    id: 'notifications',
    label: 'Notifications',
    subtitle: 'Manage and send notifications to users',
    icon: Icons.notifications_none_rounded,
    section: NavSection.support,
    permission: 'notifications.view',
    phase: 'Phase 9',
  ),
  _soon(
    id: 'reports',
    label: 'Reports',
    subtitle: 'View insights and generate reports across the platform',
    icon: Icons.insert_chart_outlined_rounded,
    section: NavSection.reports,
    permission: 'reports.view',
    phase: 'Phase 10',
  ),
  _soon(
    id: 'audit-logs',
    label: 'Audit Logs',
    subtitle: 'Track and review all admin activities and changes',
    icon: Icons.assignment_outlined,
    section: NavSection.reports,
    permission: 'audit.view',
    phase: 'Phase 11',
  ),
  _soon(
    id: 'settings',
    label: 'System Settings',
    subtitle: 'Manage and configure system preferences',
    icon: Icons.settings_outlined,
    section: NavSection.system,
    permission: 'settings.view',
    phase: 'Phase 12',
  ),
];

AdminModule moduleFor(String location) => adminModules.firstWhere(
      (m) => location.startsWith(m.path),
      orElse: () => adminModules.first,
    );

/// Counts shown as small badges on nav items (sample values for the UI phase).
const Map<String, int> navBadges = {'notifications': 12};
