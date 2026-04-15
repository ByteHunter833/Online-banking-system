import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/security/biometric_auth_service.dart';
import 'package:online_banking_system/core/session/session_manager.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

class BiometricUnlockScreen extends ConsumerStatefulWidget {
  const BiometricUnlockScreen({super.key});

  @override
  ConsumerState<BiometricUnlockScreen> createState() =>
      _BiometricUnlockScreenState();
}

class _BiometricUnlockScreenState extends ConsumerState<BiometricUnlockScreen> {
  bool _isUnlocking = false;
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _unlock();
    });
  }

  Future<void> _unlock() async {
    setState(() {
      _isUnlocking = true;
      _attempted = true;
    });

    try {
      final biometric = ref.read(biometricAuthServiceProvider);
      final canAuthenticate = await biometric.canAuthenticate();
      if (!mounted) {
        return;
      }

      if (!canAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication is not available here.'),
          ),
        );
        return;
      }

      final isVerified = await biometric.authenticate();
      if (!mounted) {
        return;
      }

      if (!isVerified) {
        return;
      }

      ref.invalidate(currentUserProfileProvider);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _isUnlocking = false);
      }
    }
  }

  Future<void> _usePasswordInstead() async {
    await SessionManager.instance.clear();
    ref.read(userProvider.notifier).state = null;
    ref.read(transferDraftProvider.notifier).state = const TransferDraft();
    ref.read(lastTransferProvider.notifier).state = null;
    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(dashboardOverviewProvider);
    ref.invalidate(accountsProvider);
    ref.invalidate(beneficiariesProvider);
    ref.invalidate(cardsProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(unreadNotificationsProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(notificationPreferencesProvider);
    ref.invalidate(sessionsProvider);
    ref.invalidate(supportTicketsProvider);
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const BankingAppBar(title: 'Biometric Unlock'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(AppTheme.spacing24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radius24),
              border: Border.all(color: AppTheme.divider),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  decoration: BoxDecoration(
                    color: AppTheme.softBlue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    size: 52,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing20),
                Text(
                  'Unlock FinanceFlow',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  user?.fullName.isNotEmpty == true
                      ? 'Authenticate as ${user!.fullName} to continue.'
                      : 'Authenticate with biometrics to continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing24),
                PrimaryButton(
                  label: _attempted ? 'Try again' : 'Unlock now',
                  isLoading: _isUnlocking,
                  icon: Icons.lock_open_rounded,
                  onPressed: _unlock,
                ),
                const SizedBox(height: AppTheme.spacing12),
                SecondaryButton(
                  label: 'Use password instead',
                  onPressed: _usePasswordInstead,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
