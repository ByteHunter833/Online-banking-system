import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/security/presentation/widgets/challenge_verification_dialog.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class TransferReviewScreen extends ConsumerStatefulWidget {
  const TransferReviewScreen({super.key});

  @override
  ConsumerState<TransferReviewScreen> createState() =>
      _TransferReviewScreenState();
}

class _TransferReviewScreenState extends ConsumerState<TransferReviewScreen> {
  bool _isLoading = false;

  Future<void> _verifyTransferChallenge() async {
    final draft = ref.read(transferDraftProvider);
    final fromAccount = draft.fromAccount;
    if (fromAccount == null) {
      return;
    }

    final challengeId = await requestVerifiedChallenge(
      context,
      ref,
      purpose: 'transfer',
      payload: {
        'from_account_id': fromAccount.id,
        'recipient_account_number': draft.recipientAccountNumber,
        'amount': draft.amount.toStringAsFixed(2),
      },
      title: 'Verify transfer',
    );

    if (!mounted || challengeId == null) {
      return;
    }

    ref.read(transferDraftProvider.notifier).state = draft.copyWith(
      challengeId: challengeId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer challenge verified.')),
    );
  }

  Future<void> _confirmTransfer() async {
    final draft = ref.read(transferDraftProvider);
    final fromAccount = draft.fromAccount;

    if (fromAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an account before confirming.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = await ref
          .read(bankingApiServiceProvider)
          .transfer(
            fromAccountId: fromAccount.id,
            recipientAccountNumber: draft.recipientAccountNumber,
            amount: draft.amount,
            description: draft.note,
            challengeId: draft.challengeId.trim().isEmpty
                ? null
                : draft.challengeId,
          );

      ref.read(lastTransferProvider.notifier).state = transaction;
      ref.invalidate(dashboardOverviewProvider);
      ref.invalidate(accountsProvider);
      ref.invalidate(primaryAccountProvider);
      ref.invalidate(beneficiariesProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(unreadNotificationsProvider);
      ref.invalidate(notificationsProvider);

      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed(AppRoutes.transferSuccess);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(transferDraftProvider);
    final fromAccount = draft.fromAccount;
    final amount = draft.amount;
    final currency = fromAccount?.currency ?? 'USD';

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(title: AppStrings.reviewTransfer),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacing20),
            _ReviewItem(
              label: 'From Account',
              value: fromAccount == null
                  ? 'Not selected'
                  : '${fromAccount.accountType.toUpperCase()} • ${fromAccount.currency} ${fromAccount.availableBalance.toStringAsFixed(2)}',
            ),
            const SizedBox(height: AppTheme.spacing12),
            _ReviewItem(
              label: 'Recipient account',
              value: draft.recipientAccountNumber,
            ),
            if (draft.beneficiary != null) ...[
              const SizedBox(height: AppTheme.spacing12),
              _ReviewItem(
                label: 'Beneficiary',
                value: draft.beneficiary!.nickname,
              ),
            ],
            const SizedBox(height: AppTheme.spacing12),
            _ReviewItem(
              label: 'Amount',
              value: '${_currencySymbol(currency)}${amount.toStringAsFixed(2)}',
              isHighlight: true,
            ),
            const SizedBox(height: AppTheme.spacing12),
            _ReviewItem(
              label: 'Transaction Fee',
              value: '${_currencySymbol(currency)}0.00',
            ),
            const SizedBox(height: AppTheme.spacing12),
            _ReviewItem(
              label: 'Total',
              value: '${_currencySymbol(currency)}${amount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            if (draft.note.trim().isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing12),
              _ReviewItem(label: 'Note', value: draft.note),
            ],
            const SizedBox(height: AppTheme.spacing32),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius12),
                border: Border.all(
                  color: AppTheme.accentGreen.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_outlined,
                    color: AppTheme.accentGreen,
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      draft.challengeId.trim().isEmpty
                          ? 'You can verify this transfer first with `/security/challenges` before the final `/transactions/transfer` call.'
                          : 'Challenge verified. The final transfer call will include the confirmed challenge id.',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            SecondaryButton(
              label: draft.challengeId.trim().isEmpty
                  ? 'Verify transfer'
                  : 'Re-verify transfer',
              icon: Icons.verified_user_outlined,
              onPressed: _verifyTransferChallenge,
            ),
            const SizedBox(height: AppTheme.spacing32),
            PrimaryButton(
              label: AppStrings.transferConfirm,
              onPressed: _confirmTransfer,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppTheme.spacing12),
            SecondaryButton(
              label: AppStrings.cancel,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return '$currency ';
    }
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool isTotal;

  const _ReviewItem({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(
          color: isTotal ? AppTheme.primaryBlue : AppTheme.divider,
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
                color: isTotal
                    ? AppTheme.primaryBlue
                    : isHighlight
                    ? AppTheme.accentGreen
                    : AppTheme.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
