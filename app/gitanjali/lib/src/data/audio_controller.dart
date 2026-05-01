import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/models.dart';

/// Extended audio controller with seek, position tracking, and timing display toggle
class AudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  String? _currentAsset;
  String? _currentDisplayName;
  bool _showRemainingTime = true;

  /// Stream of player state changes
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Stream of position updates
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of duration updates
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Current asset path being played
  String? get currentAsset => _currentAsset;

  /// Display name of current track
  String? get currentDisplayName => _currentDisplayName;

  /// Whether audio is currently playing
  bool get isPlaying => _player.playing;

  /// Whether there's a track loaded
  bool get hasTrack => _currentAsset != null;

  /// Current playback position
  Duration get position => _player.position;

  /// Total duration of current track
  Duration get duration => _player.duration ?? Duration.zero;

  /// Remaining time (duration - position)
  Duration get remaining => duration - position;

  /// Whether to show remaining time (true) or total duration (false)
  bool get showRemainingTime => _showRemainingTime;

  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  /// Toggle between showing remaining time and total duration
  void toggleTimingDisplay() {
    _showRemainingTime = !_showRemainingTime;
    notifyListeners();
  }

  /// Play audio from a PageAudio
  Future<void> play(PageAudio audio) async {
    _currentAsset = audio.assetPath;
    _currentDisplayName = audio.displayName;
    notifyListeners();

    await _player.setLoopMode(audio.loop ? LoopMode.one : LoopMode.off);
    await _player.setAsset(audio.assetPath);
    await _player.play();
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.play();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Stop playback and clear current track
  Future<void> stop() async {
    await _player.stop();
    _currentAsset = null;
    _currentDisplayName = null;
    notifyListeners();
  }

  /// Seek to a specific position
  Future<void> seekTo(Duration position) async {
    final clampedPosition = Duration(
      milliseconds: position.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    await _player.seek(clampedPosition);
  }

  /// Seek relative to current position
  Future<void> seekRelative(Duration delta) async {
    await seekTo(position + delta);
  }

  /// Seek to a progress value (0.0 to 1.0)
  Future<void> seekToProgress(double progress) async {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final targetPosition = Duration(
      milliseconds: (duration.inMilliseconds * clampedProgress).round(),
    );
    await seekTo(targetPosition);
  }

  /// Skip forward by 10 seconds
  Future<void> skipForward() async {
    await seekRelative(const Duration(seconds: 10));
  }

  /// Skip backward by 10 seconds
  Future<void> skipBackward() async {
    await seekRelative(const Duration(seconds: -10));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Format a Duration as MM:SS
String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// Format remaining time with minus sign
String formatRemainingTime(Duration remaining) {
  return '-${formatDuration(remaining)}';
}
