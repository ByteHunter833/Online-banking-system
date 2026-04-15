import 'package:flutter/material.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
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

class FinanceFlowApp extends StatelessWidget {
  const FinanceFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
