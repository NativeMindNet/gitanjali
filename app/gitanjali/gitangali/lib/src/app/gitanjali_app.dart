import 'package:flutter/material.dart';
import 'package:flutter_versegrid/flutter_versegrid.dart';

import '../presentation/reader/reader_page.dart';

class GitanjaliApp extends StatelessWidget {
  const GitanjaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sri Gaudiya Gitanjali',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F4E37)),
        scaffoldBackgroundColor: const Color(0xFFF6EFE3),
        fontFamily: 'MurariChandUni',
        extensions: const <ThemeExtension<dynamic>>[
          VerseGridTheme(
            verseNumberColumnWidth: 40,
            rowVerticalPadding: 12,
            columnVerticalPadding: 9,
            gapOriginalToTranslation: 16,
            gapOriginalToTranslationCompact: 8,
            defaultOriginalFontSize: 16,
            defaultTranslationFontSize: 15,
            defaultVerseNumberFontSize: 12,
          ),
        ],
      ),
      home: const ReaderPage(),
    );
  }
}

