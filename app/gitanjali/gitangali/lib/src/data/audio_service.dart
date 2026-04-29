import 'package:just_audio/just_audio.dart';

import '../domain/models.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  String? currentAsset;

  bool get isPlaying => _player.playing;

  Future<void> play(PageAudio audio) async {
    currentAsset = audio.assetPath;
    await _player.setLoopMode(audio.loop ? LoopMode.one : LoopMode.off);
    await _player.setAsset(audio.assetPath);
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

