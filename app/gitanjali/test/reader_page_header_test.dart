import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/presentation/reader/widgets/reader_page_header.dart';

void main() {
  testWidgets('ReaderPageHeader shows title and page label when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReaderPageHeader(
            title: 'Some Title',
            showNumber: true,
            pageIndex: 4,
          ),
        ),
      ),
    );

    expect(find.text('Some Title'), findsOneWidget);
    expect(find.text('Page 5'), findsOneWidget);
  });

  testWidgets('ReaderPageHeader hides page label when showNumber is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReaderPageHeader(
            title: 'Some Title',
            showNumber: false,
            pageIndex: 1,
          ),
        ),
      ),
    );

    expect(find.text('Some Title'), findsOneWidget);
    expect(find.text('Page 2'), findsNothing);
  });
}

