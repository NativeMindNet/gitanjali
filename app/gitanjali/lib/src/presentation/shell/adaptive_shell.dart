import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../common/breakpoints.dart';
import 'phone_shell.dart';
import 'tablet_shell.dart';

/// Adaptive shell that switches between phone and tablet layouts
/// based on screen width.
///
/// - Phone (< 600px): Bottom toolbar navigation (Model A)
/// - Tablet (>= 600px): Tab bar + mini player (Model B)
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutMode = layoutModeOf(context);

    return switch (layoutMode) {
      LayoutMode.phone => const PhoneShell(),
      LayoutMode.tablet => const TabletShell(),
    };
  }
}
