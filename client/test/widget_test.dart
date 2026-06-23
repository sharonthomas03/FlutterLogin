import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/app.dart';

void main() {
  testWidgets('App smoke test - opens login screen', (WidgetTester tester) async {
    // Provide mock initial values for SharedPreferences to prevent initialization issues.
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the login page is shown by checking for 'Welcome back'.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsAtLeastNWidgets(1));
  });
}
