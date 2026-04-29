import 'package:flutter/material.dart';

class ReaderPageHeader extends StatelessWidget {
  const ReaderPageHeader({
    super.key,
    required this.title,
    required this.showNumber,
    required this.pageIndex,
  });

  final String title;
  final bool showNumber;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.trim().isNotEmpty)
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5A3D2B),
                ),
          ),
        if (showNumber) ...[
          const SizedBox(height: 8),
          Text(
            'Page ${pageIndex + 1}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.brown.shade700,
                ),
          ),
        ],
      ],
    );
  }
}

