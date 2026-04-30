import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class PageParagraphs extends StatelessWidget {
  const PageParagraphs({super.key, required this.paragraphs});

  final List<ParagraphSpec> paragraphs;

  @override
  Widget build(BuildContext context) {
    final visible = paragraphs.where((paragraph) => !paragraph.hidden).toList();
    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final paragraph in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              paragraph.text,
              textAlign: paragraph.style.textAlign,
              style: TextStyle(
                fontFamily: paragraph.style.fontFamily,
                fontSize: paragraph.style.fontSize,
                color: paragraph.style.textColor,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

