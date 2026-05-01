import 'package:flutter/material.dart';

import '../../common/breakpoints.dart';
import '../../common/theme_tokens.dart';

/// Content widget for dedication/biography pages
///
/// Layout:
/// ```
/// +---------------------------+
/// |      [Portrait Image]     |
/// |                           |
/// |   "Quote text centered    |
/// |    across multiple        |
/// |    lines if needed"       |
/// |                           |
/// |      — Attribution        |
/// +---------------------------+
/// ```
class DedicationContent extends StatelessWidget {
  const DedicationContent({
    super.key,
    this.portraitAsset,
    required this.quote,
    this.attribution,
    this.textScaleFactor = 1.0,
  });

  /// Path to portrait image asset (null to hide)
  final String? portraitAsset;

  /// Main quote text
  final String quote;

  /// Attribution line (e.g., "— Sri Bhaktivinoda Thakura")
  final String? attribution;

  /// Scale factor for text size
  final double textScaleFactor;

  @override
  Widget build(BuildContext context) {
    final maxWidth = contentMaxWidth(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
        ),
        padding: adaptivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Portrait image
            if (portraitAsset != null) ...[
              _PortraitImage(assetPath: portraitAsset!),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Quote
            Text(
              quote,
              textAlign: TextAlign.center,
              style: AppTypography.quote(context).copyWith(
                fontSize: 18 * textScaleFactor,
              ),
            ),

            // Attribution
            if (attribution != null && attribution!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                attribution!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                      fontSize: 14 * textScaleFactor,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PortraitImage extends StatelessWidget {
  const _PortraitImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 280,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 160,
            height: 220,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.person,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
          );
        },
      ),
    );
  }
}
