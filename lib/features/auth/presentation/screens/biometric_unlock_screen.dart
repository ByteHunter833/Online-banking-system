import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
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
  bool _isCreatingPin = false;
  bool _attemptedBiometric = false;
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!SessionManager.instance.isAuthenticated) {
        _goToLogin();
        return;
      }

      final user = ref.read(userProvider);
      if (SessionManager.instance.hasUnlockPin &&
          user?.biometricEnabled == true) {
        _unlockWithBiometric();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _unlockWithBiometric() async {
    if (_isUnlocking) {
      return;
    }

    setState(() {
      _isUnlocking = true;
      _attemptedBiometric = true;
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
            content: Text('Biometric unlock is unavailable. Use your PIN.'),
          ),
        );
        return;
      }

      final isVerified = await biometric.authenticate();
      if (!mounted) {
        return;
      }

      if (!isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric unlock was not confirmed.')),
        );
        return;
      }

      _completeUnlock();
    } finally {
      if (mounted) {
        setState(() => _isUnlocking = false);
      }
    }
  }

  Future<void> _createPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showMessage('Enter a 4-digit PIN.');
      return;
    }

    if (pin != confirmPin) {
      _showMessage('PIN codes do not match.');
      return;
    }

    setState(() => _isCreatingPin = true);
    try {
      await SessionManager.instance.setUnlockPin(pin);
      if (!mounted) {
        return;
      }
      _completeUnlock();
    } finally {
      if (mounted) {
        setState(() => _isCreatingPin = false);
      }
    }
  }

  void _unlockWithPin() {
    final pin = _pinController.text.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showMessage('Enter your 4-digit PIN.');
      return;
    }

    if (!SessionManager.instance.verifyUnlockPin(pin)) {
      _pinController.clear();
      _showMessage('Incorrect PIN. Try again.');
      return;
    }

    _completeUnlock();
  }

  void _completeUnlock() {
    ref.invalidate(currentUserProfileProvider);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  Future<void> _signOut() async {
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
    _goToLogin();
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isSettingPin = !SessionManager.instance.hasUnlockPin;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(
        title: isSettingPin ? 'Create PIN' : 'Unlock Session',
        showBackButton: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight = constraints.maxHeight > AppTheme.spacing24 * 2
                ? constraints.maxHeight - AppTheme.spacing24 * 2
                : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Center(
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
                          child: Icon(
                            isSettingPin
                                ? Icons.pin_outlined
                                : Icons.lock_open_rounded,
                            size: 52,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        Text(
                          isSettingPin
                              ? 'Create your 4-digit PIN'
                              : 'Unlock FinanceFlow',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          isSettingPin
                              ? 'This PIN protects the current signed-in session. It is removed when you log out.'
                              : user?.fullName.isNotEmpty == true
                              ? 'Enter the PIN for ${user!.fullName}, or use biometrics when available.'
                              : 'Enter your PIN, or use biometrics when available.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        if (isSettingPin)
                          _PinSetupForm(
                            pinController: _pinController,
                            confirmPinController: _confirmPinController,
                            isCreatingPin: _isCreatingPin,
                            onCreatePin: _createPin,
                          )
                        else
                          _PinUnlockForm(
                            pinController: _pinController,
                            biometricEnabled: user?.biometricEnabled == true,
                            attemptedBiometric: _attemptedBiometric,
                            isUnlocking: _isUnlocking,
                            onUnlockWithPin: _unlockWithPin,
                            onUnlockWithBiometric: _unlockWithBiometric,
                          ),
                        const SizedBox(height: AppTheme.spacing12),
                        TextButton(
                          onPressed: _isUnlocking || _isCreatingPin
                              ? null
                              : _signOut,
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PinSetupForm extends StatelessWidget {
  final TextEditingController pinController;
  final TextEditingController confirmPinController;
  final bool isCreatingPin;
  final VoidCallback onCreatePin;

  const _PinSetupForm({
    required this.pinController,
    required this.confirmPinController,
    required this.isCreatingPin,
    required this.onCreatePin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PinTextField(
          controller: pinController,
          label: 'New PIN',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppTheme.spacing16),
        _PinTextField(
          controller: confirmPinController,
          label: 'Confirm PIN',
          onSubmitted: (_) => onCreatePin(),
        ),
        const SizedBox(height: AppTheme.spacing20),
        PrimaryButton(
          label: 'Create PIN',
          icon: Icons.lock_outline_rounded,
          isLoading: isCreatingPin,
          onPressed: onCreatePin,
        ),
      ],
    );
  }
}

class _PinUnlockForm extends StatelessWidget {
  final TextEditingController pinController;
  final bool biometricEnabled;
  final bool attemptedBiometric;
  final bool isUnlocking;
  final VoidCallback onUnlockWithPin;
  final VoidCallback onUnlockWithBiometric;

  const _PinUnlockForm({
    required this.pinController,
    required this.biometricEnabled,
    required this.attemptedBiometric,
    required this.isUnlocking,
    required this.onUnlockWithPin,
    required this.onUnlockWithBiometric,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PinTextField(
          controller: pinController,
          label: 'Session PIN',
          onSubmitted: (_) => onUnlockWithPin(),
        ),
        const SizedBox(height: AppTheme.spacing20),
        PrimaryButton(
          label: 'Unlock with PIN',
          icon: Icons.lock_open_rounded,
          onPressed: onUnlockWithPin,
        ),
        if (biometricEnabled) ...[
          const SizedBox(height: AppTheme.spacing12),
          SecondaryButton(
            label: attemptedBiometric ? 'Try biometric again' : 'Use biometric',
            icon: Icons.fingerprint_rounded,
            isLoading: isUnlocking,
            onPressed: onUnlockWithBiometric,
          ),
        ],
      ],
    );
  }
}

class _PinTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _PinTextField({
    required this.controller,
    required this.label,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      obscureText: true,
      maxLength: 4,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        letterSpacing: 8,
        fontWeight: FontWeight.w800,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: const Icon(Icons.password_rounded),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
