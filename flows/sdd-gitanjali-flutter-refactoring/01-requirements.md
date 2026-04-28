# Requirements: gitanjali-flutter-refactoring

> Version: 1.0  
> Status: APPROVED  
> Last Updated: 2026-04-28

## Problem Statement

В репозитории уже есть legacy-приложение `legacy/legacy_gitanjajali_swift`, которое фактически является полноценным офлайн-ридером/песенником `Sri Gaudiya Gitanjali` с XML-контентом, изображениями, аудио, поиском и закладками. Целевое приложение `app/gitangali` существует только как стандартный Flutter-шаблон и не содержит ни доменной модели, ни импорта контента, ни пользовательских сценариев.

Нужно выполнить управляемый рефакторинг и миграцию: сохранить ключевое поведение legacy-приложения, но перенести его в современное Flutter-приложение с понятной архитектурой, чтобы дальнейшая разработка велась уже в `app/gitangali`.

## User Stories

### Primary

**As a** reader of `Sri Gaudiya Gitanjali`  
**I want** browseable offline access to the book content, audio, search, and bookmarks in a Flutter app  
**So that** I can use the new app without losing the core capabilities of the legacy version

### Secondary

**As a** maintainer  
**I want** the new Flutter app to have explicit data, presentation, and asset-loading boundaries  
**So that** further feature work does not depend on the legacy Objective-C codebase

**As a** product owner  
**I want** the migration to be staged and traceable  
**So that** we can verify parity incrementally instead of rewriting blindly

## Acceptance Criteria

### Must Have

1. **Given** the Flutter app is launched  
   **When** bundled Gitanjali content is loaded  
   **Then** the app shows the real product shell instead of the default Flutter counter demo

2. **Given** the user opens the main reading experience  
   **When** they navigate through book sections/pages  
   **Then** they can move through the migrated content without depending on legacy runtime code

3. **Given** the legacy app provides offline bundled content and assets  
   **When** the Flutter app is built  
   **Then** the required text, images, fonts, and audio are available from the new app package or a clearly defined local asset strategy

4. **Given** a page has associated audio  
   **When** the user starts playback  
   **Then** the audio plays inside the Flutter app with basic transport behavior

5. **Given** the user searches or bookmarks content  
   **When** they use those features in Flutter  
   **Then** equivalent high-level capabilities exist for the migrated content

6. **Given** the user closes and reopens the app  
   **When** they return later  
   **Then** the app can restore key local reader state such as last position and saved bookmarks

### Should Have

- Initial Flutter architecture should separate parsing/loading, domain models, and UI composition.
- Migration should preserve the visual identity where practical, including bundled font(s) and representative imagery.
- The first implementation increment should be testable without requiring network access.

### Won't Have (This Iteration)

- Full pixel-perfect recreation of every legacy animation effect.
- Migration of unused legacy platform code paths that do not affect the shipped user experience.
- New non-legacy product features unrelated to parity/refactoring.

## Constraints

- **Technical**: Source functionality must be derived from `legacy/legacy_gitanjajali_swift`; target implementation must live in `app/gitangali`.
- **Performance**: Core reading flow should remain responsive with bundled offline assets.
- **Platform**: Primary target is Flutter app structure under `app/gitangali`; exact platform release work can be phased.
- **Dependencies**: Migration depends on understanding the legacy XML/content model and selecting Flutter packages for audio, persistence, and structured rendering.

## Open Questions

- [ ] Is the first milestone expected to cover the full legacy feature set, or an MVP subset with reader + audio + bookmarks before advanced search parity?
- [ ] Should Flutter continue consuming the existing XML format directly, or should we convert the legacy source into a simpler intermediate asset format during build time?
- [ ] Is exact visual parity with the legacy page renderer required, or is functional parity with modernized UI acceptable for the first release?
- [ ] Which platforms are in scope for active verification in this migration: iOS only, mobile only, or all Flutter targets currently scaffolded?

## References

- `legacy/legacy_gitanjajali_swift/Gitanjali/Resources/example.xml`
- `legacy/legacy_gitanjajali_swift/Gitanjali/Classes/Interface/BUIMainViewController.m`
- `legacy/legacy_gitanjajali_swift/Gitanjali/Classes/Interface/BUISharedAudioPlayerView.m`
- `app/gitangali/lib/main.dart`
- `app/gitangali/pubspec.yaml`

---

## Approval

- [x] Reviewed by: user
- [x] Approved on: 2026-04-28
- [x] Notes: Approved by user as-is
