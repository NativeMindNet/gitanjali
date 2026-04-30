import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/presentation/reader/widgets/reader_swipe_navigator.dart';

void main() {
  testWidgets('ReaderSwipeNavigator triggers next on fast left swipe', (tester) async {
    var nextCalls = 0;
    var prevCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderSwipeNavigator(
            onNext: () => nextCalls += 1,
            onPrevious: () => prevCalls += 1,
            child: const ColoredBox(
              key: ValueKey('surface'),
              color: Colors.transparent,
              child: SizedBox(width: 300, height: 300),
            ),
          ),
        ),
      ),
    );

    await tester.fling(find.byKey(const ValueKey('surface')), const Offset(-200, 0), 1200);
    await tester.pump();

    expect(nextCalls, 1);
    expect(prevCalls, 0);
  });

  testWidgets('ReaderSwipeNavigator triggers previous on fast right swipe', (tester) async {
    var nextCalls = 0;
    var prevCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderSwipeNavigator(
            onNext: () => nextCalls += 1,
            onPrevious: () => prevCalls += 1,
            child: const ColoredBox(
              key: ValueKey('surface'),
              color: Colors.transparent,
              child: SizedBox(width: 300, height: 300),
            ),
          ),
        ),
      ),
    );

    await tester.fling(find.byKey(const ValueKey('surface')), const Offset(200, 0), 1200);
    await tester.pump();

    expect(nextCalls, 0);
    expect(prevCalls, 1);
  });

  testWidgets('ReaderSwipeNavigator ignores swipe below velocity threshold', (tester) async {
    var nextCalls = 0;
    var prevCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderSwipeNavigator(
            onNext: () => nextCalls += 1,
            onPrevious: () => prevCalls += 1,
            velocityThreshold: 2000,
            child: const ColoredBox(
              key: ValueKey('surface'),
              color: Colors.transparent,
              child: SizedBox(width: 300, height: 300),
            ),
          ),
        ),
      ),
    );

    await tester.fling(find.byKey(const ValueKey('surface')), const Offset(-200, 0), 1200);
    await tester.pump();

    expect(nextCalls, 0);
    expect(prevCalls, 0);
  });
}

