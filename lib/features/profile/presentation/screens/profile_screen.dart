import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/session/session_manager.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:online_banking_system/features/beneficiaries/presentation/screens/beneficiaries_screen.dart';
import 'package:online_banking_system/features/kyc/presentation/screens/kyc_screen.dart';
import 'package:online_banking_system/features/statements/presentation/screens/statements_screen.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late bool _darkModeEnabled = false;

  Future<void> _openChangePasswordDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
  }

  Future<void> _openDeactivateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _DeactivateAccountDialog(),
    );
  }

  Future<void> _openEditProfileDialog(User? user) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile is still loading.')),
      );
      return;
    }

    await showDialog<User>(
      context: context,
      builder: (_) => _EditProfileDialog(initialUser: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cachedUser = ref.watch(userProvider);
    final currentUserAsync = ref.watch(currentUserProfileProvider);
    final user = currentUserAsync.maybeWhen(
      data: (value) => value,
      orElse: () => cachedUser,
    );
    final fullName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'User';
    final email = user?.email ?? 'No email';
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: BankingAppBar(title: AppStrings.profile, showBackButton: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppTheme.white,
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                children: [
                  AppAvatar(
                    name: fullName,
                    imageUrl: user?.profileImage,
                    size: 100,
                    backgroundColor: AppTheme.softBlue,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    fullName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  SecondaryButton(
                    label: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    onPressed: () => _openEditProfileDialog(user),
                    isEnabled: user != null,
                    width: 170,
                    height: 40,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue,
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radius12,
                            ),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.mfaEnabled == true ||
                                        user?.biometricEnabled == true
                                    ? 'Security protections are active'
                                    : 'Strengthen your protection',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                user?.mfaEnabled == true ||
                                        user?.biometricEnabled == true
                                    ? 'Biometric sign in, alerts and transfer protection are enabled.'
                                    : 'Enable biometric sign in and MFA from Settings or Security Center.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.darkGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            _SettingsSection(
              title: 'Account',
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  label: AppStrings.personalInfo,
                  trailing: user?.phoneNumber.isNotEmpty == true
                      ? user!.phoneNumber
                      : 'Incomplete',
                  onTap: () => _openEditProfileDialog(user),
                ),
                _SettingsTile(
                  icon: Icons.security_outlined,
                  label: AppStrings.security,
                  onTap: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.securityCenter);
                  },
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  label: AppStrings.changePassword,
                  onTap: _openChangePasswordDialog,
                ),
                _SettingsTile(
                  icon: Icons.person_off_outlined,
                  label: 'Deactivate account',
                  onTap: _openDeactivateDialog,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            _SettingsSection(
              title: 'Preferences',
              children: [
                _SettingsTile(
                  icon: Icons.fingerprint,
                  label: AppStrings.enableBiometric,
                  trailing: user?.biometricEnabled == true ? 'On' : 'Off',
                  onTap: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.settings);
                  },
                ),
                _SettingsToggleTile(
                  icon: Icons.dark_mode_outlined,
                  label: AppStrings.darkMode,
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() => _darkModeEnabled = value);
                  },
                ),
                _SettingsTile(
                  icon: Icons.language,
                  label: 'Language',
                  trailing: 'English',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  label: 'Statements',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StatementsScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.people_alt_outlined,
                  label: 'Beneficiaries',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BeneficiariesScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.verified_user_outlined,
                  label: 'KYC Verification',
                  trailing: user?.kycStatus.isNotEmpty == true
                      ? user!.kycStatus
                      : 'pending',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const KycScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            _SettingsSection(
              title: 'Support & Legal',
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  label: AppStrings.faq,
                  onTap: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.faq);
                  },
                ),
                _SettingsTile(
                  icon: Icons.headset_mic_outlined,
                  label: AppStrings.support,
                  onTap: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.support);
                  },
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  label: AppStrings.privacyPolicy,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  label: AppStrings.termsConditions,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: AppStrings.aboutUs,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing20,
              ),
              child: PrimaryButton(
                label: AppStrings.logout,
                isLoading: authState.isLoading,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            try {
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .logout();
                            } catch (_) {}

                            ref.read(userProvider.notifier).state = null;
                            ref.read(transferDraftProvider.notifier).state =
                                const TransferDraft();
                            ref.read(lastTransferProvider.notifier).state =
                                null;
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

                            if (!context.mounted) return;
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacementNamed(AppRoutes.login);
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacing32),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppTheme.spacing20),
          ],
        ),
      ),
    );
  }
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  final User initialUser;

  const _EditProfileDialog({required this.initialUser});

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.initialUser.fullName,
    );
    _phoneController = TextEditingController(
      text: widget.initialUser.phoneNumber,
    );
    _dateOfBirthController = TextEditingController(
      text: _formatDate(widget.initialUser.dateOfBirth),
    );
    _addressLine1Controller = TextEditingController(
      text: widget.initialUser.addressLine1.isNotEmpty
          ? widget.initialUser.addressLine1
          : widget.initialUser.address,
    );
    _addressLine2Controller = TextEditingController(
      text: widget.initialUser.addressLine2,
    );
    _cityController = TextEditingController(text: widget.initialUser.city);
    _stateController = TextEditingController(text: widget.initialUser.state);
    _postalCodeController = TextEditingController(
      text: widget.initialUser.postalCode,
    );
    _countryController = TextEditingController(
      text: widget.initialUser.country,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial =
        DateTime.tryParse(_dateOfBirthController.text) ??
        DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _dateOfBirthController.text = _formatDate(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final updated = await ref
          .read(bankingApiServiceProvider)
          .updateCurrentUser(
            fullName: _fullNameController.text,
            phone: _phoneController.text,
            dateOfBirth: _dateOfBirthController.text,
            addressLine1: _addressLine1Controller.text,
            addressLine2: _addressLine2Controller.text,
            city: _cityController.text,
            state: _stateController.text,
            postalCode: _postalCodeController.text,
            country: _countryController.text,
          );
      ref.read(userProvider.notifier).state = updated;
      await SessionManager.instance.setCurrentUser(updated);
      invalidateLiveBankingData(
        ref,
        includeProfile: true,
        includeAccounts: false,
        includeNotifications: false,
        includeCards: true,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
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
      title: const Text('Edit personal information'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Use at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _dateOfBirthController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date of birth',
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  onTap: _pickDateOfBirth,
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address line 1',
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _addressLine2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address line 2',
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(labelText: 'Postal code'),
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
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
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }

    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isSubmitting = false;
  bool _isRequestingOtp = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    setState(() => _isRequestingOtp = true);
    try {
      final result = await ref
          .read(bankingApiServiceProvider)
          .requestOtp(purpose: 'change_password');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.debugOtp.isNotEmpty
                ? 'OTP sent. Debug code: ${result.debugOtp}'
                : result.message,
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
        setState(() => _isRequestingOtp = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final message = await ref
          .read(bankingApiServiceProvider)
          .changePassword(
            currentPassword: _currentPasswordController.text.trim(),
            newPassword: _newPasswordController.text.trim(),
            otpCode: _otpController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      title: const Text('Change password'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Current password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: 'New password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'Use at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: 'OTP code'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Enter the OTP code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                SecondaryButton(
                  label: 'Request OTP',
                  height: 44,
                  isLoading: _isRequestingOtp,
                  onPressed: _requestOtp,
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
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _DeactivateAccountDialog extends ConsumerStatefulWidget {
  const _DeactivateAccountDialog();

  @override
  ConsumerState<_DeactivateAccountDialog> createState() =>
      _DeactivateAccountDialogState();
}

class _DeactivateAccountDialogState
    extends ConsumerState<_DeactivateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isSubmitting = false;
  bool _isRequestingOtp = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    setState(() => _isRequestingOtp = true);
    try {
      final result = await ref
          .read(bankingApiServiceProvider)
          .requestOtp(purpose: 'account_deactivation');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.debugOtp.isNotEmpty
                ? 'OTP sent. Debug code: ${result.debugOtp}'
                : result.message,
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
        setState(() => _isRequestingOtp = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final message = await ref
          .read(bankingApiServiceProvider)
          .deactivateAccount(
            password: _passwordController.text.trim(),
            otpCode: _otpController.text.trim(),
          );

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
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      title: const Text('Deactivate account'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This action will disable your account. Confirm with password and OTP.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: 'OTP code'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Enter the OTP code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                SecondaryButton(
                  label: 'Request OTP',
                  height: 44,
                  isLoading: _isRequestingOtp,
                  onPressed: _requestOtp,
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
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Deactivate'),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        Container(
          color: AppTheme.white,
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    const Divider(height: 1, color: AppTheme.divider),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 132),
              child: Text(
                trailing!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.primaryBlue,
    );
  }
}
