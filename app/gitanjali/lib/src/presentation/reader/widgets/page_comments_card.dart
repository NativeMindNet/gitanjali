import 'package:flutter/material.dart';

class PageCommentsCard extends StatelessWidget {
  const PageCommentsCard({super.key, required this.comments});

  final String? comments;

  @override
  Widget build(BuildContext context) {
    final text = comments?.trim();
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}

