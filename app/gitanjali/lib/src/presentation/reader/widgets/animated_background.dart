import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    required this.frames,
    required this.framesPerSecond,
  });

  final List<String> frames;
  final double? framesPerSecond;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  Timer? _timer;
  int _frameIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frames != widget.frames) {
      _frameIndex = 0;
    }
    if (oldWidget.framesPerSecond != widget.framesPerSecond) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.frames[_frameIndex],
      key: ValueKey<String>(widget.frames[_frameIndex]),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF1E7D3),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_frameDuration, (_) {
      if (!mounted || widget.frames.length < 2) {
        return;
      }
      setState(() {
        _frameIndex = (_frameIndex + 1) % widget.frames.length;
      });
    });
  }

  Duration get _frameDuration {
    final fps = widget.framesPerSecond;
    if (fps == null || fps <= 0) {
      return const Duration(milliseconds: 120);
    }
    final ms = (1000 / fps).round();
    return Duration(milliseconds: ms.clamp(16, 2000));
  }
}
