import 'package:flutter_test/flutter_test.dart';
import 'package:popbash/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PopBashApp());

    // Verify that the title text is found.
    expect(find.text('POPBASH'), findsOneWidget);
  });
}
