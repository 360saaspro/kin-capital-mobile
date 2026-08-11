import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin_app/main.dart';

void main() {
  testWidgets('Kin App smoke test', (WidgetTester tester) async {
    // Ignore network image errors in tests.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) {
        return;
      }
      originalOnError?.call(details);
    };

    // Build our app and trigger a frame.
    await tester.pumpWidget(const KinApp());
    await tester.pump(); // Allow some time for animations/images to "fail"

    // Verify that 'Home' navigation is present.
    expect(find.text('Home'), findsWidgets);
    
    // Verify that the balance label is present.
    expect(find.text('Available to send'), findsOneWidget);
    
    // Restore error handler.
    FlutterError.onError = originalOnError;
  });
}
