import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/domain/models.dart';
import 'package:gitangali/src/presentation/reader/widgets/current_page_audio_card.dart';

void main() {
  testWidgets('CurrentPageAudioCard shows play icon when not playing and autoplay subtitle',
      (tester) async {
    var toggled = false;
    final audio = PageAudio(
      assetPath: 'assets/legacy/Sounds/song.m4a',
      displayName: 'Song',
      autoplay: true,
      loop: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrentPageAudioCard(
            audio: audio,
            isPlaying: false,
            onToggle: () => toggled = true,
          ),
        ),
      ),
    );

    expect(find.text('Song'), findsOneWidget);
    expect(find.text('Autoplay enabled'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);

    await tester.tap(find.text('Song'));
    expect(toggled, isTrue);
  });

  testWidgets('CurrentPageAudioCard shows stop icon when playing and tap-to-play subtitle',
      (tester) async {
    final audio = PageAudio(
      assetPath: 'assets/legacy/Sounds/song.m4a',
      displayName: 'Song',
      autoplay: false,
      loop: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrentPageAudioCard(
            audio: audio,
            isPlaying: true,
            onToggle: () {},
          ),
        ),
      ),
    );

    expect(find.text('Tap to play'), findsOneWidget);
    expect(find.byIcon(Icons.stop_circle_outlined), findsOneWidget);
  });
}

