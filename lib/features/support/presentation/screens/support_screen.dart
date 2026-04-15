import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  Future<void> _showCreateTicketDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final created = await showDialog<SupportTicket>(
      context: context,
      builder: (_) => const _CreateTicketDialog(),
    );
    if (!context.mounted || created == null) return;

    ref.invalidate(supportTicketsProvider);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Support ticket created.')));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupportConversationScreen(ticket: created),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(supportTicketsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: AppStrings.support,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => _showCreateTicketDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(supportTicketsProvider),
          ),
        ],
      ),
      body: ticketsAsync.when(
        data: (tickets) {
          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing20),
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
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                      ),
                      child: const Icon(
                        Icons.support_agent_outlined,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    Text(
                      'Help That Stays Connected',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: AppTheme.white),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      'This screen now reads your real `/support` tickets and lets you continue each conversation from the app.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    Wrap(
                      spacing: AppTheme.spacing8,
                      runSpacing: AppTheme.spacing8,
                      children: [
                        SecondaryButton(
                          label: 'Create ticket',
                          width: 150,
                          height: 44,
                          onPressed: () =>
                              _showCreateTicketDialog(context, ref),
                        ),
                        PrimaryButton(
                          label: AppStrings.faq,
                          width: 120,
                          height: 44,
                          onPressed: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(AppRoutes.faq);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing20),
              if (tickets.isEmpty)
                EmptyState(
                  icon: Icons.mark_email_read_outlined,
                  title: 'No support tickets yet',
                  message:
                      'Create your first ticket and it will appear here with live status updates.',
                  onRetry: () => _showCreateTicketDialog(context, ref),
                )
              else
                Column(
                  children: List.generate(tickets.length, (index) {
                    final ticket = tickets[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.spacing12,
                      ),
                      child: _TicketTile(
                        ticket: ticket,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SupportConversationScreen(ticket: ticket),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
            ],
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          itemCount: 4,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
            child: LoadingShimmer(
              height: 120,
              borderRadius: BorderRadius.circular(AppTheme.radius20),
            ),
          ),
        ),
        error: (error, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Support unavailable',
            message: error.toString(),
            onRetry: () => ref.invalidate(supportTicketsProvider),
          ),
        ),
      ),
    );
  }
}

class SupportConversationScreen extends ConsumerStatefulWidget {
  final SupportTicket ticket;

  const SupportConversationScreen({super.key, required this.ticket});

  @override
  ConsumerState<SupportConversationScreen> createState() =>
      _SupportConversationScreenState();
}

class _SupportConversationScreenState
    extends ConsumerState<SupportConversationScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least 2 characters.')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await ref
          .read(bankingApiServiceProvider)
          .createSupportMessage(ticketId: widget.ticket.id, message: message);
      _messageController.clear();
      ref.invalidate(supportMessagesProvider(widget.ticket.id));
      ref.invalidate(supportTicketsProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(supportMessagesProvider(widget.ticket.id));

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: widget.ticket.subject,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(supportMessagesProvider(widget.ticket.id));
              ref.invalidate(supportTicketsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing20,
              AppTheme.spacing20,
              AppTheme.spacing20,
              AppTheme.spacing12,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radius20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppTheme.spacing8,
                    runSpacing: AppTheme.spacing8,
                    children: [
                      _TicketBadge(
                        label: widget.ticket.status,
                        color: _statusColor(widget.ticket.status),
                      ),
                      _TicketBadge(
                        label: widget.ticket.priority,
                        color: _priorityColor(widget.ticket.priority),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  Text(
                    widget.ticket.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (widget.ticket.adminNote.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    Text(
                      'Admin note: ${widget.ticket.adminNote}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const EmptyState(
                    icon: Icons.forum_outlined,
                    title: 'No replies yet',
                    message: 'New support replies will appear in this thread.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.spacing12,
                      ),
                      child: _SupportMessageBubble(message: message),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing20,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  child: LoadingShimmer(
                    height: 84,
                    borderRadius: BorderRadius.circular(AppTheme.radius16),
                  ),
                ),
              ),
              error: (error, _) => Center(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Conversation unavailable',
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(supportMessagesProvider(widget.ticket.id)),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write a message to support',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radius16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  PrimaryButton(
                    label: 'Send',
                    width: 96,
                    height: 52,
                    isLoading: _isSending,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
      case 'closed':
        return AppTheme.accentGreen;
      case 'in_progress':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.warningOrange;
    }
  }

  static Color _priorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return AppTheme.errorRed;
      case 'high':
        return AppTheme.warningOrange;
      case 'low':
        return AppTheme.accentGreen;
      default:
        return AppTheme.primaryBlue;
    }
  }
}

class _CreateTicketDialog extends ConsumerStatefulWidget {
  const _CreateTicketDialog();

  @override
  ConsumerState<_CreateTicketDialog> createState() =>
      _CreateTicketDialogState();
}

class _CreateTicketDialogState extends ConsumerState<_CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _priority = 'medium';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final ticket = await ref
          .read(bankingApiServiceProvider)
          .createSupportTicket(
            subject: _subjectController.text.trim(),
            message: _messageController.text.trim(),
            priority: _priority,
          );
      if (!mounted) return;
      Navigator.of(context).pop(ticket);
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
      title: const Text('Create support ticket'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) {
                    if (value == null || value.trim().length < 4) {
                      return 'Use at least 4 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _priority = value);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _messageController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Describe the issue',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Use at least 10 characters';
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
          child: const Text('Cancel'),
        ),
        TextButton(
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

class _TicketTile extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const _TicketTile({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radius20),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                _TicketBadge(
                  label: ticket.status,
                  color: SupportConversationScreenStateColors.status(
                    ticket.status,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              ticket.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGrey),
            ),
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                _TicketBadge(
                  label: ticket.priority,
                  color: SupportConversationScreenStateColors.priority(
                    ticket.priority,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(ticket.updatedAt),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppTheme.mediumGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}

class _TicketBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TicketBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing10,
        vertical: AppTheme.spacing6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SupportMessageBubble extends StatelessWidget {
  final SupportMessage message;

  const _SupportMessageBubble({required this.message});

  bool get _isCustomerMessage => message.authorRole == 'customer';

  @override
  Widget build(BuildContext context) {
    final bubbleColor = _isCustomerMessage
        ? AppTheme.primaryBlue
        : AppTheme.white;
    final textColor = _isCustomerMessage ? AppTheme.white : AppTheme.darkGrey;

    return Align(
      alignment: _isCustomerMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(AppTheme.radius20),
            border: _isCustomerMessage
                ? null
                : Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.authorRole.replaceAll('_', ' '),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                message.message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                _formatTime(message.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor.withValues(alpha: 0.74),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} • $hour:$minute';
  }
}

class SupportConversationScreenStateColors {
  static Color status(String status) {
    switch (status) {
      case 'resolved':
      case 'closed':
        return AppTheme.accentGreen;
      case 'in_progress':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.warningOrange;
    }
  }

  static Color priority(String priority) {
    switch (priority) {
      case 'urgent':
        return AppTheme.errorRed;
      case 'high':
        return AppTheme.warningOrange;
      case 'low':
        return AppTheme.accentGreen;
      default:
        return AppTheme.primaryBlue;
    }
  }
}
