import 'package:flutter/material.dart';

import '../common/theme_tokens.dart';

/// Full-screen cover/splash page with background image and title
class CoverPage extends StatelessWidget {
  const CoverPage({
    super.key,
    this.onTap,
  });

  /// Called when user taps to continue
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              'assets/legacy/Images/cover.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.accent.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.5),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Title
                  Text(
                    'Sri Gaudiya\nGitanjali',
                    textAlign: TextAlign.center,
                    style: AppTypography.coverTitle(context).copyWith(
                      color: Colors.white,
                      fontSize: 42,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Sri Chaitanya Saraswat Math',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamilyDefault,
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Tap to continue hint
                  if (onTap != null)
                    Text(
                      'Tap to continue',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
