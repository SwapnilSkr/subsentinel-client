import 'package:flutter_test/flutter_test.dart';
import 'package:subsentinel/main.dart';

void main() {
  testWidgets('SubSentinel app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SubSentinelApp());

    // Verify the app starts with Command Center
    expect(find.text('Command Center'), findsOneWidget);
    expect(find.text('Your subscription cockpit'), findsOneWidget);
  });
}
