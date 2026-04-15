import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class TransferSuccessScreen extends ConsumerStatefulWidget {
  const TransferSuccessScreen({super.key});

  @override
  ConsumerState<TransferSuccessScreen> createState() =>
      _TransferSuccessScreenState();
}

class _TransferSuccessScreenState extends ConsumerState<TransferSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(lastTransferProvider);
    final draft = ref.watch(transferDraftProvider);
    final currency =
        transaction?.currency ?? draft.fromAccount?.currency ?? 'USD';
    final amount = transaction?.amount ?? draft.amount;
    final recipient = draft.recipientAccountNumber;
    final reference = transaction?.referenceNumber.isNotEmpty == true
        ? transaction!.referenceNumber
        : 'Pending reference';

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppTheme.accentGreen,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing32),
            Text(
              AppStrings.transferSuccess,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(color: AppTheme.darkGrey),
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'Your transfer response has been received from the backend.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.mediumGrey),
            ),
            const SizedBox(height: AppTheme.spacing32),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radius16),
                border: Border.all(color: AppTheme.divider),
              ),
              padding: const EdgeInsets.all(AppTheme.spacing20),
              margin: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing20,
              ),
              child: Column(
                children: [
                  _SuccessDetail(label: 'Reference', value: reference),
                  const SizedBox(height: AppTheme.spacing12),
                  _SuccessDetail(
                    label: 'Amount',
                    value:
                        '${_currencySymbol(currency)}${amount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _SuccessDetail(label: 'Recipient', value: recipient),
                  const SizedBox(height: AppTheme.spacing12),
                  _SuccessDetail(label: 'Time', value: 'Just now'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing32),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing20,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Back Home',
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushReplacementNamed(AppRoutes.home);
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  SecondaryButton(
                    label: 'Share Receipt',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Receipt sharing can be added next.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
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

class _SuccessDetail extends StatelessWidget {
  final String label;
  final String value;

  const _SuccessDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGrey),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
