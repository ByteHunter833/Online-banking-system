import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/beneficiaries/presentation/screens/beneficiaries_screen.dart';
import 'package:online_banking_system/features/kyc/presentation/screens/kyc_screen.dart';
import 'package:online_banking_system/features/statements/presentation/screens/statements_screen.dart';
import 'package:online_banking_system/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedUser = ref.watch(userProvider);
    final currentUserAsync = ref.watch(currentUserProfileProvider);
    final dashboardAsync = ref.watch(dashboardOverviewProvider);
    final hideBalance = ref.watch(hideBalanceProvider);
    final user = currentUserAsync.maybeWhen(
      data: (value) => value,
      orElse: () => cachedUser,
    );
    final unreadBadge = dashboardAsync.maybeWhen(
      data: (overview) => overview.unreadNotifications > 0
          ? overview.unreadNotifications.toString()
          : null,
      orElse: () => null,
    );
    final greetingName = user?.firstName.isNotEmpty == true
        ? user!.firstName
        : 'there';
    final fullName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'User';

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: AppTheme.lightBg,
        titleSpacing: 0,
        leadingWidth: 76,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacing20,
            top: AppTheme.spacing12,
            bottom: AppTheme.spacing12,
          ),
          child: AppAvatar(
            name: fullName,
            imageUrl: user?.profileImage,
            size: 48,
            borderColor: AppTheme.white,
            boxShadow: AppTheme.softShadow,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.hello}, $greetingName!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Everything important in one place',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          _HeaderActionButton(
            icon: Icons.notifications_none_rounded,
            badge: unreadBadge,
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.notifications);
            },
          ),
          const SizedBox(width: AppTheme.spacing8),
          _HeaderActionButton(
            icon: Icons.tune_rounded,
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.settings);
            },
          ),
          const SizedBox(width: AppTheme.spacing20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing20,
          AppTheme.spacing8,
          AppTheme.spacing20,
          AppTheme.spacing32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dashboardAsync.when(
              data: (overview) {
                final accounts = overview.accounts;
                if (accounts.isEmpty) {
                  return const _InlineFeedbackCard(
                    title: 'Balance unavailable',
                    message:
                        'Create your first account to see your balance here.',
                  );
                }
                final account = accounts.firstWhere(
                  (item) => item.isPrimary,
                  orElse: () => accounts.first,
                );
                return GestureDetector(
                  onTap: () {
                    ref.read(hideBalanceProvider.notifier).state = !hideBalance;
                  },
                  child: BalanceCard(
                    accountType: 'Current Account',
                    balance: account.balance,
                    currency: account.currency,
                    hideBalance: hideBalance,
                    onHideToggle: () {
                      ref.read(hideBalanceProvider.notifier).state =
                          !hideBalance;
                    },
                  ),
                );
              },
              loading: () => LoadingShimmer(
                height: 210,
                borderRadius: BorderRadius.circular(AppTheme.radius20),
              ),
              error: (err, stack) => const _InlineFeedbackCard(
                title: 'Balance unavailable',
                message: 'We could not load your current account right now.',
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            dashboardAsync.maybeWhen(
              data: (overview) => overview.alerts.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(AppTheme.radius20),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live alerts',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          ...overview.alerts.map(
                            (alert) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTheme.spacing8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  const SizedBox(width: AppTheme.spacing8),
                                  Expanded(
                                    child: Text(
                                      alert,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppTheme.spacing24),
            _SectionCard(
              title: AppStrings.quickActions,
              subtitle: 'Live banking tools connected to your backend',
              child: const _QuickActionsGrid(),
            ),
            const SizedBox(height: AppTheme.spacing24),
            _SecuritySnapshotCard(user: user),
            const SizedBox(height: AppTheme.spacing24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.recentTransactions,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        'Track your latest activity without leaving home',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.transactions);
                  },
                  child: const Text(AppStrings.viewAll),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            dashboardAsync.when(
              data: (overview) {
                final recent = overview.recentTransactions.take(3).toList();
                if (recent.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history_outlined,
                    title: AppStrings.noTransactions,
                    message:
                        'Your latest payments and transfers will show up here.',
                  );
                }

                return Column(
                  children: List.generate(recent.length, (index) {
                    final txn = recent[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.spacing12,
                      ),
                      child: TransactionTile(
                        title: txn.recipientName,
                        subtitle: txn.description,
                        amount: txn.amount,
                        currency: txn.currency,
                        isDebit: txn.isDebit,
                        status: txn.transactionStatus,
                        category: txn.category,
                        date: txn.transactionDate,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransactionDetailScreen(transaction: txn),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                );
              },
              loading: () => Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LoadingShimmer(
                      height: 92,
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                    ),
                  ),
                ),
              ),
              error: (err, stack) => const _InlineFeedbackCard(
                title: 'Transactions unavailable',
                message: 'Your recent activity could not be loaded.',
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            dashboardAsync.maybeWhen(
              data: (overview) =>
                  _SpendingSummary(transactions: overview.recentTransactions),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;

        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacing12,
          crossAxisSpacing: AppTheme.spacing12,
          childAspectRatio: isWide ? 0.9 : 1.05,
          children: [
            QuickActionButton(
              icon: Icons.send_outlined,
              label: AppStrings.sendMoney,
              backgroundColor: AppTheme.primaryBlue,
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(AppRoutes.transfer);
              },
            ),
            QuickActionButton(
              icon: Icons.people_alt_outlined,
              label: 'Beneficiaries',
              backgroundColor: AppTheme.accentGreen,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BeneficiariesScreen(),
                  ),
                );
              },
            ),
            QuickActionButton(
              icon: Icons.description_outlined,
              label: 'Statements',
              backgroundColor: AppTheme.accentPurple,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatementsScreen()),
                );
              },
            ),
            QuickActionButton(
              icon: Icons.verified_user_outlined,
              label: 'KYC',
              backgroundColor: AppTheme.warningOrange,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const KycScreen()));
              },
            ),
          ],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius24),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacing4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppTheme.spacing20),
          child,
        ],
      ),
    );
  }
}

class _InlineFeedbackCard extends StatelessWidget {
  final String title;
  final String message;

  const _InlineFeedbackCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              child: Icon(icon),
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: badge == null
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.lightBg, width: 2),
                  ),
                  child: Text(
                    badge!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SpendingSummary extends StatelessWidget {
  final List<Transaction> transactions;

  const _SpendingSummary({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final categories = <String, double>{};
    for (final item in transactions) {
      if (item.isDebit == true) {
        final category = item.category.trim().isNotEmpty
            ? item.category
            : 'transfer';
        categories[category] = (categories[category] ?? 0) + item.amount;
      }
    }

    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) {
      return const SizedBox.shrink();
    }

    final top = sorted.take(3).toList();
    final total = top.fold<double>(0, (sum, item) => sum + item.value);
    const colors = [
      AppTheme.primaryBlue,
      AppTheme.warningOrange,
      AppTheme.accentGreen,
    ];
    const icons = [
      Icons.receipt_long_outlined,
      Icons.shopping_bag_outlined,
      Icons.account_balance_wallet_outlined,
    ];

    return _SectionCard(
      title: 'Spending Summary',
      subtitle: 'A quick snapshot based on your recent debit activity',
      child: Column(
        children: List.generate(top.length, (index) {
          final item = top[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == top.length - 1 ? 0 : AppTheme.spacing16,
            ),
            child: _SpendingCategory(
              icon: icons[index % icons.length],
              label: item.key.replaceAll('_', ' '),
              amount: item.value.toStringAsFixed(2),
              percentage: total == 0 ? 0 : item.value / total,
              color: colors[index % colors.length],
            ),
          );
        }),
      ),
    );
  }
}

class _SecuritySnapshotCard extends StatelessWidget {
  final dynamic user;

  const _SecuritySnapshotCard({this.user});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Security Snapshot',
      subtitle: 'Essential protections for your online banking profile',
      child: Column(
        children: [
          _SecurityStatusTile(
            icon: Icons.verified_user_outlined,
            title: 'Two-step verification',
            subtitle: user?.mfaEnabled == true
                ? 'Transfer confirmations are protected'
                : 'Enable MFA for stronger payment protection',
            status: user?.mfaEnabled == true ? 'Active' : 'Off',
            color: user?.mfaEnabled == true
                ? AppTheme.accentGreen
                : AppTheme.warningOrange,
          ),
          const SizedBox(height: AppTheme.spacing12),
          _SecurityStatusTile(
            icon: Icons.notifications_active_outlined,
            title: 'Fraud alerts',
            subtitle: 'Instant notifications for unusual activity',
            status: 'On',
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: AppTheme.spacing12),
          _SecurityStatusTile(
            icon: Icons.fingerprint_outlined,
            title: 'Biometric unlock',
            subtitle: user?.biometricEnabled == true
                ? 'Biometric access is enabled for this profile'
                : 'Enable biometric sign in for faster secure access',
            status: user?.biometricEnabled == true ? 'Ready' : 'Off',
            color: user?.biometricEnabled == true
                ? AppTheme.accentGreen
                : AppTheme.warningOrange,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Align(
            alignment: Alignment.centerLeft,
            child: SecondaryButton(
              label: 'Open Security Center',
              icon: Icons.shield_outlined,
              width: 220,
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(AppRoutes.securityCenter);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityStatusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const _SecurityStatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 330;
        final iconBox = Container(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTheme.radius12),
          ),
          child: Icon(icon, color: color),
        );
        final textBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        );
        final statusChip = Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing10,
            vertical: AppTheme.spacing6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.radius16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: stack
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBox,
                    const SizedBox(height: AppTheme.spacing12),
                    textBlock,
                    const SizedBox(height: AppTheme.spacing12),
                    statusChip,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBox,
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textBlock,
                          const SizedBox(height: AppTheme.spacing8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: statusChip,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SpendingCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final double percentage;
  final Color color;

  const _SpendingCategory({
    required this.icon,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radius12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppTheme.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
