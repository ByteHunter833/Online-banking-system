class AppRoutes {
  // Auth Routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String biometric = '/biometric';

  // Main Routes
  static const String home = '/home';
  static const String accounts = '/accounts';
  static const String transfer = '/transfer';
  static const String transferReview = '/transfer-review';
  static const String transferSuccess = '/transfer-success';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transaction-detail';
  static const String cards = '/cards';
  static const String cardDetails = '/card-details';
  static const String beneficiaries = '/beneficiaries';
  static const String statements = '/statements';
  static const String kyc = '/kyc';
  static const String adminConsole = '/admin-console';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String securityCenter = '/security-center';
  static const String support = '/support';
  static const String faq = '/faq';
}

class AppStrings {
  // General
  static const String appName = 'FinanceFlow';
  static const String continueStr = 'Continue';
  static const String next = 'Next';
  static const String skip = 'Skip';
  static const String back = 'Back';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String logout = 'Logout';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String noData = 'No data available';

  // Splash Screen
  static const String splashTitle = 'Welcome to $appName';
  static const String splashSubtitle = 'Your financial companion';

  // Onboarding
  static const String onboardingTitle1 = 'Secure Banking';
  static const String onboardingDesc1 =
      'Bank-grade security with 256-bit encryption';
  static const String onboardingTitle2 = 'Instant Transfers';
  static const String onboardingDesc2 = 'Send and receive money in seconds';
  static const String onboardingTitle3 = 'Spending Insights';
  static const String onboardingDesc3 =
      'Track and analyze your spending patterns';
  static const String onboardingTitle4 = 'Smart Notifications';
  static const String onboardingDesc4 =
      'Real-time alerts for your transactions';

  // Authentication
  static const String welcome = 'Welcome Back';
  static const String loginEmail = 'Email or Phone Number';
  static const String loginPassword = 'Password';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';
  static const String rememberMe = 'Remember me';
  static const String signUpSubtitle = 'Create your account in seconds';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String agreeTerms = 'I agree to the Terms & Conditions';
  static const String enterOtp = 'Enter OTP';
  static const String otpSent = 'OTP sent to your email';
  static const String verifyOtp = 'Verify OTP';
  static const String resendOtp = 'Resend OTP';
  static const String useFingerprint = 'Use Fingerprint';
  static const String biometricLogin = 'Biometric Login';

  // Home Screen
  static const String hello = 'Hello';
  static const String currentBalance = 'Current Balance';
  static const String quickActions = 'Quick Actions';
  static const String recentTransactions = 'Recent Transactions';
  static const String viewAll = 'View All';
  static const String sendMoney = 'Send Money';
  static const String receiveMoney = 'Receive Money';
  static const String topUp = 'Top Up';
  static const String payBills = 'Pay Bills';

  // Accounts & Cards
  static const String accounts = 'Accounts';
  static const String myAccounts = 'My Accounts';
  static const String accountDetails = 'Account Details';
  static const String accountNumber = 'Account Number';
  static const String iban = 'IBAN';
  static const String availableBalance = 'Available Balance';
  static const String cards = 'Cards';
  static const String myCards = 'My Cards';
  static const String cardNumber = 'Card Number';
  static const String cardType = 'Card Type';
  static const String expiryDate = 'Expiry Date';
  static const String cvv = 'CVV';

  // Transfer
  static const String transfer = 'Transfer Money';
  static const String enterRecipient = 'Enter Recipient';
  static const String selectRecipient = 'Select Recipient';
  static const String enterAmount = 'Enter Amount';
  static const String selectAccount = 'Select Account';
  static const String addNote = 'Add Note (Optional)';
  static const String reviewTransfer = 'Review Transfer';
  static const String transferConfirm = 'Confirm Transfer';
  static const String transferSuccess = 'Transfer Successful!';
  static const String transferFailed = 'Transfer Failed';
  static const String transferTo = 'Transfer to';
  static const String amount = 'Amount';
  static const String note = 'Note';

  // Transactions
  static const String transactions = 'Transactions';
  static const String transactionHistory = 'Transaction History';
  static const String debit = 'Debit';
  static const String credit = 'Credit';
  static const String search = 'Search transactions...';
  static const String filterBy = 'Filter by';
  static const String all = 'All';
  static const String income = 'Income';
  static const String expenses = 'Expenses';
  static const String pending = 'Pending';
  static const String completed = 'Completed';
  static const String failed = 'Failed';

  // Notifications
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No notifications yet';
  static const String bankingAlerts = 'Banking Alerts';
  static const String securityAlerts = 'Security Alerts';
  static const String promotional = 'Promotional';
  static const String markAllAsRead = 'Mark all as read';

  // Profile & Settings
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String personalInfo = 'Personal Information';
  static const String security = 'Security';
  static const String changePassword = 'Change Password';
  static const String enableBiometric = 'Enable Biometric Login';
  static const String language = 'Language';
  static const String theme = 'Theme';
  static const String darkMode = 'Dark Mode';
  static const String aboutUs = 'About Us';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsConditions = 'Terms & Conditions';
  static const String logout2 = 'Logout';

  // Support
  static const String support = 'Support';
  static const String faq = 'FAQ';
  static const String contactSupport = 'Contact Support';
  static const String liveChat = 'Live Chat';
  static const String reportIssue = 'Report an Issue';
  static const String submitFeedback = 'Submit Feedback';

  // Error Messages
  static const String invalidEmail = 'Please enter a valid email';
  static const String weakPassword = 'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String fieldRequired = 'This field is required';
  static const String networkError = 'Network error. Please try again.';
  static const String unknownError = 'An unknown error occurred';
  static const String insufficientBalance = 'Insufficient balance';
  static const String invalidAmount = 'Please enter a valid amount';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String signupSuccess = 'Account created successfully!';
  static const String passwordChanged = 'Password changed successfully';
  static const String settingsSaved = 'Settings saved successfully';

  // Empty States
  static const String noTransactions = 'No transactions yet';
  static const String noAccounts = 'No accounts available';
  static const String noCards = 'No cards available';
  static const String comingSoon = 'Coming Soon';
}

class AppAssets {
  static const String assetsPath = 'assets/images/';

  // Splash & Onboarding
  static const String logo = '${assetsPath}logo.png';
  static const String onboard1 = '${assetsPath}onboard_secure.png';
  static const String onboard2 = '${assetsPath}onboard_transfer.png';
  static const String onboard3 = '${assetsPath}onboard_analytics.png';
  static const String onboard4 = '${assetsPath}onboard_notifications.png';

  // Icons
  static const String sendIcon = '${assetsPath}send.png';
  static const String receiveIcon = '${assetsPath}receive.png';
  static const String topupIcon = '${assetsPath}topup.png';
  static const String billsIcon = '${assetsPath}bills.png';
}
