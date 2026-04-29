import 'package:flutter/material.dart';

import 'animated_background.dart';

class BackgroundLayer extends StatelessWidget {
  const BackgroundLayer({
    super.key,
    required this.assetPath,
    required this.frames,
    required this.framesPerSecond,
  });

  final String? assetPath;
  final List<String> frames;
  final double? framesPerSecond;

  @override
  Widget build(BuildContext context) {
    if (frames.length > 1) {
      return AnimatedBackground(
        frames: frames,
        framesPerSecond: framesPerSecond,
      );
    }

    if (assetPath == null) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF1E7D3),
        ),
      );
    }

    return Image.asset(
      assetPath!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF1E7D3),
        ),
      ),
    );
  }
}
