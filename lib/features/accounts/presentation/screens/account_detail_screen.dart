import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class AccountDetailScreen extends ConsumerWidget {
  final String accountId;
  final Account? initialAccount;

  const AccountDetailScreen({
    super.key,
    required this.accountId,
    this.initialAccount,
  });

  Future<void> _showEditPreferencesDialog(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditAccountPreferencesDialog(account: account),
    );

    if (!context.mounted || updated != true) {
      return;
    }

    ref.invalidate(accountDetailProvider(accountId));
    ref.invalidate(accountsProvider);
    ref.invalidate(primaryAccountProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(accountDetailProvider(accountId));
    final account = accountAsync.maybeWhen(
      data: (value) => value,
      orElse: () => initialAccount,
    );

    if (account == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: BankingAppBar(
          title: AppStrings.accountDetails,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(accountDetailProvider(accountId)),
            ),
          ],
        ),
        body: accountAsync.when(
          data: (_) => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: EmptyState(
              icon: Icons.error_outline,
              title: 'Account unavailable',
              message: error.toString(),
              onRetry: () => ref.invalidate(accountDetailProvider(accountId)),
            ),
          ),
        ),
      );
    }

    final limitRatio = account.dailyTransferLimit <= 0
        ? 0.0
        : (account.dailyTransferredAmount / account.dailyTransferLimit).clamp(
            0.0,
            1.0,
          );

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: AppStrings.accountDetails,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditPreferencesDialog(context, ref, account),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(accountDetailProvider(accountId)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radius24),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppTheme.spacing8,
                    runSpacing: AppTheme.spacing8,
                    children: [
                      _Badge(label: account.displayName),
                      _Badge(label: account.accountStatus),
                      if (account.isPrimary) const _Badge(label: 'Primary'),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  Text(
                    '${account.currency} ${account.balance.toStringAsFixed(2)}',
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Available ${account.currency} ${account.availableBalance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Daily remaining',
                    value:
                        '${account.currency} ${account.remainingDailyTransfer.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: _MetricCard(
                    title: 'Transferred today',
                    value:
                        '${account.currency} ${account.dailyTransferredAmount.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing20),
            _Section(
              title: 'Account information',
              children: [
                _DetailRow(
                  label: 'Account number',
                  value: account.accountNumber,
                ),
                _DetailRow(label: 'IBAN', value: account.iban),
                _DetailRow(label: 'Currency', value: account.currency),
                _DetailRow(
                  label: 'Type',
                  value: _capitalize(account.accountType),
                ),
                _DetailRow(
                  label: 'Status',
                  value: _capitalize(account.accountStatus),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            _Section(
              title: 'Transfer limits',
              children: [
                _DetailRow(
                  label: 'Daily limit',
                  value:
                      '${account.currency} ${account.dailyTransferLimit.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Used today',
                  value:
                      '${account.currency} ${account.dailyTransferredAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: AppTheme.spacing12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: limitRatio,
                    minHeight: 10,
                    backgroundColor: AppTheme.softBlue,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            _Section(
              title: 'Lifecycle',
              children: [
                _DetailRow(
                  label: 'Opened',
                  value: _formatDate(account.openDate),
                ),
                _DetailRow(
                  label: 'Last updated',
                  value: _formatDate(account.updatedAt),
                ),
                _DetailRow(label: 'Bank', value: account.bankName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ');
  }

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}

class _EditAccountPreferencesDialog extends ConsumerStatefulWidget {
  final Account account;

  const _EditAccountPreferencesDialog({required this.account});

  @override
  ConsumerState<_EditAccountPreferencesDialog> createState() =>
      _EditAccountPreferencesDialogState();
}

class _EditAccountPreferencesDialogState
    extends ConsumerState<_EditAccountPreferencesDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late bool _isPrimary;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.account.nickname);
    _isPrimary = widget.account.isPrimary;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(bankingApiServiceProvider).updateAccountPreferences(
            accountId: widget.account.id,
            nickname: _nicknameController.text.trim(),
            isPrimary: _isPrimary,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account preferences'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
                validator: (value) {
                  if (value != null && value.trim().length > 100) {
                    return 'Use 100 characters or fewer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Make primary account'),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() => _isPrimary = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius20),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.softShadow,
      ),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.darkGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
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
              value.isEmpty ? '-' : value,
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

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing10,
        vertical: AppTheme.spacing6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
