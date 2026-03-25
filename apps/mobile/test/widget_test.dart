import 'package:flutter_test/flutter_test.dart';
import 'package:kaiiak/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const KaiakApp());
    expect(find.text('DEMO'), findsOneWidget);
  });
}
