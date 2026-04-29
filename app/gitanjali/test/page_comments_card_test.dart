import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/presentation/reader/widgets/page_comments_card.dart';

void main() {
  testWidgets('PageCommentsCard hides itself when comments are empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageCommentsCard(comments: '   '),
        ),
      ),
    );

    expect(find.byType(Card), findsNothing);
    expect(find.text('Any'), findsNothing);
  });

  testWidgets('PageCommentsCard renders Card with trimmed comments', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageCommentsCard(comments: '  Important note  '),
        ),
      ),
    );

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Important note'), findsOneWidget);
  });
}

