// Extracts plain text, structured JSON, and (optionally) copies referenced images
// from bundled legacy Gitanjali XML into docs/extracted-gitanjali/.
//
// Usage (from app/gitanjali):
//   dart run tool/extract_book_content.dart
//   dart run tool/extract_book_content.dart --copy-media

import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

const _books = <String, String>{
  'en': 'assets/legacy/example.xml',
  'ru': 'assets/legacy/example_ru.xml',
};

void main(List<String> args) {
  final copyMedia = args.contains('--copy-media');
  final scriptPath = Platform.script.toFilePath();
  final packageRoot = File(scriptPath).parent.parent.path;
  final repoRoot = Directory(packageRoot).parent.parent.path;
  final outRoot = '$repoRoot/docs/extracted-gitanjali';
  final legacyRoot = '$packageRoot/assets/legacy';

  final assetIndex = _indexLegacyAssets(packageRoot, legacyRoot);
  Directory(outRoot).createSync(recursive: true);

  for (final entry in _books.entries) {
    final lang = entry.key;
    final xmlRel = entry.value;
    final xmlPath = '$packageRoot/$xmlRel';
    final doc = XmlDocument.parse(File(xmlPath).readAsStringSync());
    final root = doc.rootElement;

    final mediaRefs = <String>{};
    _collectMediaRefs(root, mediaRefs.add);

    final resolved = _resolveAllMediaRefs(mediaRefs, assetIndex, packageRoot);
    final book = root.getElement('book') ?? root;
    final head = book.getElement('head');
    final title = head?.getElement('book-title')?.innerText.trim() ?? 'Gitanjali';
    final pages = _extractPages(book.getElement('body'));

    final langPath = '$outRoot/$lang';
    Directory(langPath).createSync(recursive: true);

    File('$langPath/book_plain.txt').writeAsStringSync(_formatPlainText(title, pages));
    File('$langPath/book.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'language': lang,
        'sourceXml': xmlRel,
        'bookTitle': title,
        'pageCount': pages.length,
        'pages': [
          for (var i = 0; i < pages.length; i++)
            {
              'index': i,
              'title': pages[i].title,
              'contentTitle': pages[i].contentTitle,
              'showNumber': pages[i].showNumber,
              'paragraphs': pages[i].paragraphs,
              if (pages[i].comments != null && pages[i].comments!.isNotEmpty)
                'comments': pages[i].comments,
            },
        ],
      }),
    );

    File('$langPath/media_manifest.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'rawReferences': mediaRefs.toList()..sort(),
        'resolvedFiles': resolved.files.toList()..sort(),
        'keyframeDirectories': resolved.keyframeDirs.toList()..sort(),
        'missing': resolved.missing.toList()..sort(),
      }),
    );

    if (copyMedia) {
      final mediaPath = '$langPath/media';
      final mediaDir = Directory(mediaPath);
      if (mediaDir.existsSync()) {
        mediaDir.deleteSync(recursive: true);
      }
      mediaDir.createSync(recursive: true);
      for (final f in resolved.files) {
        final src = File('$packageRoot/$f');
        final destPath = '$mediaPath/${f.replaceFirst('assets/legacy/', '')}';
        File(destPath).parent.createSync(recursive: true);
        src.copySync(destPath);
      }
      for (final dir in resolved.keyframeDirs) {
        final srcDir = Directory('$packageRoot/$dir');
        if (!srcDir.existsSync()) {
          continue;
        }
        for (final entity in srcDir.listSync(recursive: true)) {
          if (entity is! File) {
            continue;
          }
          final rel = entity.path.replaceAll('\\', '/').substring(packageRoot.length + 1);
          final destPath = '$mediaPath/${rel.replaceFirst('assets/legacy/', '')}';
          File(destPath).parent.createSync(recursive: true);
          entity.copySync(destPath);
        }
      }
    }
  }

  stderr.writeln(
    'Wrote text + manifests under: $outRoot\n'
    '${copyMedia ? 'Copied media into each language folder under media/.' : 'Skipped binary copy (pass --copy-media to copy images into docs/extracted-gitanjali/<lang>/media/).'}',
  );
}

class _AssetIndex {
  _AssetIndex(this.paths);

  final Set<String> paths;
}

_AssetIndex _indexLegacyAssets(String packageRoot, String legacyRoot) {
  final paths = <String>{};
  for (final entity in Directory(legacyRoot).listSync(recursive: true)) {
    if (entity is File) {
      final rel = entity.path.replaceAll('\\', '/').substring(packageRoot.length + 1);
      paths.add(rel);
    }
  }
  return _AssetIndex(paths);
}

String? _normalizeRaw(String? rawPath) {
  if (rawPath == null || rawPath.trim().isEmpty) {
    return null;
  }
  return rawPath
      .trim()
      .replaceAll(r'($APP_BUNDLE)/', '')
      .replaceAll(r'($DOCS_DIR)/', '')
      .replaceAll('\\', '/');
}

String? _resolveOneFile(String? raw, _AssetIndex assets) {
  final normalized = _normalizeRaw(raw);
  if (normalized == null) {
    return null;
  }
  final direct = 'assets/legacy/$normalized';
  if (assets.paths.contains(direct)) {
    return direct;
  }
  final inImages = 'assets/legacy/Images/$normalized';
  if (assets.paths.contains(inImages)) {
    return inImages;
  }
  for (final p in assets.paths) {
    if (p.endsWith('/$normalized')) {
      return p;
    }
  }
  return null;
}

String? _resolveKeyframeDir(String? raw, _AssetIndex assets) {
  final normalized = _normalizeRaw(raw);
  if (normalized == null) {
    return null;
  }
  final prefix = 'assets/legacy/Images/$normalized/';
  final has = assets.paths.any((p) => p.startsWith(prefix));
  return has ? 'assets/legacy/Images/$normalized' : null;
}

class _ResolvedMedia {
  _ResolvedMedia({
    required this.files,
    required this.keyframeDirs,
    required this.missing,
  });

  final Set<String> files;
  final Set<String> keyframeDirs;
  final Set<String> missing;
}

_ResolvedMedia _resolveAllMediaRefs(Set<String> rawRefs, _AssetIndex assets, String packageRoot) {
  final files = <String>{};
  final keyframeDirs = <String>{};
  final missing = <String>{};

  for (final raw in rawRefs) {
    final normalized = _normalizeRaw(raw);
    if (normalized == null) {
      continue;
    }
    if (normalized.endsWith('.m4a') ||
        normalized.endsWith('.mp3') ||
        normalized.endsWith('.aac') ||
        normalized.endsWith('.wav')) {
      final a = _resolveOneFile(raw, assets);
      if (a != null) {
        files.add(a);
      } else {
        missing.add(raw);
      }
      continue;
    }
    final file = _resolveOneFile(raw, assets);
    if (file != null) {
      files.add(file);
      continue;
    }
    final kf = _resolveKeyframeDir(raw, assets);
    if (kf != null) {
      keyframeDirs.add(kf);
      continue;
    }
    missing.add(raw);
  }
  return _ResolvedMedia(files: files, keyframeDirs: keyframeDirs, missing: missing);
}

void _collectMediaRefs(XmlElement root, void Function(String) emit) {
  for (final el in root.descendants) {
    if (el is! XmlElement) {
      continue;
    }
    final n = el.name.local;
    if (n == 'image' || n == 'highlighted-image' || n == 'disabled-image' || n == 'audio') {
      final t = el.innerText.trim();
      if (t.isNotEmpty) {
        emit(t);
      }
    }
    if (n == 'background') {
      final img = el.getAttribute('image');
      if (img != null && img.trim().isNotEmpty) {
        emit(img.trim());
      }
    }
    if (n == 'target') {
      final type = el.getAttribute('type');
      if (type == 'image' || type == 'keyframe') {
        final t = el.innerText.trim();
        if (t.isNotEmpty) {
          emit(t);
        }
      }
    }
  }
}

class _PageOut {
  _PageOut({
    required this.title,
    required this.contentTitle,
    required this.paragraphs,
    required this.comments,
    required this.showNumber,
  });

  final String title;
  final String contentTitle;
  final List<String> paragraphs;
  final String? comments;
  final bool showNumber;
}

class _Draft {
  _Draft({required this.title, required this.contentTitle});

  String title;
  String contentTitle;
  final List<String> paragraphs = [];
  String? comments;
  var showNumber = true;
  var hasControls = false;
  var hasBackground = false;
  var hasAudio = false;

  bool get hasVisibleContent =>
      paragraphs.isNotEmpty ||
      (comments?.trim().isNotEmpty ?? false) ||
      hasControls ||
      hasBackground ||
      hasAudio;

  _PageOut toPageOut() {
    return _PageOut(
      title: title,
      contentTitle: contentTitle,
      paragraphs: List<String>.from(paragraphs),
      comments: comments,
      showNumber: showNumber,
    );
  }
}

bool _truthyHidden(XmlElement p) {
  final v = p.getAttribute('hidden');
  return v == '1' || v?.toLowerCase() == 'true';
}

void _applyPageToDraft(_Draft draft, XmlElement page) {
  for (final child in page.childElements) {
    switch (child.name.local) {
      case 'p':
        if (!_truthyHidden(child)) {
          final text = child.innerText.trim();
          if (text.isNotEmpty) {
            draft.paragraphs.add(text);
          }
        }
      case 'comments':
        draft.comments = child.findElements('p').map((e) => e.innerText.trim()).join('\n');
      case 'show-number':
        draft.showNumber = child.innerText.trim() != '0';
      case 'controls':
        draft.hasControls = child.findElements('control').isNotEmpty;
      case 'audio':
        draft.hasAudio = child.innerText.trim().isNotEmpty;
      case 'background':
        draft.hasBackground = true;
      default:
        break;
    }
  }
}

List<_PageOut> _extractPages(XmlElement? body) {
  if (body == null) {
    return const [];
  }
  final pages = <_PageOut>[];

  void walk(XmlElement section, String inheritedTitle, String inheritedContentTitle) {
    var sectionTitle = inheritedTitle;
    var contentTitle = inheritedContentTitle;
    var draft = _Draft(title: sectionTitle, contentTitle: contentTitle);

    for (final child in section.childElements) {
      switch (child.name.local) {
        case 'title':
          final t = child.findElements('p').map((e) => e.innerText.trim()).join(' ').trim();
          if (t.isNotEmpty) {
            sectionTitle = t;
            draft.title = sectionTitle;
          }
        case 'content-title':
          final t = child.findElements('p').map((e) => e.innerText.trim()).join(' ').trim();
          if (t.isNotEmpty) {
            contentTitle = t;
            draft.contentTitle = contentTitle;
          }
        case 'p':
          if (!_truthyHidden(child)) {
            final text = child.innerText.trim();
            if (text.isNotEmpty) {
              draft.paragraphs.add(text);
            }
          }
        case 'page':
          _applyPageToDraft(draft, child);
          if (draft.hasVisibleContent) {
            pages.add(draft.toPageOut());
          }
          draft = _Draft(
            title: sectionTitle,
            contentTitle: contentTitle.isEmpty ? sectionTitle : contentTitle,
          );
        case 'section':
          walk(
            child,
            sectionTitle,
            contentTitle.isEmpty ? sectionTitle : contentTitle,
          );
        default:
          break;
      }
    }

    if (draft.hasVisibleContent) {
      pages.add(draft.toPageOut());
    }
  }

  final rootSection = body.getElement('section');
  if (rootSection != null) {
    walk(rootSection, '', '');
  }
  return pages;
}

String _formatPlainText(String bookTitle, List<_PageOut> pages) {
  final b = StringBuffer()..writeln(bookTitle)..writeln();
  for (var i = 0; i < pages.length; i++) {
    final p = pages[i];
    b.writeln('--- Page ${i + 1} ---');
    if (p.title.isNotEmpty) {
      b.writeln('[Section: ${p.title}]');
    }
    if (p.contentTitle.isNotEmpty && p.contentTitle != p.title) {
      b.writeln('[Content: ${p.contentTitle}]');
    }
    for (final line in p.paragraphs) {
      b.writeln(line);
      b.writeln();
    }
    if (p.comments != null && p.comments!.trim().isNotEmpty) {
      b.writeln('--- Comments ---');
      b.writeln(p.comments);
      b.writeln();
    }
  }
  return b.toString();
}
