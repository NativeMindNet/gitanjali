class LegacyAssetResolver {
  LegacyAssetResolver(this.assets);

  final List<String> assets;

  String? resolveImage(String? rawPath) => _resolve(rawPath, preferredFolder: 'Images');

  String? resolveAudio(String? rawPath) => _resolve(rawPath, preferredFolder: 'Sounds');

  String? resolveKeyframePreview(String? rawPath) {
    final normalized = _normalize(rawPath);
    if (normalized == null) {
      return null;
    }
    final prefix = 'assets/legacy/Images/$normalized/';
    final matches = assets.where((asset) => asset.startsWith(prefix)).toList()..sort();
    return matches.isEmpty ? null : matches.first;
  }

  String? _resolve(String? rawPath, {required String preferredFolder}) {
    final normalized = _normalize(rawPath);
    if (normalized == null) {
      return null;
    }
    final direct = 'assets/legacy/$normalized';
    if (assets.contains(direct)) {
      return direct;
    }
    final inPreferredFolder = 'assets/legacy/$preferredFolder/$normalized';
    if (assets.contains(inPreferredFolder)) {
      return inPreferredFolder;
    }
    final imageFolder = 'assets/legacy/Images/$normalized';
    if (assets.contains(imageFolder)) {
      return imageFolder;
    }
    final soundFolder = 'assets/legacy/Sounds/$normalized';
    if (assets.contains(soundFolder)) {
      return soundFolder;
    }
    return assets.cast<String?>().firstWhere(
          (asset) => asset != null && asset.endsWith('/$normalized'),
          orElse: () => null,
        );
  }

  String? _normalize(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) {
      return null;
    }
    return rawPath
        .trim()
        .replaceAll(r'($APP_BUNDLE)/', '')
        .replaceAll(r'($DOCS_DIR)/', '')
        .replaceAll('\\', '/');
  }
}

