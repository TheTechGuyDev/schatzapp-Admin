/// Sample users for the UI phase. Replaced by Supabase data (profiles,
/// wallets, devices, ledger, admin history) in the backend phase.
library;

enum AccountStatus { active, inactive, restricted, suspended, blocked, deleted }

extension AccountStatusX on AccountStatus {
  String get label => switch (this) {
    AccountStatus.active => 'Active',
    AccountStatus.inactive => 'Inactive',
    AccountStatus.restricted => 'Restricted',
    AccountStatus.suspended => 'Suspended',
    AccountStatus.blocked => 'Blocked',
    AccountStatus.deleted => 'Deleted',
  };
}

class AdminUser {
  AdminUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.accountNo,
    required this.sfzNo,
    required this.countryCode,
    required this.country,
    required this.status,
    required this.kyc,
    required this.joined,
    required this.lastActive,
    required this.lastLogin,
    required this.balance,
    this.walletRestricted = false,
    this.flagged = false,
  });

  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String accountNo;
  final String sfzNo;
  final String countryCode;
  final String country;
  AccountStatus status;
  final String kyc;
  final String joined;
  final String lastActive;
  final String lastLogin;
  final String balance;
  bool walletRestricted;
  bool flagged;

  /// Administrative history for this user (newest first). Actions taken in
  /// the UI are added here so the history tab updates immediately.
  final List<AdminAction> history = [];

  bool matches(String q) {
    if (q.isEmpty) return true;
    final s = q.toLowerCase();
    return [
      name,
      username,
      email,
      phone,
      accountNo,
      sfzNo,
      id,
    ].any((v) => v.toLowerCase().contains(s));
  }
}

class AdminAction {
  AdminAction({
    required this.action,
    required this.reason,
    required this.admin,
    required this.role,
    required this.when,
    required this.from,
    required this.to,
  });

  final String action;
  final String reason;
  final String admin;
  final String role;
  final String when;
  final String from;
  final String to;
}

class DeviceRecord {
  const DeviceRecord(
    this.type,
    this.model,
    this.os,
    this.appVersion,
    this.deviceId,
    this.firstSeen,
    this.lastLogin,
    this.lastLogout,
    this.current,
  );
  final String type;
  final String model;
  final String os;
  final String appVersion;
  final String deviceId;
  final String firstSeen;
  final String lastLogin;
  final String lastLogout;
  final bool current;
}

class LoginRecord {
  const LoginRecord(
    this.when,
    this.event,
    this.device,
    this.ip,
    this.location,
    this.ok,
  );
  final String when;
  final String event;
  final String device;
  final String ip;
  final String location;
  final bool ok;
}

class UserTx {
  const UserTx(
    this.ref,
    this.when,
    this.type,
    this.direction,
    this.amount,
    this.fee,
    this.counterparty,
    this.provider,
    this.status,
    this.description,
  );
  final String ref;
  final String when;
  final String type;

  /// 'in' or 'out'
  final String direction;
  final String amount;
  final String fee;
  final String counterparty;
  final String provider;
  final String status;
  final String description;
}

class CaseRecord {
  const CaseRecord(
    this.ref,
    this.kind,
    this.category,
    this.opened,
    this.status,
    this.assignee,
  );
  final String ref;

  /// 'Complaint' or 'Dispute'
  final String kind;
  final String category;
  final String opened;
  final String status;
  final String assignee;
}

class SecurityAlert {
  const SecurityAlert(this.title, this.detail, this.when, this.critical);
  final String title;
  final String detail;
  final String when;
  final bool critical;
}

class InvestigationNote {
  InvestigationNote(this.text, this.author, this.when);
  final String text;
  final String author;
  final String when;
}

class SampleUsers {
  SampleUsers._();

  static final List<AdminUser> all = [
    _u(
      '5f1c2a9e',
      'Abiola Martins',
      'abiola_m',
      'abiola.martins@example.com',
      '+234 803 412 8890',
      'SA-1000231',
      'SFZ-4471-0231',
      'NG',
      'Nigeria',
      AccountStatus.active,
      'Verified',
      'Jan 12, 2026',
      '2 min ago',
      'Today, 09:14',
      'SFZ 64,300',
    ),
    _u(
      '8a77d3b1',
      'Chinedu Okafor',
      'chinedu',
      'chinedu.okafor@example.com',
      '+234 806 220 1934',
      'SA-1000232',
      'SFZ-4471-0232',
      'NG',
      'Nigeria',
      AccountStatus.active,
      'Verified',
      'Feb 03, 2026',
      '15 min ago',
      'Today, 08:52',
      'SFZ 12,950',
    ),
    _u(
      'c0e4b7f2',
      'Sarah Collins',
      'sarahc',
      'sarah.collins@example.com',
      '+44 7700 900 142',
      'SA-1000233',
      'SFZ-4471-0233',
      'GB',
      'United Kingdom',
      AccountStatus.restricted,
      'Pending',
      'Feb 18, 2026',
      '3 hours ago',
      'Today, 06:40',
      'SFZ 3,200',
      walletRestricted: true,
    ),
    _u(
      '1d9f6a40',
      'Michael Uche',
      'mike_uche',
      'michael.uche@example.com',
      '+234 812 555 0187',
      'SA-1000234',
      'SFZ-4471-0234',
      'NG',
      'Nigeria',
      AccountStatus.active,
      'Verified',
      'Mar 02, 2026',
      '1 hour ago',
      'Today, 07:58',
      'SFZ 88,410',
    ),
    _u(
      'e3a1c958',
      'Olivia Anderson',
      'olivia.a',
      '',
      '+1 202 555 0147',
      'SA-1000235',
      'SFZ-4471-0235',
      'US',
      'United States',
      AccountStatus.suspended,
      'Rejected',
      'Mar 21, 2026',
      '2 days ago',
      'Nov 22, 18:20',
      'SFZ 0',
      flagged: true,
    ),
    _u(
      '77b2e0c4',
      'Temi Adeyemi',
      'temi',
      'temi.adeyemi@example.com',
      '+234 809 771 2365',
      'SA-1000236',
      'SFZ-4471-0236',
      'NG',
      'Nigeria',
      AccountStatus.active,
      'Verified',
      'Apr 07, 2026',
      'Yesterday',
      'Nov 23, 21:05',
      'SFZ 7,500',
    ),
    _u(
      'a5c8f213',
      'James Wilson',
      'jwilson',
      'james.wilson@example.com',
      '+1 416 555 0132',
      'SA-1000237',
      'SFZ-4471-0237',
      'CA',
      'Canada',
      AccountStatus.inactive,
      'Pending',
      'Apr 19, 2026',
      '41 days ago',
      'Oct 14, 10:12',
      'SFZ 250',
    ),
    _u(
      '3f6d9b27',
      'Kwame Mensah',
      'kwame',
      'kwame.mensah@example.com',
      '+233 24 555 0190',
      'SA-1000238',
      'SFZ-4471-0238',
      'GH',
      'Ghana',
      AccountStatus.blocked,
      'Rejected',
      'May 05, 2026',
      '12 days ago',
      'Nov 12, 14:33',
      'SFZ 0',
      walletRestricted: true,
      flagged: true,
    ),
    _u(
      '9e0a4c16',
      'Lena Fischer',
      'lena_f',
      'lena.fischer@example.com',
      '+49 151 5550 1834',
      'SA-1000239',
      'SFZ-4471-0239',
      'DE',
      'Germany',
      AccountStatus.active,
      'Verified',
      'May 28, 2026',
      '5 min ago',
      'Today, 09:20',
      'SFZ 21,060',
    ),
    _u(
      'b4e7f590',
      'Grace Eze',
      'grace',
      '',
      '+234 701 555 2210',
      'SA-1000240',
      'SFZ-4471-0240',
      'NG',
      'Nigeria',
      AccountStatus.deleted,
      'Verified',
      'Jun 11, 2026',
      '64 days ago',
      'Sep 21, 08:00',
      'SFZ 0',
    ),
    _u(
      '6c3b8d72',
      'Ibrahim Sule',
      'ibrahim',
      'ibrahim.sule@example.com',
      '+234 815 555 6612',
      'SA-1000241',
      'SFZ-4471-0241',
      'NG',
      'Nigeria',
      AccountStatus.inactive,
      'Not started',
      'Jul 02, 2026',
      '35 days ago',
      'Oct 20, 19:45',
      'SFZ 1,020',
    ),
    _u(
      'd8f1a364',
      'Amina Yusuf',
      'amina_y',
      'amina.yusuf@example.com',
      '+254 712 555 018',
      'SA-1000242',
      'SFZ-4471-0242',
      'KE',
      'Kenya',
      AccountStatus.active,
      'Pending',
      'Aug 15, 2026',
      '30 min ago',
      'Today, 08:30',
      'SFZ 4,860',
    ),
  ];

  static AdminUser _u(
    String id,
    String name,
    String username,
    String email,
    String phone,
    String acc,
    String sfz,
    String cc,
    String country,
    AccountStatus status,
    String kyc,
    String joined,
    String lastActive,
    String lastLogin,
    String balance, {
    bool walletRestricted = false,
    bool flagged = false,
  }) => AdminUser(
    id: '$id-1c2d-4e5f-9a8b-${id.substring(0, 4)}c7d1e2f3',
    name: name,
    username: '@$username',
    email: email,
    phone: phone,
    accountNo: acc,
    sfzNo: sfz,
    countryCode: cc,
    country: country,
    status: status,
    kyc: kyc,
    joined: joined,
    lastActive: lastActive,
    lastLogin: lastLogin,
    balance: balance,
    walletRestricted: walletRestricted,
    flagged: flagged,
  );

  static AdminUser? byId(String id) {
    for (final u in all) {
      if (u.id == id) return u;
    }
    return null;
  }

  /// Seeds sample history once so the profile tabs have content.
  static void ensureHistory(AdminUser u) {
    if (u.history.isNotEmpty) return;
    if (u.status == AccountStatus.restricted || u.walletRestricted) {
      u.history.add(
        AdminAction(
          action: 'Wallet transactions restricted',
          reason:
              'Several card top-ups reversed by the issuer within 24 hours.',
          admin: 'Daniel Ade',
          role: 'Investigation Admin',
          when: 'Nov 20, 2026 · 14:12',
          from: 'Wallet: Open',
          to: 'Wallet: Restricted',
        ),
      );
    }
    if (u.status == AccountStatus.suspended) {
      u.history.add(
        AdminAction(
          action: 'Account suspended (14 days)',
          reason: 'Fraud report from two users; under investigation.',
          admin: 'Kesta Wealth',
          role: 'Super Admin',
          when: 'Nov 21, 2026 · 10:05',
          from: 'Active',
          to: 'Suspended',
        ),
      );
    }
    if (u.status == AccountStatus.blocked) {
      u.history.add(
        AdminAction(
          action: 'Account permanently blocked',
          reason: 'Confirmed account takeover scheme; evidence in case DSP-2026-0091.',
          admin: 'Kesta Wealth',
          role: 'Super Admin',
          when: 'Nov 12, 2026 · 16:40',
          from: 'Suspended',
          to: 'Blocked',
        ),
      );
    }
    if (u.status == AccountStatus.deleted) {
      u.history.add(
        AdminAction(
          action: 'Account deleted by user',
          reason: 'User requested deletion in the app. Records retained (retention schedule).',
          admin: 'System',
          role: 'Automatic',
          when: 'Sep 21, 2026 · 08:00',
          from: 'Active',
          to: 'Deleted',
        ),
      );
    }
    u.history.add(
      AdminAction(
        action: 'Profile viewed for investigation',
        reason: 'Routine review of reported account.',
        admin: 'Ruth Bello',
        role: 'Customer Support Admin',
        when: 'Nov 18, 2026 · 11:22',
        from: '-',
        to: '-',
      ),
    );
  }

  static List<DeviceRecord> devices(AdminUser u) => const [
    DeviceRecord(
      'Mobile',
      'Samsung Galaxy S23',
      'Android 14',
      '2.4.1',
      'a3f9-••••-71c2',
      'Jan 12, 2026',
      'Today, 09:14',
      'Nov 23, 22:40',
      true,
    ),
    DeviceRecord(
      'Web',
      'Chrome on Windows',
      'Windows 11',
      'Web 1.0',
      'web-••••-0d8e',
      'Oct 02, 2026',
      'Nov 23, 18:02',
      'Nov 23, 19:30',
      false,
    ),
    DeviceRecord(
      'Mobile',
      'iPhone 12',
      'iOS 17.6',
      '2.3.0',
      'f71b-••••-9a04',
      'Mar 30, 2026',
      'Aug 14, 07:21',
      'Aug 14, 07:55',
      false,
    ),
  ];

  static const logins = <LoginRecord>[
    LoginRecord(
      'Today, 09:14',
      'Login',
      'Samsung Galaxy S23',
      '102.89.••.14',
      'Lagos, NG',
      true,
    ),
    LoginRecord(
      'Nov 23, 22:40',
      'Logout',
      'Samsung Galaxy S23',
      '102.89.••.14',
      'Lagos, NG',
      true,
    ),
    LoginRecord(
      'Nov 23, 18:02',
      'Web link (QR)',
      'Chrome on Windows',
      '197.210.••.3',
      'Lagos, NG',
      true,
    ),
    LoginRecord(
      'Nov 22, 03:11',
      'Failed app password',
      'Samsung Galaxy S23',
      '102.89.••.14',
      'Lagos, NG',
      false,
    ),
    LoginRecord(
      'Nov 20, 07:45',
      'Login',
      'Samsung Galaxy S23',
      '102.89.••.14',
      'Lagos, NG',
      true,
    ),
  ];

  static const transactions = <UserTx>[
    UserTx(
      'TXN-2026-112301',
      'Nov 23, 2026 · 10:30',
      'Schatz transfer',
      'out',
      'SFZ 2,500',
      'SFZ 0',
      'Chinedu Okafor (SA-1000232)',
      'Internal ledger',
      'Completed',
      'Rent share',
    ),
    UserTx(
      'TXN-2026-112244',
      'Nov 22, 2026 · 16:05',
      'Deposit',
      'in',
      'SFZ 10,000',
      'SFZ 25',
      'Card •••• 4417',
      'Paystack',
      'Completed',
      'Wallet top-up',
    ),
    UserTx(
      'TXN-2026-112190',
      'Nov 21, 2026 · 12:41',
      'Airtime purchase',
      'out',
      'SFZ 300',
      'SFZ 0',
      'MTN 0803 •••• 890',
      'Reloadly',
      'Completed',
      'Airtime',
    ),
    UserTx(
      'TXN-2026-112131',
      'Nov 20, 2026 · 09:12',
      'Gift card loaded',
      'in',
      'SFZ 5,000',
      'SFZ 0',
      'Gift card GC-8F2A-19D4',
      'Schatz Gift Card',
      'Completed',
      'Loaded by recipient',
    ),
    UserTx(
      'TXN-2026-112077',
      'Nov 19, 2026 · 20:33',
      'Data purchase',
      'out',
      'SFZ 1,200',
      'SFZ 0',
      'Airtel 0812 •••• 187',
      'Reloadly',
      'Failed',
      'Provider timeout',
    ),
    UserTx(
      'TXN-2026-111980',
      'Nov 18, 2026 · 08:02',
      'Withdrawal',
      'out',
      'SFZ 8,000',
      'SFZ 40',
      'GTBank •••• 1029',
      'Paystack',
      'Reversed',
      'Bank rejected',
    ),
    UserTx(
      'TXN-2026-111902',
      'Nov 17, 2026 · 13:27',
      'Schatz transfer',
      'in',
      'SFZ 1,750',
      'SFZ 0',
      'Lena Fischer (SA-1000239)',
      'Internal ledger',
      'Completed',
      'Dinner',
    ),
    UserTx(
      'TXN-2026-111850',
      'Nov 16, 2026 · 11:10',
      'Gift card purchase',
      'out',
      'SFZ 5,000',
      'SFZ 50',
      'Gift card GC-77B1-04E2',
      'Schatz Gift Card',
      'Pending',
      'For a friend',
    ),
  ];

  static const cases = <CaseRecord>[
    CaseRecord(
      'CMP-2026-0412',
      'Complaint',
      'Payment complaint',
      'Nov 19, 2026',
      'Under Review',
      'Ruth Bello',
    ),
    CaseRecord(
      'DSP-2026-0088',
      'Dispute',
      'Financial dispute',
      'Nov 02, 2026',
      'Resolved',
      'Daniel Ade',
    ),
    CaseRecord(
      'CMP-2026-0301',
      'Complaint',
      'Account access',
      'Sep 14, 2026',
      'Closed',
      'Ruth Bello',
    ),
  ];

  static const alerts = <SecurityAlert>[
    SecurityAlert(
      'Failed app password',
      '1 failed attempt from a known device',
      'Nov 22, 03:11',
      false,
    ),
    SecurityAlert(
      'New device sign-in',
      'Chrome on Windows linked by QR',
      'Nov 23, 18:02',
      false,
    ),
    SecurityAlert(
      'Reversed withdrawal',
      'GTBank rejected a withdrawal of SFZ 8,000',
      'Nov 18, 08:02',
      true,
    ),
  ];
}
