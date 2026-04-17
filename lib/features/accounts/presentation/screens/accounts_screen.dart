import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  Future<void> _showCreateAccountDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final account = await showDialog<Account>(
      context: context,
      builder: (_) => const _CreateAccountDialog(),
    );
    if (!context.mounted || account == null) return;

    invalidateLiveBankingData(
      ref,
      includeTransactions: false,
      includeNotifications: false,
    );
    ref.read(selectedAccountProvider.notifier).state = account;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully.')),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AccountDetailScreen(accountId: account.id, initialAccount: account),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: AppStrings.myAccounts,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateAccountDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(accountsProvider),
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: AppStrings.noAccounts,
              message: 'Create your first account from the app or backend.',
              onRetry: () => _showCreateAccountDialog(context, ref),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(accounts.length, (index) {
                final account = accounts[index];
                final typeColor = account.accountType == 'current'
                    ? AppTheme.primaryBlue
                    : account.accountType == 'savings'
                    ? AppTheme.accentGreen
                    : AppTheme.errorRed;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedAccountProvider.notifier).state =
                          account;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AccountDetailScreen(
                            accountId: account.id,
                            initialAccount: account,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [typeColor, typeColor.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                      ),
                      padding: const EdgeInsets.all(AppTheme.spacing20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  account.displayName.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ),
                              if (account.isPrimary)
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: AppTheme.spacing8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PRIMARY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          Text(
                            '${account.currency} ${account.balance.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppTheme.spacing6),
                          Text(
                            'Available ${account.currency} ${account.availableBalance.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Account Number',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      account.accountNumber,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: AppTheme.spacing8),
                                  Text(
                                    account.accountStatus.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.76,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          itemCount: 3,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
            child: LoadingShimmer(
              height: 180,
              borderRadius: BorderRadius.circular(AppTheme.radius16),
            ),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Accounts unavailable',
            message: error.toString(),
            onRetry: () => ref.invalidate(accountsProvider),
          ),
        ),
      ),
    );
  }
}

class _CreateAccountDialog extends ConsumerStatefulWidget {
  const _CreateAccountDialog();

  @override
  ConsumerState<_CreateAccountDialog> createState() =>
      _CreateAccountDialogState();
}

class _CreateAccountDialogState extends ConsumerState<_CreateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _initialDepositController = TextEditingController(text: '0');
  String _selectedCurrency = 'USD';
  bool _isPrimary = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _initialDepositController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final initialDeposit =
        double.tryParse(_initialDepositController.text.trim()) ?? 0;

    setState(() => _isSubmitting = true);
    try {
      final account = await ref
          .read(bankingApiServiceProvider)
          .createAccount(
            nickname: _nicknameController.text.trim(),
            currency: _selectedCurrency,
            initialDeposit: initialDeposit,
            isPrimary: _isPrimary,
          );

      if (!mounted) return;
      Navigator.of(context).pop(account);
    } catch (error) {
      if (!mounted) return;
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
      title: const Text('Create account'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: 'Nickname',
                    hintText: 'Salary, Travel, Savings...',
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCurrency,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCurrency = value);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _initialDepositController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Initial deposit',
                    hintText: '0.00',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount < 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as primary account'),
                  value: _isPrimary,
                  onChanged: (value) => setState(() => _isPrimary = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
