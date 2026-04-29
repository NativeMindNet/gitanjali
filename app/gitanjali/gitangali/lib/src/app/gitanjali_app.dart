import 'package:flutter/material.dart';

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
      ),
      home: const ReaderPage(),
    );
  }
}

