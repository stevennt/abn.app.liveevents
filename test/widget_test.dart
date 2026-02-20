import 'package:flutter_test/flutter_test.dart';

import 'package:abn_app_liveevents/main.dart';

void main() {
  testWidgets('app shell renders tab navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const LiveEventsApp());
    await tester.pumpAndSettle();

    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
