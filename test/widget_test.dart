import 'package:flutter_test/flutter_test.dart';
import 'package:kenzeno/main.dart';
import 'package:kenzeno/app/modules/onboard/views/splashview.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that SplashView is rendered.
    expect(find.byType(SplashView), findsOneWidget);

    // Allow the OnboardController splash screen timer (5 seconds) to fire
    await tester.pump(const Duration(seconds: 5));
  });
}
