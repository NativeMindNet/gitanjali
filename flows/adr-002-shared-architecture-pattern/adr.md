# ADR-002: Shared Architecture Pattern Across Legacy Apps

## Meta

- **Number**: ADR-002
- **Type**: enabling
- **Status**: APPROVED
- **Created**: 2026-04-29
- **Decided**: 2011-01 (legacy decision, documented retroactively)
- **Author**: Dmitry Panin (legacy), documented by /legacy analysis
- **Reviewers**: Migration team

## Context

Multiple legacy iOS book reader applications were developed between 2011-2022:
- `legacy_gitanjajali_swift` / `legacy-gitanjali-swift` - Sri Gaudiya Gitanjali reader
- `legacy-sgg-ru-v1` - Russian localized variant
- `legacy-cookbook` - Recipe book reader

All applications share nearly identical code architecture, demonstrating a deliberate pattern that should be understood and preserved during migration.

## Decision Drivers

- **Code reuse**: Avoid rewriting core functionality for each book
- **Maintainability**: Single architecture enables fixes to propagate
- **Content focus**: Different books need different content, not different code
- **Team knowledge**: Developers understand one pattern, not multiple

## Considered Options

### Option 1: Shared Architecture with Content-Only Variation (chosen)

**Description**: All apps share identical:
- Data Core: `BBook`, `BBookHeader`, `BBookBody`, `BBookPage`, `BBookSection`, `BParagraph`, `BParagraphStyle`
- Interface: `BUIMainViewController`, `BUIPageView`, `BUIControl`, `BUIAnimationView`, `BUISharedAudioPlayerView`
- Search: `BUISearchViewController`, `BUITitlesSearchViewController`, `BUITextSearchViewController`, `BUICommentsSearchViewController`
- Utilities: `BBookmarkManager`, `BXMLDeserializableObject`, `UIColor+StringExtension`

Only `example.xml`, images, sounds, and fonts vary per app.

**Pros**:
- Maximum code reuse
- Bug fixes benefit all apps
- Consistent user experience
- Easy to add new books

**Cons**:
- Apps are tightly coupled
- Adding app-specific features requires conditional logic
- All apps must update together

**Estimated Effort**: Low (initial setup), Very Low (new books)

### Option 2: Forked Codebases per Book

**Description**: Each app maintains independent codebase.

**Pros**:
- Complete independence
- Book-specific optimizations possible

**Cons**:
- Bug fixes must be applied N times
- Drift between implementations
- Higher maintenance burden

**Estimated Effort**: High

## Decision

We will use **Shared Architecture with Content-Only Variation** because:

- It proven successful across 4 apps over 10+ years
- Content authors focus on XML and assets, not code
- Migration to Flutter can target one architecture, not multiple
- Architectural concepts translate directly to Flutter

## Consequences

### Positive

- Single codebase pattern to migrate
- Lessons from one app apply to all
- Clear separation: code (shared) vs content (per-app)
- Migration team learns one architecture

### Negative

- Cannot optimize for specific books without affecting all
- Shared code complexity grows over time

### Neutral

- Each app has its own Xcode project wrapping shared Classes
- Thirdparty dependencies (id3lib) also shared

## Architecture Layers (Legacy)

### Layer 1: Data Core
| Class | Responsibility |
|-------|----------------|
| `BBook` | Root object, deserializes from XML |
| `BBookHeader` | Metadata: title, authors, translators, controls |
| `BBookBody` | Content container: styles, sections |
| `BBookSection` | Hierarchical navigation (can nest) |
| `BBookPage` | Single page: paragraphs, background, audio, controls |
| `BParagraph` | Text content with style reference |
| `BParagraphStyle` | Font, color, alignment settings |
| `BControlInfo` | Button/control definition |
| `BBookmark` | Saved page reference |
| `BBookmarkManager` | Bookmark persistence |

### Layer 2: Animation System
| Class | Responsibility |
|-------|----------------|
| `BAnimation` | Container for animation targets |
| `BAnimationTarget` | Base class for animation subjects |
| `BKeyframeAnimationTarget` | Frame-sequence backgrounds |
| `BImageAnimationTarget` | Single-image animation |
| `BVideoAnimationTarget` | Video playback target |
| `BBasicAction` | Base animation action |
| `BFadeAction` | Opacity animation |
| `BScaleAction` | Scale animation |
| `BRotationAction` | Rotation animation |

### Layer 3: Interface
| Class | Responsibility |
|-------|----------------|
| `BUIMainViewController` | Primary reader controller |
| `BUIPageView` | Page rendering view |
| `BUIControl` | Interactive button |
| `BUIAnimationView` | Background animation renderer |
| `BUISharedAudioPlayerView` | Audio playback UI |
| `BUIBookmarksViewController` | Bookmarks list |
| `BUISearchViewController` | Search container |
| `BUITitlesSearchViewController` | Title search |
| `BUITextSearchViewController` | Content search |
| `BUICommentsSearchViewController` | Comments search |

### Layer 4: App Delegate
| Class | Responsibility |
|-------|----------------|
| `booksAppDelegate` | App lifecycle, book loading |

## File Comparison Across Legacy Apps

```
legacy-cookbook/Classes/              ≈ identical to
legacy-sgg-ru-v1/Classes/             ≈ identical to
legacy-gitanjali-swift/Gitanjali/Classes/  ≈ identical to
legacy_gitanjajali_swift/Gitanjali/Classes/
```

Only Resources differ:
- `example.xml` - book content
- `Images/` - book-specific images
- `Sounds/` - book-specific audio
- `*.ttf` - custom fonts

## Implementation Notes

- All classes use `BXMLDeserializableObject` protocol for XML parsing
- Manual reference counting (pre-ARC era code)
- UIKit notifications for cross-component communication
- `($APP_BUNDLE)` placeholder resolved at runtime

## Migration Mapping to Flutter

| Legacy ObjC | Flutter Equivalent |
|-------------|-------------------|
| `BBook` | `Book` model |
| `BBookPage` | `BookPage` model |
| `BUIMainViewController` | `ReaderController` + `ReaderScreen` |
| `BUIPageView` | `PageRenderer` widget |
| `BBookmarkManager` | `BookmarkStore` interface |
| `BUISearchViewController` | `SearchScreen` |
| Notifications | State management (Provider/Riverpod) |

## Related Decisions

- ADR-001: Book XML Format (defines content structure)

## Related Specs

- `flows/sdd-gitanjali-flutter-refactoring/`: Flutter architecture design
- `flows/sdd-gitanjali-flutter-refactoring-v2/`: Animation system migration

## References

- `legacy/legacy_gitanjajali_swift/Gitanjali/Classes/`
- `legacy/legacy-cookbook/Classes/`
- `legacy/legacy-sgg-ru-v1/Classes/`
- `legacy/README.md`

## Tags

architecture legacy patterns migration objc flutter

---

## Approval

### Review History

| Date | Reviewer | Status | Comments |
|------|----------|--------|----------|
| 2026-04-29 | /legacy | approved | Documented from legacy analysis |

### Final Decision

- [x] Approved by: legacy analysis
- [x] Decided on: 2011 (retroactive documentation 2026-04-29)
- [x] Implementation assigned to: Migration team
