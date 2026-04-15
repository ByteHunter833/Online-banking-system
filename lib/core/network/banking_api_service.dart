import 'package:dio/dio.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';

class BankingApiService {
  final Dio dio;

  BankingApiService(this.dio);

  Future<User> getCurrentUser() async {
    try {
      final response = await dio.get('/users/me');
      return User.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<User> updateCurrentUser({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? mfaEnabled,
    bool? biometricEnabled,
  }) async {
    try {
      final response = await dio.patch(
        '/users/update',
        data: _compactMap({
          'full_name': _trimmedOrNull(fullName),
          'phone': _trimmedOrNull(phone),
          'date_of_birth': _trimmedOrNull(dateOfBirth),
          'address_line1': _trimmedOrNull(addressLine1),
          'address_line2': _trimmedOrNull(addressLine2),
          'city': _trimmedOrNull(city),
          'state': _trimmedOrNull(state),
          'postal_code': _trimmedOrNull(postalCode),
          'country': _trimmedOrNull(country),
          'mfa_enabled': mfaEnabled,
          'biometric_enabled': biometricEnabled,
        }),
      );
      return User.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otpCode,
  }) async {
    try {
      final response = await dio.post(
        '/users/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'otp_code': otpCode,
        },
      );
      return _extractMessage(response.data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<String> deactivateAccount({
    required String password,
    required String otpCode,
  }) async {
    try {
      final response = await dio.post(
        '/users/deactivate',
        data: {'password': password, 'otp_code': otpCode},
      );
      return _extractMessage(response.data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<DashboardOverview> getDashboardOverview({
    String? currentUserName,
  }) async {
    try {
      final response = await dio.get('/dashboard/overview');
      return DashboardOverview.fromApi(
        _asMap(response.data),
        currentUserName: currentUserName,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<Account>> getAccounts() async {
    try {
      final response = await dio.get('/accounts/');
      final accounts = _asMapList(response.data).map(Account.fromApi).toList();
      accounts.sort((a, b) {
        if (a.isPrimary == b.isPrimary) {
          return b.openDate.compareTo(a.openDate);
        }
        return a.isPrimary ? -1 : 1;
      });
      return accounts;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Account> getAccount(String accountId) async {
    try {
      final response = await dio.get('/accounts/$accountId');
      return Account.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Account> createAccount({
    String? nickname,
    String currency = 'USD',
    double initialDeposit = 0,
    bool isPrimary = false,
  }) async {
    try {
      final response = await dio.post(
        '/accounts/',
        data: {
          if (nickname != null && nickname.trim().isNotEmpty)
            'nickname': nickname.trim(),
          'currency': currency,
          'initial_deposit': initialDeposit.toStringAsFixed(2),
          'is_primary': isPrimary,
        },
      );
      return Account.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Account> updateAccountPreferences({
    required String accountId,
    String? nickname,
    bool? isPrimary,
  }) async {
    try {
      final response = await dio.patch(
        '/accounts/$accountId/preferences',
        data: _compactMap({
          'nickname': _trimmedOrNull(nickname),
          'is_primary': isPrimary,
        }),
      );
      return Account.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<Beneficiary>> getBeneficiaries() async {
    try {
      final response = await dio.get('/beneficiaries/');
      final beneficiaries = _asMapList(
        response.data,
      ).map(Beneficiary.fromApi).toList();
      beneficiaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return beneficiaries;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Beneficiary> createBeneficiary({
    required String accountNumber,
    required String nickname,
    String? challengeId,
  }) async {
    try {
      final response = await dio.post(
        '/beneficiaries/',
        data: {
          'account_number': accountNumber,
          'nickname': nickname,
          if (challengeId != null && challengeId.trim().isNotEmpty)
            'challenge_id': challengeId,
        },
      );
      return Beneficiary.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<BankCard>> getCards({String? cardHolderName}) async {
    try {
      final response = await dio.get('/cards/');
      final cards = _asMapList(response.data)
          .map((item) => BankCard.fromApi(item, cardHolderName: cardHolderName))
          .toList();
      cards.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      return cards;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<BankCard> createCard({
    required String accountId,
    String cardType = 'virtual',
    double? spendingLimit,
    String? cardHolderName,
  }) async {
    try {
      final response = await dio.post(
        '/cards/',
        data: {
          'account_id': accountId,
          'card_type': cardType,
          if (spendingLimit != null)
            'spending_limit': spendingLimit.toStringAsFixed(2),
        },
      );
      return BankCard.fromApi(
        _asMap(response.data),
        cardHolderName: cardHolderName,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<BankCard> freezeCard(String cardId, {String? reason}) async {
    try {
      final response = await dio.post(
        '/cards/$cardId/freeze',
        data: {
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason,
        },
      );
      return BankCard.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<BankCard> unfreezeCard(String cardId) async {
    try {
      final response = await dio.post('/cards/$cardId/unfreeze');
      return BankCard.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<BankCard> updateCardSpendingLimit(
    String cardId,
    double spendingLimit, {
    String? cardHolderName,
  }) async {
    try {
      final response = await dio.patch(
        '/cards/$cardId/spending-limit',
        data: {'spending_limit': spendingLimit.toStringAsFixed(2)},
      );
      return BankCard.fromApi(
        _asMap(response.data),
        cardHolderName: cardHolderName,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<BankCard> updateCardControls({
    required String cardId,
    bool? onlineEnabled,
    bool? atmEnabled,
    bool? contactlessEnabled,
    double? spendingLimit,
    String? cardHolderName,
  }) async {
    try {
      final response = await dio.patch(
        '/cards/$cardId/controls',
        data: _compactMap({
          'online_enabled': onlineEnabled,
          'atm_enabled': atmEnabled,
          'contactless_enabled': contactlessEnabled,
          if (spendingLimit != null)
            'spending_limit': spendingLimit.toStringAsFixed(2),
        }),
      );
      return BankCard.fromApi(
        _asMap(response.data),
        cardHolderName: cardHolderName,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<Transaction>> getTransactions({String? currentUserName}) async {
    try {
      final response = await dio.get('/transactions/history');
      final transactions = _asMapList(response.data)
          .map(
            (item) =>
                Transaction.fromApi(item, currentUserName: currentUserName),
          )
          .toList();
      transactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );
      return transactions;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<PaginatedTransactions> getPaginatedTransactions({
    String? accountId,
    String? status,
    String? direction,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 20,
    String? currentUserName,
  }) async {
    try {
      final response = await dio.get(
        '/transactions',
        queryParameters: {
          if (accountId != null && accountId.trim().isNotEmpty)
            'account_id': accountId,
          if (status != null && status.trim().isNotEmpty) 'status': status,
          if (direction != null && direction.trim().isNotEmpty)
            'direction': direction,
          if (dateFrom != null && dateFrom.trim().isNotEmpty)
            'date_from': dateFrom,
          if (dateTo != null && dateTo.trim().isNotEmpty) 'date_to': dateTo,
          'page': page,
          'page_size': pageSize,
        },
      );
      return PaginatedTransactions.fromApi(
        _asMap(response.data),
        currentUserName: currentUserName,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Transaction> getTransactionDetail(
    String transactionId, {
    String? currentUserName,
  }) async {
    try {
      final response = await dio.get('/transactions/$transactionId');
      return Transaction.fromApi(
        _asMap(response.data),
        currentUserName: currentUserName,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Transaction> transfer({
    required String fromAccountId,
    required String recipientAccountNumber,
    required double amount,
    String? description,
    String? otpCode,
    String? challengeId,
    String? idempotencyKey,
  }) async {
    try {
      final response = await dio.post(
        '/transactions/transfer',
        options: Options(
          headers: {
            if (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
              'Idempotency-Key': idempotencyKey,
          },
        ),
        data: {
          'from_account_id': fromAccountId,
          'recipient_account_number': recipientAccountNumber,
          'amount': amount.toStringAsFixed(2),
          'idempotency_key':
              idempotencyKey ??
              'financeflow-${DateTime.now().microsecondsSinceEpoch}',
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (otpCode != null && otpCode.trim().isNotEmpty)
            'otp_code': otpCode.trim(),
          if (challengeId != null && challengeId.trim().isNotEmpty)
            'challenge_id': challengeId.trim(),
        },
      );
      return Transaction.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<RecurringTransfer> createRecurringTransfer({
    required String fromAccountId,
    required String beneficiaryId,
    required double amount,
    required String frequency,
    required String startDate,
    required String challengeId,
    String? endDate,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '/recurring-transfers/',
        data: {
          'from_account_id': fromAccountId,
          'beneficiary_id': beneficiaryId,
          'amount': amount.toStringAsFixed(2),
          'frequency': frequency,
          'start_date': startDate,
          'challenge_id': challengeId,
          if (endDate != null && endDate.trim().isNotEmpty) 'end_date': endDate,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
        },
      );
      return RecurringTransfer.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<StatementExport> createStatementExport({
    required String accountId,
    required String dateFrom,
    required String dateTo,
    String format = 'csv',
  }) async {
    try {
      final response = await dio.post(
        '/statements/exports',
        data: {
          'account_id': accountId,
          'date_from': dateFrom,
          'date_to': dateTo,
          'format': format,
        },
      );
      return StatementExport.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<StatementExport> getStatementExport(String exportId) async {
    try {
      final response = await dio.get('/statements/exports/$exportId');
      return StatementExport.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await dio.get('/notifications/');
      final notifications = _asMapList(
        response.data,
      ).map(AppNotification.fromApi).toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<AppNotification> markNotificationRead(String notificationId) async {
    try {
      final response = await dio.patch('/notifications/$notificationId/read');
      return AppNotification.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<NotificationPreferences> getNotificationPreferences() async {
    try {
      final response = await dio.get('/notifications/preferences');
      return NotificationPreferences.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<NotificationPreferences> updateNotificationPreferences({
    NotificationChannelPreference? system,
    NotificationChannelPreference? securityAlert,
    NotificationChannelPreference? transaction,
    NotificationChannelPreference? support,
  }) async {
    try {
      final response = await dio.put(
        '/notifications/preferences',
        data: {
          if (system != null) 'system': system.toApi(),
          if (securityAlert != null) 'security_alert': securityAlert.toApi(),
          if (transaction != null) 'transaction': transaction.toApi(),
          if (support != null) 'support': support.toApi(),
        },
      );
      return NotificationPreferences.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<OTPDispatchInfo> requestOtp({
    required String purpose,
    String deliveryChannel = 'email',
  }) async {
    try {
      final response = await dio.post(
        '/auth/otp/request',
        data: {'purpose': purpose, 'delivery_channel': deliveryChannel},
      );
      return OTPDispatchInfo.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<String> verifyOtp({
    required String purpose,
    required String otpCode,
  }) async {
    try {
      final response = await dio.post(
        '/auth/otp/verify',
        data: {'purpose': purpose, 'otp_code': otpCode},
      );
      return _extractMessage(response.data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<MFASetupDetails> setupTotp({required String password}) async {
    try {
      final response = await dio.post(
        '/security/mfa/totp/setup',
        data: {'password': password},
      );
      return MFASetupDetails.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<MFASetupStatus> confirmTotp({
    required String mfaSetupId,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        '/security/mfa/totp/confirm',
        data: {'mfa_setup_id': mfaSetupId, 'code': code},
      );
      return MFASetupStatus.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<SecurityChallenge> createChallenge({
    required String purpose,
    String preferredMethod = 'totp',
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await dio.post(
        '/security/challenges',
        data: _compactMap({
          'purpose': purpose,
          'preferred_method': preferredMethod,
          'context': context,
        }),
      );
      return SecurityChallenge.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<SecurityChallengeVerification> verifyChallenge({
    required String challengeId,
    required String method,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        '/security/challenges/$challengeId/verify',
        data: {'method': method, 'code': code},
      );
      return SecurityChallengeVerification.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<UserSessionInfo>> getSessions() async {
    try {
      final response = await dio.get('/security/sessions');
      final items = _asMapList(_asMap(response.data)['items']);
      final sessions = items.map(UserSessionInfo.fromApi).toList();
      sessions.sort((a, b) {
        if (a.current == b.current) {
          final aSeen = a.lastSeenAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bSeen = b.lastSeenAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bSeen.compareTo(aSeen);
        }
        return a.current ? -1 : 1;
      });
      return sessions;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<String> revokeSession(String sessionId) async {
    try {
      final response = await dio.delete('/security/sessions/$sessionId');
      return _extractMessage(response.data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<KycSubmission> createKycSubmission({
    required String documentType,
    required String documentNumber,
    required List<String> files,
    required String addressText,
  }) async {
    try {
      final response = await dio.post(
        '/kyc/submissions',
        data: {
          'document_type': documentType,
          'document_number': documentNumber,
          'files': files,
          'address_text': addressText,
        },
      );
      return KycSubmission.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<SupportTicket>> getSupportTickets() async {
    try {
      final response = await dio.get('/support/');
      final tickets = _asMapList(
        response.data,
      ).map(SupportTicket.fromApi).toList();
      tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return tickets;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<SupportTicket> getSupportTicket(String ticketId) async {
    try {
      final response = await dio.get('/support/$ticketId');
      return SupportTicket.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<SupportTicket> createSupportTicket({
    required String subject,
    required String message,
    String priority = 'medium',
  }) async {
    try {
      final response = await dio.post(
        '/support/',
        data: {
          'subject': subject.trim(),
          'message': message.trim(),
          'priority': priority,
        },
      );
      return SupportTicket.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<SupportMessage>> getSupportMessages(String ticketId) async {
    try {
      final response = await dio.get('/support/$ticketId/messages');
      final messages = _asMapList(
        response.data,
      ).map(SupportMessage.fromApi).toList();
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return messages;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<SupportMessage> createSupportMessage({
    required String ticketId,
    required String message,
  }) async {
    try {
      final response = await dio.post(
        '/support/$ticketId/messages',
        data: {'message': message.trim()},
      );
      return SupportMessage.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/admin/login',
        data: {'email': email, 'password': password},
      );
      return _asMap(response.data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<User>> getAdminUsers() async {
    try {
      final response = await dio.get('/admin/users');
      return _asMapList(response.data).map(User.fromApi).toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<Transaction>> getAdminTransactions({
    String? currentUserName,
  }) async {
    try {
      final response = await dio.get('/admin/transactions');
      return _asMapList(response.data)
          .map(
            (item) =>
                Transaction.fromApi(item, currentUserName: currentUserName),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Account> adminFreezeAccount({
    required String accountId,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/admin/accounts/$accountId/freeze',
        data: {'reason': reason},
      );
      return Account.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Account> adminUnfreezeAccount({
    required String accountId,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/admin/accounts/$accountId/unfreeze',
        data: {'reason': reason},
      );
      return Account.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Transaction> adminFlagTransaction({
    required String transactionId,
    required String reason,
    String? currentUserName,
  }) async {
    try {
      final response = await dio.post(
        '/admin/transactions/$transactionId/flag',
        data: {'reason': reason},
      );
      return Transaction.fromApi(
        _asMap(response.data),
        currentUserName: currentUserName,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<AuditLogEntry>> getAuditLogs() async {
    try {
      final response = await dio.get('/admin/audit-logs');
      return _asMapList(response.data).map(AuditLogEntry.fromApi).toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<SupportTicket>> getAdminSupportTickets() async {
    try {
      final response = await dio.get('/admin/support');
      return _asMapList(response.data).map(SupportTicket.fromApi).toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<SupportTicket> adminUpdateSupportTicket({
    required String ticketId,
    String? status,
    String? adminNote,
  }) async {
    try {
      final response = await dio.patch(
        '/admin/support/$ticketId',
        data: _compactMap({
          'status': _trimmedOrNull(status),
          'admin_note': _trimmedOrNull(adminNote),
        }),
      );
      return SupportTicket.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<KycSubmission>> getAdminKycSubmissions() async {
    try {
      final response = await dio.get('/admin/kyc/submissions');
      return _asMapList(response.data).map(KycSubmission.fromApi).toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<KycSubmission> adminReviewKycSubmission({
    required String submissionId,
    required String status,
    String? reviewNote,
  }) async {
    try {
      final response = await dio.post(
        '/admin/kyc/submissions/$submissionId/review',
        data: {
          'status': status,
          if (reviewNote != null && reviewNote.trim().isNotEmpty)
            'review_note': reviewNote.trim(),
        },
      );
      return KycSubmission.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<FraudCase>> getFraudCases({String? status, int? scoreGte}) async {
    try {
      final response = await dio.get(
        '/admin/fraud/cases',
        queryParameters: _compactMap({
          'status': _trimmedOrNull(status),
          'score_gte': scoreGte,
        }),
      );
      return _asMapList(response.data).map(FraudCase.fromApi).toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<FraudCase> decideFraudCase({
    required String caseId,
    required String decision,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/admin/fraud/cases/$caseId/decision',
        data: {'decision': decision, 'reason': reason},
      );
      return FraudCase.fromApi(_asMap(response.data));
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(Object? value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _compactMap(Map<String, dynamic> value) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      if (entry.value != null) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  String? _trimmedOrNull(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _extractMessage(Object? value) {
    final data = _asMap(value);
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return 'Request completed';
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map<String, dynamic>) {
          final msg = first['msg'];
          if (msg is String && msg.trim().isNotEmpty) {
            return msg;
          }
        }
      }
    }

    return error.message ?? 'Request failed';
  }
}
