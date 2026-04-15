import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class SecurityCenterScreen extends ConsumerStatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  ConsumerState<SecurityCenterScreen> createState() =>
      _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends ConsumerState<SecurityCenterScreen> {
  String? _revokingSessionId;

  Future<void> _revokeSession(UserSessionInfo session) async {
    setState(() => _revokingSessionId = session.id);
    try {
      await ref.read(bankingApiServiceProvider).revokeSession(session.id);
      ref.invalidate(sessionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${session.deviceName} has been signed out.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _revokingSessionId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cachedUser = ref.watch(userProvider);
    final currentUserAsync = ref.watch(currentUserProfileProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final user = currentUserAsync.maybeWhen(
      data: (value) => value,
      orElse: () => cachedUser,
    );

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: 'Security Center',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(currentUserProfileProvider);
              ref.invalidate(sessionsProvider);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing24),
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
                    Icons.shield_outlined,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing20),
                Text(
                  'Live Security Snapshot',
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(color: AppTheme.white),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'This screen is now backed by `/users/me` and `/security/sessions` so you can review real protection status and active devices.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          _SecurityCard(
            title: 'Protection Overview',
            children: [
              _StatusTile(
                icon: Icons.mark_email_read_outlined,
                title: 'Email verification',
                subtitle: user?.isEmailVerified == true
                    ? 'Your email is verified.'
                    : 'Finish verification to strengthen account recovery.',
                status: user?.isEmailVerified == true ? 'Verified' : 'Pending',
                color: user?.isEmailVerified == true
                    ? AppTheme.accentGreen
                    : AppTheme.warningOrange,
              ),
              const Divider(),
              _StatusTile(
                icon: Icons.lock_outline_rounded,
                title: 'Multi-factor authentication',
                subtitle: user?.mfaEnabled == true
                    ? 'Extra confirmation is enabled for your profile.'
                    : 'Turn this on in Settings for stronger sign in protection.',
                status: user?.mfaEnabled == true ? 'Enabled' : 'Disabled',
                color: user?.mfaEnabled == true
                    ? AppTheme.accentGreen
                    : AppTheme.warningOrange,
              ),
              const Divider(),
              _StatusTile(
                icon: Icons.fingerprint,
                title: 'Biometric sign in',
                subtitle: user?.biometricEnabled == true
                    ? 'Biometric access is enabled on your profile.'
                    : 'You can enable this from Settings.',
                status: user?.biometricEnabled == true ? 'Enabled' : 'Disabled',
                color: user?.biometricEnabled == true
                    ? AppTheme.accentGreen
                    : AppTheme.warningOrange,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          _SecurityCard(
            title: 'Authenticator App',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.qr_code_2_outlined,
                  color: AppTheme.primaryBlue,
                ),
                title: const Text('Set up TOTP'),
                subtitle: const Text(
                  'Generate a secret, scan it in your authenticator app, then confirm the code.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (_) => const _SetupTotpDialog(),
                  );
                  if (!context.mounted) {
                    return;
                  }
                  ref.invalidate(currentUserProfileProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          _SecurityCard(
            title: 'Active Sessions',
            children: [
              sessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const EmptyState(
                      icon: Icons.devices_other_outlined,
                      title: 'No active sessions',
                      message: 'Signed-in devices will appear here.',
                    );
                  }

                  return Column(
                    children: List.generate(sessions.length, (index) {
                      final session = sessions[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == sessions.length - 1
                              ? 0
                              : AppTheme.spacing12,
                        ),
                        child: _SessionTile(
                          session: session,
                          isRevoking: _revokingSessionId == session.id,
                          onRevoke: session.current
                              ? null
                              : () => _revokeSession(session),
                        ),
                      );
                    }),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Sessions unavailable',
                  message: error.toString(),
                  onRetry: () => ref.invalidate(sessionsProvider),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          _SecurityCard(
            title: 'Emergency Actions',
            children: [
              _ActionTile(
                icon: Icons.credit_card_off_outlined,
                title: 'Freeze all cards',
                subtitle:
                    'Use card controls in the Cards tab for instant action',
                color: AppTheme.warningOrange,
                onTap: () => _showInfo(
                  'Card freeze is managed from the Cards section so you can choose exactly which card to lock.',
                ),
              ),
              const Divider(),
              _ActionTile(
                icon: Icons.password_outlined,
                title: 'Change password',
                subtitle: 'Open the reset flow from Profile when needed',
                color: AppTheme.primaryBlue,
                onTap: () => _showInfo(
                  'Password reset is available from the existing forgot-password flow.',
                ),
              ),
              const Divider(),
              _ActionTile(
                icon: Icons.support_agent_outlined,
                title: 'Report suspicious activity',
                subtitle: 'Create a support ticket for fraud or access issues',
                color: AppTheme.errorRed,
                onTap: () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(AppRoutes.support),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SetupTotpDialog extends ConsumerStatefulWidget {
  const _SetupTotpDialog();

  @override
  ConsumerState<_SetupTotpDialog> createState() => _SetupTotpDialogState();
}

class _SetupTotpDialogState extends ConsumerState<_SetupTotpDialog> {
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  MFASetupDetails? _setup;
  bool _isLoading = false;
  bool _isConfirming = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _startSetup() async {
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your password first.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final setup = await ref.read(bankingApiServiceProvider).setupTotp(
            password: _passwordController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      setState(() => _setup = setup);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirm() async {
    if (_setup == null || _codeController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the authenticator code first.')),
      );
      return;
    }

    setState(() => _isConfirming = true);
    try {
      final status = await ref.read(bankingApiServiceProvider).confirmTotp(
            mfaSetupId: _setup!.mfaSetupId,
            code: _codeController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.mfaEnabled ? 'TOTP enabled successfully.' : status.status,
          ),
        ),
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
        setState(() => _isConfirming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set up authenticator app'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: AppTheme.spacing16),
              SecondaryButton(
                label: 'Generate TOTP secret',
                isLoading: _isLoading,
                onPressed: _startSetup,
              ),
              if (_setup != null) ...[
                const SizedBox(height: AppTheme.spacing16),
                SelectableText(
                  'Secret: ${_setup!.secretBase32}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppTheme.spacing8),
                SelectableText(
                  _setup!.otpauthUrl,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Authenticator code',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConfirming ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (_setup != null)
          FilledButton(
            onPressed: _isConfirming ? null : _confirm,
            child: _isConfirming
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm'),
          ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SecurityCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacing12),
          ...children,
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const _StatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radius12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Text(
          status,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final UserSessionInfo session;
  final bool isRevoking;
  final VoidCallback? onRevoke;

  const _SessionTile({
    required this.session,
    required this.isRevoking,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: session.current
            ? AppTheme.softBlue.withValues(alpha: 0.25)
            : AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.devices_outlined, color: AppTheme.primaryBlue),
              const SizedBox(width: AppTheme.spacing10),
              Expanded(
                child: Text(
                  session.deviceName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (session.current)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing10,
                    vertical: AppTheme.spacing6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Current',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            session.ipAddress.isEmpty
                ? 'IP unavailable'
                : 'IP ${session.ipAddress}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            session.lastSeenAt == null
                ? 'Last seen unavailable'
                : 'Last seen ${_formatDateTime(session.lastSeenAt!)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
          ),
          if (!session.current) ...[
            const SizedBox(height: AppTheme.spacing12),
            Align(
              alignment: Alignment.centerRight,
              child: SecondaryButton(
                label: 'Revoke',
                width: 120,
                height: 42,
                isLoading: isRevoking,
                onPressed: onRevoke ?? () {},
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} • $hour:$minute';
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.spacing10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
