import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/presentation/reader/widgets/animated_background.dart';

void main() {
  testWidgets('AnimatedBackground switches frames by fps timing', (tester) async {
    const frames = <String>[
      'assets/legacy/Images/Anim/frame1.png',
      'assets/legacy/Images/Anim/frame2.png',
      'assets/legacy/Images/Anim/frame3.png',
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedBackground(
            frames: frames,
            framesPerSecond: 10,
          ),
        ),
      ),
    );

    expect(find.byKey(ValueKey<String>(frames[0])), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 110));
    expect(find.byKey(ValueKey<String>(frames[1])), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 110));
    expect(find.byKey(ValueKey<String>(frames[2])), findsOneWidget);
  });

  testWidgets('AnimatedBackground uses fallback timing when fps is null', (tester) async {
    const frames = <String>[
      'assets/legacy/Images/Anim/frame1.png',
      'assets/legacy/Images/Anim/frame2.png',
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedBackground(
            frames: frames,
            framesPerSecond: null,
          ),
        ),
      ),
    );

    expect(find.byKey(ValueKey<String>(frames[0])), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 130));
    expect(find.byKey(ValueKey<String>(frames[1])), findsOneWidget);
  });

  testWidgets('AnimatedBackground updates timer when fps changes', (tester) async {
    const frames = <String>[
      'assets/legacy/Images/Anim/frame1.png',
      'assets/legacy/Images/Anim/frame2.png',
      'assets/legacy/Images/Anim/frame3.png',
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedBackground(
            key: ValueKey('bg'),
            frames: frames,
            framesPerSecond: 20,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byKey(ValueKey<String>(frames[1])), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedBackground(
            key: ValueKey('bg'),
            frames: frames,
            framesPerSecond: 2,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(ValueKey<String>(frames[1])), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 420));
    expect(find.byKey(ValueKey<String>(frames[2])), findsOneWidget);
  });
}
