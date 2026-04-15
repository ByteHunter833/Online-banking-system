import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:online_banking_system/core/network/banking_api_service.dart';
import 'package:online_banking_system/core/session/session_manager.dart';
import 'package:online_banking_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';

class TransferDraft {
  final Account? fromAccount;
  final Beneficiary? beneficiary;
  final String recipientAccountNumber;
  final double amount;
  final String note;
  final String challengeId;

  const TransferDraft({
    this.fromAccount,
    this.beneficiary,
    this.recipientAccountNumber = '',
    this.amount = 0,
    this.note = '',
    this.challengeId = '',
  });

  TransferDraft copyWith({
    Account? fromAccount,
    Beneficiary? beneficiary,
    String? recipientAccountNumber,
    double? amount,
    String? note,
    String? challengeId,
  }) {
    return TransferDraft(
      fromAccount: fromAccount ?? this.fromAccount,
      beneficiary: beneficiary ?? this.beneficiary,
      recipientAccountNumber:
          recipientAccountNumber ?? this.recipientAccountNumber,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      challengeId: challengeId ?? this.challengeId,
    );
  }
}

class TransactionsQuery {
  final String? accountId;
  final String? status;
  final String? direction;
  final String? dateFrom;
  final String? dateTo;
  final int page;
  final int pageSize;

  const TransactionsQuery({
    this.accountId,
    this.status,
    this.direction,
    this.dateFrom,
    this.dateTo,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionsQuery &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          status == other.status &&
          direction == other.direction &&
          dateFrom == other.dateFrom &&
          dateTo == other.dateTo &&
          page == other.page &&
          pageSize == other.pageSize;

  @override
  int get hashCode => Object.hash(
    accountId,
    status,
    direction,
    dateFrom,
    dateTo,
    page,
    pageSize,
  );
}

final bankingApiServiceProvider = Provider<BankingApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return BankingApiService(dio);
});

final userProvider = StateProvider<User?>((ref) {
  return SessionManager.instance.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null ||
      SessionManager.instance.isAuthenticated;
});

final currentUserProfileProvider = FutureProvider<User>((ref) async {
  final api = ref.watch(bankingApiServiceProvider);
  final user = await api.getCurrentUser();
  ref.read(userProvider.notifier).state = user;
  await SessionManager.instance.setCurrentUser(user);
  return user;
});

final dashboardOverviewProvider = FutureProvider<DashboardOverview>((
  ref,
) async {
  final api = ref.watch(bankingApiServiceProvider);
  final user = ref.watch(userProvider);
  return api.getDashboardOverview(currentUserName: user?.fullName);
});

final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final api = ref.watch(bankingApiServiceProvider);
  return api.getAccounts();
});

final accountDetailProvider = FutureProvider.family<Account, String>((
  ref,
  accountId,
) async {
  final api = ref.watch(bankingApiServiceProvider);
  return api.getAccount(accountId);
});

final beneficiariesProvider = FutureProvider<List<Beneficiary>>((ref) async {
  final api = ref.watch(bankingApiServiceProvider);
  return api.getBeneficiaries();
});

final selectedAccountProvider = StateProvider<Account?>((ref) => null);

final primaryAccountProvider = FutureProvider<Account>((ref) async {
  final accounts = await ref.watch(accountsProvider.future);
  if (accounts.isEmpty) {
    throw Exception('No accounts available');
  }
  return accounts.firstWhere(
    (account) => account.isPrimary,
    orElse: () => accounts.first,
  );
});

final cardsProvider = FutureProvider<List<BankCard>>((ref) async {
  final api = ref.watch(bankingApiServiceProvider);
  final user = ref.watch(userProvider);
  final cardHolderName = user?.fullName;
  return api.getCards(cardHolderName: cardHolderName);
});

final selectedCardProvider = StateProvider<BankCard?>((ref) => null);

final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final api = ref.watch(bankingApiServiceProvider);
  final user = ref.watch(userProvider);
  return api.getTransactions(currentUserName: user?.fullName);
});

final paginatedTransactionsProvider =
    FutureProvider.family<PaginatedTransactions, TransactionsQuery>((
      ref,
      query,
    ) async {
      final api = ref.watch(bankingApiServiceProvider);
      final user = ref.watch(userProvider);
      return api.getPaginatedTransactions(
        accountId: query.accountId,
        status: query.status,
        direction: query.direction,
        dateFrom: query.dateFrom,
        dateTo: query.dateTo,
        page: query.page,
        pageSize: query.pageSize,
        currentUserName: user?.fullName,
      );
    });

final transactionDetailProvider = FutureProvider.family<Transaction, String>((
  ref,
  transactionId,
) async {
  final api = ref.watch(bankingApiServiceProvider);
  final user = ref.watch(userProvider);
  return api.getTransactionDetail(
    transactionId,
    currentUserName: user?.fullName,
  );
});

final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final api = ref.watch(bankingApiServiceProvider);
  return api.getNotifications();
});

final unreadNotificationsProvider = FutureProvider<int>((ref) async {
  final notifications = await ref.watch(notificationsProvider.future);
  return notifications.where((notification) => !notification.isRead).length;
});

final notificationPreferencesProvider = FutureProvider<NotificationPreferences>(
  (ref) async {
    final api = ref.watch(bankingApiServiceProvider);
    return api.getNotificationPreferences();
  },
);

final sessionsProvider = FutureProvider<List<UserSessionInfo>>((ref) async {
  final api = ref.watch(bankingApiServiceProvider);
  return api.getSessions();
});

final supportTicketsProvider = FutureProvider<List<SupportTicket>>((ref) async {
  final api = ref.watch(bankingApiServiceProvider);
  return api.getSupportTickets();
});

final supportMessagesProvider =
    FutureProvider.family<List<SupportMessage>, String>((ref, ticketId) async {
      final api = ref.watch(bankingApiServiceProvider);
      return api.getSupportMessages(ticketId);
    });

final loadingProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);
final hideBalanceProvider = StateProvider<bool>((ref) => false);

final transferDraftProvider = StateProvider<TransferDraft>(
  (ref) => const TransferDraft(),
);

final lastTransferProvider = StateProvider<Transaction?>((ref) => null);
