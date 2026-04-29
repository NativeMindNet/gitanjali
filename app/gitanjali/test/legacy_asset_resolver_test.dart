import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/data/legacy_asset_resolver.dart';

void main() {
  group('LegacyAssetResolver', () {
    final assets = <String>[
      'assets/legacy/Images/page.png',
      'assets/legacy/Sounds/song.m4a',
      'assets/legacy/Images/Anim/bg0001.png',
      'assets/legacy/Images/Anim/bg0002.png',
      'assets/legacy/custom/path/icon.png',
    ];

    test('resolves image path from image folder', () {
      final resolver = LegacyAssetResolver(assets);
      expect(resolver.resolveImage('page.png'), 'assets/legacy/Images/page.png');
    });

    test('resolves audio path from sound folder', () {
      final resolver = LegacyAssetResolver(assets);
      expect(resolver.resolveAudio('song.m4a'), 'assets/legacy/Sounds/song.m4a');
    });

    test('resolves keyframe preview to first sorted frame', () {
      final resolver = LegacyAssetResolver(assets);
      expect(resolver.resolveKeyframePreview('Anim'), 'assets/legacy/Images/Anim/bg0001.png');
    });

    test('normalizes legacy bundle placeholders in path', () {
      final resolver = LegacyAssetResolver(assets);
      expect(
        resolver.resolveImage(r'($APP_BUNDLE)/custom/path/icon.png'),
        'assets/legacy/custom/path/icon.png',
      );
    });

    test('returns null for unknown assets', () {
      final resolver = LegacyAssetResolver(assets);
      expect(resolver.resolveImage('missing.png'), isNull);
      expect(resolver.resolveAudio('missing.m4a'), isNull);
      expect(resolver.resolveKeyframePreview('MissingAnim'), isNull);
    });
  });
}
