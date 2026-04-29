import 'package:flutter/material.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.pages,
    required this.globalControls,
  });

  final String id;
  final String title;
  final List<BookPage> pages;
  final List<ControlInfo> globalControls;
}

class BookPage {
  const BookPage({
    required this.index,
    required this.title,
    required this.contentTitle,
    required this.paragraphs,
    required this.comments,
    required this.backgroundAsset,
    required this.controls,
    required this.showNumber,
    required this.audio,
  });

  final int index;
  final String title;
  final String? contentTitle;
  final List<ParagraphSpec> paragraphs;
  final String? comments;
  final String? backgroundAsset;
  final List<ControlInfo> controls;
  final bool showNumber;
  final PageAudio? audio;

  String get searchableContent => paragraphs.map((e) => e.text).join(' ').toLowerCase();

  List<ControlInfo> get linkControls =>
      controls.where((control) => control.type == ControlType.pageLink).toList();

  BookPage copyWith({int? index}) {
    return BookPage(
      index: index ?? this.index,
      title: title,
      contentTitle: contentTitle,
      paragraphs: paragraphs,
      comments: comments,
      backgroundAsset: backgroundAsset,
      controls: controls,
      showNumber: showNumber,
      audio: audio,
    );
  }
}

class PageDraft {
  PageDraft({
    required this.title,
    required this.contentTitle,
  });

  String title;
  String contentTitle;
  final List<ParagraphSpec> paragraphs = <ParagraphSpec>[];
  final List<ControlInfo> controls = <ControlInfo>[];
  String? comments;
  String? backgroundAsset;
  bool showNumber = true;
  PageAudio? audio;

  bool get hasVisibleContent =>
      paragraphs.isNotEmpty ||
      controls.isNotEmpty ||
      comments?.trim().isNotEmpty == true ||
      backgroundAsset != null ||
      audio != null;

  BookPage build() {
    return BookPage(
      index: 0,
      title: title,
      contentTitle: contentTitle.isEmpty ? null : contentTitle,
      paragraphs: List<ParagraphSpec>.unmodifiable(paragraphs),
      comments: comments,
      backgroundAsset: backgroundAsset,
      controls: List<ControlInfo>.unmodifiable(controls),
      showNumber: showNumber,
      audio: audio,
    );
  }
}

class ParagraphSpec {
  const ParagraphSpec({
    required this.text,
    required this.hidden,
    required this.style,
  });

  final String text;
  final bool hidden;
  final ParagraphStyleSpec style;
}

class ParagraphStyleSpec {
  const ParagraphStyleSpec({
    required this.fontFamily,
    required this.fontSize,
    required this.textAlign,
    required this.textColor,
  });

  final String fontFamily;
  final double fontSize;
  final TextAlign textAlign;
  final Color textColor;
}

class PageAudio {
  const PageAudio({
    required this.assetPath,
    required this.displayName,
    required this.autoplay,
    required this.loop,
  });

  final String assetPath;
  final String displayName;
  final bool autoplay;
  final bool loop;
}

class SearchResult {
  const SearchResult({
    required this.pageIndex,
    required this.title,
    required this.excerpt,
  });

  final int pageIndex;
  final String title;
  final String excerpt;
}

enum SearchScope {
  content('Content'),
  comments('Comments'),
  titles('Titles');

  const SearchScope(this.label);

  final String label;
}

enum ControlType {
  prevPage,
  nextPage,
  bookmarks,
  addBookmark,
  playSound,
  stopSound,
  togglePlayer,
  search,
  pageLink,
  unknown,
}

extension ControlTypeX on ControlType {
  static ControlType fromXml(String? value) {
    switch (value) {
      case 'prev-page':
        return ControlType.prevPage;
      case 'next-page':
        return ControlType.nextPage;
      case 'bookmarks':
        return ControlType.bookmarks;
      case 'add-bookmark':
        return ControlType.addBookmark;
      case 'play-sound':
        return ControlType.playSound;
      case 'stop-sound':
        return ControlType.stopSound;
      case 'toggle-player':
        return ControlType.togglePlayer;
      case 'search':
        return ControlType.search;
      case 'page-link':
        return ControlType.pageLink;
      default:
        return ControlType.unknown;
    }
  }
}

class ControlInfo {
  const ControlInfo({
    required this.type,
    required this.targetPageIndex,
    required this.imageAsset,
    required this.highlightedImageAsset,
  });

  final ControlType type;
  final int? targetPageIndex;
  final String? imageAsset;
  final String? highlightedImageAsset;
}

