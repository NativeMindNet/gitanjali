import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../common/breakpoints.dart';
import '../common/theme_tokens.dart';
import 'settings_controller.dart';

/// Full-screen settings page (used on tablets)
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.controller,
  });

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final padding = adaptivePadding(context);
    final maxWidth = contentMaxWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? double.infinity,
              ),
              child: ListView(
                padding: padding,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Language section
                  _SectionHeader(title: 'Language / Язык'),
                  _LanguageSelector(
                    value: controller.language,
                    onChanged: controller.setLanguage,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Text size section
                  _SectionHeader(title: 'Text Size / Размер текста'),
                  _TextSizeSelector(
                    value: controller.textSize,
                    onChanged: controller.setTextSize,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Theme section
                  _SectionHeader(title: 'Theme / Тема'),
                  _ThemeSelector(
                    value: controller.theme,
                    onChanged: controller.setTheme,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // About section
                  _SectionHeader(title: 'About'),
                  _AboutSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Settings content widget that can be used in both page and sheet
class SettingsContent extends StatelessWidget {
  const SettingsContent({
    super.key,
    required this.controller,
  });

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language section
            _SectionHeader(title: 'Language / Язык'),
            _LanguageSelector(
              value: controller.language,
              onChanged: controller.setLanguage,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Text size section
            _SectionHeader(title: 'Text Size / Размер текста'),
            _TextSizeSelector(
              value: controller.textSize,
              onChanged: controller.setTextSize,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Theme section
            _SectionHeader(title: 'Theme / Тема'),
            _ThemeSelector(
              value: controller.theme,
              onChanged: controller.setTheme,
            ),

            const SizedBox(height: AppSpacing.lg),

            // About section
            _AboutSection(),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.value,
    required this.onChanged,
  });

  final LanguageOption value;
  final ValueChanged<LanguageOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: LanguageOption.values.map((option) {
        return RadioListTile<LanguageOption>(
          title: Text(option.label),
          value: option,
          groupValue: value,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    );
  }
}

class _TextSizeSelector extends StatelessWidget {
  const _TextSizeSelector({
    required this.value,
    required this.onChanged,
  });

  final TextSizeOption value;
  final ValueChanged<TextSizeOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TextSizeOption>(
      segments: TextSizeOption.values.map((option) {
        return ButtonSegment<TextSizeOption>(
          value: option,
          label: Text(option.label),
        );
      }).toList(),
      selected: {value},
      onSelectionChanged: (newSelection) {
        onChanged(newSelection.first);
      },
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.value,
    required this.onChanged,
  });

  final ThemeOption value;
  final ValueChanged<ThemeOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ThemeOption.values.map((option) {
        return RadioListTile<ThemeOption>(
          title: Text(option.label),
          value: option,
          groupValue: value,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Version 1.0.0',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Sri Chaitanya Saraswat Math',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}
