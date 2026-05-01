import 'package:flutter/material.dart';

import '../common/theme_tokens.dart';
import 'settings_controller.dart';
import 'settings_page.dart';

/// Modal bottom sheet for settings (used on phones)
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.controller,
  });

  final SettingsController controller;

  /// Show settings sheet as modal bottom sheet
  static Future<void> show(BuildContext context, SettingsController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SettingsSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SettingsContent(controller: controller),
              ),
            ),
          ],
        );
      },
    );
  }
}
