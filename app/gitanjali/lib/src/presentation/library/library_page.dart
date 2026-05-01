import 'package:flutter/material.dart';

import '../common/breakpoints.dart';
import '../common/theme_tokens.dart';

/// Library page with TOC categories over full-screen background
class LibraryPage extends StatelessWidget {
  const LibraryPage({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  final List<LibraryCategory> categories;
  final void Function(LibraryCategory category) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/legacy/Images/toc_background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accent.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.4),
                    ],
                  ),
                ),
              );
            },
          ),

          // Dark overlay for text readability
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Content
          SafeArea(
            child: _buildCategoryList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final padding = adaptivePadding(context);

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: padding.horizontal / 2,
        vertical: AppSpacing.xl,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryItem(
          category: category,
          onTap: () => onCategoryTap(category),
        );
      },
    );
  }
}

/// A single category item in the TOC list
class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.onTap,
  });

  final LibraryCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Text(
              category.title,
              textAlign: TextAlign.center,
              style: AppTypography.tocItem(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Model for a library category
class LibraryCategory {
  const LibraryCategory({
    required this.id,
    required this.title,
    required this.pageIndex,
  });

  final String id;
  final String title;
  final int pageIndex;
}
