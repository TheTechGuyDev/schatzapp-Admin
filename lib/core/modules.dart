import 'package:material_ui/material_ui.dart';

import '../features/dashboard/dashboard_page.dart';
import '../features/audit/audit_logs_page.dart';
import '../features/deposits/deposits_page.dart';
import '../features/disputes/disputes_page.dart';
import '../features/moderation/moderation_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/reports/reports_page.dart';
import '../features/requests/requests_page.dart';
import '../features/roles/roles_page.dart';
import '../features/settings/settings_page.dart';
import '../features/support/support_page.dart';
import '../features/airtime/airtime_page.dart';
import '../features/cards/cards_page.dart';
import '../features/giftcards/gift_cards_page.dart';
import '../features/kyc/kyc_page.dart';
import '../features/transactions/transactions_page.dart';
import '../features/wallets/wallets_page.dart';
import '../features/users/users_page.dart';

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
  AdminModule(
    id: 'users',
    label: 'Users',
    subtitle: 'Search, monitor and investigate user accounts',
    icon: Icons.people_alt_outlined,
    section: NavSection.main,
    permission: 'users.view',
    builder: (_) => const UsersPage(),
  ),
  AdminModule(
    id: 'roles',
    label: 'Roles & Permissions',
    subtitle: 'Manage admin roles and their access permissions',
    icon: Icons.manage_accounts_outlined,
    section: NavSection.main,
    permission: 'roles.view',
    builder: (_) => const RolesPage(),
  ),
  AdminModule(
    id: 'kyc',
    label: 'KYC Verification',
    subtitle: 'Verify user identities and manage KYC compliance',
    icon: Icons.fact_check_outlined,
    section: NavSection.main,
    permission: 'kyc.view',
    builder: (_) => const KycPage(),
  ),
  AdminModule(
    id: 'transactions',
    label: 'Transactions',
    subtitle: 'Monitor and trace every wallet transaction',
    icon: Icons.swap_horiz_rounded,
    section: NavSection.main,
    permission: 'transactions.view',
    builder: (_) => const TransactionsPage(),
  ),
  AdminModule(
    id: 'wallets',
    label: 'Wallets',
    subtitle: 'Manage user wallets and balances',
    icon: Icons.account_balance_wallet_outlined,
    section: NavSection.main,
    permission: 'wallets.view',
    builder: (_) => const WalletsPage(),
  ),
  AdminModule(
    id: 'deposits',
    label: 'Deposits & Top-ups',
    subtitle: 'Card and bank transfer top-ups that become Schatz',
    icon: Icons.add_card_rounded,
    section: NavSection.main,
    permission: 'deposits.view',
    builder: (_) => const DepositsPage(),
  ),
  AdminModule(
    id: 'cards',
    label: 'Cards',
    subtitle: 'Saved payment cards and card top-ups',
    icon: Icons.credit_card_outlined,
    section: NavSection.main,
    permission: 'cards.view',
    builder: (_) => const CardsPage(),
  ),
  AdminModule(
    id: 'gift-cards',
    label: 'Gift Cards',
    subtitle: 'Manage gift cards, orders and redemptions',
    icon: Icons.card_giftcard_outlined,
    section: NavSection.main,
    permission: 'giftcards.view',
    builder: (_) => const GiftCardsPage(),
  ),
  AdminModule(
    id: 'airtime-data',
    label: 'Airtime & Data',
    subtitle: 'Airtime and data purchases, networks and vendors',
    icon: Icons.cell_tower_rounded,
    section: NavSection.main,
    permission: 'airtime.view',
    builder: (_) => const AirtimePage(),
  ),
  AdminModule(
    id: 'disputes',
    label: 'Disputes',
    subtitle: 'Complaints, disputes and investigations',
    icon: Icons.shield_outlined,
    section: NavSection.support,
    permission: 'disputes.view',
    builder: (_) => const DisputesPage(),
  ),
  AdminModule(
    id: 'support',
    label: 'Support Tickets',
    subtitle: 'Manage and resolve customer support requests',
    icon: Icons.headset_mic_outlined,
    section: NavSection.support,
    permission: 'support.view',
    builder: (_) => const SupportPage(),
  ),
  AdminModule(
    id: 'moderation',
    label: 'Content & Safety',
    subtitle: 'Reported messages, Stories, For You posts, profiles and groups',
    icon: Icons.flag_outlined,
    section: NavSection.support,
    permission: 'moderation.view',
    builder: (_) => const ModerationPage(),
  ),
  AdminModule(
    id: 'requests',
    label: 'Account Requests',
    subtitle: 'Name changes, unsupported countries and account closures',
    icon: Icons.how_to_reg_outlined,
    section: NavSection.support,
    permission: 'requests.view',
    builder: (_) => const RequestsPage(),
  ),
  AdminModule(
    id: 'notifications',
    label: 'Notifications',
    subtitle: 'Manage and send notifications to users',
    icon: Icons.notifications_none_rounded,
    section: NavSection.support,
    permission: 'notifications.view',
    builder: (_) => const NotificationsPage(),
  ),
  AdminModule(
    id: 'reports',
    label: 'Reports',
    subtitle: 'View insights and generate reports across the platform',
    icon: Icons.insert_chart_outlined_rounded,
    section: NavSection.reports,
    permission: 'reports.view',
    builder: (_) => const ReportsPage(),
  ),
  AdminModule(
    id: 'audit-logs',
    label: 'Audit Logs',
    subtitle: 'Track and review all admin activities and changes',
    icon: Icons.assignment_outlined,
    section: NavSection.reports,
    permission: 'audit.view',
    builder: (_) => const AuditLogsPage(),
  ),
  AdminModule(
    id: 'settings',
    label: 'System Settings',
    subtitle: 'Manage and configure system preferences',
    icon: Icons.settings_outlined,
    section: NavSection.system,
    permission: 'settings.view',
    builder: (_) => const SettingsPage(),
  ),
];

AdminModule moduleFor(String location) => adminModules.firstWhere(
  (m) => location.startsWith(m.path),
  orElse: () => adminModules.first,
);

/// Counts shown as small badges on nav items (sample values for the UI phase).
const Map<String, int> navBadges = {'notifications': 12};
