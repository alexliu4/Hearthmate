import 'package:flutter_test/flutter_test.dart';

import 'package:hearthmate/main.dart';

void main() {
  testWidgets('app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const HearthmateApp());
    expect(find.text('Pomodoro'), findsOneWidget);
  });
}
