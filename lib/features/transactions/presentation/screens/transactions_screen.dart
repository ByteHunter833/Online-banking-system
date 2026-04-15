import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final query = TransactionsQuery(
      status: _selectedFilter == 'all' ? null : _selectedFilter,
      page: 1,
      pageSize: 100,
    );
    final transactionsAsync = ref.watch(paginatedTransactionsProvider(query));

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: AppStrings.transactionHistory,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.invalidate(paginatedTransactionsProvider(query)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: AppStrings.all,
                    isSelected: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: AppStrings.completed,
                    isSelected: _selectedFilter == 'completed',
                    onTap: () => setState(() => _selectedFilter = 'completed'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: AppStrings.pending,
                    isSelected: _selectedFilter == 'pending',
                    onTap: () => setState(() => _selectedFilter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: AppStrings.failed,
                    isSelected: _selectedFilter == 'failed',
                    onTap: () => setState(() => _selectedFilter = 'failed'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Expanded(
            child: transactionsAsync.when(
              data: (page) {
                var filteredTransactions = page.items;
                if (_searchQuery.isNotEmpty) {
                  filteredTransactions = filteredTransactions
                      .where(
                        (item) =>
                            item.recipientName.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            item.description.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            item.referenceNumber.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                      )
                      .toList();
                }

                if (filteredTransactions.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: AppStrings.noTransactions,
                    message: 'No transactions found for your selection',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.spacing12,
                      ),
                      child: Text(
                        'Showing ${filteredTransactions.length} of ${page.total} transactions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    ...List.generate(filteredTransactions.length, (index) {
                      final transaction = filteredTransactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spacing12,
                        ),
                        child: TransactionTile(
                          title: transaction.recipientName,
                          subtitle: transaction.description,
                          amount: transaction.amount,
                          currency: transaction.currency,
                          isDebit: transaction.isDebit,
                          status: transaction.transactionStatus,
                          category: transaction.category,
                          date: transaction.transactionDate,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailScreen(
                                  transaction: transaction,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  child: LoadingShimmer(
                    height: 92,
                    borderRadius: BorderRadius.circular(AppTheme.radius16),
                  ),
                ),
              ),
              error: (error, stackTrace) => Center(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Transactions unavailable',
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(paginatedTransactionsProvider(query)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radius20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSelected ? AppTheme.white : AppTheme.darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
