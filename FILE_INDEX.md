# Project File Structure & Reference

Complete guide to every file in FinanceFlow banking app.

## 📚 Documentation Files

| File                                                 | Purpose                                | When to Read                  |
| ---------------------------------------------------- | -------------------------------------- | ----------------------------- |
| [README.md](README.md)                               | **Main project overview**              | Starting project overview     |
| [QUICK_START.md](QUICK_START.md)                     | **Get app running in 5 minutes**       | Before first run              |
| [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)   | **Feature-by-feature breakdown**       | Understanding what's built    |
| [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md) | **Connect FastAPI backend**            | When integrating backend      |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md)             | **Solutions for common issues**        | When something breaks         |
| [ROADMAP.md](ROADMAP.md)                             | **Feature status & development order** | Planning next steps           |
| [schema.md](schema.md)                               | **Data models documentation**          | Understanding data structures |
| [FILE_INDEX.md](FILE_INDEX.md)                       | **This file - all files explained**    | Navigating codebase           |

---

## 🏗️ Core Application Files

### Entry Point

```
lib/main.dart (280 lines)
├─ Purpose: App entry point, routing configuration
├─ Key Components:
│  ├─ void main() - Runs ProviderScope wrapper
│  ├─ MaterialApp setup with theme
│  ├─ 14 named routes configuration
│  └─ Home screen: SplashScreen
├─ When to modify:
│  ├─ Adding new routes
│  ├─ Changing theme
│  └─ Modifying initial screen
└─ Related files:
   ├─ lib/constants/app_constants.dart
   └─ lib/theme/app_theme.dart
```

---

## 🎨 Theme & Styling

### Theme Configuration

````
lib/theme/app_theme.dart (220 lines)
├─ Purpose: Centralized design system (colors, fonts, spacing)
├─ Key Classes:
│  ├─ AppTheme - Main theme provider
│  ├─ AppColors - All color constants
│  ├─ AppTypography - Font sizes & weights
│  └─ AppSpacing - Spacing constants
├─ Key Features:
│  ├─ 5+ primary colors with variations
│  ├─ Complete TextTheme hierarchy
│  ├─ Button and input decoration themes
│  ├─ Consistent spacing scale (4px-based)
│  └─ Border radius constants
├─ When to modify:
│  ├─ Changing brand colors
│  ├─ Updating typography
│  ├─ Adjusting spacing
│  └─ Adding dark theme
└─ Example Usage:
   ```dart
   Container(color: AppTheme.primaryBlue)
   Text('Hello', style: Theme.of(context).textTheme.titleLarge)
   Padding(padding: EdgeInsets.all(AppSpacing.medium16))
````

```

---

## 📋 Constants & Configuration

### App Constants
```

lib/constants/app_constants.dart (320 lines)
├─ Purpose: Centralized routes, strings, and assets
├─ Key Classes:
│ ├─ AppRoutes - All 14 named routes
│ ├─ AppStrings - 100+ localization strings
│ └─ AppAssets - Asset paths
├─ Routes Defined:
│ ├─ Auth: /splash, /onboarding, /login, /signup, /forgot-password, /otp, /biometric
│ ├─ Main: /home, /accounts, /transfer, /transfer-review, /transfer-success
│ └─ Additional: /transactions, /cards, /notifications, /profile, /settings, /support, /faq
├─ When to modify:
│ ├─ Adding new screens
│ ├─ Updating app text
│ ├─ Adding new routes
│ └─ Changing asset paths
└─ Example Usage:

```dart
Navigator.pushNamed(context, AppRoutes.home);
Text(AppStrings.welcomeMessage);
String assetPath = AppAssets.logoImage;
```

```

---

## 🧮 Data Models

### Banking Models
```

lib/models/banking_models.dart (450 lines)
├─ Purpose: All data model definitions with JSON serialization
├─ Models Defined:
│ ├─ User (firstName, lastName, email, phone, profile, DOB, address)
│ ├─ Account (type, balance, availableBalance, creditLimit, IBAN, routing)
│ ├─ BankCard (cardNumber, expiry, CVV, type, frozen, limits)
│ ├─ Transaction (type, status, amount, currency, sender, recipient, dates, fee)
│ ├─ AppNotification (title, message, type, read, metadata)
│ └─ Recipient (name, contact, account, IBAN, bank, favorite)
├─ Key Features:
│ ├─ fromJson() for API deserialization
│ ├─ toJson() for API serialization
│ ├─ Enum types for status/type
│ └─ Default values for optional fields
├─ API Ready:
│ ├─ Structure matches API response
│ ├─ Field names match API (with @JsonKey support)
│ └─ Null-safety handled
└─ Example Usage:

```dart
final user = User.fromJson(jsonData);
final json = user.toJson();
final status = Transaction.Status.completed;
```

```

---

## 💾 Data Layer

### Mock Data Service
```

lib/data/mock_data_service.dart (400 lines)
├─ Purpose: Provides realistic mock data for testing without backend
├─ Services Provided:
│ ├─ getMockUser() - Complete user profile
│ ├─ getMockAccounts() - 3 account types (Current, Savings, Credit)
│ ├─ getMockCards() - 3 cards (Visa debit, Mastercard credit, Virtual)
│ ├─ getMockTransactions() - 7 transactions with various statuses
│ ├─ getMockRecipients() - 3 saved recipients
│ └─ getMockNotifications() - 5 categorized notifications
├─ Data Features:
│ ├─ Realistic amounts and balances
│ ├─ Various transaction statuses
│ ├─ Proper date formatting
│ ├─ Multiple account types
│ └─ Virtual card support
├─ When to modify:
│ ├─ Changing mock data structure
│ ├─ Before API integration (if needed for testing)
│ └─ Adding new data types
├─ When to replace:
│ ├─ Integrating with backend API
│ ├─ Connecting to real database
│ └─ Making production build
└─ Example Usage:

```dart
final user = MockDataService.getMockUser();
final accounts = MockDataService.getMockAccounts();
```

```

### Repository Directory (To be created)
```

lib/data/repositories/ (PLACEHOLDER - To be created during API integration)
├─ Purpose: Abstract data fetching (mock/API)
├─ Planned Files:
│ ├─ auth_repository.dart - Login, signup, token refresh
│ ├─ user_repository.dart - User profile, personal info
│ ├─ account_repository.dart - Account list, details
│ ├─ card_repository.dart - Card management
│ ├─ transaction_repository.dart - Transaction history
│ ├─ transfer_repository.dart - Money transfer
│ ├─ recipient_repository.dart - Saved recipients
│ └─ notification_repository.dart - Notifications
└─ Implementation Guide:
See [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md)

```

---

## 🔄 State Management (Riverpod)

### App Providers
```

lib/providers/app_providers.dart (80 lines)
├─ Purpose: Riverpod providers for reactive state management
├─ Providers for Data:
│ ├─ userProvider - Current authenticated user
│ ├─ accountsProvider - User's accounts list
│ ├─ primaryAccountProvider - Main account (derived)
│ ├─ cardsProvider - User's cards
│ ├─ transactionsProvider - Transaction history
│ ├─ recipientsProvider - Saved recipients
│ └─ notificationsProvider - All notifications
├─ Providers for UI State:
│ ├─ loadingProvider - Global loading state
│ ├─ errorProvider - Global error messages
│ ├─ hideBalanceProvider - Balance visibility toggle
│ └─ selectedTabProvider - Current tab index
├─ Providers for Features:
│ ├─ transferAmountProvider - Transfer input amount
│ ├─ transferRecipientProvider - Selected recipient
│ ├─ transferFromAccountProvider - From account
│ └─ searchQueryProvider - Search text
├─ Provider Types:
│ ├─ FutureProvider - For async data (API calls)
│ ├─ StateProvider - For simple state mutations
│ └─ StateNotifierProvider - For complex state
├─ When to modify:
│ ├─ Adding new data types
│ ├─ Creating new features
│ ├─ Changing state logic
│ └─ Adding filters/search
└─ Example Usage:

```dart
final user = ref.watch(userProvider);
ref.refresh(userProvider);  // Reload data
user.when(
  data: (u) => Text(u.name),
  loading: () => Loading(),
  error: (e, st) => ErrorWidget(),
);
```

```

---

## 🎨 Reusable Widgets

### Widgets Library
```

lib/widgets/reusable_widgets.dart (650 lines)
├─ Purpose: Shared UI components used across multiple screens
├─ Input Widgets:
│ ├─ CustomTextField (TextFieldWidget)
│ │ ├─ Text input with validation
│ │ ├─ Prefix/suffix icons
│ │ ├─ Password visibility toggle
│ │ ├─ Error message display
│ │ └─ Focus state handling
│ │
│ └─ OTPInputField
│ ├─ 6-digit code input
│ ├─ Auto-focus between fields
│ ├─ Copy from clipboard support
│ └─ Paste functionality
├─ Button Widgets:
│ ├─ PrimaryButton
│ │ ├─ Main CTA button (blue)
│ │ ├─ Loading spinner
│ │ ├─ Disabled state
│ │ └─ Full width option
│ │
│ ├─ SecondaryButton
│ │ ├─ Alternative action (outlined)
│ │ ├─ Same features as primary
│ │ └─ Transparent background
│ │
│ └─ QuickActionButton
│ ├─ Icon + label
│ ├─ Grid-friendly
│ └─ Home screen quick actions
├─ Display Widgets:
│ ├─ BalanceCard
│ │ ├─ Account balance display
│ │ ├─ Hide/show toggle
│ │ ├─ Gradient background
│ │ ├─ Multiple account types
│ │ └─ Account number display
│ │
│ ├─ TransactionTile
│ │ ├─ Transaction list item
│ │ ├─ Status-based colors
│ │ ├─ Amount and date
│ │ ├─ Type indicators (in/out)
│ │ └─ Recipient/sender name
│ │
│ └─ BankingAppBar
│ ├─ Custom app bar
│ ├─ Back button
│ ├─ Title
│ ├─ Action buttons
│ └─ Flexible height
├─ State Widgets:
│ ├─ EmptyState
│ │ ├─ Custom icon
│ │ ├─ Title and message
│ │ ├─ Optional retry button
│ │ └─ Full screen state
│ │
│ └─ LoadingShimmer
│ ├─ Animated loading placeholder
│ ├─ Shimmer effect
│ ├─ Customizable dimensions
│ └─ Multiple items support
├─ When to modify:
│ ├─ Changing widget styles
│ ├─ Adding new input types
│ ├─ Adjusting animations
│ └─ Adding new states
└─ Example Usage:

```dart
CustomTextField(hint: "Enter email", onChanged: (v) {})
PrimaryButton(label: "Login", onPressed: () {})
BalanceCard(balance: user.balance)
TransactionTile(transaction: tx)
EmptyState(icon: Icons.inbox, title: "No transactions")
```

```

---

## 📱 Screen Files

### Authentication Screens

```

lib/screens/splash_screen.dart (120 lines)
├─ Purpose: App intro animation
├─ Features:
│ ├─ Animated logo
│ ├─ Particle or gradient background
│ ├─ Auto-transition after 3 seconds
│ └─ Fade/scale animations
└─ Navigation: → OnboardingScreen

lib/screens/onboarding_screen.dart (170 lines)
├─ Purpose: Feature showcase (4 pages)
├─ Features:
│ ├─ PageView carousel (4 screens)
│ ├─ Dot indicators
│ ├─ Feature images + descriptions
│ ├─ Skip / Next buttons
│ ├─ Continue on last page
│ └─ Smooth transitions
├─ Pages:
│ ├─ Page 1: Secure Banking
│ ├─ Page 2: Instant Transfers
│ ├─ Page 3: Spending Insights
│ └─ Page 4: Notifications
└─ Navigation: Skip → LoginScreen, Continue → LoginScreen

lib/screens/login_screen.dart (150 lines)
├─ Purpose: User authentication
├─ Features:
│ ├─ Email/phone input (CustomTextField)
│ ├─ Password input with visibility toggle
│ ├─ Remember me checkbox
│ ├─ Form validation
│ ├─ Forgot password link → ForgotPasswordScreen (TODO)
│ ├─ Biometric login button → BiometricScreen (TODO)
│ ├─ OTP button → OTPScreen (TODO)
│ ├─ Sign up link → SignUpScreen (TODO)
│ └─ Submit button with loading state
└─ Navigation: Submit → HomeScreen (with mock auth)

```

### Main Dashboard

```

lib/screens/home_screen.dart (280 lines)
├─ Purpose: Main dashboard showing account overview
├─ Sections:
│ ├─ Header with greeting + avatar
│ ├─ Balance card with hide/show
│ ├─ 4 quick action buttons
│ │ ├─ Send Money → TransferScreen
│ │ ├─ Receive → (TODO)
│ │ ├─ Top Up → (TODO)
│ │ └─ Pay Bills → (TODO)
│ ├─ Recent transactions (3 items)
│ ├─ Spending summary by category
│ └─ View all link → TransactionsScreen
├─ Features:
│ ├─ Reactive balance hiding
│ ├─ Pull-to-refresh (ready)
│ ├─ Unread notification badge
│ ├─ Navigation to other screens
│ └─ Real-time data updates
└─ Data: Via userProvider + accountsProvider from Riverpod

```

### Accounts Management

```

lib/screens/accounts_screen.dart (100 lines)
├─ Purpose: Display all user accounts
├─ Features:
│ ├─ Account cards with type colors
│ ├─ Account type badge (Current/Savings/Credit)
│ ├─ Account number (masked)
│ ├─ Balance display
│ ├─ Primary account indicator
│ ├─ Tap to view details → AccountDetailScreen (TODO)
│ └─ Add account button → (TODO)
├─ Account Types:
│ ├─ Current (blue)
│ ├─ Savings (green)
│ └─ Credit (red)
└─ Data: Via accountsProvider from Riverpod

```

### Cards Management

```

lib/screens/cards_screen.dart (160 lines)
├─ Purpose: Display and manage cards
├─ Features:
│ ├─ Visa card styling (blue)
│ ├─ Mastercard styling (orange)
│ ├─ Card number masking (shows last 4 digits)
│ ├─ Cardholder name display
│ ├─ Expiry date
│ ├─ Chip design element
│ ├─ Virtual card badge
│ ├─ Frozen status indicator
│ ├─ Lock icon for frozen cards
│ ├─ Tap for details → CardDetailScreen (TODO)
│ └─ Freeze/unfreeze action → (TODO)
├─ Card Types:
│ ├─ Debit cards
│ ├─ Credit cards
│ └─ Virtual cards
└─ Data: Via cardsProvider from Riverpod

```

### Transfer Flow (3 screens)

```

lib/screens/transfer_screen.dart (180 lines)
├─ Purpose: Initiate money transfer
├─ Features:
│ ├─ Recipient selector dropdown
│ ├─ Recipient favorites
│ ├─ Account selector (from which account)
│ ├─ Amount input with validation
│ ├─ Optional notes field
│ ├─ Form validation
│ └─ Next button
├─ Validation:
│ ├─ Recipient required
│ ├─ Amount > 0
│ ├─ Amount ≤ available balance
│ └─ Form complete
└─ Navigation: Next → TransferReviewScreen

lib/screens/transfer_review_screen.dart (120 lines)
├─ Purpose: Review transfer before confirmation
├─ Shows:
│ ├─ From account details
│ ├─ Recipient details
│ ├─ Transfer amount
│ ├─ Transfer fee
│ ├─ Total amount
│ ├─ Security message
│ ├─ Confirm button
│ └─ Cancel button
└─ Navigation: Confirm → TransferSuccessScreen, Cancel → Back

lib/screens/transfer_success_screen.dart (140 lines)
├─ Purpose: Show transfer result
├─ Features:
│ ├─ Scale-in animated checkmark
│ ├─ Transaction reference number
│ ├─ Amount transferred
│ ├─ Recipient name
│ ├─ Transfer date/time
│ ├─ Back to home button
│ ├─ Share receipt button → (TODO)
│ └─ Auto-navigate after 3 seconds
└─ Navigation: Back Home → HomeScreen

```

### Transaction History

```

lib/screens/transactions_screen.dart (180 lines)
├─ Purpose: View and filter transaction history
├─ Features:
│ ├─ Search bar (text search)
│ ├─ Filter chips: All, Completed, Pending, Failed
│ ├─ Transaction list with TransactionTile
│ ├─ Real-time filtering
│ ├─ Clear filters button
│ ├─ Tap transaction → TransactionDetailScreen (TODO)
│ └─ Empty state when no results
├─ Sorting Options:
│ ├─ By date (newest first)
│ ├─ By amount
│ └─ By status
└─ Data: Via transactionsProvider + filtering logic

```

### Notifications

```

lib/screens/notifications_screen.dart (140 lines)
├─ Purpose: View all notifications
├─ Features:
│ ├─ Notification list with type-specific icons
│ ├─ Color-coded by type (green/red/purple)
│ ├─ Read/unread indicator
│ ├─ Relative timestamp (now, 1h ago, etc)
│ ├─ Mark as read option
│ ├─ Mark all as read button
│ ├─ Delete notification → (TODO)
│ ├─ Tap to view details → (TODO)
│ └─ Empty state message
├─ Notification Types:
│ ├─ Transaction (green, bank icon)
│ ├─ Security (red, shield icon)
│ └─ Promotional (purple, tag icon)
└─ Data: Via notificationsProvider from Riverpod

```

### Profile & Settings

```

lib/screens/profile_screen.dart (280 lines)
├─ Purpose: User profile and preferences
├─ Sections:
│ ├─ Profile Header
│ │ ├─ Avatar image
│ │ ├─ Full name
│ │ ├─ Email address
│ │ └─ Edit button → EditProfileScreen (TODO)
│ ├─ Account Section
│ │ ├─ Personal Information
│ │ ├─ Security settings
│ │ └─ Change password
│ ├─ Preferences Section
│ │ ├─ Biometric toggle
│ │ ├─ Dark mode toggle
│ │ ├─ Language selector
│ │ └─ Currency selector
│ ├─ Support Section
│ │ ├─ FAQ → FAQScreen
│ │ ├─ Support → SupportScreen
│ │ ├─ Privacy Policy
│ │ ├─ Terms & Conditions
│ │ └─ About app
│ └─ Actions
│ └─ Logout (with confirmation)
└─ Data: Via userProvider from Riverpod

```

### Support & FAQ

```

lib/screens/support_screen.dart (150 lines)
├─ Purpose: Customer support entry point
├─ Features:
│ ├─ 5 support options with icons:
│ │ ├─ Email support → Email launcher (TODO)
│ │ ├─ Phone support → Phone launcher (TODO)
│ │ ├─ Live chat → Chat UI (TODO)
│ │ ├─ Report bug → Bug report form (TODO)
│ │ └─ Send feedback → Feedback form (TODO)
│ ├─ Common issues section
│ ├─ FAQ link → FAQScreen
│ └─ Contact information display
└─ Navigation: FAQ → FAQScreen, Support options → External

lib/screens/faq_screen.dart (150 lines)
├─ Purpose: Frequently asked questions
├─ Features:
│ ├─ 8 expandable FAQ items
│ ├─ Animated expand/collapse
│ ├─ RotationTransition for arrow icon
│ ├─ Question + answer display
│ ├─ Smooth 300ms animation
│ └─ Categories (Security, Transfer, Fees, etc)
├─ FAQ Topics:
│ ├─ Password reset
│ ├─ Security questions
│ ├─ Transfer time
│ ├─ Fee structure
│ ├─ Cancel transfers
│ ├─ Biometric setup
│ ├─ Support availability
│ └─ Account security
└─ Navigation: Back to previous screen

```

### Navigation Shell

```

lib/screens/main_navigation.dart (60 lines)
├─ Purpose: Bottom tab navigation connecting all main screens
├─ Tabs (5):
│ ├─ Home → HomeScreen
│ ├─ Accounts → AccountsScreen
│ ├─ History → TransactionsScreen
│ ├─ Cards → CardsScreen
│ └─ Profile → ProfileScreen
├─ Features:
│ ├─ IndexedStack for persistent state
│ ├─ BottomNavigationBar with 5 items
│ ├─ Icon + label per tab
│ ├─ Selected/unselected colors
│ ├─ Current tab tracking
│ └─ Smooth transitions
└─ Navigation: Tab taps route between screens

```

---

## 🧩 Feature Folder (Legacy Structure)

```

lib/screens/features/auth/ (Existing from boilerplate)
├─ Purpose: Authentication feature module (to be integrated)
├─ Structure:
│ ├─ data/
│ │ ├─ auth_api.dart - API calls
│ │ └─ auth_repository_impl.dart - Repository impl
│ ├─ domain/
│ │ └─ auth_repository.dart - Repository interface
│ └─ presentation/
│ ├─ notifier/
│ │ └─ auth_notifier.dart - State notifier
│ ├─ providers/
│ │ └─ auth_provider.dart - Riverpod providers
│ ├─ screens/
│ │ └─ auth_screen.dart - Auth logic
│ └─ state/
│ └─ auth_state.dart - State definitions
├─ Purpose: Can be extended for real authentication logic
└─ Note: Main app uses simpler approach in new screens

```

---

## 📦 Assets Directory

```

assets/
├─ Purpose: Static files (images, icons, etc)
├─ Current Status: Empty - ready for population
└─ To Add:
├─ images/
│ ├─ logo.png
│ ├─ avatar.png
│ ├─ card_bg.png
│ └─ (feature images for onboarding)
└─ icons/
├─ send_money.svg
├─ receive.svg
└─ (action icons)

```

---

## 🔌 Core Utilities

### HTTP Client
```

lib/core/dio_client.dart (80+ lines)
├─ Purpose: Centralized HTTP client configuration
├─ Features:
│ ├─ Base URL configuration
│ ├─ Request timeout settings
│ ├─ Interceptors for logging
│ ├─ Token management (placeholder)
│ ├─ Error handling
│ └─ Response parsing
├─ When to modify:
│ ├─ Changing API base URL
│ ├─ Adding request headers
│ ├─ Implementing token refresh
│ ├─ Adding custom interceptors
│ └─ Updating timeout settings
└─ Example:

```dart
final dio = DioClient.instance;
final response = await dio.get('/users/profile');
```

```

---

## 🧪 Testing

```

test/widget_test.dart
├─ Purpose: Placeholder for widget tests
├─ Features:
│ └─ Example test structure
├─ When to Expand:
│ ├─ After backend integration
│ ├─ For each new screen
│ ├─ For critical flows
│ └─ For state management
└─ Tools:
├─ flutter_test
├─ riverpod_test
└─ mockito

```

---

## 📄 Configuration Files

### Pubspec
```

pubspec.yaml
├─ Purpose: Project metadata and dependencies
├─ Key Info:
│ ├─ App name: online_banking_system
│ ├─ Version: 1.0.0+1
│ ├─ SDK: ^3.10.8
│ └─ Dart: ^3.10.8
├─ Dependencies:
│ ├─ flutter_riverpod: ^3.2.1
│ ├─ dio: ^5.9.1
│ ├─ lottie: ^3.1.0
│ ├─ persistent_bottom_nav_bar: ^6.2.1
│ └─ cupertino_icons: ^1.0.8
├─ When to modify:
│ ├─ Adding new packages
│ ├─ Updating versions
│ ├─ Adding assets
│ └─ Changing app metadata
└─ Asset config ready for images/icons

```

### Analysis
```

analysis_options.yaml
├─ Purpose: Dart linter configuration
├─ Configurations:
│ ├─ Lint rules
│ ├─ Ignored patterns
│ ├─ Error levels
│ └─ Custom rules
└─ When to modify:
├─ Enforcing code style
├─ Ignoring false positives
└─ Adding custom lint rules

```

### Android Configuration
```

android/app/build.gradle.kts
├─ Purpose: Android build configuration
├─ Key Settings:
│ ├─ Min SDK: 21
│ ├─ Target SDK: 34
│ ├─ Dependencies
│ └─ Signing config
└─ When to modify:
├─ Changing min/target SDK
├─ Adding Android dependencies
├─ Configuring app signing
└─ Setting up Firebase, etc

```

### iOS Configuration
```

ios/Runner.xcworkspace/
├─ Purpose: iOS project structure
├─ Key Files:
│ ├─ Runner.xcodeproj - Xcode project
│ ├─ Podfile - iOS dependencies
│ ├─ AppDelegate.swift - App lifecycle
│ └─ Info.plist - App metadata
└─ When to modify:
├─ Adding iOS dependencies
├─ Configuring app permissions
├─ Setting up app signing
└─ Adding native iOS code

```

---

## 🗺️ Navigation Flow

```

Splash Screen
↓ (auto - 3 seconds)
Onboarding Screen (4 pages)
↓ (skip or complete)
Login Screen
↓ (sign in with any credentials)
Main Navigation (Bottom Tabs)
├─ Home Screen
│ ├─ Send Money → Transfer Screen
│ ├─ Receive → (TODO)
│ ├─ View All Transactions → Transactions Screen
│ ├─ Notifications → Notifications Screen
│ └─ Settings → Profile Screen
├─ Accounts Screen
│ └─ Tap Account → Account Details (TODO)
├─ Transactions Screen
│ ├─ Search & Filter
│ └─ Tap Transaction → Details (TODO)
├─ Cards Screen
│ └─ Tap Card → Card Details (TODO)
└─ Profile Screen
├─ Edit Profile → Edit Profile Screen (TODO)
├─ FAQ → FAQ Screen
├─ Support → Support Screen
├─ Settings → Settings Screen (in profile)
└─ Logout → Login Screen

Transfer Flow:
Transfer Screen
↓
Transfer Review Screen
↓
Transfer Success Screen
↓
Home Screen (auto after 3 seconds)

```

---

## 📊 File Statistics

| Category | Count | Purpose |
|----------|-------|---------|
| **Documentation** | 8 files | Project reference |
| **Screens** | 14 files | UI implementation |
| **Models** | 1 file | Data definitions |
| **Data Services** | 1 file | Mock data + repository base |
| **State Management** | 1 file | Riverpod providers |
| **Widgets** | 1 file | Reusable components |
| **Theme** | 1 file | Design system |
| **Constants** | 1 file | App configuration |
| **Utilities** | 1 file | Core helpers |
| **Config** | 5 files | Build configuration |
| **TOTAL** | ~38 files | Complete project |

---

## 🔄 Recommended Reading Order

1. **Understanding the Project**
   - Start: [README.md](README.md)
   - Then: [QUICK_START.md](QUICK_START.md)
   - Then: [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)

2. **Getting Code Running**
   - Follow: [QUICK_START.md](QUICK_START.md) (5 minutes)
   - If issues: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

3. **Understanding Code Structure**
   - Read: This file (FILE_INDEX.md)
   - Look at: `lib/theme/app_theme.dart`
   - Look at: `lib/constants/app_constants.dart`
   - Look at: `lib/models/banking_models.dart`

4. **Modifying for Your Needs**
   - Update: `lib/theme/app_theme.dart` (colors, fonts)
   - Update: `lib/constants/app_constants.dart` (strings, routes)
   - Browse: Individual screens as needed

5. **Integrating Backend**
   - Follow: [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md)
   - Create: Repository classes
   - Update: Riverpod providers

6. **Extending Features**
   - Study: [ROADMAP.md](ROADMAP.md)
   - Pick feature:
   - Create screen file
   - Add route + provider
   - Add to navigation

---

## 💡 Quick Navigation by Task

### "I need to change app colors"
→ `lib/theme/app_theme.dart`

### "I need to add a new screen"
→ Create file in `lib/screens/`, update:
- `lib/constants/app_constants.dart` (add route)
- `lib/main.dart` (add to routes)
- Navigation from other screen

### "I need to change app text"
→ `lib/constants/app_constants.dart`

### "I need to add new data"
→ Steps:
1. Add model in `lib/models/banking_models.dart`
2. Create mock in `lib/data/mock_data_service.dart`
3. Add provider in `lib/providers/app_providers.dart`
4. Use in screen

### "I need to fix a bug"
→ Locate issue:
1. Find screen showing bug
2. Check data via provider
3. Check theme/constants
4. Use [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues

### "I need to integrate backend"
→ [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md)

### "I need to deploy app"
→ Follow deployment section in [README.md](README.md)

---

## 📚 Related Documentation

- **Project Overview**: [README.md](README.md)
- **Quick Start**: [QUICK_START.md](QUICK_START.md)
- **API Integration**: [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md)
- **Feature Implementation**: [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
- **Roadmap**: [ROADMAP.md](ROADMAP.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Data Models**: [schema.md](schema.md)
- **This File**: [FILE_INDEX.md](FILE_INDEX.md)

---

**Last Updated**: Latest implementation
**Total Implementation**: ~62% complete (13/19+ screens)
**Ready For**: Backend integration & testing

---

Happy exploring! 🚀
```
