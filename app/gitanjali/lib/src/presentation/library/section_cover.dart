import 'package:flutter/material.dart';

import '../common/breakpoints.dart';
import '../common/theme_tokens.dart';

/// Section cover page with illustration and title
class SectionCover extends StatelessWidget {
  const SectionCover({
    super.key,
    required this.title,
    this.illustrationAsset,
    this.onTap,
  });

  final String title;
  final String? illustrationAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final padding = adaptivePadding(context);
    final maxWidth = contentMaxWidth(context);

    return GestureDetector(
      onTap: onTap,
      child: Scaffold(
        backgroundColor: AppColors.readerBackground,
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? double.infinity,
              ),
              padding: padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration
                  if (illustrationAsset != null)
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Image.asset(
                          illustrationAsset!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 64,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    const Spacer(flex: 2),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.pageTitle(context).copyWith(
                        fontSize: 28,
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
