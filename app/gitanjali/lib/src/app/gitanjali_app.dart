import 'package:flutter/material.dart';

import '../presentation/common/theme_tokens.dart';
import '../presentation/shell/adaptive_shell.dart';

/// Main application widget for Gitanjali
///
/// Uses AdaptiveShell to switch between phone and tablet layouts.
/// Supports light and dark themes via AppTheme.
class GitanjaliApp extends StatelessWidget {
  const GitanjaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sri Gaudiya Gitanjali',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // TODO: Connect to SettingsController

      // Adaptive shell as home
      home: const AdaptiveShell(),
    );
  }
}
