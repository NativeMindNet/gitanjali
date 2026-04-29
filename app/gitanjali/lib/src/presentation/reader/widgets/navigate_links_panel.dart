import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/models.dart';
import 'page_link_button.dart';

class NavigateLinksPanel extends StatelessWidget {
  const NavigateLinksPanel({
    super.key,
    required this.controls,
    required this.onControlTap,
  });

  final List<ControlInfo> controls;
  final Future<void> Function(ControlInfo control) onControlTap;

  @override
  Widget build(BuildContext context) {
    if (controls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(
          'Navigate',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: controls
              .map(
                (control) => PageLinkButton(
                  control: control,
                  onPressed: () => unawaited(onControlTap(control)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

