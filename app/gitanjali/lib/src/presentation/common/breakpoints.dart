import 'package:flutter/widgets.dart';

import '../../domain/models.dart';

/// Breakpoint thresholds for adaptive layout
class Breakpoints {
  Breakpoints._();

  /// XS: Very small phones (< 360px)
  static const double xs = 360;

  /// SM: Standard phones (360-599px)
  static const double sm = 600;

  /// MD: Tablets (600-899px)
  static const double md = 900;

  /// LG: Desktop / large tablets (>= 900px)
  static const double lg = 900;

  /// Threshold for switching between phone and tablet layout
  static const double phoneTabletThreshold = 600;
}

/// Returns the current layout mode based on screen width
LayoutMode layoutModeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width >= Breakpoints.phoneTabletThreshold
      ? LayoutMode.tablet
      : LayoutMode.phone;
}

/// Returns adaptive padding based on screen width
EdgeInsets adaptivePadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;

  if (width < Breakpoints.xs) {
    return const EdgeInsets.symmetric(horizontal: 8);
  } else if (width < Breakpoints.sm) {
    return const EdgeInsets.symmetric(horizontal: 16);
  } else if (width < Breakpoints.md) {
    return const EdgeInsets.symmetric(horizontal: 24);
  } else {
    return const EdgeInsets.symmetric(horizontal: 32);
  }
}

/// Returns the content max width for large screens
double? contentMaxWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width >= Breakpoints.md ? 800 : null;
}

/// Extension for easy access to layout mode
extension LayoutModeX on BuildContext {
  LayoutMode get layoutMode => layoutModeOf(this);
  bool get isPhone => layoutMode == LayoutMode.phone;
  bool get isTablet => layoutMode == LayoutMode.tablet;
}
