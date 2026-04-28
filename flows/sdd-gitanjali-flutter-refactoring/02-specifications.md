# Specifications: gitanjali-flutter-refactoring

> Version: 1.0  
> Status: APPROVED  
> Last Updated: 2026-04-28  
> Requirements: `flows/sdd-gitanjali-flutter-refactoring/01-requirements.md`

## Overview

Новая реализация в `app/gitangali` должна заменить legacy Objective-C reader из `legacy/legacy_gitanjajali_swift` полноценным Flutter-приложением, которое использует локально упакованный контент и не зависит от legacy runtime-кода. Первая миграционная версия ориентируется на функциональную паритетность ядра продукта: reader, page navigation, page links, bookmarks, audio, search, и сохранение reader state.

Спецификация намеренно разделяет перенос на два уровня:
- **Must-build now**: базовая архитектура Flutter, XML ingestion, reader shell, bookmarks, search, audio, local persistence.
- **Can defer**: полная визуальная идентичность, сложные legacy animations, малоиспользуемые transition-режимы и UIKit-specific plumbing.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `app/gitangali/lib` | Create | New Flutter app architecture, models, services, screens, widgets |
| `app/gitangali/pubspec.yaml` | Modify | Add runtime packages, assets, fonts, and audio declarations |
| `app/gitangali/test` | Modify | Replace template test with targeted tests for parser/state/bootstrap |
| `app/gitangali/assets` | Create | New packaged content for XML, images, audio, and fonts |
| `legacy/legacy_gitanjajali_swift` | Read-only input | Source of truth for migration behavior and bundled content |
| `flows/sdd-gitanjali-flutter-refactoring` | Modify | SDD artifacts and implementation log updates |

## Architecture

### Component Diagram

```text
Bundled Flutter Assets
  ├─ XML book source
  ├─ images
  ├─ audio
  └─ fonts
          |
          v
BookAssetLoader -> BookXmlParser -> Domain Models -> ReaderRepository
                                              |             |
                                              |             +-> ReaderPersistence
                                              |             +-> AudioPlaybackService
                                              v
                                        ReaderController
                                              |
                  -------------------------------------------------
                  |                       |                       |
                  v                       v                       v
             ReaderScreen            SearchScreen          BookmarksScreen
                  |
                  v
     PageRenderer + ControlOverlay + MiniAudioPlayer
```

### Data Flow

```text
App startup
  -> load bundled XML/assets metadata
  -> parse into in-memory book structure
  -> restore last reader state from local storage
  -> build reader route at restored page

Reader interaction
  -> user gesture/control action
  -> ReaderController updates page index / bookmarks / search target / audio state
  -> UI rebuilds from controller state
  -> persistence updates in background-safe local storage
```

### Architectural Decisions

1. **Asset-first offline architecture**
   The Flutter app reads bundled assets directly and does not require network APIs or legacy runtime code.

2. **Direct XML consumption for v1**
   The first migration version should parse the existing legacy XML format directly instead of introducing a build-time conversion pipeline. This keeps parity work traceable against the source asset and lowers migration risk.

3. **Single source of truth for reader state**
   Current page, current book model, bookmarks, search jump targets, and active audio metadata should be coordinated by one reader-facing controller/service boundary rather than UIKit notifications.

4. **Simplified modern UI with functional parity**
   Flutter UI may modernize presentation details, but must preserve core reader behaviors and content semantics.

## Interfaces

### New Interfaces

```dart
abstract class BookRepository {
  Future<Book> loadBook();
}

abstract class ReaderStateStore {
  Future<ReaderState?> loadState();
  Future<void> saveState(ReaderState state);
}

abstract class BookmarkStore {
  Future<List<Bookmark>> loadBookmarks(String bookId);
  Future<void> saveBookmarks(String bookId, List<Bookmark> bookmarks);
}

abstract class AudioPlaybackService {
  Future<void> load(PageAudio audio);
  Future<void> play();
  Future<void> stop();
  Stream<AudioPlaybackState> watchState();
}
```

### Modified Interfaces

- No existing Dart interfaces are reused; the current app is still the default template.
- Native platform entrypoints remain scaffolded and continue to host the Flutter runtime without feature-specific logic.

## Data Models

### New Types

```dart
class Book {
  final BookMetadata metadata;
  final List<BookPage> pages;
  final BookSection rootSection;
  final List<ControlInfo> globalControls;
}

class BookPage {
  final int index;
  final List<Paragraph> paragraphs;
  final Paragraph? comments;
  final BackgroundSpec background;
  final PageAudio? audio;
  final List<ControlInfo> controls;
  final bool showNumber;
  final String? contentTitle;
}

class ReaderState {
  final int currentPageIndex;
  final String? highlightedQuery;
}
```

### Schema Changes

- No changes to the legacy XML source format in v1.
- Local persistence will move from legacy `NSUserDefaults` and XML bookmark files to Flutter-managed local storage.
- Bookmark storage format may change internally, but must preserve semantics: page-targeted entries scoped to a book identifier.

### XML Support Scope For V1

Must parse and represent:
- `book/head/body`
- `styles/style`
- recursive `section`
- `title`, `content-title`, `p`
- page `background`
- page and global `controls`
- page `audio`
- page `comments`
- page `show-number`

Deferred support allowed:
- legacy video animation targets
- exact page curl transitions
- any parser behavior only needed for unused legacy branches

## Behavior Specifications

### Happy Path

1. App starts and loads the bundled `Gitanjali` XML source plus referenced assets.
2. Parser produces a domain `Book` with flat page list and section tree.
3. Reader state store restores the last page index, if available.
4. Reader screen opens on the restored page.
5. User navigates via swipe, prev/next buttons, or `page-link` controls.
6. Page content renders with background, styled paragraphs, optional comments, and page number visibility.
7. If page audio exists, the user can play/stop it; autoplay starts when configured.
8. User can open search, search across the defined scopes, and jump to a selected result.
9. User can add bookmarks for the current page and reopen saved bookmarks later.
10. Reader state persists after relevant changes.

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Missing asset reference | XML points to missing image/audio file | App does not crash; missing media is skipped and issue is surfaced in debug logging |
| Invalid page-link target | Control `arg` cannot resolve to a page | Tap is ignored safely |
| Corrupt or unsupported XML node | Parser encounters unexpected content | Parsing fails with explicit error and app shows a recoverable failure screen |
| No saved reader state | First launch or cleared storage | Reader opens at the first available page |
| Page without audio | User presses audio-related controls | Controls are disabled or absent for that page |
| Empty search query | User opens search with no input | No filtered results are shown; app remains responsive |
| Out-of-range restored page index | Stored page no longer exists | Reader falls back to page `0` |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| Asset load failure | Missing or undeclared bundled file | Show app-level error state with retry/restart option in debug builds; fail gracefully in release |
| XML parse failure | Unsupported format or malformed source | Show content-load failure screen instead of crashing |
| Audio playback failure | Unsupported/failed local file playback | Show non-blocking message/state and keep reader usable |
| Persistence write failure | Storage unavailable or serialization issue | Keep in-memory session active and log failure |

## Dependencies

### Requires

- Flutter dependencies for XML parsing, local persistence, and audio playback
- Bundled migration of the legacy XML file, font(s), images, and audio assets into the Flutter app

### Blocks

- Implementation of the new reader shell in `app/gitangali`
- Any further modernization work that assumes a stable Flutter domain model

## Integration Points

### External Systems

- Flutter package for XML parsing
- Flutter package for local key-value/object persistence
- Flutter package for local audio playback

### Internal Systems

- `app/gitangali/lib/main.dart` becomes bootstrap into the real app shell
- New app modules under `app/gitangali/lib/src/...`
- `pubspec.yaml` will declare migrated assets and fonts

## Testing Strategy

### Unit Tests

- [ ] XML parser converts required legacy nodes into domain models
- [ ] Reader state restoration falls back correctly for empty/invalid persisted state
- [ ] Bookmark storage preserves add/remove/load behavior
- [ ] Search indexing/filtering returns expected pages for content/comments/titles

### Integration Tests

- [ ] App bootstrap loads bundled content and renders first/restored page
- [ ] Reader navigation updates visible page and persisted reader state
- [ ] Audio control flow works for pages with and without audio

### Manual Verification

- [ ] Launch `app/gitangali` and confirm the default counter demo is gone
- [ ] Navigate between several migrated pages using gestures and controls
- [ ] Open search and jump to at least one result in each supported scope
- [ ] Add, open, and delete bookmarks
- [ ] Restart app and confirm last page is restored

## Migration / Rollout

Migration will be implemented in staged slices inside the same Flutter app:

1. **Foundation**: app shell, dependencies, assets, domain models, parser, persistence contracts
2. **Reader core**: reader screen, page rendering, navigation, page links, saved position
3. **User features**: bookmarks, search, audio playback
4. **Polish**: visual refinement, optional animation support, expanded test coverage

The legacy Objective-C app remains the behavioral reference during migration and is not modified.

## Open Design Questions

- [ ] Which local persistence approach is preferred for bookmarks and reader state: lightweight key-value only, or a structured local database?
- [ ] Should the first version support legacy background animations immediately, or can that be explicitly deferred to phase 4?
- [ ] Is bookmark reordering required for parity in the first implementation slice, or only add/open/delete?

---

## Approval

- [x] Reviewed by: user
- [x] Approved on: 2026-04-28
- [x] Notes: Approved by user as-is
