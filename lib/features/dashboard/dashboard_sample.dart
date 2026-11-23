/// Sample data for the Dashboard UI phase. Replaced by live Supabase data
/// in the backend phase.
library;

class CountryStat {
  const CountryStat(this.code, this.name, this.registered, this.active,
      this.restricted, this.newThisMonth);

  final String code;
  final String name;
  final int registered;
  final int active;
  final int restricted;
  final int newThisMonth;

  int get inactive => registered - active;
}

class TxRow {
  const TxRow(this.user, this.type, this.amount, this.status, this.time);
  final String user;
  final String type;
  final String amount;
  final String status;
  final String time;
}

enum Level { critical, warning, info, normal }

class AttentionItem {
  const AttentionItem(this.label, this.count, this.hint, this.route, this.level);
  final String label;
  final int count;
  final String hint;
  final String route;
  final Level level;
}

class AlertItem {
  const AlertItem(this.title, this.detail, this.time, this.level);
  final String title;
  final String detail;
  final String time;
  final Level level;
}

class DashboardSample {
  DashboardSample._();

  /// Account statistics (requirement 1A).
  static const userStats = <(String, int, String)>[
    ('Registered', 12480, 'All accounts created'),
    ('Active (30d)', 7842, 'Real app activity'),
    ('Daily active', 3915, 'Last 24 hours'),
    ('Weekly active', 6120, 'Last 7 days'),
    ('Monthly active', 7842, 'Last 30 days'),
    ('Inactive', 4638, 'No activity in 30 days'),
    ('Suspended', 42, 'Temporarily suspended'),
    ('Restricted', 87, 'Account or wallet limits'),
    ('Blocked', 19, 'Permanently blocked'),
    ('Deleted', 156, 'Records retained'),
  ];

  static const weekLabels = [
    'Nov 17', 'Nov 18', 'Nov 19', 'Nov 20', 'Nov 21', 'Nov 22', 'Nov 23',
  ];

  static const dau = <double>[3420, 3610, 3880, 3640, 3790, 3720, 3915];
  static const signups = <double>[1180, 1260, 1410, 1300, 1390, 1350, 1520];

  static const volume = <double>[
    5.2e6, 6.1e6, 8.4e6, 6.9e6, 5.8e6, 7.3e6, 8.1e6,
  ];
  static const txCount = <double>[7120, 7860, 9540, 8310, 7480, 8650, 9432];

  static const featureUsage = <(String, double)>[
    ('Chats', 0.92),
    ('Voice and video calls', 0.61),
    ('Wallet', 0.47),
    ('Stories', 0.38),
    ('Private chats', 0.21),
  ];

  /// Volume by category in naira (30 days).
  static const txCategories = <(String, double)>[
    ('Schatz transfers', 21.4e6),
    ('Wallet top-ups', 12.1e6),
    ('Airtime & Data', 6.8e6),
    ('Gift cards', 5.6e6),
    ('Others', 2.3e6),
  ];

  static const countries = <CountryStat>[
    CountryStat('NG', 'Nigeria', 6240, 4310, 41, 812),
    CountryStat('DE', 'Germany', 1820, 1104, 9, 206),
    CountryStat('GH', 'Ghana', 1105, 702, 11, 133),
    CountryStat('GB', 'United Kingdom', 948, 561, 6, 97),
    CountryStat('US', 'United States', 712, 398, 4, 71),
    CountryStat('KE', 'Kenya', 504, 301, 7, 58),
    CountryStat('ZA', 'South Africa', 433, 236, 5, 39),
    CountryStat('FR', 'France', 312, 160, 2, 27),
    CountryStat('CA', 'Canada', 254, 139, 1, 22),
    CountryStat('NL', 'Netherlands', 150, 31, 1, 9),
  ];

  /// Account status split for the donut.
  static const statusSplit = <(String, double)>[
    ('Active', 7842),
    ('Inactive', 4334),
    ('Restricted', 87),
    ('Suspended', 42),
    ('Blocked', 19),
    ('Deleted', 156),
  ];

  static const transactions = <TxRow>[
    TxRow('John Okafor', 'Schatz transfer', '₦250,000.00', 'Completed', '2m ago'),
    TxRow('Emily Johnson', 'Airtime purchase', '₦2,500.00', 'Completed', '5m ago'),
    TxRow('Michael Uche', 'Gift card purchase', '₦45,000.00', 'Completed', '10m ago'),
    TxRow('Sarah Collins', 'Wallet top-up', '₦100,000.00', 'Pending', '15m ago'),
    TxRow('David Brown', 'Data bundle', '₦7,500.00', 'Failed', '20m ago'),
  ];

  static const attention = <AttentionItem>[
    AttentionItem('KYC reviews waiting', 126, 'Oldest waiting 2 days', '/kyc', Level.warning),
    AttentionItem('Open support tickets', 38, '6 past response target', '/support', Level.info),
    AttentionItem('Open disputes', 9, '2 escalated', '/disputes', Level.critical),
    AttentionItem('Reported accounts', 14, 'Flagged by other users', '/users', Level.warning),
    AttentionItem('Failed transactions (24h)', 23, 'Above normal rate', '/transactions', Level.critical),
    AttentionItem('Approvals waiting', 1, 'Super Admin promotion', '/roles', Level.info),
  ];

  static const alerts = <AlertItem>[
    AlertItem('High value transaction', '₦5,000,000.00 by John Okafor', '2m ago', Level.critical),
    AlertItem('KYC verification pending', '34 users waiting verification', '15m ago', Level.warning),
    AlertItem('New admin sign-in', 'Michael Uche from Lagos, NG', '1h ago', Level.info),
    AlertItem('Failed login attempts', '5 failed attempts on an admin account', '2h ago', Level.critical),
  ];

  static const systemStatus = <(String, String)>[
    ('Database', 'Operational'),
    ('API & Edge Functions', 'Operational'),
    ('Calls (Agora)', 'Operational'),
    ('Storage', '78% used'),
  ];

  static const summary = <(String, String)>[
    ('Total wallet balance (Schatz)', '₦1.28B'),
    ('Gift cards issued', '18,456'),
    ('Gift cards not yet loaded', '1,204'),
    ('Calls in progress', '124'),
    ('Open support tickets', '38'),
    ('Admins online', '6'),
    ('System uptime', '99.98%'),
  ];
}
