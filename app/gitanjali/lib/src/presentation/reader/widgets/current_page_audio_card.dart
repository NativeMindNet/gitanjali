import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class CurrentPageAudioCard extends StatelessWidget {
  const CurrentPageAudioCard({
    super.key,
    required this.audio,
    required this.isPlaying,
    required this.onToggle,
  });

  final PageAudio audio;
  final bool isPlaying;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline,
        ),
        title: Text(audio.displayName),
        subtitle: Text(audio.autoplay ? 'Autoplay enabled' : 'Tap to play'),
        onTap: onToggle,
      ),
    );
  }
}

