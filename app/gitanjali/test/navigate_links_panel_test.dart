import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/domain/models.dart';
import 'package:gitangali/src/presentation/reader/widgets/navigate_links_panel.dart';

void main() {
  testWidgets('NavigateLinksPanel renders buttons and calls onControlTap on tap',
      (tester) async {
    late final List<ControlInfo> tapped;
    tapped = <ControlInfo>[];

    final c1 = ControlInfo(
      type: ControlType.pageLink,
      targetPageIndex: 1,
      imageAsset: null,
      highlightedImageAsset: null,
    );
    final c2 = ControlInfo(
      type: ControlType.pageLink,
      targetPageIndex: 4,
      imageAsset: null,
      highlightedImageAsset: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NavigateLinksPanel(
            controls: <ControlInfo>[c1, c2],
            onControlTap: (control) async {
              tapped.add(control);
            },
          ),
        ),
      ),
    );

    expect(find.text('Navigate'), findsOneWidget);
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('Page 5'), findsOneWidget);

    await tester.tap(find.text('Page 2'));
    expect(tapped, [c1]);
  });
}

