import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/domain/models.dart';
import 'package:gitangali/src/presentation/reader/widgets/page_paragraphs.dart';

void main() {
  testWidgets('PageParagraphs renders only visible paragraphs', (tester) async {
    const style = ParagraphStyleSpec(
      fontFamily: 'MurariChandUni',
      fontSize: 18,
      textAlign: TextAlign.left,
      textColor: Color(0xFF000000),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageParagraphs(
            paragraphs: [
              ParagraphSpec(text: 'Visible 1', hidden: false, style: style),
              ParagraphSpec(text: 'Hidden', hidden: true, style: style),
              ParagraphSpec(text: 'Visible 2', hidden: false, style: style),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Visible 1'), findsOneWidget);
    expect(find.text('Visible 2'), findsOneWidget);
    expect(find.text('Hidden'), findsNothing);
  });

  testWidgets('PageParagraphs hides itself when all paragraphs are hidden', (tester) async {
    const style = ParagraphStyleSpec(
      fontFamily: 'MurariChandUni',
      fontSize: 18,
      textAlign: TextAlign.left,
      textColor: Color(0xFF000000),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageParagraphs(
            paragraphs: [
              ParagraphSpec(text: 'Hidden', hidden: true, style: style),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(Text), findsNothing);
  });
}

