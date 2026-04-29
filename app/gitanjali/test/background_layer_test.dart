import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/presentation/reader/widgets/animated_background.dart';
import 'package:gitangali/src/presentation/reader/widgets/background_layer.dart';

void main() {
  testWidgets('BackgroundLayer uses animated widget for multi-frame backgrounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BackgroundLayer(
            assetPath: null,
            frames: <String>['a.png', 'b.png'],
            framesPerSecond: 12,
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedBackground), findsOneWidget);
  });

  testWidgets('BackgroundLayer uses static image for single asset background', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BackgroundLayer(
            assetPath: 'assets/legacy/Images/static.png',
            frames: <String>[],
            framesPerSecond: null,
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedBackground), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('BackgroundLayer uses color fallback when no background is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BackgroundLayer(
            assetPath: null,
            frames: <String>[],
            framesPerSecond: null,
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedBackground), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(DecoratedBox), findsWidgets);
  });
}
