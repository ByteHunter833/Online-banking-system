import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/session/session_manager.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = await ref
          .read(authNotifierProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());

      if (!mounted) return;

      ref.read(userProvider.notifier).state = user;
      await SessionManager.instance.setOnboardingSeen(true);
      if (!mounted) return;
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

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      final error =
          ref.read(authNotifierProvider).error ?? AppStrings.networkError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _openForgotPassword() {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }

  void _openSignUpFlow() {
    Navigator.of(context).pushNamed(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
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
                        Icons.account_balance_rounded,
                        color: AppTheme.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    Text(
                      AppStrings.welcome,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: AppTheme.white),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      'Sign in with your FinanceFlow credentials to load live accounts, cards and transaction history.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    Wrap(
                      spacing: AppTheme.spacing8,
                      runSpacing: AppTheme.spacing8,
                      children: const [
                        _HeroChip(
                          icon: Icons.lock_outline_rounded,
                          label: 'Bearer auth',
                        ),
                        _HeroChip(
                          icon: Icons.sync_alt_rounded,
                          label: 'Live backend data',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius24),
                  border: Border.all(color: AppTheme.divider),
                  boxShadow: AppTheme.softShadow,
                ),
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      'Your credentials will be sent to `/auth/login`, then protected screens will use the access token automatically.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: AppTheme.softBlue,
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Text(
                              'Default backend URL is `http://10.0.2.2:8000`. Override it with `--dart-define=API_BASE_URL=...` if needed.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.darkGrey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            label: AppStrings.loginEmail,
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.fieldRequired;
                              }
                              if (!value.contains('@')) {
                                return AppStrings.invalidEmail;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing20),
                          CustomTextField(
                            controller: _passwordController,
                            label: AppStrings.loginPassword,
                            hint: 'Enter your password',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.fieldRequired;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: AppTheme.spacing8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                            ),
                            Text(
                              AppStrings.rememberMe,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _openForgotPassword,
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    if (authState.error != null) ...[
                      Text(
                        authState.error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                    ],
                    PrimaryButton(
                      label: AppStrings.login,
                      onPressed: _handleLogin,
                      isLoading: authState.isLoading,
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing12,
                          ),
                          child: Text(
                            'OR',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    Row(
                      children: [
                        Expanded(
                          child: _SocialLoginButton(
                            icon: Icons.fingerprint,
                            label: 'Biometric',
                            onPressed: () {
                              final canUseBiometric =
                                  SessionManager.instance.isAuthenticated &&
                                  SessionManager
                                          .instance
                                          .currentUser
                                          ?.biometricEnabled ==
                                      true;
                              if (canUseBiometric) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamed(AppRoutes.biometric);
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Biometric unlock is available after you sign in once and enable it in Settings.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: _SocialLoginButton(
                            icon: Icons.person_add_alt_1_outlined,
                            label: 'Create account',
                            onPressed: _openSignUpFlow,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Center(
                child: GestureDetector(
                  onTap: _openSignUpFlow,
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: AppStrings.signUp,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.white, size: 16),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.white),
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppTheme.spacing8),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
