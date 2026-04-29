import 'package:flutter_test/flutter_test.dart';

import 'package:gitangali/src/app/gitanjali_app.dart';

void main() {
  testWidgets('loads Gitanjali shell', (WidgetTester tester) async {
    await tester.pumpWidget(const GitanjaliApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sri Gaudiya Gitanjali'), findsWidgets);
  });
}
