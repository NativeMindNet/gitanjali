import 'package:flutter/material.dart';

import '../../data/audio_controller.dart';
import '../common/breakpoints.dart';
import '../common/theme_tokens.dart';

/// Audio page with now playing and expanded controls
class AudioPage extends StatelessWidget {
  const AudioPage({
    super.key,
    required this.audioController,
  });

  final AudioController audioController;

  @override
  Widget build(BuildContext context) {
    final padding = adaptivePadding(context);
    final maxWidth = contentMaxWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio'),
      ),
      body: ListenableBuilder(
        listenable: audioController,
        builder: (context, _) {
          if (!audioController.hasTrack) {
            return _NoTrackView();
          }

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? double.infinity,
              ),
              padding: padding,
              child: _NowPlayingView(audioController: audioController),
            ),
          );
        },
      ),
    );
  }
}

class _NoTrackView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No audio playing',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Play audio from a page to see it here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingView extends StatelessWidget {
  const _NowPlayingView({required this.audioController});

  final AudioController audioController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),

        // Album art placeholder
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.music_note,
            size: 80,
            color: AppColors.primary,
          ),
        ),

        const Spacer(),

        // Track title
        Text(
          audioController.currentDisplayName ?? 'Unknown Track',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xl),

        // Progress slider
        StreamBuilder<Duration>(
          stream: audioController.positionStream,
          builder: (context, snapshot) {
            return Column(
              children: [
                Slider(
                  value: audioController.progress,
                  onChanged: (value) {
                    audioController.seekToProgress(value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(audioController.position),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: audioController.toggleTimingDisplay,
                        child: Text(
                          audioController.showRemainingTime
                              ? formatRemainingTime(audioController.remaining)
                              : formatDuration(audioController.duration),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              iconSize: 32,
              onPressed: audioController.skipBackward,
            ),
            const SizedBox(width: AppSpacing.lg),
            IconButton(
              icon: Icon(
                audioController.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              iconSize: 64,
              onPressed: audioController.togglePlayPause,
            ),
            const SizedBox(width: AppSpacing.lg),
            IconButton(
              icon: const Icon(Icons.forward_10),
              iconSize: 32,
              onPressed: audioController.skipForward,
            ),
          ],
        ),

        const Spacer(flex: 2),
      ],
    );
  }
}
