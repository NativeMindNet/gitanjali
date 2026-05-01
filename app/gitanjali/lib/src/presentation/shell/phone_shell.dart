import 'package:flutter/material.dart';

import '../../data/audio_controller.dart';
import '../../data/book_repository.dart';
import '../../data/reader_store.dart';
import '../../domain/models.dart';
import '../reader/reader_controller.dart';
import '../reader/reader_page.dart';
import '../settings/settings_controller.dart';

/// Phone shell with Navigator and bottom toolbar overlay (Model A)
///
/// Features:
/// - Single navigator for all screens
/// - Bottom toolbar with navigation controls
/// - Settings as modal bottom sheet
/// - Search as modal bottom sheet
class PhoneShell extends StatefulWidget {
  const PhoneShell({super.key});

  @override
  State<PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends State<PhoneShell> {
  late final ReaderStore _store;
  late final SettingsController _settingsController;
  late final AudioController _audioController;
  late final ReaderController _readerController;

  BookLanguage _currentLanguage = BookLanguage.eng;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _store = ReaderStore();
    _settingsController = SettingsController(store: _store);
    _audioController = AudioController();
    _readerController = ReaderController(
      repository: BookRepository(),
      store: _store,
      audioService: _audioController,
    );

    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _settingsController.initialize();
    _settingsController.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (!mounted) return;

    final systemLocale = Localizations.localeOf(context).languageCode;
    final newLanguage = _settingsController.effectiveLanguage(systemLocale);

    if (newLanguage != _currentLanguage) {
      _currentLanguage = newLanguage;
      _readerController.initialize(
        bookLanguage: newLanguage,
        forceReload: true,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      final systemLocale = Localizations.localeOf(context).languageCode;
      _currentLanguage = _settingsController.effectiveLanguage(systemLocale);
      _readerController.initialize(bookLanguage: _currentLanguage);
    }
  }

  @override
  void dispose() {
    _settingsController.removeListener(_onSettingsChanged);
    _settingsController.dispose();
    _audioController.dispose();
    _readerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For now, just render the existing ReaderPage
    // TODO: Replace with proper Navigator when other screens are ready
    return ListenableBuilder(
      listenable: _readerController,
      builder: (context, _) {
        return ReaderPageContent(
          controller: _readerController,
          settingsController: _settingsController,
          audioController: _audioController,
        );
      },
    );
  }
}

/// Extracted ReaderPage content that receives controllers from shell
class ReaderPageContent extends StatelessWidget {
  const ReaderPageContent({
    super.key,
    required this.controller,
    required this.settingsController,
    required this.audioController,
  });

  final ReaderController controller;
  final SettingsController settingsController;
  final AudioController audioController;

  @override
  Widget build(BuildContext context) {
    return ReaderPage(
      controller: controller,
      settingsController: settingsController,
    );
  }
}
