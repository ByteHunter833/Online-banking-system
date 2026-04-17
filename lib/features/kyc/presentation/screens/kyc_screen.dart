import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentTypeController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _filesController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;
  KycSubmission? _latestSubmission;

  @override
  void dispose() {
    _documentTypeController.dispose();
    _documentNumberController.dispose();
    _filesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final files = _filesController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final submission = await ref
          .read(bankingApiServiceProvider)
          .createKycSubmission(
            documentType: _documentTypeController.text.trim(),
            documentNumber: _documentNumberController.text.trim(),
            files: files,
            addressText: _addressController.text.trim(),
          );

      if (!mounted) {
        return;
      }

      setState(() => _latestSubmission = submission);
      invalidateLiveBankingData(
        ref,
        includeProfile: true,
        includeAccounts: false,
        includeTransactions: false,
        includeCards: false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC submission sent successfully.')),
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
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const BankingAppBar(title: 'KYC Verification'),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radius20),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  user?.kycStatus.isNotEmpty == true
                      ? user!.kycStatus
                      : 'pending',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radius20),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit verification data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  TextFormField(
                    controller: _documentTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Document type',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Use at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  TextFormField(
                    controller: _documentNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Document number',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Use at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  TextFormField(
                    controller: _filesController,
                    decoration: const InputDecoration(
                      labelText: 'Files',
                      hintText: 'passport_front.jpg, passport_back.jpg',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Add at least one file name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value == null || value.trim().length < 5) {
                        return 'Use at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  PrimaryButton(
                    label: 'Submit KYC',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          if (_latestSubmission != null) ...[
            const SizedBox(height: AppTheme.spacing20),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radius20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest submission',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  Text('Status: ${_latestSubmission!.status}'),
                  const SizedBox(height: AppTheme.spacing8),
                  Text('Document: ${_latestSubmission!.documentType}'),
                  const SizedBox(height: AppTheme.spacing8),
                  Text('Address: ${_latestSubmission!.addressText}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
