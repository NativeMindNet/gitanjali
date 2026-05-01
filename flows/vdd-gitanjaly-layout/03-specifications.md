# Specifications: Gitanjali Adaptive Layout

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-01
> Requirements: [01-requirements.md](./01-requirements.md)
> Visual: [02-visual.md](./02-visual.md)

## Overview

Расширение Flutter приложения Gitanjali для поддержки:
1. Адаптивной навигации (Model A для телефонов, Model B для планшетов)
2. Новых типов экранов (Cover, TOC, Section Cover, Dedication)
3. Настроек пользователя (язык, размер текста, тема)
4. Mini player с seek и toggle timings
5. Улучшенной типографики (нумерация стихов, стилизация перевода)

---

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `lib/src/app/gitanjali_app.dart` | Modify | Routing, theme provider |
| `lib/src/domain/models.dart` | Modify | Add AppSettings, TextSizeOption, ThemeOption |
| `lib/src/data/reader_store.dart` | Modify | Add settings persistence |
| `lib/src/presentation/reader/` | Modify | Refactor to support new layouts |
| `lib/src/presentation/shell/` | Create | Adaptive shell (tab bar / toolbar) |
| `lib/src/presentation/cover/` | Create | Cover screen |
| `lib/src/presentation/library/` | Create | TOC / categories |
| `lib/src/presentation/settings/` | Create | Settings screen/sheet |
| `lib/src/presentation/audio/` | Create | Audio library / now playing |
| `lib/src/presentation/common/` | Create | Shared widgets (mini player, etc) |

---

## Architecture

### Component Diagram

```
GitanjaliApp
    │
    ├─ ThemeProvider (InheritedWidget or Provider)
    │   └─ manages: themeMode, textScale, locale
    │
    └─ AdaptiveShell (decides layout based on screen width)
        │
        ├─ [Phone Layout - Model A]
        │   └─ Navigator with bottom toolbar overlay
        │       ├─ CoverPage
        │       ├─ LibraryPage (TOC)
        │       ├─ ReaderPage
        │       ├─ SettingsSheet (modal)
        │       ├─ SearchSheet (modal)
        │       └─ BookmarksSheet (modal)
        │
        └─ [Tablet Layout - Model B]
            └─ Scaffold with persistent BottomNavigationBar
                ├─ Tab: Home → CoverPage / ContinueReading
                ├─ Tab: Library → LibraryPage (TOC + Search + Bookmarks)
                ├─ Tab: Audio → AudioLibraryPage / NowPlayingPage
                └─ Tab: Settings → SettingsPage (full screen)
                │
                └─ MiniPlayerBar (persistent, above tab bar)
```

### Breakpoint Detection

```dart
enum LayoutMode { phone, tablet }

LayoutMode layoutModeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width >= 600 ? LayoutMode.tablet : LayoutMode.phone;
}
```

### Data Flow

```
User Action (tap, swipe, settings change)
    │
    ▼
Controller (ChangeNotifier)
    │
    ├─ ReaderController (existing) - page navigation, bookmarks, search
    ├─ SettingsController (new) - language, textSize, theme
    └─ AudioController (refactored from AudioService) - playback, seek, timings
    │
    ▼
Store (SharedPreferences)
    │
    ▼
UI Update (notifyListeners → AnimatedBuilder / Consumer)
```

---

## Interfaces

### New: SettingsController

```dart
class SettingsController extends ChangeNotifier {
  SettingsController({required this.store});

  final ReaderStore store;

  LanguageOption _language = LanguageOption.auto;
  TextSizeOption _textSize = TextSizeOption.medium;
  ThemeOption _theme = ThemeOption.light;

  LanguageOption get language => _language;
  TextSizeOption get textSize => _textSize;
  ThemeOption get theme => _theme;

  BookLanguage get effectiveLanguage {
    if (_language == LanguageOption.auto) {
      return _systemLanguage();
    }
    return _language == LanguageOption.russian
        ? BookLanguage.ru
        : BookLanguage.eng;
  }

  double get textScaleFactor {
    switch (_textSize) {
      case TextSizeOption.small: return 0.85;
      case TextSizeOption.medium: return 1.0;
      case TextSizeOption.large: return 1.15;
      case TextSizeOption.extraLarge: return 1.3;
    }
  }

  ThemeMode get themeMode {
    switch (_theme) {
      case ThemeOption.light: return ThemeMode.light;
      case ThemeOption.dark: return ThemeMode.dark;
      case ThemeOption.system: return ThemeMode.system;
    }
  }

  Future<void> initialize() async { ... }
  Future<void> setLanguage(LanguageOption value) async { ... }
  Future<void> setTextSize(TextSizeOption value) async { ... }
  Future<void> setTheme(ThemeOption value) async { ... }
}
```

### New: AudioController (extends existing AudioService)

```dart
class AudioController extends ChangeNotifier {
  // Existing functionality
  Future<void> play(PageAudio audio) async { ... }
  Future<void> stop() async { ... }

  // New functionality
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  Duration get remaining => duration - position;

  Stream<Duration> get positionStream => _player.positionStream;

  bool showRemainingTime = true; // tap to toggle

  void toggleTimingDisplay() {
    showRemainingTime = !showRemainingTime;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekRelative(Duration delta) async {
    final newPosition = position + delta;
    await seekTo(newPosition.clamp(Duration.zero, duration));
  }
}
```

### Modified: ReaderStore

```dart
class ReaderStore {
  // Existing methods...

  // New settings methods
  Future<LanguageOption> loadLanguage() async { ... }
  Future<void> saveLanguage(LanguageOption value) async { ... }

  Future<TextSizeOption> loadTextSize() async { ... }
  Future<void> saveTextSize(TextSizeOption value) async { ... }

  Future<ThemeOption> loadTheme() async { ... }
  Future<void> saveTheme(ThemeOption value) async { ... }
}
```

---

## Data Models

### New Types

```dart
enum LanguageOption {
  auto('Автоматически / Auto'),
  russian('Русский'),
  english('English');

  const LanguageOption(this.label);
  final String label;
}

enum TextSizeOption {
  small('S'),
  medium('M'),
  large('L'),
  extraLarge('XL');

  const TextSizeOption(this.label);
  final String label;
}

enum ThemeOption {
  light('Светлая / Light'),
  dark('Тёмная / Dark'),
  system('Системная / System');

  const ThemeOption(this.label);
  final String label;
}

enum LayoutMode {
  phone,  // < 600px width
  tablet, // >= 600px width
}

/// Page type for different visual treatments
enum PageType {
  cover,      // Full-screen background with title
  toc,        // Table of contents / categories
  section,    // Section cover with illustration
  dedication, // Portrait + quote
  reader,     // Standard content page with verses
}
```

### Extended BookPage

```dart
class BookPage {
  // Existing fields...

  // New field for page type detection
  PageType get pageType {
    if (backgroundAsset != null && paragraphs.isEmpty && controls.isEmpty) {
      return PageType.cover;
    }
    if (linkControls.length > 3) {
      return PageType.toc;
    }
    // Additional heuristics...
    return PageType.reader;
  }
}
```

### Schema Changes (SharedPreferences keys)

```
reader_settings_language    -> String (auto|russian|english)
reader_settings_textSize    -> String (small|medium|large|extraLarge)
reader_settings_theme       -> String (light|dark|system)
```

---

## Widget Specifications

### AdaptiveShell

```dart
class AdaptiveShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mode = layoutModeOf(context);

    return switch (mode) {
      LayoutMode.phone => PhoneShell(),
      LayoutMode.tablet => TabletShell(),
    };
  }
}
```

### TabletShell (Model B)

```dart
class TabletShell extends StatefulWidget {
  // 4 tabs: Home, Library, Audio, Settings
  // Persistent MiniPlayerBar above BottomNavigationBar
  // Each tab has its own Navigator for nested navigation
}
```

### MiniPlayerBar

```dart
class MiniPlayerBar extends StatelessWidget {
  // Height: 64px
  // Components:
  //   - Play/Pause button (40x40)
  //   - Track title (flexible)
  //   - Timing display (tap to toggle: "1:30 / -2:36" <-> "1:30 / 4:06")
  //   - Seek slider (full width below)
  //   - Expand chevron (opens full player sheet)

  // Visibility: only shown when audio is loaded
}
```

### VerseBlock (for Reader page)

```dart
class VerseBlock extends StatelessWidget {
  const VerseBlock({
    required this.verseNumber,
    required this.original,
    required this.translation,
  });

  // Layout:
  // +------+------------------------------------------+
  // |  1   | jaya jaya girirajer arati visala         | <- original (center, dark)
  // |      | sri gaura-mandala-majhe ...              |
  // |      |                                          |
  // |      | All glories to the grand arati...        | <- translation (gray)
  // +------+------------------------------------------+

  // Verse number column: fixed width 40px, top-aligned
  // Original: centered, fontWeight medium, color dark
  // Translation: left-aligned, color gray (0.6 opacity)
}
```

### SettingsPage / SettingsSheet

```dart
class SettingsContent extends StatelessWidget {
  // Sections:
  // 1. Language (radio group: Auto, Русский, English)
  // 2. Text Size (segmented control: S, M, L, XL)
  // 3. Theme (radio group: Light, Dark, System)
  // 4. About (version, copyright)

  // On phone: shown as ModalBottomSheet
  // On tablet: shown as full-screen tab content
}
```

---

## Behavior Specifications

### Happy Path: Language Change

1. User opens Settings (tap [S] icon or Settings tab)
2. User selects different language (e.g., Русский → English)
3. System saves preference to SharedPreferences
4. SettingsController notifies listeners
5. ReaderController.initialize(forceReload: true) is called
6. Book content reloads with new language
7. User returns to reading at same page index

### Happy Path: Audio Playback with Seek

1. User taps Play on page with audio
2. AudioController.play() loads and starts track
3. MiniPlayerBar appears with track info
4. User drags seek slider
5. AudioController.seekTo() updates position
6. Playback continues from new position
7. Timing display updates in real-time

### Happy Path: Tablet Navigation

1. App launches, detects tablet (width >= 600)
2. TabletShell renders with 4 tabs
3. User taps Library tab
4. TOC categories displayed
5. User taps category
6. Section cover or content list shown
7. User taps item
8. Reader page opens with back button in header
9. User swipes to navigate between pages

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Language change mid-playback | User changes language while audio playing | Stop audio, reload content, user must restart playback |
| Orientation change | Device rotates | Layout adapts without losing state |
| Deep link to page | App opened via link | Navigate directly to page, initialize in background |
| Missing audio file | Referenced audio file not in assets | Show toast error, hide audio controls for that page |
| Very small screen (<320px) | Old device | Use XS breakpoint, minimal padding, scrollable content |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| Book load failure | XML parse error, missing file | Show error state with retry button |
| Audio load failure | Missing or corrupt audio file | Show toast "Audio unavailable", continue silently |
| Settings save failure | SharedPreferences error | Log error, continue with in-memory state |
| Image load failure | Missing asset | Show placeholder or empty container |

---

## Dependencies

### Requires

- Existing: `just_audio`, `shared_preferences`, `xml`
- No new dependencies required

### Blocks

- None (self-contained feature)

---

## Integration Points

### Internal Systems

| System | Integration |
|--------|------------|
| ReaderController | Receives language from SettingsController |
| AudioService | Extended to AudioController with seek/timings |
| ReaderStore | Extended with settings persistence |
| Theme | Managed by SettingsController.themeMode |

### External Systems

- None (offline-first app)

---

## Testing Strategy

### Unit Tests

- [ ] SettingsController - language/textSize/theme get/set
- [ ] AudioController - seek, timing toggle, remaining calculation
- [ ] ReaderStore - settings persistence round-trip
- [ ] LayoutMode detection - breakpoint thresholds

### Widget Tests

- [ ] AdaptiveShell - renders correct shell for width
- [ ] MiniPlayerBar - displays timings, responds to tap toggle
- [ ] SettingsContent - all options render and respond
- [ ] VerseBlock - verse number + original + translation layout
- [ ] TabletShell - 4 tabs present, navigation works

### Integration Tests

- [ ] Language change flow - settings → reload → content changes
- [ ] Audio seek flow - play → seek → position updates
- [ ] Tablet navigation - tab switch → nested navigation → back

### Manual Verification

- [ ] XS breakpoint (<360px) - readable, minimal UI
- [ ] SM breakpoint (360-599px) - standard phone layout
- [ ] MD breakpoint (600-899px) - tablet with tab bar
- [ ] LG breakpoint (>=900px) - desktop with centered content
- [ ] Portrait/Landscape rotation - smooth transition
- [ ] Dark theme - all screens readable

---

## Migration / Rollout

### Data Migration

- No migration needed
- New settings keys will be created on first use
- Defaults: language=auto, textSize=medium, theme=light

### Rollout

- Single release, no feature flags
- All users get adaptive layout
- Existing bookmarks and page position preserved

---

## Open Design Questions

- [x] Tab bar composition → 4 tabs: Home, Library, Audio, Settings
- [x] Timing format → elapsed + remaining (tap to toggle to elapsed + total)
- [x] Read tab → merged into Settings (text size + theme)

---

## File Structure (Proposed)

```
lib/
├── main.dart
└── src/
    ├── app/
    │   └── gitanjali_app.dart (modify: add ThemeProvider, routing)
    ├── data/
    │   ├── audio_service.dart → audio_controller.dart (rename + extend)
    │   ├── book_repository.dart
    │   ├── legacy_asset_resolver.dart
    │   ├── reader_store.dart (modify: add settings)
    │   └── xml_helpers.dart
    ├── domain/
    │   └── models.dart (modify: add enums, PageType)
    └── presentation/
        ├── shell/
        │   ├── adaptive_shell.dart (new)
        │   ├── phone_shell.dart (new)
        │   └── tablet_shell.dart (new)
        ├── cover/
        │   └── cover_page.dart (new)
        ├── library/
        │   ├── library_page.dart (new)
        │   ├── toc_list.dart (new)
        │   └── section_cover.dart (new)
        ├── reader/
        │   ├── reader_page.dart (modify)
        │   ├── reader_controller.dart (modify: receive settings)
        │   └── widgets/
        │       ├── verse_block.dart (new)
        │       ├── dedication_content.dart (new)
        │       └── ... (existing widgets)
        ├── audio/
        │   ├── audio_page.dart (new)
        │   └── mini_player_bar.dart (new)
        ├── settings/
        │   ├── settings_page.dart (new)
        │   ├── settings_sheet.dart (new)
        │   └── settings_controller.dart (new)
        └── common/
            ├── breakpoints.dart (new)
            └── theme_tokens.dart (new)
```

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-01
- [x] Notes: Specs approved, proceeding to PLAN phase
