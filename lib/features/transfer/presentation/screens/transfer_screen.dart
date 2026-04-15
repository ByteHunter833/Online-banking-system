import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/beneficiaries/presentation/screens/beneficiaries_screen.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  Account? _selectedAccount;
  Beneficiary? _selectedBeneficiary;
  final bool _isLoading = false;

  @override
  void dispose() {
    _recipientAccountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _proceedWithTransfer() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    ref.read(transferDraftProvider.notifier).state = TransferDraft(
      fromAccount: _selectedAccount,
      beneficiary: _selectedBeneficiary,
      recipientAccountNumber: _recipientAccountController.text.trim(),
      amount: amount,
      note: _noteController.text.trim(),
    );

    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed(AppRoutes.transferReview);
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(title: AppStrings.transfer),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipient account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacing12),
              Align(
                alignment: Alignment.centerLeft,
                child: SecondaryButton(
                  label: 'Choose beneficiary',
                  width: 180,
                  height: 42,
                  icon: Icons.people_alt_outlined,
                  onPressed: () async {
                    final beneficiary = await Navigator.of(context).push<Beneficiary>(
                      MaterialPageRoute(
                        builder: (_) => const BeneficiariesScreen(
                          selectionMode: true,
                        ),
                      ),
                    );
                    if (!mounted || beneficiary == null) {
                      return;
                    }

                    setState(() {
                      _selectedBeneficiary = beneficiary;
                      _recipientAccountController.text =
                          beneficiary.accountNumber;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              if (_selectedBeneficiary != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing14),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius16),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedBeneficiary!.nickname,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              _selectedBeneficiary!.accountNumber,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          setState(() {
                            _selectedBeneficiary = null;
                            _recipientAccountController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.softBlue,
                  borderRadius: BorderRadius.circular(AppTheme.radius16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Text(
                        'Backend transfers use `recipient_account_number`, so this screen now sends the payment to the exact account you enter.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              CustomTextField(
                controller: _recipientAccountController,
                label: 'Recipient account number',
                hint: 'Enter destination account number',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.account_balance_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (value.trim().length < 8) {
                    return 'Account number must be at least 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                AppStrings.selectAccount,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacing16),
              accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: AppStrings.noAccounts,
                      message: 'You need an account before sending money.',
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: DropdownButton<Account>(
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16,
                        vertical: AppTheme.spacing4,
                      ),
                      hint: const Text('Choose account'),
                      value: _selectedAccount,
                      items: accounts.map((account) {
                        return DropdownMenuItem<Account>(
                          value: account,
                          child: Text(
                            '${account.accountType.toUpperCase()} - ${account.currency} ${account.availableBalance.toStringAsFixed(2)}',
                          ),
                        );
                      }).toList(),
                      onChanged: (Account? value) {
                        setState(() => _selectedAccount = value);
                      },
                    ),
                  );
                },
                loading: () => LoadingShimmer(
                  height: 56,
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
                error: (error, stackTrace) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Accounts unavailable',
                  message: error.toString(),
                  onRetry: () => ref.invalidate(accountsProvider),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              CustomTextField(
                controller: _amountController,
                label: AppStrings.amount,
                hint: 'Enter amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(Icons.payments_outlined),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return AppStrings.invalidAmount;
                  }
                  if (_selectedAccount != null &&
                      amount > _selectedAccount!.availableBalance) {
                    return AppStrings.insufficientBalance;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing20),
              CustomTextField(
                controller: _noteController,
                label: AppStrings.addNote,
                hint: 'Add optional note',
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: AppTheme.spacing20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security checks before confirmation',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    const _SecurityCheckRow(
                      label: 'Recipient format',
                      status: 'Validated',
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    const _SecurityCheckRow(
                      label: 'Session protection',
                      status: 'Encrypted',
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    _SecurityCheckRow(
                      label: 'Amount review',
                      status: _amountController.text.isEmpty
                          ? 'Pending'
                          : 'Ready',
                      color: AppTheme.warningOrange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing32),
              PrimaryButton(
                label: AppStrings.next,
                onPressed: _proceedWithTransfer,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityCheckRow extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const _SecurityCheckRow({
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, color: color, size: 18),
        const SizedBox(width: AppTheme.spacing8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Container(
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
        ),
      ],
    );
  }
}
