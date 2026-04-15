import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(
      transactionDetailProvider(transaction.id),
    );
    final detail = transactionAsync.maybeWhen(
      data: (value) => value,
      orElse: () => transaction,
    );
    final amountColor = detail.isDebit
        ? AppTheme.errorRed
        : AppTheme.accentGreen;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: 'Transaction Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.invalidate(transactionDetailProvider(detail.id)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            transactionAsync.when(
              data: (_) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (error, _) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing14),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radius16),
                    border: Border.all(
                      color: AppTheme.warningOrange.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Text(
                    'Showing cached transaction data. ${error.toString()}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radius24),
                border: Border.all(color: AppTheme.divider),
                boxShadow: AppTheme.softShadow,
              ),
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      detail.isDebit
                          ? Icons.arrow_outward_rounded
                          : Icons.arrow_downward_rounded,
                      color: amountColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    '${detail.isDebit ? '-' : '+'} ${_currencySymbol(detail.currency)}${detail.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.darkGrey,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing10,
                      vertical: AppTheme.spacing6,
                    ),
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _capitalize(detail.transactionStatus),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    detail.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            _DetailSection(
              title: 'Payment info',
              children: [
                _DetailRow(label: 'Recipient', value: detail.recipientName),
                _DetailRow(label: 'Category', value: detail.category),
                _DetailRow(
                  label: 'Date',
                  value: _formatDateTime(detail.transactionDate),
                ),
                _DetailRow(label: 'Reference', value: detail.referenceNumber),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            _DetailSection(
              title: 'Charges',
              children: [
                _DetailRow(
                  label: 'Transfer amount',
                  value:
                      '${_currencySymbol(detail.currency)}${detail.amount.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Fee',
                  value:
                      '${_currencySymbol(detail.currency)}${detail.fee.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Type',
                  value: _capitalize(detail.transactionType),
                ),
              ],
            ),
            if (detail.notes.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing16),
              _DetailSection(
                title: 'Notes',
                children: [
                  Text(
                    detail.notes,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGrey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _currencySymbol(String currency) {
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

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ');
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} • $hour:$minute';
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius20),
        border: Border.all(color: AppTheme.divider),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacing16),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
