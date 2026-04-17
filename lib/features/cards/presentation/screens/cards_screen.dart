import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  Future<void> _showCreateCardDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final accounts = await ref.read(accountsProvider.future);
      if (!context.mounted) return;

      if (accounts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Create an account first before issuing a card.'),
          ),
        );
        return;
      }

      final created = await showDialog<bool>(
        context: context,
        builder: (_) => _CreateCardDialog(accounts: accounts),
      );
      if (!context.mounted) return;

      if (created == true) {
        invalidateLiveBankingData(
          ref,
          includeAccounts: false,
          includeTransactions: false,
          includeNotifications: false,
          includeCards: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card issued successfully.')),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: AppStrings.myCards,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateCardDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(cardsProvider),
          ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return EmptyState(
              icon: Icons.credit_card_off_outlined,
              title: AppStrings.noCards,
              message:
                  'Issue a card from the app or backend to manage it here.',
              onRetry: () => _showCreateCardDialog(context, ref),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            itemCount: cards.length + 1,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppTheme.spacing20),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _CardsSecurityOverview();
              }

              return _CardTile(card: cards[index - 1]);
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          itemCount: 3,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing20),
            child: LoadingShimmer(
              height: 280,
              borderRadius: BorderRadius.circular(AppTheme.radius20),
            ),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Cards unavailable',
            message: error.toString(),
            onRetry: () => ref.invalidate(cardsProvider),
          ),
        ),
      ),
    );
  }

  static String _accountSuffix(String accountNumber) {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }

    return accountNumber.substring(accountNumber.length - 4);
  }
}

class _CreateCardDialog extends ConsumerStatefulWidget {
  final List<Account> accounts;

  const _CreateCardDialog({required this.accounts});

  @override
  ConsumerState<_CreateCardDialog> createState() => _CreateCardDialogState();
}

class _CreateCardDialogState extends ConsumerState<_CreateCardDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedAccountId;
  String _selectedCardType = 'virtual';
  String _limitValue = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.accounts.first.id;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final limitText = _limitValue.trim();
    final spendingLimit = limitText.isEmpty ? null : double.tryParse(limitText);

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(bankingApiServiceProvider)
          .createCard(
            accountId: _selectedAccountId,
            cardType: _selectedCardType,
            spendingLimit: spendingLimit,
            cardHolderName: ref.read(userProvider)?.fullName,
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
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
      title: const Text('Issue new card'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Linked account',
                  ),
                  items: widget.accounts
                      .map(
                        (account) => DropdownMenuItem(
                          value: account.id,
                          child: Text(
                            '${account.displayName} • ${CardsScreen._accountSuffix(account.accountNumber)}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAccountId = value);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCardType,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Card type'),
                  items: const [
                    DropdownMenuItem(value: 'virtual', child: Text('Virtual')),
                    DropdownMenuItem(
                      value: 'physical',
                      child: Text('Physical'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCardType = value);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  initialValue: _limitValue,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Spending limit',
                    hintText: 'Optional',
                  ),
                  onChanged: (value) => _limitValue = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }

                    final limit = double.tryParse(value.trim());
                    if (limit == null || limit <= 0) {
                      return 'Enter a valid limit';
                    }
                    return null;
                  },
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

class _UpdateCardLimitDialog extends ConsumerStatefulWidget {
  final BankCard card;

  const _UpdateCardLimitDialog({required this.card});

  @override
  ConsumerState<_UpdateCardLimitDialog> createState() =>
      _UpdateCardLimitDialogState();
}

class _UpdateCardLimitDialogState
    extends ConsumerState<_UpdateCardLimitDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _limitValue;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _limitValue = widget.card.monthlyLimit > 0
        ? widget.card.monthlyLimit.toStringAsFixed(2)
        : '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nextLimit = double.tryParse(_limitValue.trim()) ?? 0;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(bankingApiServiceProvider)
          .updateCardSpendingLimit(
            widget.card.id,
            nextLimit,
            cardHolderName: ref.read(userProvider)?.fullName,
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
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
      title: const Text('Update spending limit'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: _limitValue,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'New limit',
              hintText: '0.00',
            ),
            onChanged: (value) => _limitValue = value,
            validator: (value) {
              final limit = double.tryParse(value?.trim() ?? '');
              if (limit == null || limit <= 0) {
                return 'Enter a valid limit';
              }
              return null;
            },
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
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _CardsSecurityOverview extends StatelessWidget {
  const _CardsSecurityOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius24),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card Security', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            'Freeze cards, watch spending limits and protect online payments.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Wrap(
            spacing: AppTheme.spacing8,
            runSpacing: AppTheme.spacing8,
            children: const [
              _SecurityChip(
                icon: Icons.lock_clock_outlined,
                label: '24/7 monitoring',
                color: AppTheme.primaryBlue,
              ),
              _SecurityChip(
                icon: Icons.credit_card_off_outlined,
                label: 'Instant freeze',
                color: AppTheme.warningOrange,
              ),
              _SecurityChip(
                icon: Icons.verified_user_outlined,
                label: '3D Secure ready',
                color: AppTheme.accentGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpdateCardControlsDialog extends ConsumerStatefulWidget {
  final BankCard card;

  const _UpdateCardControlsDialog({required this.card});

  @override
  ConsumerState<_UpdateCardControlsDialog> createState() =>
      _UpdateCardControlsDialogState();
}

class _UpdateCardControlsDialogState
    extends ConsumerState<_UpdateCardControlsDialog> {
  late bool _onlineEnabled;
  late bool _atmEnabled;
  late bool _contactlessEnabled;
  late String _limitValue;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _onlineEnabled = !widget.card.isFrozen;
    _atmEnabled = !widget.card.isFrozen;
    _contactlessEnabled = !widget.card.isFrozen;
    _limitValue = widget.card.monthlyLimit > 0
        ? widget.card.monthlyLimit.toStringAsFixed(2)
        : '';
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final limit = _limitValue.trim().isEmpty
          ? null
          : double.tryParse(_limitValue.trim());
      await ref
          .read(bankingApiServiceProvider)
          .updateCardControls(
            cardId: widget.card.id,
            onlineEnabled: _onlineEnabled,
            atmEnabled: _atmEnabled,
            contactlessEnabled: _contactlessEnabled,
            spendingLimit: limit,
            cardHolderName: ref.read(userProvider)?.fullName,
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
      title: const Text('Card controls'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online payments'),
                value: _onlineEnabled,
                onChanged: (value) {
                  setState(() => _onlineEnabled = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('ATM withdrawals'),
                value: _atmEnabled,
                onChanged: (value) {
                  setState(() => _atmEnabled = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Contactless'),
                value: _contactlessEnabled,
                onChanged: (value) {
                  setState(() => _contactlessEnabled = value);
                },
              ),
              const SizedBox(height: AppTheme.spacing12),
              TextFormField(
                initialValue: _limitValue,
                decoration: const InputDecoration(
                  labelText: 'Spending limit',
                  hintText: 'Optional',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (value) => _limitValue = value,
              ),
            ],
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
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _CardTile extends ConsumerWidget {
  final BankCard card;

  const _CardTile({required this.card});

  Color get _backgroundColor {
    if (card.cardBrand.toLowerCase() == 'visa') {
      return const Color(0xFF1F1F4D);
    }

    return const Color(0xFFD2691E);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageRatio = card.monthlyLimit == 0
        ? 0.0
        : (card.usedMonthly / card.monthlyLimit).clamp(0.0, 1.0);

    Future<void> toggleFreezeState() async {
      try {
        final api = ref.read(bankingApiServiceProvider);
        if (card.isFrozen) {
          await api.unfreezeCard(card.id);
        } else {
          await api.freezeCard(card.id, reason: 'User action from mobile app');
        }
        invalidateLiveBankingData(
          ref,
          includeAccounts: false,
          includeTransactions: false,
          includeNotifications: false,
          includeCards: true,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(card.isFrozen ? 'Card unfrozen.' : 'Card frozen.'),
          ),
        );
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }

    Future<void> showLimitDialog() async {
      final updated = await showDialog<bool>(
        context: context,
        builder: (_) => _UpdateCardLimitDialog(card: card),
      );
      if (!context.mounted) return;

      if (updated == true) {
        invalidateLiveBankingData(
          ref,
          includeAccounts: false,
          includeTransactions: false,
          includeNotifications: false,
          includeCards: true,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Card limit updated.')));
      }
    }

    Future<void> showControlsDialog() async {
      final updated = await showDialog<bool>(
        context: context,
        builder: (_) => _UpdateCardControlsDialog(card: card),
      );
      if (!context.mounted) {
        return;
      }

      if (updated == true) {
        invalidateLiveBankingData(
          ref,
          includeAccounts: false,
          includeTransactions: false,
          includeNotifications: false,
          includeCards: true,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Card controls updated.')));
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_backgroundColor, _backgroundColor.withValues(alpha: 0.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.cardType.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      card.cardBrand,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing8,
                alignment: WrapAlignment.end,
                children: [
                  if (card.isVirtual)
                    _TopStatusBadge(
                      label: 'Virtual',
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  _TopStatusBadge(
                    label: card.isFrozen ? 'Frozen' : 'Active',
                    color: card.isFrozen
                        ? Colors.orange.withValues(alpha: 0.24)
                        : Colors.white.withValues(alpha: 0.18),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            card.maskedCardNumber,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Wrap(
            spacing: AppTheme.spacing24,
            runSpacing: AppTheme.spacing12,
            children: [
              _CardMetaItem(label: 'Card holder', value: card.cardHolder),
              _CardMetaItem(label: 'Expires', value: card.expiryDate),
              _CardMetaItem(
                label: 'Online payments',
                value: card.isFrozen ? 'Disabled' : 'Protected',
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          Text(
            'Spending limit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usageRatio,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            '${card.usedMonthly.toStringAsFixed(0)} of ${card.monthlyLimit.toStringAsFixed(0)} used',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          Wrap(
            spacing: AppTheme.spacing8,
            runSpacing: AppTheme.spacing8,
            children: [
              _ActionChip(
                icon: card.isFrozen
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                label: card.isFrozen ? 'Unfreeze card' : 'Freeze card',
                onTap: toggleFreezeState,
              ),
              _ActionChip(
                icon: Icons.tune_outlined,
                label: 'Manage limits',
                onTap: showLimitDialog,
              ),
              _ActionChip(
                icon: Icons.settings_outlined,
                label: 'Card controls',
                onTap: showControlsDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TopStatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing10,
        vertical: AppTheme.spacing6,
      ),
      decoration: BoxDecoration(
        color: color,
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

class _CardMetaItem extends StatelessWidget {
  final String label;
  final String value;

  const _CardMetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing12,
            vertical: AppTheme.spacing10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SecurityChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
