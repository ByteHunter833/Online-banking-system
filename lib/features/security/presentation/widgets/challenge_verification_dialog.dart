import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';

Future<String?> requestVerifiedChallenge(
  BuildContext context,
  WidgetRef ref, {
  required String purpose,
  String preferredMethod = 'totp',
  Map<String, dynamic>? payload,
  String? title,
}) async {
  try {
    final challenge = await ref.read(bankingApiServiceProvider).createChallenge(
          purpose: purpose,
          preferredMethod: preferredMethod,
          context: payload,
        );

    if (!context.mounted) {
      return null;
    }

    return showDialog<String>(
      context: context,
      builder: (_) => _ChallengeVerificationDialog(
        challenge: challenge,
        title: title ?? 'Verify action',
      ),
    );
  } catch (error) {
    if (!context.mounted) {
      return null;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
    return null;
  }
}

class _ChallengeVerificationDialog extends ConsumerStatefulWidget {
  final SecurityChallenge challenge;
  final String title;

  const _ChallengeVerificationDialog({
    required this.challenge,
    required this.title,
  });

  @override
  ConsumerState<_ChallengeVerificationDialog> createState() =>
      _ChallengeVerificationDialogState();
}

class _ChallengeVerificationDialogState
    extends ConsumerState<_ChallengeVerificationDialog> {
  final _codeController = TextEditingController();
  late String _selectedMethod;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.challenge.allowedMethods.isNotEmpty
        ? widget.challenge.allowedMethods.first
        : 'totp';
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the verification code first.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await ref
          .read(bankingApiServiceProvider)
          .verifyChallenge(
            challengeId: widget.challenge.challengeId,
            method: _selectedMethod,
            code: code,
          );

      if (!mounted) {
        return;
      }

      if (result.status == 'verified') {
        Navigator.of(context).pop(widget.challenge.challengeId);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge status: ${result.status}')),
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
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purpose: ${widget.challenge.purpose.replaceAll('_', ' ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            DropdownButtonFormField<String>(
              initialValue: _selectedMethod,
              decoration: const InputDecoration(labelText: 'Verification method'),
              items: widget.challenge.allowedMethods
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(method.replaceAll('_', ' ')),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMethod = value);
                }
              },
            ),
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Code',
                hintText: 'Enter 6-digit code',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'Challenge expires at ${_formatDateTime(widget.challenge.expiresAt)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _verify,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }
}
