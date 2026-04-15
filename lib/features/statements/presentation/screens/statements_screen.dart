import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class StatementsScreen extends ConsumerStatefulWidget {
  const StatementsScreen({super.key});

  @override
  ConsumerState<StatementsScreen> createState() => _StatementsScreenState();
}

class _StatementsScreenState extends ConsumerState<StatementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  String? _selectedAccountId;
  String _format = 'csv';
  bool _isSubmitting = false;
  final List<StatementExport> _exports = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    _dateFromController.text = _formatDate(start);
    _dateToController.text = _formatDate(now);
  }

  @override
  void dispose() {
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial =
        DateTime.tryParse(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = _formatDate(picked);
      setState(() {});
    }
  }

  Future<void> _createExport() async {
    if (!_formKey.currentState!.validate() || _selectedAccountId == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final export = await ref.read(bankingApiServiceProvider).createStatementExport(
            accountId: _selectedAccountId!,
            dateFrom: _dateFromController.text.trim(),
            dateTo: _dateToController.text.trim(),
            format: _format,
          );

      if (!mounted) {
        return;
      }

      setState(() => _exports.insert(0, export));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statement export requested.')),
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

  Future<void> _refreshExport(int index) async {
    final export = _exports[index];
    try {
      final refreshed = await ref
          .read(bankingApiServiceProvider)
          .getStatementExport(export.exportId);
      if (!mounted) {
        return;
      }
      setState(() => _exports[index] = refreshed);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const BankingAppBar(title: 'Statements & Exports'),
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
            child: accountsAsync.when(
              data: (accounts) {
                _selectedAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;

                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Request statement export',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppTheme.spacing16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Account',
                        ),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateFromController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'From',
                              ),
                              onTap: () => _pickDate(_dateFromController),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: TextFormField(
                              controller: _dateToController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'To',
                              ),
                              onTap: () => _pickDate(_dateToController),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      DropdownButtonFormField<String>(
                        initialValue: _format,
                        decoration: const InputDecoration(labelText: 'Format'),
                        items: const [
                          DropdownMenuItem(value: 'csv', child: Text('CSV')),
                          DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _format = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing20),
                      PrimaryButton(
                        label: 'Create export',
                        isLoading: _isSubmitting,
                        onPressed: _createExport,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Accounts unavailable',
                message: error.toString(),
                onRetry: () => ref.invalidate(accountsProvider),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          Text('Recent exports', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacing12),
          if (_exports.isEmpty)
            const EmptyState(
              icon: Icons.file_download_outlined,
              title: 'No exports yet',
              message: 'Create a statement export and track its status here.',
            )
          else
            Column(
              children: List.generate(_exports.length, (index) {
                final export = _exports[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                export.exportId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                'Status: ${export.status}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (export.downloadUrl.isNotEmpty)
                                Text(
                                  export.downloadUrl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppTheme.primaryBlue),
                                ),
                              if (export.errorMessage.isNotEmpty)
                                Text(
                                  export.errorMessage,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppTheme.errorRed),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () => _refreshExport(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
