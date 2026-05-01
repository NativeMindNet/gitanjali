import 'package:flutter/material.dart';

import '../../data/audio_controller.dart';
import '../../data/book_repository.dart';
import '../../data/reader_store.dart';
import '../../domain/models.dart';
import '../audio/audio_page.dart';
import '../common/theme_tokens.dart';
import '../reader/reader_controller.dart';
import '../reader/reader_page.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_page.dart';

/// Tablet shell with bottom tab bar and mini player (Model B)
///
/// Tabs:
/// - Home: Cover / Continue reading
/// - Library: TOC / Categories / Search / Bookmarks
/// - Audio: Now Playing / Audio library
/// - Settings: Language, text size, theme
class TabletShell extends StatefulWidget {
  const TabletShell({super.key});

  @override
  State<TabletShell> createState() => _TabletShellState();
}

class _TabletShellState extends State<TabletShell> {
  late final ReaderStore _store;
  late final SettingsController _settingsController;
  late final AudioController _audioController;
  late final ReaderController _readerController;

  int _currentTabIndex = 0;
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

    setState(() {}); // Rebuild for theme changes
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
    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildTabContent(),
          ),

          // Mini player (shown when audio is loaded)
          ListenableBuilder(
            listenable: _audioController,
            builder: (context, _) {
              if (!_audioController.hasTrack) {
                return const SizedBox.shrink();
              }
              return _MiniPlayerBar(audioController: _audioController);
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: 'Audio',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _currentTabIndex,
      children: [
        // Tab 0: Home - Reader
        ReaderPage(
          controller: _readerController,
          settingsController: _settingsController,
        ),

        // Tab 1: Library - Placeholder
        _PlaceholderTab(
          icon: Icons.library_books,
          title: 'Library',
          subtitle: 'TOC, Search, Bookmarks',
        ),

        // Tab 2: Audio
        AudioPage(audioController: _audioController),

        // Tab 3: Settings
        SettingsPage(controller: _settingsController),
      ],
    );
  }
}

/// Temporary mini player bar widget
class _MiniPlayerBar extends StatelessWidget {
  const _MiniPlayerBar({required this.audioController});

  final AudioController audioController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppLayout.miniPlayerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: StreamBuilder<Duration>(
        stream: audioController.positionStream,
        builder: (context, snapshot) {
          final position = audioController.position;
          final duration = audioController.duration;
          final progress = audioController.progress;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: Colors.transparent,
              ),

              // Controls row
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Play/Pause button
                      IconButton(
                        icon: Icon(
                          audioController.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 40,
                        ),
                        onPressed: audioController.togglePlayPause,
                      ),

                      const SizedBox(width: 12),

                      // Track info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audioController.currentDisplayName ?? 'Unknown',
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Timing display (tap to toggle)
                      GestureDetector(
                        onTap: audioController.toggleTimingDisplay,
                        child: Text(
                          audioController.showRemainingTime
                              ? '${formatDuration(position)} / ${formatRemainingTime(audioController.remaining)}'
                              : '${formatDuration(position)} / ${formatDuration(duration)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Expand button (placeholder)
                      IconButton(
                        icon: const Icon(Icons.expand_less),
                        onPressed: () {
                          // TODO: Show expanded player sheet
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Placeholder tab content
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Coming soon',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
