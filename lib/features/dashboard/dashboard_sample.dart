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
  const TxRow(this.ref, this.user, this.type, this.amount, this.status, this.time);
  final String ref;
  final String user;
  final String type;
  final String amount;
  final String status;
  final String time;
}

class AttentionItem {
  const AttentionItem(this.label, this.count, this.hint, this.route, this.urgent);
  final String label;
  final int count;
  final String hint;
  final String route;
  final bool urgent;
}

class DashboardSample {
  DashboardSample._();

  /// Account statistics (requirement 1A).
  static const userStats = <(String, int, String)>[
    ('Registered users', 12480, 'All accounts ever created'),
    ('Active users (30d)', 7842, 'Used chat, calls, stories or wallet'),
    ('Daily active (DAU)', 3915, 'Active in the last 24 hours'),
    ('Weekly active (WAU)', 6120, 'Active in the last 7 days'),
    ('Monthly active (MAU)', 7842, 'Active in the last 30 days'),
    ('Inactive users', 4638, 'No activity in 30 days'),
    ('Suspended', 42, 'Temporarily suspended'),
    ('Restricted', 87, 'Account or wallet limits'),
    ('Blocked', 19, 'Permanently blocked'),
    ('Deleted (retained)', 156, 'Records kept for retention'),
  ];

  static final List<String> last30Labels = () {
    const months = ['Oct', 'Nov'];
    final out = <String>[];
    for (var i = 0; i < 30; i++) {
      final day = 25 + i;
      out.add(day <= 31 ? '${months[0]} $day' : '${months[1]} ${day - 31}');
    }
    return out;
  }();

  static const dau = <double>[
    2310, 2420, 2560, 2700, 2850, 3010, 3120, 3160, 3150, 3190,
    3260, 3350, 3440, 3520, 3550, 3530, 3560, 3620, 3690, 3740,
    3790, 3820, 3840, 3830, 3810, 3830, 3860, 3900, 3990, 4120,
  ];

  static const signups = <double>[
    820, 840, 870, 900, 930, 960, 990, 1010, 1020, 1030,
    1050, 1080, 1110, 1140, 1150, 1150, 1170, 1200, 1230, 1270,
    1310, 1340, 1360, 1380, 1390, 1400, 1420, 1450, 1520, 1680,
  ];

  static const featureUsage = <(String, double)>[
    ('Chats', 0.92),
    ('Voice and video calls', 0.61),
    ('Wallet', 0.47),
    ('Stories', 0.38),
    ('Private chats', 0.21),
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
    TxRow('TX-90412', 'Amaka O.', 'Transfer', '₦25,000', 'Completed', '2 min ago'),
    TxRow('TX-90411', 'Tunde A.', 'Top up', '₦100,000', 'Pending', '9 min ago'),
    TxRow('TX-90410', 'Grace E.', 'Withdrawal', '₦48,500', 'Completed', '21 min ago'),
    TxRow('TX-90409', 'Ibrahim S.', 'Transfer', '₦7,200', 'Failed', '34 min ago'),
    TxRow('TX-90408', 'Chiamaka N.', 'Gift card', '₦50,000', 'Completed', '1 hr ago'),
  ];

  static const attention = <AttentionItem>[
    AttentionItem('KYC reviews waiting', 126, 'Oldest waiting 2 days', '/kyc', true),
    AttentionItem('Open support tickets', 38, '6 past response target', '/support', false),
    AttentionItem('Open disputes', 9, '2 escalated', '/disputes', true),
    AttentionItem('Reported accounts', 14, 'Flagged by users', '/users', false),
    AttentionItem('Failed transactions (24h)', 23, 'Above normal rate', '/transactions', true),
    AttentionItem('Approvals waiting', 1, 'Super Admin promotion', '/roles', false),
  ];
}
