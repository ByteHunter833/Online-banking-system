import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
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
  bool _isRequestingOtp = false;

  Future<bool> _requestTransferOtp() async {
    final draft = ref.read(transferDraftProvider);
    final fromAccount = draft.fromAccount;
    if (fromAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an account before requesting OTP.'),
        ),
      );
      return false;
    }

    setState(() => _isRequestingOtp = true);

    try {
      final dispatch = await ref
          .read(bankingApiServiceProvider)
          .requestTransferVerification(
            fromAccountId: fromAccount.id,
            recipientAccountNumber: draft.recipientAccountNumber,
            amount: draft.amount,
            description: draft.note,
          );

      if (!mounted) {
        return false;
      }

      final otpCode = await showDialog<String>(
        context: context,
        builder: (_) => _TransferOtpDialog(dispatch: dispatch),
      );

      if (!mounted || otpCode == null) {
        return false;
      }

      ref.read(transferDraftProvider.notifier).state = ref
          .read(transferDraftProvider)
          .copyWith(otpCode: otpCode, challengeId: '');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transfer code is ready.')));
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return false;
    } finally {
      if (mounted) {
        setState(() => _isRequestingOtp = false);
      }
    }
  }

  Future<void> _confirmTransfer() async {
    var draft = ref.read(transferDraftProvider);
    var fromAccount = draft.fromAccount;

    if (fromAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an account before confirming.')),
      );
      return;
    }

    if (draft.otpCode.trim().isEmpty) {
      final otpReady = await _requestTransferOtp();
      if (!otpReady || !mounted) {
        return;
      }
      draft = ref.read(transferDraftProvider);
      fromAccount = draft.fromAccount;
      if (fromAccount == null) {
        return;
      }
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
            otpCode: draft.otpCode.trim().isEmpty ? null : draft.otpCode.trim(),
          );

      ref.read(lastTransferProvider.notifier).state = transaction;
      invalidateLiveBankingData(ref);
      ref.invalidate(beneficiariesProvider);

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
    final hasTransferOtp = draft.otpCode.trim().isNotEmpty;
    final verificationColor = hasTransferOtp
        ? AppTheme.accentGreen
        : AppTheme.primaryBlue;

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
                color: verificationColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius12),
                border: Border.all(
                  color: verificationColor.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: [
                  Icon(
                    hasTransferOtp
                        ? Icons.verified_user_outlined
                        : Icons.mark_email_unread_outlined,
                    color: verificationColor,
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      hasTransferOtp
                          ? 'Transfer code entered. You can send the transfer now or request a new code.'
                          : 'A 6-digit transfer code is required before the transfer can be sent.',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            SecondaryButton(
              label: hasTransferOtp ? 'Get new code' : 'Get transfer code',
              icon: Icons.password_outlined,
              onPressed: () => _requestTransferOtp(),
              isEnabled: !_isRequestingOtp,
              isLoading: _isRequestingOtp,
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

class _TransferOtpDialog extends StatefulWidget {
  final OTPDispatchInfo dispatch;

  const _TransferOtpDialog({required this.dispatch});

  @override
  State<_TransferOtpDialog> createState() => _TransferOtpDialogState();
}

class _TransferOtpDialogState extends State<_TransferOtpDialog> {
  final _codeController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _errorText = 'Enter the 6-digit code.');
      return;
    }

    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final channel = widget.dispatch.deliveryChannel.replaceAll('_', ' ');

    return AlertDialog(
      title: const Text('Transfer code'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dispatch.message.isEmpty
                  ? 'Enter the 6-digit code sent by $channel.'
                  : widget.dispatch.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.dispatch.expiresInSeconds > 0) ...[
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Expires in ${_formatExpiry(widget.dispatch.expiresInSeconds)}.',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.darkGrey),
              ),
            ],
            if (widget.dispatch.debugOtp.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: SelectableText(
                  'Debug code: ${widget.dispatch.debugOtp}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              controller: _codeController,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: '6-digit code',
                counterText: '',
                errorText: _errorText,
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Use code')),
      ],
    );
  }

  String _formatExpiry(int seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes <= 1) {
      return '1 minute';
    }
    return '$minutes minutes';
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
