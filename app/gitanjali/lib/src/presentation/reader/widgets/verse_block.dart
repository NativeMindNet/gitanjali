import 'package:flutter/material.dart';
import 'package:flutter_versegrid/flutter_versegrid.dart';

import '../../common/theme_tokens.dart';

/// Block displaying a verse with number, original text, and translation.
///
/// Delegates layout to [VersePassage] from `flutter_versegrid`.
class VerseBlock extends StatelessWidget {
  const VerseBlock({
    super.key,
    this.verseNumber,
    required this.original,
    this.translation,
    this.textScaleFactor = 1.0,
  });

  /// Verse number (null to hide)
  final int? verseNumber;

  /// Original text (Sanskrit/Bengali transliteration)
  final String original;

  /// Translation text
  final String? translation;

  /// Scale factor for text size
  final double textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return VersePassage(
      layout: VersePassageLayout.tabletRow,
      verseNumber: verseNumber,
      primary: original,
      secondary: translation,
      textScaleFactor: textScaleFactor,
      primaryStyle: AppTypography.originalVerse(context),
      secondaryStyle: AppTypography.translation(context),
      verseNumberStyle: AppTypography.verseNumber(context),
    );
  }
}

/// Simplified verse block without verse number (for phone layout).
class SimpleVerseBlock extends StatelessWidget {
  const SimpleVerseBlock({
    super.key,
    required this.original,
    this.translation,
    this.textScaleFactor = 1.0,
  });

  final String original;
  final String? translation;
  final double textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return VersePassage(
      layout: VersePassageLayout.columnCenter,
      primary: original,
      secondary: translation,
      textScaleFactor: textScaleFactor,
      primaryStyle: AppTypography.originalVerse(context),
      secondaryStyle: AppTypography.translation(context),
    );
  }
}
