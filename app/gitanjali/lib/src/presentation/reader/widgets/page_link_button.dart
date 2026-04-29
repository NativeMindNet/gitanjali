import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class PageLinkButton extends StatelessWidget {
  const PageLinkButton({
    super.key,
    required this.control,
    required this.onPressed,
  });

  final ControlInfo control;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final asset = control.highlightedImageAsset ?? control.imageAsset;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade200),
        ),
        child: asset == null
            ? Center(
                child: Text(
                  'Page ${control.targetPageIndex! + 1}',
                  textAlign: TextAlign.center,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      'Page ${control.targetPageIndex! + 1}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

