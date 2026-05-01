import 'package:flutter/material.dart';

import '../../common/theme_tokens.dart';

/// Block displaying a verse with number, original text, and translation
///
/// Layout:
/// ```
/// +------+------------------------------------------+
/// |  1   | jaya jaya girirajer arati visala         |
/// |      | sri gaura-mandala-majhe ...              |
/// |      |                                          |
/// |      | All glories to the grand arati...        |
/// +------+------------------------------------------+
/// ```
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.verseGap / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse number column
          SizedBox(
            width: AppLayout.verseNumberWidth,
            child: verseNumber != null
                ? Text(
                    '$verseNumber',
                    style: AppTypography.verseNumber(context).copyWith(
                      fontSize: 12 * textScaleFactor,
                    ),
                    textAlign: TextAlign.center,
                  )
                : null,
          ),

          // Content column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Original text
                Text(
                  original,
                  textAlign: TextAlign.center,
                  style: AppTypography.originalVerse(context).copyWith(
                    fontSize: 16 * textScaleFactor,
                  ),
                ),

                // Translation
                if (translation != null && translation!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    translation!,
                    textAlign: TextAlign.center,
                    style: AppTypography.translation(context).copyWith(
                      fontSize: 15 * textScaleFactor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Balance spacing on right
          const SizedBox(width: AppLayout.verseNumberWidth),
        ],
      ),
    );
  }
}

/// Simplified verse block without verse number (for phone layout)
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.paragraphGap / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Original text
          Text(
            original,
            textAlign: TextAlign.center,
            style: AppTypography.originalVerse(context).copyWith(
              fontSize: 16 * textScaleFactor,
            ),
          ),

          // Translation
          if (translation != null && translation!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              translation!,
              textAlign: TextAlign.center,
              style: AppTypography.translation(context).copyWith(
                fontSize: 15 * textScaleFactor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
