import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/session/session_manager.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _quickPreviewEnabled = false;
  String? _securityUpdateKey;
  String? _notificationUpdateKey;

  Future<void> _updateUserSetting({
    required String key,
    required Future<User> Function() action,
    required String successMessage,
  }) async {
    setState(() => _securityUpdateKey = key);
    try {
      final user = await action();
      ref.read(userProvider.notifier).state = user;
      await SessionManager.instance.setCurrentUser(user);
      ref.invalidate(currentUserProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _securityUpdateKey = null);
      }
    }
  }

  Future<void> _updateNotificationSetting({
    required String key,
    required NotificationPreferences preferences,
    required bool value,
  }) async {
    setState(() => _notificationUpdateKey = key);
    try {
      final api = ref.read(bankingApiServiceProvider);

      switch (key) {
        case 'transaction':
          await api.updateNotificationPreferences(
            transaction: preferences.transaction.copyWith(inApp: value),
          );
          break;
        case 'security_alert':
          await api.updateNotificationPreferences(
            securityAlert: preferences.securityAlert.copyWith(inApp: value),
          );
          break;
        case 'support':
          await api.updateNotificationPreferences(
            support: preferences.support.copyWith(inApp: value),
          );
          break;
        case 'system':
          await api.updateNotificationPreferences(
            system: preferences.system.copyWith(inApp: value),
          );
          break;
      }

      ref.invalidate(notificationPreferencesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification preferences updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _notificationUpdateKey = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cachedUser = ref.watch(userProvider);
    final currentUserAsync = ref.watch(currentUserProfileProvider);
    final notificationPreferencesAsync = ref.watch(
      notificationPreferencesProvider,
    );
    final user = currentUserAsync.maybeWhen(
      data: (value) => value,
      orElse: () => cachedUser,
    );

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const BankingAppBar(title: AppStrings.settings),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radius24),
                boxShadow: AppTheme.softShadow,
              ),
              padding: const EdgeInsets.all(AppTheme.spacing24),
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
                      Icons.tune_rounded,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  Text(
                    'Settings',
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(color: AppTheme.white),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'These controls are now backed by your banking API, so changes stay in sync across devices.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            _SettingsCard(
              title: 'Security',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.shield_outlined,
                    color: AppTheme.primaryBlue,
                  ),
                  title: const Text('Security Center'),
                  subtitle: const Text(
                    'Sessions, trusted devices and emergency controls',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.securityCenter);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  value: user?.biometricEnabled ?? false,
                  onChanged: user == null || _securityUpdateKey != null
                      ? null
                      : (value) => _updateUserSetting(
                          key: 'biometric',
                          action: () => ref
                              .read(bankingApiServiceProvider)
                              .updateCurrentUser(biometricEnabled: value),
                          successMessage: value
                              ? 'Biometric sign in enabled.'
                              : 'Biometric sign in disabled.',
                        ),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Biometric sign in'),
                  subtitle: const Text('Save this preference to your profile'),
                  activeThumbColor: AppTheme.primaryBlue,
                ),
                const Divider(),
                SwitchListTile(
                  value: user?.mfaEnabled ?? false,
                  onChanged: user == null || _securityUpdateKey != null
                      ? null
                      : (value) => _updateUserSetting(
                          key: 'mfa',
                          action: () => ref
                              .read(bankingApiServiceProvider)
                              .updateCurrentUser(mfaEnabled: value),
                          successMessage: value
                              ? 'Multi-factor authentication enabled.'
                              : 'Multi-factor authentication disabled.',
                        ),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Multi-factor authentication'),
                  subtitle: const Text('Syncs with `/users/update`'),
                  activeThumbColor: AppTheme.primaryBlue,
                ),
                const Divider(),
                SwitchListTile(
                  value: _quickPreviewEnabled,
                  onChanged: (value) {
                    setState(() => _quickPreviewEnabled = value);
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Balance quick preview'),
                  subtitle: const Text('This preference stays on this device'),
                  activeThumbColor: AppTheme.primaryBlue,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            _SettingsCard(
              title: 'Notifications',
              children: [
                notificationPreferencesAsync.when(
                  data: (preferences) => Column(
                    children: [
                      _NotificationSwitchTile(
                        title: 'Transaction alerts',
                        subtitle: 'In-app updates for transfers and payments',
                        value: preferences.transaction.inApp,
                        enabled: _notificationUpdateKey == null,
                        onChanged: (value) => _updateNotificationSetting(
                          key: 'transaction',
                          preferences: preferences,
                          value: value,
                        ),
                      ),
                      const Divider(),
                      _NotificationSwitchTile(
                        title: 'Security alerts',
                        subtitle: 'Suspicious login or risk notifications',
                        value: preferences.securityAlert.inApp,
                        enabled: _notificationUpdateKey == null,
                        onChanged: (value) => _updateNotificationSetting(
                          key: 'security_alert',
                          preferences: preferences,
                          value: value,
                        ),
                      ),
                      const Divider(),
                      _NotificationSwitchTile(
                        title: 'Support updates',
                        subtitle: 'Ticket replies and status changes',
                        value: preferences.support.inApp,
                        enabled: _notificationUpdateKey == null,
                        onChanged: (value) => _updateNotificationSetting(
                          key: 'support',
                          preferences: preferences,
                          value: value,
                        ),
                      ),
                      const Divider(),
                      _NotificationSwitchTile(
                        title: 'System notices',
                        subtitle: 'General service and maintenance messages',
                        value: preferences.system.inApp,
                        enabled: _notificationUpdateKey == null,
                        onChanged: (value) => _updateNotificationSetting(
                          key: 'system',
                          preferences: preferences,
                          value: value,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: 'Notification settings unavailable',
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(notificationPreferencesProvider),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            _SettingsCard(
              title: 'Help',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.help_outline_rounded,
                    color: AppTheme.primaryBlue,
                  ),
                  title: const Text('FAQ'),
                  subtitle: const Text('Find quick answers'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.faq);
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.headset_mic_outlined,
                    color: AppTheme.primaryBlue,
                  ),
                  title: const Text('Support'),
                  subtitle: const Text(
                    'Create tickets and continue conversations',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.support);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      activeThumbColor: AppTheme.primaryBlue,
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radius20),
        border: Border.all(color: AppTheme.divider),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacing8),
          ...children,
        ],
      ),
    );
  }
}
