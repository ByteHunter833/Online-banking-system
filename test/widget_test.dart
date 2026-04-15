import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_banking_system/app/app.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';

void main() {
  testWidgets('App boots into the splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FinanceFlowApp()));
    await tester.pump();

    expect(find.text('SecureAuth'), findsOneWidget);
    expect(find.text('Protected by Design'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);
  });
}
