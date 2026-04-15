double _parseDecimal(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? 0;
  }

  return 0;
}

DateTime _parseDate(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  return DateTime.now();
}

String _readString(Object? value, {String fallback = ''}) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  return fallback;
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}

bool _readBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }

  return fallback;
}

List<String> _readStringList(Object? value) {
  if (value is List) {
    return value
        .map((item) => item is String ? item : item?.toString() ?? '')
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  return const [];
}

Map<String, dynamic>? _readMap(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

DateTime? _readOptionalDate(Object? value) {
  final normalized = _readString(value);
  if (normalized.isEmpty) {
    return null;
  }
  return _parseDate(normalized);
}

({String firstName, String lastName}) _splitName(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((item) => item.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return (firstName: 'User', lastName: '');
  }

  if (parts.length == 1) {
    return (firstName: parts.first, lastName: '');
  }

  return (firstName: parts.first, lastName: parts.sublist(1).join(' '));
}

String _maskAccountLabel(String value) {
  if (value.length <= 4) {
    return value;
  }

  return 'Account • ${value.substring(value.length - 4)}';
}

// User Models
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final DateTime dateOfBirth;
  final String address;
  final String city;
  final String country;
  final String postalCode;
  final String accountStatus;
  final bool isEmailVerified;
  final bool mfaEnabled;
  final bool biometricEnabled;
  final String kycStatus;
  final List<String> roles;
  final DateTime joinDate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.dateOfBirth,
    required this.address,
    required this.city,
    required this.country,
    required this.postalCode,
    required this.accountStatus,
    required this.isEmailVerified,
    required this.mfaEnabled,
    required this.biometricEnabled,
    required this.kycStatus,
    required this.roles,
    required this.joinDate,
  });

  String get fullName =>
      [firstName, lastName].where((value) => value.trim().isNotEmpty).join(' ');

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _readString(json['id']),
      firstName: _readString(json['first_name']),
      lastName: _readString(json['last_name']),
      email: _readString(json['email']),
      phoneNumber: _readString(json['phone_number']),
      profileImage: _readString(json['profile_image']),
      dateOfBirth: _parseDate(json['date_of_birth']),
      address: _readString(json['address']),
      city: _readString(json['city']),
      country: _readString(json['country']),
      postalCode: _readString(json['postal_code']),
      accountStatus: _readString(json['account_status'], fallback: 'active'),
      isEmailVerified: _readBool(json['is_email_verified']),
      mfaEnabled: _readBool(json['mfa_enabled']),
      biometricEnabled: _readBool(json['biometric_enabled']),
      kycStatus: _readString(json['kyc_status'], fallback: 'pending'),
      roles: _readStringList(json['roles']),
      joinDate: _parseDate(json['join_date']),
    );
  }

  factory User.fromApi(Map<String, dynamic> json) {
    final fullName = _readString(json['full_name'], fallback: 'User');
    final split = _splitName(fullName);
    final addressLine1 = _readString(json['address_line1']);
    final addressLine2 = _readString(json['address_line2']);
    final address = [
      addressLine1,
      addressLine2,
    ].where((value) => value.trim().isNotEmpty).join(', ');

    return User(
      id: _readString(json['id']),
      firstName: split.firstName,
      lastName: split.lastName,
      email: _readString(json['email']),
      phoneNumber: _readString(json['phone']),
      profileImage: '',
      dateOfBirth: _parseDate(json['date_of_birth']),
      address: address,
      city: _readString(json['city']),
      country: _readString(json['country']),
      postalCode: _readString(json['postal_code']),
      accountStatus: json['is_active'] == false ? 'inactive' : 'active',
      isEmailVerified: _readBool(json['is_email_verified']),
      mfaEnabled: _readBool(json['mfa_enabled']),
      biometricEnabled: _readBool(json['biometric_enabled']),
      kycStatus: _readString(json['kyc_status'], fallback: 'pending'),
      roles: _readStringList(json['roles']),
      joinDate: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'address': address,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'account_status': accountStatus,
      'is_email_verified': isEmailVerified,
      'mfa_enabled': mfaEnabled,
      'biometric_enabled': biometricEnabled,
      'kyc_status': kycStatus,
      'roles': roles,
      'join_date': joinDate.toIso8601String(),
    };
  }
}

// Account Models
class Account {
  final String id;
  final String userId;
  final String accountNumber;
  final String iban;
  final String nickname;
  final String accountType;
  final String currency;
  final double balance;
  final double availableBalance;
  final double creditLimit;
  final double usedCredit;
  final double dailyTransferLimit;
  final double dailyTransferredAmount;
  final DateTime openDate;
  final DateTime updatedAt;
  final bool isPrimary;
  final String bankName;
  final String routingNumber;
  final String accountStatus;

  Account({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.iban,
    required this.nickname,
    required this.accountType,
    required this.currency,
    required this.balance,
    required this.availableBalance,
    required this.creditLimit,
    required this.usedCredit,
    required this.dailyTransferLimit,
    required this.dailyTransferredAmount,
    required this.openDate,
    required this.updatedAt,
    required this.isPrimary,
    required this.bankName,
    required this.routingNumber,
    required this.accountStatus,
  });

  String get displayBalance => balance.toStringAsFixed(2);
  String get displayName {
    if (nickname.trim().isNotEmpty) {
      return nickname.trim();
    }

    return '${accountType[0].toUpperCase()}${accountType.substring(1)} account';
  }

  double get remainingDailyTransfer {
    final remaining = dailyTransferLimit - dailyTransferredAmount;
    return remaining > 0 ? remaining : 0;
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: _readString(json['id']),
      userId: _readString(json['user_id']),
      accountNumber: _readString(json['account_number']),
      iban: _readString(json['iban']),
      nickname: _readString(json['nickname']),
      accountType: _readString(json['account_type'], fallback: 'current'),
      currency: _readString(json['currency'], fallback: 'USD'),
      balance: _parseDecimal(json['balance']),
      availableBalance: _parseDecimal(json['available_balance']),
      creditLimit: _parseDecimal(json['credit_limit']),
      usedCredit: _parseDecimal(json['used_credit']),
      dailyTransferLimit: _parseDecimal(json['daily_transfer_limit']),
      dailyTransferredAmount: _parseDecimal(json['daily_transferred_amount']),
      openDate: _parseDate(json['open_date']),
      updatedAt: _parseDate(json['updated_at']),
      isPrimary: json['is_primary'] == true,
      bankName: _readString(json['bank_name']),
      routingNumber: _readString(json['routing_number']),
      accountStatus: _readString(json['account_status'], fallback: 'active'),
    );
  }

  factory Account.fromApi(Map<String, dynamic> json) {
    final nickname = _readString(json['nickname']);
    final normalizedNickname = nickname.toLowerCase();
    String accountType = 'current';

    if (normalizedNickname.contains('save')) {
      accountType = 'savings';
    } else if (normalizedNickname.contains('credit')) {
      accountType = 'credit';
    } else if (json['is_primary'] == false) {
      accountType = 'savings';
    }

    return Account(
      id: _readString(json['id']),
      userId: '',
      accountNumber: _readString(json['account_number']),
      iban: _readString(json['iban']),
      nickname: nickname,
      accountType: accountType,
      currency: _readString(json['currency'], fallback: 'USD'),
      balance: _parseDecimal(json['balance']),
      availableBalance: _parseDecimal(json['available_balance']),
      creditLimit: 0,
      usedCredit: 0,
      dailyTransferLimit: _parseDecimal(json['daily_transfer_limit']),
      dailyTransferredAmount: _parseDecimal(json['daily_transferred_amount']),
      openDate: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at'] ?? json['created_at']),
      isPrimary: json['is_primary'] == true,
      bankName: 'FinanceFlow Bank',
      routingNumber: 'N/A',
      accountStatus: _readString(json['status'], fallback: 'active'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_number': accountNumber,
      'iban': iban,
      'nickname': nickname,
      'account_type': accountType,
      'currency': currency,
      'balance': balance,
      'available_balance': availableBalance,
      'credit_limit': creditLimit,
      'used_credit': usedCredit,
      'daily_transfer_limit': dailyTransferLimit,
      'daily_transferred_amount': dailyTransferredAmount,
      'open_date': openDate.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_primary': isPrimary,
      'bank_name': bankName,
      'routing_number': routingNumber,
      'account_status': accountStatus,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Card Models
class BankCard {
  final String id;
  final String accountId;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cardType;
  final String cardBrand;
  final String cvv;
  final bool isActive;
  final bool isFrozen;
  final double dailyLimit;
  final double monthlyLimit;
  final double usedDaily;
  final double usedMonthly;
  final String cardStatus;
  final bool isVirtual;
  final DateTime createdDate;

  BankCard({
    required this.id,
    required this.accountId,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cardType,
    required this.cardBrand,
    required this.cvv,
    required this.isActive,
    required this.isFrozen,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.usedDaily,
    required this.usedMonthly,
    required this.cardStatus,
    required this.isVirtual,
    required this.createdDate,
  });

  String get maskedCardNumber {
    if (cardNumber.contains('*')) {
      return cardNumber;
    }

    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      return '**** **** **** ${digits.substring(digits.length - 4)}';
    }

    if (cardNumber.trim().isNotEmpty) {
      return cardNumber;
    }

    return '**** **** **** ****';
  }

  factory BankCard.fromJson(Map<String, dynamic> json) {
    return BankCard(
      id: _readString(json['id']),
      accountId: _readString(json['account_id']),
      cardNumber: _readString(json['card_number']),
      cardHolder: _readString(json['card_holder']),
      expiryDate: _readString(json['expiry_date']),
      cardType: _readString(json['card_type'], fallback: 'debit'),
      cardBrand: _readString(json['card_brand'], fallback: 'Visa'),
      cvv: _readString(json['cvv']),
      isActive: json['is_active'] != false,
      isFrozen: json['is_frozen'] == true,
      dailyLimit: _parseDecimal(json['daily_limit']),
      monthlyLimit: _parseDecimal(json['monthly_limit']),
      usedDaily: _parseDecimal(json['used_daily']),
      usedMonthly: _parseDecimal(json['used_monthly']),
      cardStatus: _readString(json['card_status'], fallback: 'active'),
      isVirtual: json['is_virtual'] == true,
      createdDate: _parseDate(json['created_date']),
    );
  }

  factory BankCard.fromApi(
    Map<String, dynamic> json, {
    String? cardHolderName,
  }) {
    final last4 = _readString(json['last4'], fallback: '0000');
    final maskedPan = _readString(
      json['masked_pan'],
      fallback: '**** **** **** $last4',
    );
    final expiresAt = _readString(json['expires_at']);
    String expiryDate = '--/--';
    if (expiresAt.isNotEmpty) {
      final parsed = DateTime.tryParse(expiresAt);
      if (parsed != null) {
        final month = parsed.month.toString().padLeft(2, '0');
        final year = (parsed.year % 100).toString().padLeft(2, '0');
        expiryDate = '$month/$year';
      }
    }

    final status = _readString(json['status'], fallback: 'active');
    final spendingLimit = _parseDecimal(json['spending_limit']);
    final apiCardType = _readString(json['card_type'], fallback: 'physical');

    return BankCard(
      id: _readString(json['id']),
      accountId: _readString(json['account_id']),
      cardNumber: maskedPan,
      cardHolder: cardHolderName ?? 'Primary holder',
      expiryDate: expiryDate,
      cardType: apiCardType == 'virtual' ? 'virtual' : 'debit',
      cardBrand: _readString(json['brand'], fallback: 'Card'),
      cvv: '***',
      isActive: status == 'active',
      isFrozen: status == 'frozen',
      dailyLimit: spendingLimit,
      monthlyLimit: spendingLimit,
      usedDaily: 0,
      usedMonthly: 0,
      cardStatus: status,
      isVirtual: apiCardType == 'virtual',
      createdDate: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'card_number': cardNumber,
      'card_holder': cardHolder,
      'expiry_date': expiryDate,
      'card_type': cardType,
      'card_brand': cardBrand,
      'cvv': cvv,
      'is_active': isActive,
      'is_frozen': isFrozen,
      'daily_limit': dailyLimit,
      'monthly_limit': monthlyLimit,
      'used_daily': usedDaily,
      'used_monthly': usedMonthly,
      'card_status': cardStatus,
      'is_virtual': isVirtual,
      'created_date': createdDate.toIso8601String(),
    };
  }
}

// Transaction Models
class Transaction {
  final String id;
  final String accountId;
  final String transactionType;
  final String transactionStatus;
  final double amount;
  final String currency;
  final String recipientName;
  final String recipientId;
  final String senderName;
  final String senderId;
  final String description;
  final String category;
  final DateTime transactionDate;
  final DateTime completedDate;
  final String referenceNumber;
  final String notes;
  final double fee;

  Transaction({
    required this.id,
    required this.accountId,
    required this.transactionType,
    required this.transactionStatus,
    required this.amount,
    required this.currency,
    required this.recipientName,
    required this.recipientId,
    required this.senderName,
    required this.senderId,
    required this.description,
    required this.category,
    required this.transactionDate,
    required this.completedDate,
    required this.referenceNumber,
    required this.notes,
    required this.fee,
  });

  bool get isDebit =>
      transactionType == 'withdrawal' ||
      transactionType == 'transfer' ||
      transactionType == 'card_payment' ||
      transactionType == 'internal_transfer';
  bool get isCompleted => transactionStatus == 'completed';
  bool get isPending => transactionStatus == 'pending';

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: _readString(json['id']),
      accountId: _readString(json['account_id']),
      transactionType: _readString(json['transaction_type']),
      transactionStatus: _readString(
        json['transaction_status'],
        fallback: 'pending',
      ),
      amount: _parseDecimal(json['amount']),
      currency: _readString(json['currency'], fallback: 'USD'),
      recipientName: _readString(json['recipient_name']),
      recipientId: _readString(json['recipient_id']),
      senderName: _readString(json['sender_name']),
      senderId: _readString(json['sender_id']),
      description: _readString(json['description']),
      category: _readString(json['category'], fallback: 'other'),
      transactionDate: _parseDate(json['transaction_date']),
      completedDate: _parseDate(json['completed_date']),
      referenceNumber: _readString(json['reference_number']),
      notes: _readString(json['notes']),
      fee: _parseDecimal(json['fee']),
    );
  }

  factory Transaction.fromApi(
    Map<String, dynamic> json, {
    String? currentUserName,
  }) {
    final transactionType = _readString(
      json['transaction_type'],
      fallback: 'internal_transfer',
    );
    final failureReason = _readString(json['failure_reason']);
    final description = _readString(json['description']).trim().isNotEmpty
        ? _readString(json['description'])
        : 'Internal transfer';
    final recipientId = _readString(json['to_account_id']);
    final recipientName = description != 'Internal transfer'
        ? description
        : _maskAccountLabel(recipientId);

    return Transaction(
      id: _readString(json['id']),
      accountId: _readString(json['from_account_id']),
      transactionType: transactionType,
      transactionStatus: _readString(json['status'], fallback: 'pending'),
      amount: _parseDecimal(json['amount']),
      currency: _readString(json['currency'], fallback: 'USD'),
      recipientName: recipientName,
      recipientId: recipientId,
      senderName: currentUserName ?? 'You',
      senderId: _readString(json['from_account_id']),
      description: description,
      category: transactionType == 'internal_transfer'
          ? 'transfer'
          : transactionType.replaceAll('_', ' '),
      transactionDate: _parseDate(json['created_at']),
      completedDate: _parseDate(json['processed_at'] ?? json['created_at']),
      referenceNumber: _readString(json['reference']),
      notes: failureReason.isNotEmpty ? failureReason : description,
      fee: _parseDecimal(json['fee_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'transaction_type': transactionType,
      'transaction_status': transactionStatus,
      'amount': amount,
      'currency': currency,
      'recipient_name': recipientName,
      'recipient_id': recipientId,
      'sender_name': senderName,
      'sender_id': senderId,
      'description': description,
      'category': category,
      'transaction_date': transactionDate.toIso8601String(),
      'completed_date': completedDate.toIso8601String(),
      'reference_number': referenceNumber,
      'notes': notes,
      'fee': fee,
    };
  }
}

// Notification Models
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String notificationType;
  final bool isRead;
  final DateTime createdAt;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.createdAt,
    this.actionUrl,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _readString(json['id']),
      userId: _readString(json['user_id']),
      title: _readString(json['title']),
      message: _readString(json['message']),
      notificationType: _readString(
        json['notification_type'],
        fallback: 'alert',
      ),
      isRead: json['is_read'] == true,
      createdAt: _parseDate(json['created_at']),
      actionUrl: json['action_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  factory AppNotification.fromApi(Map<String, dynamic> json) {
    final category = _readString(json['category'], fallback: 'system');
    String type = 'alert';

    switch (category) {
      case 'transaction':
        type = 'transaction';
        break;
      case 'security_alert':
        type = 'security';
        break;
      case 'support':
        type = 'support';
        break;
      default:
        type = 'alert';
    }

    return AppNotification(
      id: _readString(json['id']),
      userId: '',
      title: _readString(json['title']),
      message: _readString(json['message']),
      notificationType: type,
      isRead: json['is_read'] == true,
      createdAt: _parseDate(json['created_at']),
      actionUrl: null,
      metadata: _readMap(json['payload']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'action_url': actionUrl,
      'metadata': metadata,
    };
  }
}

// Recipient Models
class Recipient {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String accountNumber;
  final String iban;
  final String bankName;
  final DateTime addedDate;
  final bool isFavorite;

  Recipient({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.accountNumber,
    required this.iban,
    required this.bankName,
    required this.addedDate,
    required this.isFavorite,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      id: _readString(json['id']),
      name: _readString(json['name']),
      email: _readString(json['email']),
      phoneNumber: _readString(json['phone_number']),
      accountNumber: _readString(json['account_number']),
      iban: _readString(json['iban']),
      bankName: _readString(json['bank_name']),
      addedDate: _parseDate(json['added_date']),
      isFavorite: json['is_favorite'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'account_number': accountNumber,
      'iban': iban,
      'bank_name': bankName,
      'added_date': addedDate.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipient && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class NotificationChannelPreference {
  final bool inApp;
  final bool email;
  final bool sms;

  const NotificationChannelPreference({
    required this.inApp,
    required this.email,
    required this.sms,
  });

  factory NotificationChannelPreference.fromApi(Map<String, dynamic> json) {
    return NotificationChannelPreference(
      inApp: _readBool(json['in_app'], fallback: true),
      email: _readBool(json['email']),
      sms: _readBool(json['sms']),
    );
  }

  NotificationChannelPreference copyWith({
    bool? inApp,
    bool? email,
    bool? sms,
  }) {
    return NotificationChannelPreference(
      inApp: inApp ?? this.inApp,
      email: email ?? this.email,
      sms: sms ?? this.sms,
    );
  }

  Map<String, dynamic> toApi() {
    return {'in_app': inApp, 'email': email, 'sms': sms};
  }
}

class NotificationPreferences {
  final NotificationChannelPreference system;
  final NotificationChannelPreference securityAlert;
  final NotificationChannelPreference transaction;
  final NotificationChannelPreference support;

  const NotificationPreferences({
    required this.system,
    required this.securityAlert,
    required this.transaction,
    required this.support,
  });

  factory NotificationPreferences.fromApi(Map<String, dynamic> json) {
    return NotificationPreferences(
      system: NotificationChannelPreference.fromApi(
        _readMap(json['system']) ?? const <String, dynamic>{},
      ),
      securityAlert: NotificationChannelPreference.fromApi(
        _readMap(json['security_alert']) ?? const <String, dynamic>{},
      ),
      transaction: NotificationChannelPreference.fromApi(
        _readMap(json['transaction']) ?? const <String, dynamic>{},
      ),
      support: NotificationChannelPreference.fromApi(
        _readMap(json['support']) ?? const <String, dynamic>{},
      ),
    );
  }
}

class UserSessionInfo {
  final String id;
  final String familyId;
  final String deviceId;
  final String deviceName;
  final String ipAddress;
  final DateTime? lastSeenAt;
  final String status;
  final bool current;

  const UserSessionInfo({
    required this.id,
    required this.familyId,
    required this.deviceId,
    required this.deviceName,
    required this.ipAddress,
    required this.lastSeenAt,
    required this.status,
    required this.current,
  });

  factory UserSessionInfo.fromApi(Map<String, dynamic> json) {
    final lastSeenValue = _readString(json['last_seen_at']);
    return UserSessionInfo(
      id: _readString(json['id']),
      familyId: _readString(json['family_id']),
      deviceId: _readString(json['device_id']),
      deviceName: _readString(json['device_name'], fallback: 'Unknown device'),
      ipAddress: _readString(json['ip_address']),
      lastSeenAt: lastSeenValue.isEmpty ? null : _parseDate(lastSeenValue),
      status: _readString(json['status'], fallback: 'active'),
      current: _readBool(json['current']),
    );
  }
}

class SupportTicket {
  final String id;
  final String subject;
  final String message;
  final String status;
  final String priority;
  final String adminNote;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.priority,
    required this.adminNote,
    required this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromApi(Map<String, dynamic> json) {
    final resolvedAtValue = _readString(json['resolved_at']);
    return SupportTicket(
      id: _readString(json['id']),
      subject: _readString(json['subject']),
      message: _readString(json['message']),
      status: _readString(json['status'], fallback: 'open'),
      priority: _readString(json['priority'], fallback: 'medium'),
      adminNote: _readString(json['admin_note']),
      resolvedAt: resolvedAtValue.isEmpty ? null : _parseDate(resolvedAtValue),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}

class SupportMessage {
  final String id;
  final String ticketId;
  final String authorUserId;
  final String authorRole;
  final String message;
  final DateTime createdAt;

  const SupportMessage({
    required this.id,
    required this.ticketId,
    required this.authorUserId,
    required this.authorRole,
    required this.message,
    required this.createdAt,
  });

  factory SupportMessage.fromApi(Map<String, dynamic> json) {
    return SupportMessage(
      id: _readString(json['id']),
      ticketId: _readString(json['ticket_id']),
      authorUserId: _readString(json['author_user_id']),
      authorRole: _readString(json['author_role'], fallback: 'customer'),
      message: _readString(json['message']),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class DashboardOverview {
  final double totalBalance;
  final int unreadNotifications;
  final String pendingKycStatus;
  final List<String> alerts;
  final List<Account> accounts;
  final List<Transaction> recentTransactions;
  final List<BankCard> frozenCards;

  const DashboardOverview({
    required this.totalBalance,
    required this.unreadNotifications,
    required this.pendingKycStatus,
    required this.alerts,
    required this.accounts,
    required this.recentTransactions,
    required this.frozenCards,
  });

  factory DashboardOverview.fromApi(
    Map<String, dynamic> json, {
    String? currentUserName,
  }) {
    final accounts = List<Map<String, dynamic>>.from(
      json['accounts'] as List? ?? const [],
    ).map(Account.fromApi).toList();
    final recentTransactions = List<Map<String, dynamic>>.from(
      json['recent_transactions'] as List? ?? const [],
    ).map((item) => Transaction.fromApi(item, currentUserName: currentUserName)).toList();
    final frozenCards = List<Map<String, dynamic>>.from(
      json['frozen_cards'] as List? ?? const [],
    ).map((item) => BankCard.fromApi(item, cardHolderName: currentUserName)).toList();

    return DashboardOverview(
      totalBalance: _parseDecimal(json['total_balance']),
      unreadNotifications: _readInt(json['unread_notifications']),
      pendingKycStatus: _readString(json['pending_kyc_status']),
      alerts: _readStringList(json['alerts']),
      accounts: accounts,
      recentTransactions: recentTransactions,
      frozenCards: frozenCards,
    );
  }
}

class Beneficiary {
  final String id;
  final String accountNumber;
  final String nickname;
  final String status;
  final DateTime? lastUsedAt;
  final DateTime createdAt;

  const Beneficiary({
    required this.id,
    required this.accountNumber,
    required this.nickname,
    required this.status,
    required this.lastUsedAt,
    required this.createdAt,
  });

  factory Beneficiary.fromApi(Map<String, dynamic> json) {
    return Beneficiary(
      id: _readString(json['id']),
      accountNumber: _readString(json['account_number']),
      nickname: _readString(json['nickname']),
      status: _readString(json['status'], fallback: 'active'),
      lastUsedAt: _readOptionalDate(json['last_used_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class OTPDispatchInfo {
  final String message;
  final String purpose;
  final int expiresInSeconds;
  final String deliveryChannel;
  final String debugOtp;

  const OTPDispatchInfo({
    required this.message,
    required this.purpose,
    required this.expiresInSeconds,
    required this.deliveryChannel,
    required this.debugOtp,
  });

  factory OTPDispatchInfo.fromApi(Map<String, dynamic> json) {
    return OTPDispatchInfo(
      message: _readString(json['message']),
      purpose: _readString(json['purpose']),
      expiresInSeconds: _readInt(json['expires_in_seconds']),
      deliveryChannel: _readString(json['delivery_channel']),
      debugOtp: _readString(json['debug_otp']),
    );
  }
}

class MFASetupDetails {
  final String mfaSetupId;
  final String secretBase32;
  final String otpauthUrl;
  final DateTime expiresAt;

  const MFASetupDetails({
    required this.mfaSetupId,
    required this.secretBase32,
    required this.otpauthUrl,
    required this.expiresAt,
  });

  factory MFASetupDetails.fromApi(Map<String, dynamic> json) {
    return MFASetupDetails(
      mfaSetupId: _readString(json['mfa_setup_id']),
      secretBase32: _readString(json['secret_base32']),
      otpauthUrl: _readString(json['otpauth_url']),
      expiresAt: _parseDate(json['expires_at']),
    );
  }
}

class MFASetupStatus {
  final bool mfaEnabled;
  final String status;
  final List<String> recoveryCodes;

  const MFASetupStatus({
    required this.mfaEnabled,
    required this.status,
    required this.recoveryCodes,
  });

  factory MFASetupStatus.fromApi(Map<String, dynamic> json) {
    return MFASetupStatus(
      mfaEnabled: _readBool(json['mfa_enabled']),
      status: _readString(json['status']),
      recoveryCodes: _readStringList(json['recovery_codes']),
    );
  }
}

class SecurityChallenge {
  final String challengeId;
  final String purpose;
  final List<String> allowedMethods;
  final String status;
  final DateTime expiresAt;

  const SecurityChallenge({
    required this.challengeId,
    required this.purpose,
    required this.allowedMethods,
    required this.status,
    required this.expiresAt,
  });

  factory SecurityChallenge.fromApi(Map<String, dynamic> json) {
    return SecurityChallenge(
      challengeId: _readString(json['challenge_id']),
      purpose: _readString(json['purpose']),
      allowedMethods: _readStringList(json['allowed_methods']),
      status: _readString(json['status']),
      expiresAt: _parseDate(json['expires_at']),
    );
  }
}

class SecurityChallengeVerification {
  final String status;
  final DateTime verifiedAt;
  final String verifiedMethod;

  const SecurityChallengeVerification({
    required this.status,
    required this.verifiedAt,
    required this.verifiedMethod,
  });

  factory SecurityChallengeVerification.fromApi(Map<String, dynamic> json) {
    return SecurityChallengeVerification(
      status: _readString(json['status']),
      verifiedAt: _parseDate(json['verified_at']),
      verifiedMethod: _readString(json['verified_method']),
    );
  }
}

class PaginatedTransactions {
  final List<Transaction> items;
  final int page;
  final int pageSize;
  final int total;

  const PaginatedTransactions({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory PaginatedTransactions.fromApi(
    Map<String, dynamic> json, {
    String? currentUserName,
  }) {
    final items = List<Map<String, dynamic>>.from(
      json['items'] as List? ?? const [],
    ).map((item) => Transaction.fromApi(item, currentUserName: currentUserName)).toList();
    final meta = _readMap(json['meta']) ?? const <String, dynamic>{};
    return PaginatedTransactions(
      items: items,
      page: _readInt(meta['page'], fallback: 1),
      pageSize: _readInt(meta['page_size'], fallback: items.length),
      total: _readInt(meta['total'], fallback: items.length),
    );
  }
}

class RecurringTransfer {
  final String id;
  final String fromAccountId;
  final String beneficiaryId;
  final double amount;
  final String frequency;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextRunAt;
  final DateTime? lastRunAt;
  final DateTime createdAt;

  const RecurringTransfer({
    required this.id,
    required this.fromAccountId,
    required this.beneficiaryId,
    required this.amount,
    required this.frequency,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.nextRunAt,
    required this.lastRunAt,
    required this.createdAt,
  });

  factory RecurringTransfer.fromApi(Map<String, dynamic> json) {
    return RecurringTransfer(
      id: _readString(json['id']),
      fromAccountId: _readString(json['from_account_id']),
      beneficiaryId: _readString(json['beneficiary_id']),
      amount: _parseDecimal(json['amount']),
      frequency: _readString(json['frequency']),
      status: _readString(json['status']),
      startDate: _parseDate(json['start_date']),
      endDate: _readOptionalDate(json['end_date']),
      nextRunAt: _readOptionalDate(json['next_run_at']),
      lastRunAt: _readOptionalDate(json['last_run_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class StatementExport {
  final String exportId;
  final String status;
  final String downloadUrl;
  final String errorMessage;
  final DateTime? completedAt;

  const StatementExport({
    required this.exportId,
    required this.status,
    required this.downloadUrl,
    required this.errorMessage,
    required this.completedAt,
  });

  factory StatementExport.fromApi(Map<String, dynamic> json) {
    return StatementExport(
      exportId: _readString(json['export_id']),
      status: _readString(json['status']),
      downloadUrl: _readString(json['download_url']),
      errorMessage: _readString(json['error_message']),
      completedAt: _readOptionalDate(json['completed_at']),
    );
  }
}

class KycSubmission {
  final String submissionId;
  final String userId;
  final String reviewerUserId;
  final String status;
  final String documentType;
  final String documentNumber;
  final List<String> files;
  final String addressText;
  final String reviewNote;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const KycSubmission({
    required this.submissionId,
    required this.userId,
    required this.reviewerUserId,
    required this.status,
    required this.documentType,
    required this.documentNumber,
    required this.files,
    required this.addressText,
    required this.reviewNote,
    required this.reviewedAt,
    required this.createdAt,
  });

  factory KycSubmission.fromApi(Map<String, dynamic> json) {
    return KycSubmission(
      submissionId: _readString(json['submission_id']),
      userId: _readString(json['user_id']),
      reviewerUserId: _readString(json['reviewer_user_id']),
      status: _readString(json['status']),
      documentType: _readString(json['document_type']),
      documentNumber: _readString(json['document_number']),
      files: _readStringList(json['files']),
      addressText: _readString(json['address_text']),
      reviewNote: _readString(json['review_note']),
      reviewedAt: _readOptionalDate(json['reviewed_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class AuditLogEntry {
  final String id;
  final String action;
  final String resourceType;
  final String resourceId;
  final String status;
  final String description;
  final DateTime createdAt;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  factory AuditLogEntry.fromApi(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: _readString(json['id']),
      action: _readString(json['action']),
      resourceType: _readString(json['resource_type']),
      resourceId: _readString(json['resource_id']),
      status: _readString(json['status']),
      description: _readString(json['description']),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class FraudCase {
  final String caseId;
  final String transactionId;
  final String userId;
  final String status;
  final int score;
  final List<String> reasons;
  final String decision;
  final String decisionReason;
  final DateTime? decidedAt;
  final DateTime createdAt;

  const FraudCase({
    required this.caseId,
    required this.transactionId,
    required this.userId,
    required this.status,
    required this.score,
    required this.reasons,
    required this.decision,
    required this.decisionReason,
    required this.decidedAt,
    required this.createdAt,
  });

  factory FraudCase.fromApi(Map<String, dynamic> json) {
    return FraudCase(
      caseId: _readString(json['case_id']),
      transactionId: _readString(json['transaction_id']),
      userId: _readString(json['user_id']),
      status: _readString(json['status']),
      score: _readInt(json['score']),
      reasons: _readStringList(json['reasons']),
      decision: _readString(json['decision']),
      decisionReason: _readString(json['decision_reason']),
      decidedAt: _readOptionalDate(json['decided_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }
}
