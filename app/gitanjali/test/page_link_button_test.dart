import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/domain/models.dart';
import 'package:gitangali/src/presentation/reader/widgets/page_link_button.dart';

void main() {
  testWidgets('PageLinkButton calls onPressed on tap', (tester) async {
    var tapped = false;
    final control = ControlInfo(
      type: ControlType.pageLink,
      targetPageIndex: 3,
      imageAsset: 'assets/legacy/Images/btn.png',
      highlightedImageAsset: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageLinkButton(
            control: control,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PageLinkButton));
    expect(tapped, isTrue);
  });

  testWidgets('PageLinkButton prefers highlightedImageAsset over imageAsset', (
    tester,
  ) async {
    const highlighted = 'assets/legacy/Images/btn_hl.png';
    const normal = 'assets/legacy/Images/btn.png';

    final control = ControlInfo(
      type: ControlType.pageLink,
      targetPageIndex: 0,
      imageAsset: normal,
      highlightedImageAsset: highlighted,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageLinkButton(
            control: control,
            onPressed: () {},
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image)).image;
    expect((image as AssetImage).assetName, highlighted);
  });

  testWidgets('PageLinkButton shows page label when no asset', (tester) async {
    final control = ControlInfo(
      type: ControlType.pageLink,
      targetPageIndex: 4,
      imageAsset: null,
      highlightedImageAsset: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageLinkButton(
            control: control,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Page 5'), findsOneWidget);
  });
}

