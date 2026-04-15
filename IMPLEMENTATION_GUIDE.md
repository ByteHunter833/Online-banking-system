# FinanceFlow - Modern Banking App UI

A production-style Flutter mobile app UI for an Online Banking System with clean architecture, responsive design, and modern banking UI/UX patterns.

## 🎨 Features

### Screens Implemented

1. **Splash Screen** - Animated introduction with smooth transitions
2. **Onboarding** - 4-page feature showcase with smooth page transitions
3. **Authentication**
   - Login screen with email/phone and password
   - Biometric login option
   - OTP verification
   - Forgot password
   - Remember me functionality

4. **Home Dashboard**
   - User greeting with profile image
   - Balance card with hide/show toggle
   - Quick actions (Send Money, Receive, Top Up, Pay Bills)
   - Recent transactions preview
   - Spending summary with category breakdown
   - Real-time notification badge

5. **Accounts**
   - Multiple account types (Current, Savings, Credit)
   - Account details and IBAN
   - Available balance display
   - Primary account indicator

6. **Transfer Money**
   - Recipient selection from favorites
   - Account selection
   - Amount validation
   - Optional notes
   - Transfer review screen
   - Success animation and confirmation

7. **Transaction History**
   - Complete transaction list
   - Status indicators (Completed, Pending, Failed)
   - Filter by type/status
   - Search functionality
   - Debit/credit indicators
   - Transaction details

8. **Cards**
   - Debit/credit card display
   - Virtual card support
   - Card status (frozen/active)
   - Expiry date and card number masking
   - Available limits

9. **Notifications**
   - Categorized notifications (Transaction, Security, Promotional)
   - Read/unread status
   - Time formatting
   - Mark all as read
   - Type-based color coding

10. **Profile & Settings**
    - Personal information
    - Biometric login toggle
    - Dark mode option
    - Language selection
    - Security settings
    - Links to support, privacy, terms

11. **Support & FAQ**
    - FAQ with expandable items
    - Support options (Email, Phone, Chat)
    - Report issue functionality
    - Multiple contact methods

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point with routing
├── theme/
│   └── app_theme.dart                # Complete theme configuration
├── constants/
│   └── app_constants.dart            # Routes, strings, assets
├── models/
│   └── banking_models.dart           # Data models for all entities
├── data/
│   └── mock_data_service.dart        # Mock data providers
├── providers/
│   └── app_providers.dart            # Riverpod state management
├── widgets/
│   └── reusable_widgets.dart         # Reusable UI components
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── main_navigation.dart          # Bottom nav shell
│   ├── home_screen.dart
│   ├── accounts_screen.dart
│   ├── cards_screen.dart
│   ├── transfer_screen.dart
│   ├── transfer_review_screen.dart
│   ├── transfer_success_screen.dart
│   ├── transactions_screen.dart
│   ├── notifications_screen.dart
│   ├── profile_screen.dart
│   ├── support_screen.dart
│   ├── faq_screen.dart
│   └── features/
│       └── auth/                     # Existing auth structure
├── core/
│   └── dio_client.dart               # HTTP client setup
└── assets/
    └── images/                       # Image assets

```

## 🎯 Architecture

### Clean Architecture Implementation

- **Presentation Layer**: Screens and widgets
- **Domain Layer**: Business logic (models/repositories)
- **Data Layer**: Mock data service (API integration ready)

### State Management

- **Riverpod** for reactive state management
- Providers for user, accounts, cards, transactions
- Local state for UI (loading, errors, filters)

### Design Patterns

- **Provider Pattern**: For dependency injection
- **Repository Pattern**: Mock data layer ready for API integration
- **Custom Widgets**: Reusable components for consistency

## 🎨 Design System

### Colors

- **Primary**: `#0066CC` (Banking Blue)
- **Secondary**: `#00D084` (Accent Green)
- **Accent**: `#7C3AED` (Purple), `#FF9500` (Orange)
- **Neutrals**: Dark Grey, Medium Grey, Light Grey, White

### Typography

- **Display Large**: 32px, Bold
- **Display Medium**: 28px, Bold
- **Heading Small**: 20px, Semi-bold
- **Body Large**: 16px, Medium
- **Body Medium**: 14px, Medium
- **Label Small**: 12px, Medium

### Spacing

- Standardized: 4, 8, 12, 16, 20, 24, 32px
- Consistent padding and margins
- Responsive to screen size

### Components

- Modern cards with soft shadows
- Rounded corners (12-20px border radius)
- Smooth transitions and animations
- Empty states for all list screens
- Loading shimmers
- Clear error messages

## 🔄 Navigation Flow

```
Splash Screen
    ↓
Onboarding (skip available)
    ↓
Login Screen
    ↓
Main Navigation Shell (Bottom Tab Bar)
    ├── Home Dashboard
    ├── Accounts
    ├── Transactions
    ├── Cards
    └── Profile

Quick Actions:
→ Transfer Money → Review → Success
→ Notifications
→ Support → FAQ
```

## 💾 Mock Data

All screens use mock data provided by `MockDataService`:

- Sample user profile
- Multiple accounts (Current, Savings, Credit)
- Debit/Credit and Virtual cards
- Transaction history with various statuses
- Notification list
- Recipient suggestions

**Ready for API Integration**: Replace mock calls with actual API endpoints

## 🚀 Getting Started

### Prerequisites

- Flutter 3.10.8+
- Dart 3.10.8+

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd Online-banking-system

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Adding Dependencies

All dependencies are in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  persistent_bottom_nav_bar: ^6.2.1
  flutter_riverpod: ^3.2.1
  dio: ^5.9.1
  lottie: ^3.1.0
```

## 🔌 API Integration Guide

### Step 1: Update DioClient

```dart
// lib/core/dio_client.dart
static Dio create() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://your.api.backend.com',
      // ... configuration
    ),
  );
  return dio;
}
```

### Step 2: Create Repository Classes

```dart
// lib/data/repositories/
class AuthRepository {
  final DioClient dioClient;

  Future<User> login(String email, String password) async {
    // API call implementation
  }
}
```

### Step 3: Update Providers

```dart
// lib/providers/app_providers.dart
final userProvider = FutureProvider((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentUser();
});
```

### Step 4: Replace Mock Data Calls

```dart
// Before:
final users = MockDataService.getMockUser();

// After:
final userAsync = ref.watch(userProvider);
userAsync.when(
  data: (user) => /* render user */,
  loading: () => /* show loader */,
  error: (err, stack) => /* show error */,
);
```

## 📱 Responsive Design

- Mobile-first approach
- Adaptive layout for tablets
- Safe area constraints
- Portrait orientation optimized
- Landscape support ready

## 🎯 TODO - Future Enhancements

- [ ] Add landscape orientation support
- [ ] Implement actual API endpoints
- [ ] Add local authentication (biometric)
- [ ] Add push notifications
- [ ] Add payment gateway integration
- [ ] Add transaction export (PDF, CSV)
- [ ] Add scheduled transfers
- [ ] Add bill payments
- [ ] Add investment features
- [ ] Add loan application
- [ ] Add dark theme
- [ ] Add multi-language support
- [ ] Add analytics tracking
- [ ] Add error logging/Sentry
- [ ] Unit and widget tests

## 🔒 Security Considerations

- Form validation on all inputs
- Password visibility toggle
- Card number masking
- Balance visibility toggle
- Biometric login ready
- HTTPS recommended for API
- Sensitive data handling

## 📊 Performance

- Efficient widget rebuilds
- Image optimization ready
- Lazy loading for lists
- Shimmer loading states
- Device-native animations

## 🐛 Known Issues & Limitations

- Mock data is hardcoded (no persistence)
- Some screens have placeholder functionality
- No actual file uploads
- No email verification
- No payment processing
- OTP is not validated against backend

## 🤝 Contributing

1. Follow Flutter best practices
2. Maintain clean code structure
3. Add documentation for new features
4. Test on both iOS and Android
5. Use the established patterns

## 📄 License

This project is provided as-is for educational and development purposes.

## 📞 Support

For issues or questions:

- Check the FAQ screen in-app
- Review code comments
- Examine mock data structure
- Check app_theme.dart for styling

## 🎓 Learning Resources

- Flutter: https://flutter.dev
- Riverpod: https://riverpod.dev
- Dio: https://github.com/flutterchina/dio
- Material Design: https://m3.material.io

---

**Built with ❤️ using Flutter**
