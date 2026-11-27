/// Sample data for the Support section (Disputes, Support Tickets,
/// Notifications, Content & Safety, Account Requests). Replaced by live
/// Supabase data in the backend phase.
library;

class CaseNote {
  const CaseNote(this.title, this.by, this.time, {this.note});
  final String title;
  final String by;
  final String time;
  final String? note;
}

class DisputeCase {
  const DisputeCase({
    required this.ref,
    required this.user,
    required this.email,
    required this.account,
    required this.category,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.assignee,
    required this.submitted,
    required this.updated,
    this.txnRef,
    this.amount,
    this.attachments = const [],
    this.history = const [],
    this.resolution,
    this.resolvedOn,
  });

  final String ref;
  final String user;
  final String email;
  final String account;
  final String category;
  final String subject;
  final String description;
  final String priority;
  final String status;
  final String assignee;
  final String submitted;
  final String updated;
  final String? txnRef;
  final String? amount;
  final List<String> attachments;
  final List<CaseNote> history;
  final String? resolution;
  final String? resolvedOn;
}

class Ticket {
  const Ticket({
    required this.id,
    required this.created,
    required this.subject,
    required this.user,
    required this.email,
    required this.category,
    required this.priority,
    required this.status,
    required this.assignee,
    required this.updated,
    required this.thread,
    this.slaBreached = false,
  });

  final String id;
  final String created;
  final String subject;
  final String user;
  final String email;
  final String category;
  final String priority;
  final String status;
  final String assignee;
  final String updated;
  final bool slaBreached;

  /// (fromUser, name, text, time)
  final List<(bool, String, String, String)> thread;
}

class SentNotification {
  const SentNotification({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.channels,
    required this.recipients,
    required this.status,
    required this.rate,
    required this.sentAt,
  });

  final String title;
  final String subtitle;
  final String type;

  /// push, email, sms, inapp
  final List<String> channels;
  final String recipients;
  final String status;
  final String rate;
  final String sentAt;
}

class ReportedItem {
  const ReportedItem({
    required this.id,
    required this.kind,
    required this.reporter,
    required this.reported,
    required this.reason,
    required this.preview,
    required this.status,
    required this.time,
    this.count = 1,
  });

  final String id;

  /// Message, Story, For You post, Profile, Group
  final String kind;
  final String reporter;
  final String reported;
  final String reason;
  final String preview;
  final String status;
  final String time;
  final int count;
}

class NameChange {
  const NameChange(
    this.id,
    this.user,
    this.current,
    this.requested,
    this.status,
    this.time, {
    this.note,
  });

  final String id;
  final String user;
  final String current;
  final String requested;
  final String status;
  final String time;
  final String? note;
}

class SampleSupport {
  SampleSupport._();

  static const disputes = [
    DisputeCase(
      ref: 'DSP-2026-00412',
      user: 'John Okafor',
      email: 'john.o***@gmail.com',
      account: 'SCZ-1004-2231',
      category: 'Financial Dispute',
      subject: 'Transfer debited but not received',
      description:
          'I sent SFZ 25,000 to Emily Johnson on Nov 24. My wallet was debited '
          'but she says she never received it.',
      priority: 'High',
      status: 'Investigation',
      assignee: 'Michael Uche',
      submitted: 'Nov 24, 2026 10:15 AM',
      updated: '12 mins ago',
      txnRef: 'TXN-2026-118204',
      amount: 'SFZ 25,000',
      attachments: ['receipt_screenshot.png', 'bank_sms.jpg'],
      history: [
        CaseNote('Case created', 'John Okafor (user)', 'Nov 24, 10:15 AM'),
        CaseNote(
          'Assigned to Michael Uche',
          'Kesta Wealth',
          'Nov 24, 10:40 AM',
        ),
        CaseNote(
          'Status changed to Investigation',
          'Michael Uche',
          'Nov 24, 11:02 AM',
          note:
              'Ledger shows debit entry only. Credit leg missing. Checking '
              'the transfer job logs.',
        ),
      ],
    ),
    DisputeCase(
      ref: 'DSP-2026-00411',
      user: 'Emily Johnson',
      email: 'emily.j***@gmail.com',
      account: 'SCZ-1004-1187',
      category: 'Gift Card Complaint',
      subject: 'Schatz Gift Card says already redeemed',
      description:
          'The gift card my brother bought me shows "already redeemed" but I '
          'never loaded it.',
      priority: 'High',
      status: 'Under Review',
      assignee: 'Linda Emmanuel',
      submitted: 'Nov 24, 2026 09:48 AM',
      updated: '40 mins ago',
      txnRef: 'GC-SFZ-8F2K-19QA',
      amount: 'SFZ 50,000',
      attachments: ['gift_card_code.png'],
      history: [
        CaseNote('Case created', 'Emily Johnson (user)', 'Nov 24, 09:48 AM'),
        CaseNote(
          'Assigned to Linda Emmanuel',
          'Auto-assign',
          'Nov 24, 09:48 AM',
        ),
      ],
    ),
    DisputeCase(
      ref: 'DSP-2026-00410',
      user: 'David Brown',
      email: 'david.b***@gmail.com',
      account: 'SCZ-1003-9921',
      category: 'Fraud Report',
      subject: 'Someone logged in from a new device',
      description:
          'I got a login alert from a device I do not know and SFZ 10,000 was '
          'sent out.',
      priority: 'High',
      status: 'Escalated',
      assignee: 'Sarah Johnson',
      submitted: 'Nov 23, 2026 08:20 PM',
      updated: '1 hour ago',
      txnRef: 'TXN-2026-117960',
      amount: 'SFZ 10,000',
      history: [
        CaseNote('Case created', 'David Brown (user)', 'Nov 23, 08:20 PM'),
        CaseNote(
          'Wallet restricted (outgoing)',
          'Sarah Johnson',
          'Nov 23, 08:31 PM',
          note: 'Precaution while the login is investigated.',
        ),
        CaseNote(
          'Escalated to Compliance',
          'Sarah Johnson',
          'Nov 23, 09:05 PM',
        ),
      ],
    ),
    DisputeCase(
      ref: 'DSP-2026-00409',
      user: 'Sarah Collins',
      email: 'sarah.c***@gmail.com',
      account: 'SCZ-1002-4410',
      category: 'Payment Complaint',
      subject: 'Card top-up charged twice',
      description: 'My Verve card was charged twice for one SFZ 5,000 top-up.',
      priority: 'Medium',
      status: 'Awaiting User Response',
      assignee: 'James Wilson',
      submitted: 'Nov 23, 2026 03:10 PM',
      updated: '3 hours ago',
      txnRef: 'TOP-2026-55120',
      amount: 'SFZ 5,000',
      history: [
        CaseNote('Case created', 'Sarah Collins (user)', 'Nov 23, 03:10 PM'),
        CaseNote(
          'Asked user for bank statement',
          'James Wilson',
          'Nov 23, 04:00 PM',
        ),
      ],
    ),
    DisputeCase(
      ref: 'DSP-2026-00408',
      user: 'Olivia Anderson',
      email: 'olivia.a***@gmail.com',
      account: 'SCZ-1001-7782',
      category: 'Account Access',
      subject: 'Cannot log in after changing phone',
      description: 'New SIM, same number. OTP never arrives.',
      priority: 'Medium',
      status: 'New',
      assignee: 'Unassigned',
      submitted: 'Nov 23, 2026 11:42 AM',
      updated: '5 hours ago',
    ),
    DisputeCase(
      ref: 'DSP-2026-00407',
      user: 'Temi Adeyemi',
      email: 'temi.a***@gmail.com',
      account: 'SCZ-1001-3390',
      category: 'Reported User',
      subject: 'User sending scam messages',
      description:
          'A user keeps sending me "double your Schatz" messages and links.',
      priority: 'Low',
      status: 'Resolved',
      assignee: 'Linda Emmanuel',
      submitted: 'Nov 22, 2026 06:12 PM',
      updated: 'Yesterday',
      resolution: 'Reported account suspended for 30 days after review.',
      resolvedOn: 'Nov 23, 2026',
      history: [
        CaseNote('Case created', 'Temi Adeyemi (user)', 'Nov 22, 06:12 PM'),
        CaseNote(
          'Account suspended (30 days)',
          'Linda Emmanuel',
          'Nov 23, 09:30 AM',
          note: '4 reports from different users, same message pattern.',
        ),
        CaseNote('Case resolved', 'Linda Emmanuel', 'Nov 23, 09:32 AM'),
      ],
    ),
    DisputeCase(
      ref: 'DSP-2026-00406',
      user: 'James Wilson',
      email: 'james.w***@gmail.com',
      account: 'SCZ-1000-8812',
      category: 'Financial Dispute',
      subject: 'Airtime purchase failed but charged',
      description: 'MTN airtime SFZ 2,000 failed, no refund yet.',
      priority: 'Medium',
      status: 'Closed',
      assignee: 'Michael Uche',
      submitted: 'Nov 21, 2026 02:30 PM',
      updated: 'Nov 22',
      txnRef: 'AIR-2026-90114',
      amount: 'SFZ 2,000',
      resolution: 'Reloadly confirmed failure. Refund entry posted.',
      resolvedOn: 'Nov 22, 2026',
    ),
    DisputeCase(
      ref: 'DSP-2026-00405',
      user: 'Linda Emmanuel',
      email: 'linda.e***@gmail.com',
      account: 'SCZ-1000-2290',
      category: 'Admin Investigation',
      subject: 'Unusual transfer pattern flagged',
      description:
          'System flagged 14 transfers under SFZ 9,900 within an hour to new '
          'accounts.',
      priority: 'High',
      status: 'Investigation',
      assignee: 'Sarah Johnson',
      submitted: 'Nov 21, 2026 09:05 AM',
      updated: '2 days ago',
    ),
  ];

  static const tickets = [
    Ticket(
      id: 'TKT-2026-001256',
      created: 'Nov 27, 10:15 AM',
      subject: 'Unable to complete bank transfer',
      user: 'John Okafor',
      email: 'john.o***@gmail.com',
      category: 'Transactions',
      priority: 'High',
      status: 'Open',
      assignee: 'Sarah Johnson',
      updated: 'Nov 27, 10:15 AM',
      thread: [
        (
          true,
          'John Okafor',
          'My bank transfer top-up has been pending since morning.',
          '10:15 AM',
        ),
      ],
    ),
    Ticket(
      id: 'TKT-2026-001255',
      created: 'Nov 27, 09:48 AM',
      subject: 'KYC verification under review',
      user: 'Emily Johnson',
      email: 'emily.j***@gmail.com',
      category: 'KYC Verification',
      priority: 'Medium',
      status: 'In Progress',
      assignee: 'Michael Uche',
      updated: 'Nov 27, 09:48 AM',
      thread: [
        (
          true,
          'Emily Johnson',
          'I uploaded my ID 3 days ago. When will it be approved?',
          '09:48 AM',
        ),
        (
          false,
          'Michael Uche',
          'Thanks Emily. Your document is in the review queue, expect an '
              'update within 24 hours.',
          '10:02 AM',
        ),
      ],
    ),
    Ticket(
      id: 'TKT-2026-001254',
      created: 'Nov 27, 09:30 AM',
      subject: 'Card payment failed',
      user: 'David Brown',
      email: 'david.b***@gmail.com',
      category: 'Cards',
      priority: 'High',
      status: 'Open',
      assignee: 'Linda Emmanuel',
      updated: 'Nov 27, 09:30 AM',
      slaBreached: true,
      thread: [(true, 'David Brown', 'Card top-up keeps failing.', '09:30 AM')],
    ),
    Ticket(
      id: 'TKT-2026-001253',
      created: 'Nov 27, 09:10 AM',
      subject: 'Wallet top up not reflecting',
      user: 'Sarah Collins',
      email: 'sarah.c***@gmail.com',
      category: 'Wallet',
      priority: 'Medium',
      status: 'In Progress',
      assignee: 'James Wilson',
      updated: 'Nov 27, 09:10 AM',
      thread: [
        (
          true,
          'Sarah Collins',
          'Topped up SFZ 5,000, not showing.',
          '09:10 AM',
        ),
      ],
    ),
    Ticket(
      id: 'TKT-2026-001252',
      created: 'Nov 27, 08:55 AM',
      subject: 'Airtime purchase unsuccessful',
      user: 'Olivia Anderson',
      email: 'olivia.a***@gmail.com',
      category: 'Airtime & Data',
      priority: 'Low',
      status: 'Resolved',
      assignee: 'Sarah Johnson',
      updated: 'Nov 27, 08:55 AM',
      thread: [
        (true, 'Olivia Anderson', 'Airtime did not arrive.', '08:55 AM'),
        (false, 'Sarah Johnson', 'Refund posted to your wallet.', '09:20 AM'),
      ],
    ),
    Ticket(
      id: 'TKT-2026-001251',
      created: 'Nov 26, 04:20 PM',
      subject: 'Login issue on mobile app',
      user: 'Temi Adeyemi',
      email: 'temi.a***@gmail.com',
      category: 'Account',
      priority: 'High',
      status: 'Resolved',
      assignee: 'Michael Uche',
      updated: 'Nov 26, 04:20 PM',
      thread: [(true, 'Temi Adeyemi', 'OTP not arriving.', '04:20 PM')],
    ),
    Ticket(
      id: 'TKT-2026-001250',
      created: 'Nov 26, 03:45 PM',
      subject: 'Dispute on failed transaction',
      user: 'James Wilson',
      email: 'james.w***@gmail.com',
      category: 'Disputes',
      priority: 'High',
      status: 'In Progress',
      assignee: 'Linda Emmanuel',
      updated: 'Nov 26, 03:45 PM',
      thread: [(true, 'James Wilson', 'I want my money back.', '03:45 PM')],
    ),
    Ticket(
      id: 'TKT-2026-001249',
      created: 'Nov 26, 02:30 PM',
      subject: 'Change of phone number',
      user: 'Linda Emmanuel',
      email: 'linda.e***@gmail.com',
      category: 'Account',
      priority: 'Low',
      status: 'Closed',
      assignee: 'James Wilson',
      updated: 'Nov 26, 02:30 PM',
      thread: [
        (true, 'Linda Emmanuel', 'How do I change my number?', '02:30 PM'),
      ],
    ),
  ];

  static const notifications = [
    SentNotification(
      title: 'Welcome to SchatzApp!',
      subtitle: 'Sent to new users',
      type: 'User',
      channels: ['push', 'email', 'inapp'],
      recipients: '1,245 Users',
      status: 'Delivered',
      rate: '98.7%',
      sentAt: 'Nov 27, 2026\n10:30 AM',
    ),
    SentNotification(
      title: 'Wallet Top Up Successful',
      subtitle: 'Notify users of successful top up',
      type: 'Transaction',
      channels: ['push', 'email', 'inapp'],
      recipients: '3,562 Users',
      status: 'Delivered',
      rate: '95.2%',
      sentAt: 'Nov 27, 2026\n09:15 AM',
    ),
    SentNotification(
      title: 'Schatz Gift Card Received',
      subtitle: 'Someone sent you a Schatz Gift Card',
      type: 'Product',
      channels: ['push', 'email'],
      recipients: '856 Users',
      status: 'Sent',
      rate: '100%',
      sentAt: 'Nov 27, 2026\n08:20 AM',
    ),
    SentNotification(
      title: 'KYC Verification Reminder',
      subtitle: 'Reminder for incomplete KYC',
      type: 'Security',
      channels: ['push', 'email', 'inapp'],
      recipients: '2,451 Users',
      status: 'Scheduled',
      rate: '',
      sentAt: 'Nov 28, 2026\n02:00 PM',
    ),
    SentNotification(
      title: 'System Maintenance Alert',
      subtitle: 'Scheduled maintenance notification',
      type: 'System',
      channels: ['push', 'email'],
      recipients: 'All Users',
      status: 'Delivered',
      rate: '99.1%',
      sentAt: 'Nov 26, 2026\n11:30 PM',
    ),
    SentNotification(
      title: 'Airtime & Data Weekend Bonus',
      subtitle: 'Promotional campaign notification',
      type: 'Marketing',
      channels: ['push', 'email', 'inapp'],
      recipients: '12,856 Users',
      status: 'Failed',
      rate: '12.6%',
      sentAt: 'Nov 26, 2026\n06:45 PM',
    ),
    SentNotification(
      title: 'Transaction Declined',
      subtitle: 'Notify failed transaction',
      type: 'Transaction',
      channels: ['push', 'email', 'inapp'],
      recipients: '1,125 Users',
      status: 'Delivered',
      rate: '93.4%',
      sentAt: 'Nov 26, 2026\n04:10 PM',
    ),
    SentNotification(
      title: 'Login from New Device',
      subtitle: 'Security alert for new login',
      type: 'Security',
      channels: ['push', 'email'],
      recipients: '534 Users',
      status: 'Delivered',
      rate: '97.6%',
      sentAt: 'Nov 26, 2026\n02:30 PM',
    ),
  ];

  static const reported = [
    ReportedItem(
      id: 'RPT-88412',
      kind: 'Message',
      reporter: 'Temi Adeyemi',
      reported: 'quickcash_ng',
      reason: 'Scam or fraud',
      preview: '"Send me 5k Schatz and I will double it in 1 hour..."',
      status: 'Pending',
      time: '8 mins ago',
      count: 4,
    ),
    ReportedItem(
      id: 'RPT-88411',
      kind: 'For You post',
      reporter: 'Emily Johnson',
      reported: 'vibes.daily',
      reason: 'Nudity or sexual content',
      preview: 'Video post (0:18)',
      status: 'Pending',
      time: '32 mins ago',
      count: 2,
    ),
    ReportedItem(
      id: 'RPT-88410',
      kind: 'Story',
      reporter: 'John Okafor',
      reported: 'mike_u',
      reason: 'Harassment',
      preview: 'Photo story with caption',
      status: 'Under Review',
      time: '1 hour ago',
    ),
    ReportedItem(
      id: 'RPT-88409',
      kind: 'Profile',
      reporter: 'Sarah Collins',
      reported: 'schatz_support_help',
      reason: 'Impersonating SchatzApp',
      preview: 'Username and photo copy SchatzApp branding',
      status: 'Pending',
      time: '2 hours ago',
      count: 7,
    ),
    ReportedItem(
      id: 'RPT-88408',
      kind: 'Group',
      reporter: 'David Brown',
      reported: 'Crypto Kings 💰',
      reason: 'Spam',
      preview: 'Group with 240 members posting referral links',
      status: 'Action Taken',
      time: 'Yesterday',
      count: 3,
    ),
    ReportedItem(
      id: 'RPT-88407',
      kind: 'Message',
      reporter: 'Olivia Anderson',
      reported: 'james_w',
      reason: 'Hate speech',
      preview: '"[message text shown to reviewers only]"',
      status: 'Dismissed',
      time: '2 days ago',
    ),
  ];

  static const nameChanges = [
    NameChange(
      'NCR-2210',
      'Emily Johnson',
      'Emily Johnson',
      'Emily Johnson-Okoro',
      'Pending',
      '20 mins ago',
    ),
    NameChange(
      'NCR-2209',
      'Michael Uche',
      'Michael Uche',
      'Michael C. Uche',
      'Pending',
      '2 hours ago',
    ),
    NameChange(
      'NCR-2208',
      'David Brown',
      'David Brown',
      'Dave Brownie',
      'Pending',
      '5 hours ago',
    ),
    NameChange(
      'NCR-2207',
      'Sarah Collins',
      'Sarah Collins',
      'Sarah Collins-Adeyemi',
      'Approved',
      'Yesterday',
      note: 'Marriage certificate checked.',
    ),
    NameChange(
      'NCR-2206',
      'James Wilson',
      'James Wilson',
      'SchatzApp Official',
      'Rejected',
      '2 days ago',
      note: 'Impersonation risk.',
    ),
  ];

  /// (phone, dial code, country guess, time)
  static const unsupportedSignups = [
    ('+1 415 *** 2290', '+1', 'United States', '12 mins ago'),
    ('+234 803 *** 1123', '+234', 'Nigeria (inactive)', '1 hour ago'),
    ('+91 98*** 41220', '+91', 'India', '3 hours ago'),
    ('+33 6 ** ** 81 20', '+33', 'France', 'Yesterday'),
    ('+1 647 *** 9012', '+1', 'Canada', 'Yesterday'),
  ];

  /// (user, account, requested, status, records kept until)
  static const closures = [
    ('Ade Bello', 'SCZ-1000-1182', 'Nov 26, 2026', 'Pending wallet check', '—'),
    ('Grace Udo', 'SCZ-1000-0921', 'Nov 20, 2026', 'Closed', 'Nov 2033'),
    (
      'Kunle Ojo',
      'SCZ-1000-0715',
      'Nov 12, 2026',
      'Closed (legal hold)',
      'Hold active',
    ),
  ];
}
