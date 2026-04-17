import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/session/session_manager.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:online_banking_system/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:online_banking_system/features/auth/presentation/screens/login_screen.dart';
import 'package:online_banking_system/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:online_banking_system/features/auth/presentation/screens/biometric_unlock_screen.dart';
import 'package:online_banking_system/features/cards/presentation/screens/cards_screen.dart';
import 'package:online_banking_system/features/beneficiaries/presentation/screens/beneficiaries_screen.dart';
import 'package:online_banking_system/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:online_banking_system/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:online_banking_system/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:online_banking_system/features/profile/presentation/screens/profile_screen.dart';
import 'package:online_banking_system/features/kyc/presentation/screens/kyc_screen.dart';
import 'package:online_banking_system/features/security/presentation/screens/security_center_screen.dart';
import 'package:online_banking_system/features/settings/presentation/screens/settings_screen.dart';
import 'package:online_banking_system/features/splash/presentation/screens/splash_screen.dart';
import 'package:online_banking_system/features/statements/presentation/screens/statements_screen.dart';
import 'package:online_banking_system/features/support/presentation/screens/faq_screen.dart';
import 'package:online_banking_system/features/support/presentation/screens/support_screen.dart';
import 'package:online_banking_system/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:online_banking_system/features/transfer/presentation/screens/transfer_review_screen.dart';
import 'package:online_banking_system/features/transfer/presentation/screens/transfer_screen.dart';
import 'package:online_banking_system/features/transfer/presentation/screens/transfer_success_screen.dart';
import 'package:online_banking_system/shared/providers/app_providers.dart';

class FinanceFlowApp extends ConsumerStatefulWidget {
  const FinanceFlowApp({super.key});

  @override
  ConsumerState<FinanceFlowApp> createState() => _FinanceFlowAppState();
}

class _FinanceFlowAppState extends ConsumerState<FinanceFlowApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  Timer? _sessionPoller;
  StreamSubscription<void>? _sessionExpiredSubscription;
  bool _isCheckingSession = false;
  bool _isHandlingSessionExpired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionExpiredSubscription = SessionManager.instance.sessionExpiredStream
        .listen((_) {
          unawaited(
            _forceAuthorization('Your session has expired. Please sign in.'),
          );
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionPoller?.cancel();
    _sessionExpiredSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkRemoteSession());
    }
  }

  void _startSessionMonitor() {
    if (_sessionPoller != null) {
      return;
    }

    _sessionPoller = Timer.periodic(
      const Duration(seconds: 20),
      (_) => unawaited(_checkRemoteSession()),
    );
    unawaited(_checkRemoteSession());
  }

  void _stopSessionMonitor() {
    _sessionPoller?.cancel();
    _sessionPoller = null;
  }

  Future<void> _checkRemoteSession() async {
    if (_isCheckingSession || !SessionManager.instance.isAuthenticated) {
      return;
    }

    _isCheckingSession = true;
    try {
      final sessions = await ref
          .read(bankingApiServiceProvider)
          .getSessions(includeRevoked: true);
      final hasCurrentActiveSession = sessions.any(
        (session) => session.current && session.isActive,
      );

      if (!hasCurrentActiveSession) {
        await _forceAuthorization(
          'This session was revoked from another device.',
        );
      }
    } catch (_) {
      if (!SessionManager.instance.isAuthenticated) {
        await _forceAuthorization('Your session has expired. Please sign in.');
      }
    } finally {
      _isCheckingSession = false;
    }
  }

  Future<void> _forceAuthorization(String message) async {
    if (_isHandlingSessionExpired) {
      return;
    }

    _isHandlingSessionExpired = true;
    _stopSessionMonitor();
    await SessionManager.instance.clear();
    _resetSessionState();

    if (mounted) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
      _scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    _isHandlingSessionExpired = false;
  }

  void _resetSessionState() {
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
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (isAuthenticated) {
      _startSessionMonitor();
    } else {
      _stopSessionMonitor();
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'FinanceFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreenParticles(),
      routes: {
        AppRoutes.splash: (context) => const SplashScreenParticles(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.biometric: (context) => const BiometricUnlockScreen(),
        AppRoutes.signup: (context) => const SignUpScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.home: (context) => const MainNavigationScreen(),
        AppRoutes.accounts: (context) => const AccountsScreen(),
        AppRoutes.cards: (context) => const CardsScreen(),
        AppRoutes.beneficiaries: (context) => const BeneficiariesScreen(),
        AppRoutes.statements: (context) => const StatementsScreen(),
        AppRoutes.kyc: (context) => const KycScreen(),
        AppRoutes.notifications: (context) => const NotificationsScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.securityCenter: (context) => const SecurityCenterScreen(),
        AppRoutes.transfer: (context) => const TransferScreen(),
        AppRoutes.transferReview: (context) => const TransferReviewScreen(),
        AppRoutes.transferSuccess: (context) => const TransferSuccessScreen(),
        AppRoutes.transactions: (context) => const TransactionsScreen(),
        AppRoutes.support: (context) => const SupportScreen(),
        AppRoutes.faq: (context) => const FAQScreen(),
      },
    );
  }
}
