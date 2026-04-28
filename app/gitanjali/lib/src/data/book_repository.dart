import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../domain/models.dart';
import 'legacy_asset_resolver.dart';
import 'xml_helpers.dart';

class BookRepository {
  static const String bookAsset = 'assets/legacy/example.xml';

  Future<Book> loadBook() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final resolver = LegacyAssetResolver(manifest.listAssets());
    final source = await rootBundle.loadString(bookAsset);

    final document = XmlDocument.parse(source);
    final root = document.rootElement;
    if (root.name.local != 'book' || root.getAttribute('version') != '1.0') {
      throw StateError('Unsupported book format');
    }

    final head = root.getElement('head');
    final body = root.getElement('body');
    if (head == null || body == null) {
      throw StateError('Book is missing head/body');
    }

    final styles = _parseStyles(body);
    final globalControls = _parseControls(head.findElements('controls').firstOrNull, resolver);
    final rootSection = body.getElement('section');
    if (rootSection == null) {
      throw StateError('Book body does not contain a root section');
    }

    final pages = <BookPage>[];
    _parseSection(
      rootSection,
      pages: pages,
      resolver: resolver,
      styles: styles,
      inheritedTitle: '',
      inheritedContentTitle: '',
    );

    return Book(
      id: head.getElementText('id') ?? 'gitanjali',
      title: head.getElementText('book-title') ?? 'Sri Gaudiya Gitanjali',
      pages: [
        for (var i = 0; i < pages.length; i++) pages[i].copyWith(index: i),
      ],
      globalControls: globalControls,
    );
  }

  Map<String, ParagraphStyleSpec> _parseStyles(XmlElement body) {
    final styles = <String, ParagraphStyleSpec>{};
    for (final element in body.findAllElements('style')) {
      final name = element.getAttribute('name');
      if (name == null || name.isEmpty) {
        continue;
      }
      styles[name] = _paragraphStyleFromAttributes(element, null);
    }
    return styles;
  }

  void _parseSection(
    XmlElement section, {
    required List<BookPage> pages,
    required LegacyAssetResolver resolver,
    required Map<String, ParagraphStyleSpec> styles,
    required String inheritedTitle,
    required String inheritedContentTitle,
  }) {
    var sectionTitle = inheritedTitle;
    var contentTitle = inheritedContentTitle;
    var draft = PageDraft(title: sectionTitle, contentTitle: contentTitle);

    for (final child in section.childElements) {
      switch (child.name.local) {
        case 'title':
          sectionTitle =
              _parseParagraphContainer(child, styles).map((e) => e.text).join(' ').trim();
          if (sectionTitle.isNotEmpty) {
            draft.title = sectionTitle;
          }
        case 'content-title':
          contentTitle =
              _parseParagraphContainer(child, styles).map((e) => e.text).join(' ').trim();
          draft.contentTitle = contentTitle;
        case 'p':
          draft.paragraphs.add(_parseParagraph(child, styles));
        case 'page':
          _applyPageMetadata(draft, child, resolver, styles);
          if (draft.hasVisibleContent) {
            pages.add(draft.build());
          }
          draft = PageDraft(
            title: sectionTitle,
            contentTitle: contentTitle.isEmpty ? sectionTitle : contentTitle,
          );
        case 'section':
          _parseSection(
            child,
            pages: pages,
            resolver: resolver,
            styles: styles,
            inheritedTitle: sectionTitle,
            inheritedContentTitle: contentTitle.isEmpty ? sectionTitle : contentTitle,
          );
        default:
          break;
      }
    }

    if (draft.hasVisibleContent) {
      pages.add(draft.build());
    }
  }

  void _applyPageMetadata(
    PageDraft draft,
    XmlElement page,
    LegacyAssetResolver resolver,
    Map<String, ParagraphStyleSpec> styles,
  ) {
    for (final child in page.childElements) {
      switch (child.name.local) {
        case 'p':
          draft.paragraphs.add(_parseParagraph(child, styles));
        case 'comments':
          draft.comments = _parseParagraphContainer(child, styles).map((e) => e.text).join('\n');
        case 'show-number':
          draft.showNumber = child.innerText.trim() != '0';
        case 'controls':
          draft.controls.addAll(_parseControls(child, resolver));
        case 'audio':
          final resolved = resolver.resolveAudio(child.innerText.trim());
          if (resolved != null) {
            draft.audio = PageAudio(
              assetPath: resolved,
              displayName: _displayNameFromAsset(resolved),
              autoplay: _truthy(child.getAttribute('autoplay')),
              loop: _truthy(child.getAttribute('loop')),
            );
          }
        case 'background':
          draft.backgroundAsset = _parseBackground(child, resolver);
        default:
          break;
      }
    }
  }

  String? _parseBackground(XmlElement background, LegacyAssetResolver resolver) {
    final imageAttribute = background.getAttribute('image');
    if (imageAttribute != null) {
      return resolver.resolveImage(imageAttribute);
    }

    for (final target in background.findAllElements('target')) {
      final type = target.getAttribute('type');
      final value = target.innerText.trim();
      if (type == 'image') {
        final resolved = resolver.resolveImage(value);
        if (resolved != null) {
          return resolved;
        }
      }
      if (type == 'keyframe') {
        final resolved = resolver.resolveKeyframePreview(value);
        if (resolved != null) {
          return resolved;
        }
      }
    }
    return null;
  }

  List<ParagraphSpec> _parseParagraphContainer(
    XmlElement element,
    Map<String, ParagraphStyleSpec> styles,
  ) {
    return element.findElements('p').map((paragraph) => _parseParagraph(paragraph, styles)).toList();
  }

  ParagraphSpec _parseParagraph(
    XmlElement element,
    Map<String, ParagraphStyleSpec> styles,
  ) {
    final styleName = element.getAttribute('style');
    final baseStyle = styles[styleName];
    final style = _paragraphStyleFromAttributes(element, baseStyle);
    return ParagraphSpec(
      text: element.innerText.trim(),
      hidden: _truthy(element.getAttribute('hidden')),
      style: style,
    );
  }

  List<ControlInfo> _parseControls(XmlElement? controls, LegacyAssetResolver resolver) {
    if (controls == null) {
      return const [];
    }
    return controls.findElements('control').map((control) {
      final type = ControlTypeX.fromXml(control.getAttribute('type'));
      final arg = control.getElementText('arg');
      final targetPageIndex = arg == null ? null : int.tryParse(arg)?.let((value) => value - 1);
      return ControlInfo(
        type: type,
        targetPageIndex: targetPageIndex,
        imageAsset: resolver.resolveImage(control.getElementText('image')),
        highlightedImageAsset: resolver.resolveImage(control.getElementText('highlighted-image')),
      );
    }).toList();
  }

  ParagraphStyleSpec _paragraphStyleFromAttributes(
    XmlElement element,
    ParagraphStyleSpec? base,
  ) {
    return ParagraphStyleSpec(
      fontFamily: element.getAttribute('font-name') ?? base?.fontFamily ?? 'MurariChandUni',
      fontSize:
          double.tryParse(element.getAttribute('font-size') ?? '') ?? base?.fontSize ?? 18,
      textAlign:
          _parseTextAlign(element.getAttribute('text-alignment')) ?? base?.textAlign ?? TextAlign.left,
      textColor:
          _parseColor(element.getAttribute('text-color')) ?? base?.textColor ?? const Color(0xDD000000),
    );
  }

  TextAlign? _parseTextAlign(String? value) {
    switch (value?.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justified':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }

  Color? _parseColor(String? value) {
    if (value == null || !value.startsWith('#')) {
      return null;
    }
    final hex = value.substring(1);
    if (hex.length != 6) {
      return null;
    }
    return Color(int.parse('FF$hex', radix: 16));
  }

  bool _truthy(String? value) => value == '1' || value?.toLowerCase() == 'true';

  String _displayNameFromAsset(String assetPath) {
    final name = assetPath.split('/').last;
    return name.replaceAll('.m4a', '').replaceAll('-', ' ');
  }
}

