/// Sample money data for the UI phase (wallet_transactions, wallets,
/// saved_cards, schatz_giftcards, gift_cards, Reloadly orders). Replaced by
/// Supabase queries in the backend phase.
///
/// Money kinds are kept apart everywhere:
///  * real money in / out goes through a payment provider (Paystack, banks);
///  * Schatz (SFZ) is the internal currency moved on the SchatzApp ledger.
library;

enum MoneyKind { fiatIn, fiatOut, internal, service }

extension MoneyKindX on MoneyKind {
  String get label => switch (this) {
    MoneyKind.fiatIn => 'Real money in',
    MoneyKind.fiatOut => 'Real money out',
    MoneyKind.internal => 'Internal Schatz',
    MoneyKind.service => 'Service purchase',
  };
}

class Txn {
  const Txn({
    required this.id,
    required this.ref,
    required this.user,
    required this.email,
    required this.type,
    required this.detail,
    required this.kind,
    required this.amount,
    required this.fee,
    required this.status,
    required this.channel,
    required this.date,
    required this.time,
    required this.icon,
    this.counterparty = '-',
    this.providerRef = '-',
  });

  final String id;
  final String ref;
  final String user;
  final String email;
  final String type;
  final String detail;
  final MoneyKind kind;
  final String amount;
  final String fee;
  final String status;
  final String channel;
  final String date;
  final String time;

  /// transfer, airtime, data, topup, giftcard, withdrawal, card
  final String icon;
  final String counterparty;
  final String providerRef;
}

class WalletRow {
  const WalletRow(
    this.user,
    this.email,
    this.accountNo,
    this.balance,
    this.local,
    this.status,
    this.kyc,
    this.lastActivity,
    this.lastTime,
    this.country,
  );
  final String user;
  final String email;
  final String accountNo;
  final String balance;
  final String local;
  final String status;
  final String kyc;
  final String lastActivity;
  final String lastTime;
  final String country;
}

class SavedCard {
  const SavedCard(
    this.user,
    this.email,
    this.brand,
    this.last4,
    this.billingCountry,
    this.isDefault,
    this.added,
    this.topups,
    this.status,
  );
  final String user;
  final String email;
  final String brand;
  final String last4;
  final String billingCountry;
  final bool isDefault;
  final String added;
  final int topups;
  final String status;
}

class AirtimeOrder {
  const AirtimeOrder(
    this.id,
    this.type,
    this.network,
    this.phone,
    this.amount,
    this.status,
    this.user,
    this.date,
    this.time,
    this.country,
  );
  final String id;
  final String type;
  final String network;
  final String phone;
  final String amount;
  final String status;
  final String user;
  final String date;
  final String time;
  final String country;
}

class GiftCardRecord {
  const GiftCardRecord({
    required this.id,
    required this.kind,
    required this.name,
    required this.value,
    required this.buyer,
    required this.buyerAccount,
    required this.purchased,
    required this.owner,
    required this.status,
    this.loadedBy = '-',
    this.loadedInto = '-',
    this.loadedAt = '-',
    this.loadedAmount = '-',
    this.txRef = '-',
    this.delivery = 'In-app',
  });

  final String id;

  /// 'Schatz' or 'Brand'
  final String kind;
  final String name;
  final String value;
  final String buyer;
  final String buyerAccount;
  final String purchased;
  final String owner;
  final String status;
  final String loadedBy;
  final String loadedInto;
  final String loadedAt;
  final String loadedAmount;
  final String txRef;
  final String delivery;
}

class SampleFinance {
  SampleFinance._();

  static const txns = <Txn>[
    Txn(
      id: 'TXN-2026-000123',
      ref: '8F7J2K9L3M',
      user: 'John Okafor',
      email: 'john.o***@gmail.com',
      type: 'Transfer',
      detail: 'To SchatzApp user',
      kind: MoneyKind.internal,
      amount: 'SFZ 2,500.00',
      fee: 'SFZ 0.00',
      status: 'Successful',
      channel: 'SchatzApp',
      date: 'Nov 24, 2026',
      time: '10:30 AM',
      icon: 'transfer',
      counterparty: 'Chinedu Okafor (SA-1000232)',
    ),
    Txn(
      id: 'TXN-2026-000122',
      ref: '3H9K1L8M2N',
      user: 'Emily Johnson',
      email: 'emily.j***@gmail.com',
      type: 'Airtime',
      detail: 'Airtel Nigeria',
      kind: MoneyKind.service,
      amount: 'SFZ 150.00',
      fee: 'SFZ 0.00',
      status: 'Successful',
      channel: 'Reloadly',
      date: 'Nov 24, 2026',
      time: '10:15 AM',
      icon: 'airtime',
      counterparty: 'Airtel 0809 •••• 412',
      providerRef: 'RLD-88412093',
    ),
    Txn(
      id: 'TXN-2026-000121',
      ref: '7G6H5J4K3L',
      user: 'Michael Uche',
      email: 'michael.u***@gmail.com',
      type: 'Wallet Top Up',
      detail: 'From card',
      kind: MoneyKind.fiatIn,
      amount: 'SFZ 5,000.00',
      fee: 'SFZ 50.00',
      status: 'Successful',
      channel: 'Card',
      date: 'Nov 24, 2026',
      time: '09:58 AM',
      icon: 'topup',
      counterparty: 'Visa •••• 4417',
      providerRef: 'PSK-T0921884',
    ),
    Txn(
      id: 'TXN-2026-000120',
      ref: '9P8O7I6U5Y',
      user: 'Sarah Collins',
      email: 'sarah.c***@gmail.com',
      type: 'Data Bundle',
      detail: 'MTN Nigeria',
      kind: MoneyKind.service,
      amount: 'SFZ 200.00',
      fee: 'SFZ 0.00',
      status: 'Pending',
      channel: 'Reloadly',
      date: 'Nov 24, 2026',
      time: '09:45 AM',
      icon: 'data',
      counterparty: 'MTN 0803 •••• 890',
      providerRef: 'RLD-88411950',
    ),
    Txn(
      id: 'TXN-2026-000119',
      ref: '2A4B6C8D0E',
      user: 'David Brown',
      email: 'david.b***@gmail.com',
      type: 'Gift Card',
      detail: 'Schatz Gift Card',
      kind: MoneyKind.internal,
      amount: 'SFZ 5,000.00',
      fee: 'SFZ 50.00',
      status: 'Successful',
      channel: 'SchatzApp',
      date: 'Nov 24, 2026',
      time: '09:30 AM',
      icon: 'giftcard',
      counterparty: 'GC-8F2A-19D4',
    ),
    Txn(
      id: 'TXN-2026-000118',
      ref: '1Z2X3C4V5B',
      user: 'Linda Emmanuel',
      email: 'linda.e***@gmail.com',
      type: 'Withdrawal',
      detail: 'To bank account',
      kind: MoneyKind.fiatOut,
      amount: 'SFZ 15,000.00',
      fee: 'SFZ 50.00',
      status: 'Failed',
      channel: 'Bank Transfer',
      date: 'Nov 24, 2026',
      time: '09:12 AM',
      icon: 'withdrawal',
      counterparty: 'GTBank •••• 1029',
      providerRef: 'PSK-W0911204',
    ),
    Txn(
      id: 'TXN-2026-000117',
      ref: '5V4B3N2M1Q',
      user: 'James Wilson',
      email: 'james.w***@gmail.com',
      type: 'Gift Card',
      detail: 'Amazon eGift (Reloadly)',
      kind: MoneyKind.service,
      amount: 'SFZ 7,500.00',
      fee: 'SFZ 75.00',
      status: 'Successful',
      channel: 'Reloadly',
      date: 'Nov 24, 2026',
      time: '08:50 AM',
      icon: 'card',
      counterparty: 'Amazon US \$50',
      providerRef: 'RLD-88410077',
    ),
    Txn(
      id: 'TXN-2026-000116',
      ref: '4R5T6Y7U8I',
      user: 'Temi Adeyemi',
      email: 'temi.a***@gmail.com',
      type: 'Withdrawal',
      detail: 'Reversed by bank',
      kind: MoneyKind.fiatOut,
      amount: 'SFZ 8,000.00',
      fee: 'SFZ 40.00',
      status: 'Reversed',
      channel: 'Bank Transfer',
      date: 'Nov 23, 2026',
      time: '06:12 PM',
      icon: 'withdrawal',
      counterparty: 'Access •••• 7733',
      providerRef: 'PSK-W0890231',
    ),
  ];

  static const wallets = <WalletRow>[
    WalletRow(
      'John Okafor',
      'john.okafor@gmail.com',
      'SA-1000231',
      'SFZ 25,000.00',
      '≈ ₦25,000,000',
      'Active',
      'Verified',
      'Nov 24, 2026',
      '10:30 AM',
      'NG',
    ),
    WalletRow(
      'Emily Johnson',
      'emily.j***@gmail.com',
      'SA-1000232',
      'SFZ 7,550.00',
      '≈ €75.50',
      'Active',
      'Verified',
      'Nov 24, 2026',
      '09:21 AM',
      'DE',
    ),
    WalletRow(
      'Sarah Collins',
      'sarah.c***@gmail.com',
      'SA-1000233',
      'SFZ 3,200.00',
      '≈ £27.20',
      'Restricted',
      'Pending',
      'Nov 23, 2026',
      '11:15 PM',
      'GB',
    ),
    WalletRow(
      'Michael Uche',
      'michael.u***@gmail.com',
      'SA-1000234',
      'SFZ 88,410.00',
      '≈ ₦88,410,000',
      'Active',
      'Verified',
      'Nov 23, 2026',
      '08:45 PM',
      'NG',
    ),
    WalletRow(
      'Olivia Anderson',
      'olivia.a***@gmail.com',
      'SA-1000235',
      'SFZ 680.00',
      '≈ \$7.30',
      'Frozen',
      'Rejected',
      'Nov 22, 2026',
      '06:30 PM',
      'US',
    ),
    WalletRow(
      'Temi Adeyemi',
      'temi.a***@gmail.com',
      'SA-1000236',
      'SFZ 45,300.00',
      '≈ ₦45,300,000',
      'Suspended',
      'Verified',
      'Nov 22, 2026',
      '04:10 PM',
      'NG',
    ),
    WalletRow(
      'James Wilson',
      'james.w***@gmail.com',
      'SA-1000237',
      'SFZ 5,900.00',
      '≈ C\$86.10',
      'Active',
      'Pending',
      'Nov 21, 2026',
      '10:20 AM',
      'CA',
    ),
  ];

  static const cards = <SavedCard>[
    SavedCard(
      'John Okafor',
      'john.o***@gmail.com',
      'Visa',
      '4417',
      'Nigeria',
      true,
      'Jan 14, 2026',
      18,
      'Active',
    ),
    SavedCard(
      'Emily Johnson',
      'emily.j***@gmail.com',
      'Mastercard',
      '8820',
      'Germany',
      true,
      'Feb 03, 2026',
      6,
      'Active',
    ),
    SavedCard(
      'Michael Uche',
      'michael.u***@gmail.com',
      'Verve',
      '0193',
      'Nigeria',
      false,
      'Mar 11, 2026',
      11,
      'Active',
    ),
    SavedCard(
      'Sarah Collins',
      'sarah.c***@gmail.com',
      'Visa',
      '6604',
      'United Kingdom',
      true,
      'Apr 22, 2026',
      3,
      'Flagged',
    ),
    SavedCard(
      'Olivia Anderson',
      'olivia.a***@gmail.com',
      'Mastercard',
      '7712',
      'United States',
      true,
      'May 30, 2026',
      2,
      'Removed',
    ),
    SavedCard(
      'Temi Adeyemi',
      'temi.a***@gmail.com',
      'Visa',
      '2045',
      'Nigeria',
      true,
      'Jun 18, 2026',
      9,
      'Active',
    ),
    SavedCard(
      'James Wilson',
      'james.w***@gmail.com',
      'Amex',
      '3005',
      'Canada',
      false,
      'Jul 07, 2026',
      1,
      'Active',
    ),
  ];

  static const airtime = <AirtimeOrder>[
    AirtimeOrder(
      'AT-2026-1124001',
      'Airtime',
      'MTN',
      '0803 •••• 678',
      'SFZ 100',
      'Successful',
      'John Okafor',
      'Nov 24, 2026',
      '10:30 AM',
      'NG',
    ),
    AirtimeOrder(
      'DT-2026-1124002',
      'Data (5GB)',
      'Airtel',
      '0901 •••• 678',
      'SFZ 250',
      'Successful',
      'Emily Johnson',
      'Nov 24, 2026',
      '10:15 AM',
      'NG',
    ),
    AirtimeOrder(
      'AT-2026-1124003',
      'Airtime',
      'Glo',
      '0812 •••• 789',
      'SFZ 50',
      'Successful',
      'Michael Uche',
      'Nov 24, 2026',
      '09:58 AM',
      'NG',
    ),
    AirtimeOrder(
      'DT-2026-1124004',
      'Data (10GB)',
      'MTN',
      '0701 •••• 678',
      'SFZ 400',
      'Failed',
      'Sarah Collins',
      'Nov 24, 2026',
      '09:42 AM',
      'NG',
    ),
    AirtimeOrder(
      'AT-2026-1124005',
      'Airtime',
      'Safaricom',
      '0712 •••• 018',
      'SFZ 200',
      'Pending',
      'Amina Yusuf',
      'Nov 24, 2026',
      '09:30 AM',
      'KE',
    ),
    AirtimeOrder(
      'AT-2026-1124006',
      'Airtime',
      'Vodafone',
      '+49 151 •••• 34',
      'SFZ 150',
      'Successful',
      'Lena Fischer',
      'Nov 24, 2026',
      '09:12 AM',
      'DE',
    ),
  ];

  static const giftCards = <GiftCardRecord>[
    GiftCardRecord(
      id: 'GC-8F2A-19D4',
      kind: 'Schatz',
      name: 'Schatz Gift Card',
      value: 'SFZ 5,000',
      buyer: 'David Brown',
      buyerAccount: 'SA-1000244',
      purchased: 'Nov 20, 2026 · 09:02',
      owner: 'Abiola Martins',
      status: 'Loaded',
      loadedBy: 'Abiola Martins',
      loadedInto: 'SA-1000231',
      loadedAt: 'Nov 20, 2026 · 09:12',
      loadedAmount: 'SFZ 5,000',
      txRef: 'TXN-2026-112131',
    ),
    GiftCardRecord(
      id: 'GC-77B1-04E2',
      kind: 'Schatz',
      name: 'Schatz Gift Card',
      value: 'SFZ 5,000',
      buyer: 'Abiola Martins',
      buyerAccount: 'SA-1000231',
      purchased: 'Nov 16, 2026 · 11:10',
      owner: 'Grace Eze',
      status: 'Purchased – Not Loaded',
      txRef: 'TXN-2026-111850',
      delivery: 'Email',
    ),
    GiftCardRecord(
      id: 'GC-3C9E-51A7',
      kind: 'Schatz',
      name: 'Schatz Gift Card',
      value: 'SFZ 10,000',
      buyer: 'Chinedu Okafor',
      buyerAccount: 'SA-1000232',
      purchased: 'Nov 15, 2026 · 15:40',
      owner: 'Chinedu Okafor',
      status: 'Purchased – Not Loaded',
      txRef: 'TXN-2026-111790',
    ),
    GiftCardRecord(
      id: 'GC-A410-7D2C',
      kind: 'Schatz',
      name: 'Schatz Gift Card',
      value: 'SFZ 2,000',
      buyer: 'Lena Fischer',
      buyerAccount: 'SA-1000239',
      purchased: 'Nov 12, 2026 · 08:21',
      owner: 'Temi Adeyemi',
      status: 'Loaded',
      loadedBy: 'Temi Adeyemi',
      loadedInto: 'SA-1000236',
      loadedAt: 'Nov 12, 2026 · 12:05',
      loadedAmount: 'SFZ 2,000',
      txRef: 'TXN-2026-111402',
    ),
    GiftCardRecord(
      id: 'GC-F55B-2E90',
      kind: 'Schatz',
      name: 'Schatz Gift Card',
      value: 'SFZ 1,000',
      buyer: 'Kwame Mensah',
      buyerAccount: 'SA-1000238',
      purchased: 'Nov 03, 2026 · 19:44',
      owner: 'Kwame Mensah',
      status: 'Cancelled',
      txRef: 'TXN-2026-110711',
    ),
    GiftCardRecord(
      id: 'RLD-88410077',
      kind: 'Brand',
      name: 'Amazon eGift Card',
      value: '\$50',
      buyer: 'James Wilson',
      buyerAccount: 'SA-1000237',
      purchased: 'Nov 24, 2026 · 08:50',
      owner: 'James Wilson',
      status: 'Delivered',
      txRef: 'TXN-2026-000117',
    ),
    GiftCardRecord(
      id: 'RLD-88409311',
      kind: 'Brand',
      name: 'Netflix Gift Card',
      value: '€25',
      buyer: 'Emily Johnson',
      buyerAccount: 'SA-1000232',
      purchased: 'Nov 23, 2026 · 17:02',
      owner: 'Emily Johnson',
      status: 'Delivered',
      txRef: 'TXN-2026-000088',
    ),
    GiftCardRecord(
      id: 'RLD-88408862',
      kind: 'Brand',
      name: 'Steam Wallet Card',
      value: '\$20',
      buyer: 'Michael Uche',
      buyerAccount: 'SA-1000234',
      purchased: 'Nov 23, 2026 · 13:15',
      owner: 'Michael Uche',
      status: 'Refunded',
      txRef: 'TXN-2026-000071',
    ),
  ];
}
