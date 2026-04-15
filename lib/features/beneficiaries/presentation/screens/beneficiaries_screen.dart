import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/security/presentation/widgets/challenge_verification_dialog.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class BeneficiariesScreen extends ConsumerWidget {
  final bool selectionMode;

  const BeneficiariesScreen({super.key, this.selectionMode = false});

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final created = await showDialog<Beneficiary>(
      context: context,
      builder: (_) => const _CreateBeneficiaryDialog(),
    );

    if (!context.mounted || created == null) {
      return;
    }

    ref.invalidate(beneficiariesProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Beneficiary added successfully.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beneficiariesAsync = ref.watch(beneficiariesProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: selectionMode ? 'Select Beneficiary' : 'Beneficiaries',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(beneficiariesProvider),
          ),
        ],
      ),
      body: beneficiariesAsync.when(
        data: (beneficiaries) {
          if (beneficiaries.isEmpty) {
            return EmptyState(
              icon: Icons.group_add_outlined,
              title: 'No beneficiaries yet',
              message:
                  'Add trusted recipients here and reuse them for transfers or recurring payments.',
              onRetry: () => _showCreateDialog(context, ref),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            itemCount: beneficiaries.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppTheme.spacing12),
            itemBuilder: (context, index) {
              final beneficiary = beneficiaries[index];
              return _BeneficiaryTile(
                beneficiary: beneficiary,
                selectionMode: selectionMode,
                onTap: () {
                  if (selectionMode) {
                    Navigator.of(context).pop(beneficiary);
                  }
                },
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          itemCount: 4,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
            child: LoadingShimmer(
              height: 96,
              borderRadius: BorderRadius.circular(AppTheme.radius16),
            ),
          ),
        ),
        error: (error, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Beneficiaries unavailable',
            message: error.toString(),
            onRetry: () => ref.invalidate(beneficiariesProvider),
          ),
        ),
      ),
    );
  }
}

class _CreateBeneficiaryDialog extends ConsumerStatefulWidget {
  const _CreateBeneficiaryDialog();

  @override
  ConsumerState<_CreateBeneficiaryDialog> createState() =>
      _CreateBeneficiaryDialogState();
}

class _CreateBeneficiaryDialogState
    extends ConsumerState<_CreateBeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(userProvider);
      String? challengeId;
      if (user?.mfaEnabled == true) {
        challengeId = await requestVerifiedChallenge(
          context,
          ref,
          purpose: 'beneficiary_create',
          payload: {
            'account_number': _accountNumberController.text.trim(),
            'nickname': _nicknameController.text.trim(),
          },
          title: 'Verify beneficiary creation',
        );
        if (challengeId == null) {
          return;
        }
      }

      final beneficiary = await ref
          .read(bankingApiServiceProvider)
          .createBeneficiary(
            accountNumber: _accountNumberController.text.trim(),
            nickname: _nicknameController.text.trim(),
            challengeId: challengeId,
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(beneficiary);
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
      title: const Text('Add beneficiary'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account number',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().length < 8) {
                    return 'Use at least 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Use at least 2 characters';
                  }
                  return null;
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

class _BeneficiaryTile extends ConsumerWidget {
  final Beneficiary beneficiary;
  final bool selectionMode;
  final VoidCallback onTap;

  const _BeneficiaryTile({
    required this.beneficiary,
    required this.selectionMode,
    required this.onTap,
  });

  Future<void> _showRecurringDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ScheduleRecurringDialog(beneficiary: beneficiary),
    );
    if (context.mounted) {
      ref.invalidate(beneficiariesProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radius16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.softBlue,
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beneficiary.nickname,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    beneficiary.accountNumber,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!selectionMode)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'recurring') {
                    _showRecurringDialog(context, ref);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'recurring',
                    child: Text('Create recurring transfer'),
                  ),
                ],
              )
            else
              const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRecurringDialog extends ConsumerStatefulWidget {
  final Beneficiary beneficiary;

  const _ScheduleRecurringDialog({required this.beneficiary});

  @override
  ConsumerState<_ScheduleRecurringDialog> createState() =>
      _ScheduleRecurringDialogState();
}

class _ScheduleRecurringDialogState
    extends ConsumerState<_ScheduleRecurringDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _startDateController = TextEditingController();
  String _frequency = 'monthly';
  String? _selectedAccountId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startDateController.text = _formatDate(DateTime.now().add(const Duration(days: 1)));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(_startDateController.text) ??
        DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      _startDateController.text = _formatDate(picked);
      setState(() {});
    }
  }

  Future<void> _submit(List<Account> accounts) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedAccount = accounts.firstWhere(
      (account) => account.id == _selectedAccountId,
      orElse: () => accounts.first,
    );

    setState(() => _isSubmitting = true);
    try {
      final challengeId = await requestVerifiedChallenge(
        context,
        ref,
        purpose: 'recurring_transfer',
        payload: {
          'beneficiary_id': widget.beneficiary.id,
          'amount': _amountController.text.trim(),
        },
        title: 'Verify recurring transfer',
      );
      if (challengeId == null) {
        return;
      }

      await ref.read(bankingApiServiceProvider).createRecurringTransfer(
            fromAccountId: selectedAccount.id,
            beneficiaryId: widget.beneficiary.id,
            amount: double.parse(_amountController.text.trim()),
            frequency: _frequency,
            startDate: _startDateController.text.trim(),
            challengeId: challengeId,
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recurring transfer scheduled.')),
      );
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
    final accountsAsync = ref.watch(accountsProvider);

    return AlertDialog(
      title: Text('Recurring for ${widget.beneficiary.nickname}'),
      content: SizedBox(
        width: double.maxFinite,
        child: accountsAsync.when(
          data: (accounts) {
            _selectedAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAccountId,
                      decoration: const InputDecoration(labelText: 'From account'),
                      items: accounts
                          .map(
                            (account) => DropdownMenuItem(
                              value: account.id,
                              child: Text(account.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedAccountId = value);
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    DropdownButtonFormField<String>(
                      initialValue: _frequency,
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      items: const [
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _frequency = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Start date'),
                      onTap: _pickDate,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppTheme.spacing12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text(error.toString()),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        accountsAsync.maybeWhen(
          data: (accounts) => FilledButton(
            onPressed: _isSubmitting ? null : () => _submit(accounts),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
