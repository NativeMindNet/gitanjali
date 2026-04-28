# Implementation Plan: gitanjali-flutter-refactoring

> Version: 1.0  
> Status: APPROVED  
> Last Updated: 2026-04-28  
> Specifications: `flows/sdd-gitanjali-flutter-refactoring/02-specifications.md`

## Summary

Implementation will replace the starter Flutter template in `app/gitangali` with a staged offline reader application driven by the legacy `Gitanjali` XML and bundled media. Work is split so that each phase leaves the app in a runnable and testable state: first establish app structure and assets, then load/parse the book, then render/navigate pages, then add bookmarks/search/audio, and finally harden with tests and polish.

The plan intentionally prioritizes feature slices that unlock verification early. A basic reader with real content is more valuable than implementing advanced animations or exact legacy chrome first.

## Task Breakdown

### Phase 1: Foundation

#### Task 1.1: Prepare Flutter app dependencies and directory structure
- **Description**: Replace the starter setup with a real app skeleton, add required packages, and establish `lib/src/...` module boundaries for app, domain, data, and presentation layers.
- **Files**:
  - `app/gitangali/pubspec.yaml` - Modify
  - `app/gitangali/lib/main.dart` - Modify
  - `app/gitangali/lib/src/app/` - Create
  - `app/gitangali/lib/src/domain/` - Create
  - `app/gitangali/lib/src/data/` - Create
  - `app/gitangali/lib/src/presentation/` - Create
- **Dependencies**: None
- **Verification**: `flutter pub get` succeeds and app boots into a non-template shell
- **Complexity**: Medium

#### Task 1.2: Package legacy source assets into Flutter app
- **Description**: Copy or reorganize required XML, image, audio, and font assets from `legacy/legacy_gitanjajali_swift/Gitanjali/Resources` into `app/gitangali/assets` and declare them in `pubspec.yaml`.
- **Files**:
  - `app/gitangali/assets/book/` - Create
  - `app/gitangali/assets/images/` - Create
  - `app/gitangali/assets/audio/` - Create
  - `app/gitangali/assets/fonts/` - Create
  - `app/gitangali/pubspec.yaml` - Modify
- **Dependencies**: Task 1.1
- **Verification**: Flutter can resolve the bundled XML, representative images, the custom font, and representative audio files at runtime
- **Complexity**: High

#### Task 1.3: Define core domain models and repository contracts
- **Description**: Implement the Dart types for book metadata, sections, pages, paragraphs, controls, audio, bookmarks, and reader state, along with repository/service interfaces from the specification.
- **Files**:
  - `app/gitangali/lib/src/domain/models/` - Create
  - `app/gitangali/lib/src/domain/services/` - Create
  - `app/gitangali/lib/src/domain/repositories/` - Create
- **Dependencies**: Task 1.1
- **Verification**: Domain model layer compiles and is usable by parser and UI layers
- **Complexity**: Medium

### Phase 2: Content Loading And Reader Core

#### Task 2.1: Implement asset loader and XML parser
- **Description**: Read the bundled XML and convert the supported legacy schema into the new domain models, including sections, pages, styles, backgrounds, controls, comments, and audio metadata.
- **Files**:
  - `app/gitangali/lib/src/data/assets/` - Create
  - `app/gitangali/lib/src/data/parsing/` - Create
  - `app/gitangali/lib/src/data/repositories/book_repository_impl.dart` - Create
  - `app/gitangali/test/` - Modify/Create parser-focused tests
- **Dependencies**: Tasks 1.2, 1.3
- **Verification**: Tests confirm parser output for required XML nodes and app can load the book from assets
- **Complexity**: High

#### Task 2.2: Implement reader state persistence
- **Description**: Add local persistence for current page position and bookmarks storage contracts, including fallback behavior for invalid or missing saved state.
- **Files**:
  - `app/gitangali/lib/src/data/persistence/` - Create
  - `app/gitangali/lib/src/data/repositories/reader_state_store_impl.dart` - Create
  - `app/gitangali/lib/src/data/repositories/bookmark_store_impl.dart` - Create
  - `app/gitangali/test/` - Modify/Create persistence tests
- **Dependencies**: Tasks 1.1, 1.3
- **Verification**: Stored state survives app restart simulation and invalid state falls back safely
- **Complexity**: Medium

#### Task 2.3: Build reader controller and bootstrap flow
- **Description**: Implement the central controller that loads the book, restores saved state, exposes current page data, and coordinates navigation/bookmark/audio/search actions.
- **Files**:
  - `app/gitangali/lib/src/app/bootstrap/` - Create
  - `app/gitangali/lib/src/presentation/reader/reader_controller.dart` - Create
  - `app/gitangali/lib/main.dart` - Modify
  - `app/gitangali/test/` - Modify/Create bootstrap/controller tests
- **Dependencies**: Tasks 2.1, 2.2
- **Verification**: App startup reaches a loaded reader state with restored page index when available
- **Complexity**: High

#### Task 2.4: Build reader screen and page rendering widgets
- **Description**: Replace the demo UI with a functional reader screen that renders backgrounds, styled text, page number visibility, and base control surfaces.
- **Files**:
  - `app/gitangali/lib/src/presentation/reader/screens/reader_screen.dart` - Create
  - `app/gitangali/lib/src/presentation/reader/widgets/` - Create
  - `app/gitangali/test/` - Modify/Create reader widget tests
- **Dependencies**: Task 2.3
- **Verification**: App displays real book content instead of the counter demo
- **Complexity**: High

#### Task 2.5: Implement navigation gestures and page-link controls
- **Description**: Add prev/next navigation, swipe gestures, and XML-driven `page-link` control handling on top of the reader screen.
- **Files**:
  - `app/gitangali/lib/src/presentation/reader/reader_controller.dart` - Modify
  - `app/gitangali/lib/src/presentation/reader/widgets/` - Modify
  - `app/gitangali/test/` - Modify/Create navigation tests
- **Dependencies**: Task 2.4
- **Verification**: User can change pages via gestures and control taps, and invalid links fail safely
- **Complexity**: Medium

### Phase 3: User Features

#### Task 3.1: Implement bookmarks flow
- **Description**: Support add/open/delete bookmark behavior for the current page, backed by local storage and exposed through a Flutter screen or sheet.
- **Files**:
  - `app/gitangali/lib/src/presentation/bookmarks/` - Create
  - `app/gitangali/lib/src/presentation/reader/reader_controller.dart` - Modify
  - `app/gitangali/lib/src/data/repositories/bookmark_store_impl.dart` - Modify
  - `app/gitangali/test/` - Modify/Create bookmark tests
- **Dependencies**: Tasks 2.2, 2.4
- **Verification**: User can save, open, and delete bookmarks across sessions
- **Complexity**: Medium

#### Task 3.2: Implement search flow
- **Description**: Build a Flutter search experience with the three legacy scopes: content, comments, and titles, with result selection jumping back into the reader.
- **Files**:
  - `app/gitangali/lib/src/presentation/search/` - Create
  - `app/gitangali/lib/src/presentation/reader/reader_controller.dart` - Modify
  - `app/gitangali/lib/src/domain/services/` - Modify/Create search abstractions
  - `app/gitangali/test/` - Modify/Create search tests
- **Dependencies**: Tasks 2.1, 2.4
- **Verification**: Search returns expected results for each scope and selecting one navigates to the matching page
- **Complexity**: High

#### Task 3.3: Implement page audio playback
- **Description**: Add audio service integration for page-bound tracks, including play/stop, autoplay, and minimal shared player UI state.
- **Files**:
  - `app/gitangali/lib/src/data/audio/` - Create
  - `app/gitangali/lib/src/presentation/audio/` - Create
  - `app/gitangali/lib/src/presentation/reader/reader_controller.dart` - Modify
  - `app/gitangali/test/` - Modify/Create audio service tests
- **Dependencies**: Tasks 2.1, 2.4
- **Verification**: Pages with audio can play and stop local tracks, and autoplay works when flagged
- **Complexity**: Medium

### Phase 4: Testing And Polish

#### Task 4.1: Remove remaining template artifacts and tighten visual polish
- **Description**: Eliminate leftover demo naming/text/tests, align app theme and titles with product identity, and ensure the UI feels coherent with migrated assets.
- **Files**:
  - `app/gitangali/README.md` - Modify
  - `app/gitangali/lib/main.dart` - Modify
  - `app/gitangali/test/widget_test.dart` - Modify or Delete
  - `app/gitangali/lib/src/...` - Modify
- **Dependencies**: Tasks 2.4, 3.1, 3.2, 3.3
- **Verification**: No counter-demo text or behavior remains anywhere in the app or tests
- **Complexity**: Low

#### Task 4.2: Expand regression coverage and run verification passes
- **Description**: Add focused unit/widget tests for the parser, reader state, bookmarks, search, and bootstrap flow; run Flutter analysis/tests and perform manual parity checks.
- **Files**:
  - `app/gitangali/test/` - Modify/Create
  - `app/gitangali/lib/src/...` - Modify if fixes are needed
- **Dependencies**: All previous implementation tasks
- **Verification**: `flutter test` and static analysis succeed; manual verification checklist is completed
- **Complexity**: Medium

#### Task 4.3: Evaluate deferred animation support
- **Description**: Decide whether image/keyframe background animation support is needed for this iteration and either implement a minimal version or explicitly defer it in the implementation log.
- **Files**:
  - `app/gitangali/lib/src/presentation/reader/widgets/` - Modify/Create
  - `flows/sdd-gitanjali-flutter-refactoring/04-implementation-log.md` - Modify
- **Dependencies**: Task 2.4
- **Verification**: Decision and outcome are documented; if implemented, representative animated backgrounds render
- **Complexity**: Medium

## Dependency Graph

```text
Task 1.1 -> Task 1.2 -> Task 2.1 -> Task 2.3 -> Task 2.4 -> Task 2.5
    |          |           |          |          |-> Task 3.1
    |          |           |          |          |-> Task 3.2
    |          |           |          |          |-> Task 3.3
    |          |           |
    |          |           -> Task 3.2
    |          |
    |          -> Task 2.1
    |
    -> Task 1.3 -> Task 2.1
    -> Task 2.2 -> Task 2.3 -> Task 3.1

Tasks 3.1, 3.2, 3.3 -> Task 4.1 -> Task 4.2
Task 2.4 -> Task 4.3
```

## File Change Summary

| File | Action | Reason |
|------|--------|--------|
| `app/gitangali/pubspec.yaml` | Modify | Add assets, fonts, and implementation dependencies |
| `app/gitangali/lib/main.dart` | Modify | Replace starter entrypoint with app bootstrap |
| `app/gitangali/lib/src/app/...` | Create | App composition and bootstrap |
| `app/gitangali/lib/src/domain/...` | Create | Book, page, control, bookmark, and reader models |
| `app/gitangali/lib/src/data/...` | Create | Asset loading, XML parsing, persistence, audio integrations |
| `app/gitangali/lib/src/presentation/...` | Create | Reader, search, bookmarks, and audio UI |
| `app/gitangali/assets/...` | Create | Migrated XML, images, audio, and font assets |
| `app/gitangali/test/...` | Modify/Create | Replace template tests with feature-focused coverage |
| `flows/sdd-gitanjali-flutter-refactoring/04-implementation-log.md` | Modify | Track implementation progress and deferrals |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Asset bundle becomes too large or awkward to manage manually | Medium | High | Migrate assets in structured directories and verify asset lookups early |
| Legacy XML semantics differ from assumptions in Flutter parser | High | High | Implement parser incrementally with tests against representative nodes and real sample content |
| Styled text rendering diverges too far from legacy layout | Medium | Medium | Prioritize semantic parity first, then tune typography and spacing with real content |
| Audio plugin behavior differs across Flutter targets | Medium | Medium | Validate on the priority target platform early and keep service abstraction isolated |
| Search implementation becomes slow on full content | Low | Medium | Start with simple in-memory indexing and optimize only after measuring |

## Rollback Strategy

If implementation fails or needs to be reverted:

1. Keep all migration work isolated inside `app/gitangali` and SDD artifacts; do not modify the legacy source.
2. Revert the most recent implementation slice while keeping completed SDD documents for future retries.
3. Temporarily fall back to the last runnable Flutter milestone rather than attempting partial feature merges.

## Checkpoints

After each phase, verify:

- [ ] App still runs after dependency and asset changes
- [ ] Parser loads the bundled book without crashing
- [ ] Reader renders real content instead of starter demo UI
- [ ] Navigation, bookmarks, search, and audio each work in their own completed slice
- [ ] Tests and analysis remain green after substantive changes

## Open Implementation Questions

- [ ] Which state management style should be used for `ReaderController`: plain `ChangeNotifier`, `ValueNotifier`, or another lightweight built-in option?
- [ ] Should large asset moves be scripted during implementation to reduce manual copy mistakes?
- [ ] Is `bookmark` reordering explicitly required in the first completed migration milestone?

---

## Approval

- [x] Reviewed by: user
- [x] Approved on: 2026-04-28
- [x] Notes: Approved by user as-is
