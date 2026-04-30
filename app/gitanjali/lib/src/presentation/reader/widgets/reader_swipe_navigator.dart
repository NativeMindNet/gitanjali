import 'package:flutter/material.dart';

class ReaderSwipeNavigator extends StatelessWidget {
  const ReaderSwipeNavigator({
    super.key,
    required this.child,
    required this.onNext,
    required this.onPrevious,
    this.velocityThreshold = 150,
  });

  final Widget child;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final double velocityThreshold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity;
        if (v == null) {
          return;
        }
        if (v < -velocityThreshold) {
          onNext();
        } else if (v > velocityThreshold) {
          onPrevious();
        }
      },
      child: child,
    );
  }
}

