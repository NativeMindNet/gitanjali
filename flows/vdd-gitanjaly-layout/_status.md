# Status: vdd-gitanjaly-layout

## Current Phase

IMPLEMENTATION

## Phase Status

IN PROGRESS (Phase 1: Foundation)

## Last Updated

2026-05-01 by Claude

## Blockers

- None

## Progress

- [x] Requirements v1.2 approved
- [x] Visual v1.2 approved
- [x] Specifications approved
- [x] Plan approved
- [x] Implementation Phase 1: Foundation
- [ ] Implementation Phase 2: Controllers  <- current
- [ ] Implementation Phase 2: Controllers
- [ ] Implementation Phase 3: Shell
- [ ] Implementation Phase 4: Screens
- [ ] Implementation Phase 5: Widgets
- [ ] Implementation Phase 6: Testing
- [ ] Implementation complete
- [ ] Documentation drafted
- [ ] Documentation approved

## Context Notes

Key decisions and context for resuming:

- Migrating layout from two legacy Objective-C iOS projects (not Swift):
  - `legacy-gitabjali-ru-swift` (Russian version, 689 images)
  - `legacy-gitanjali-en-swift` (English version, 686 images, 118 audio files)
- Target: Flutter app in `app/gitanjali/`
- Flutter app already has basic reader functionality implemented

### v1.1 Expansion (by user)

**New Screens Added:**
- Cover / Splash (full-screen with peacock feather background)
- TOC / Library Categories (full-screen list over background)
- Section Cover (illustration + title)
- Dedication / Biography pages (portrait + quote)

**iPad-specific Requirements:**
- Model B navigation: Tab bar (Back, +, Book, List, Home, Read, Audio) instead of bottom toolbar
- Mini player bar above tab bar with: Play/Pause, seek bar, elapsed/remaining timings, expand chevron
- Verse numbering column on left, translation in gray

**Design System:**
- Typography roles: H0 Cover (script), H1 Title, Byline, Original, Translation, Verse number, Quote
- Colors: off-white reader bg, full-screen bg for cover/TOC, accent (teal/blue)
- Layout tokens: max-width 720-800px, padding XS 12px to LG 32px

**Resolved Questions (v1.2):**
- [x] Tab bar: **4 tabs** (Home, Library, Audio, Settings)
- [x] Mini player: **elapsed + remaining** default, tap to toggle to elapsed + total
- [x] Read tab: **merged into Settings** (text size + theme)

## Source Analysis Summary

### Legacy Projects (Objective-C)
- **Screens**: Main reader, Bookmarks, Search (3 types), Audio player
- **Controls**: Bottom toolbar with 10+ buttons
- **Assets**: ~700 page images per language, 120+ audio files (English)
- **Data**: XML-based book content with HTML rendering
- **Font**: MurariChandUni.ttf for Sanskrit

### Current Flutter App
- **Screens**: Single ReaderPage with all features
- **Widgets**: 11 composable widgets
- **State**: ChangeNotifier pattern
- **Assets**: Already migrated to assets/legacy/
- **Languages**: English/Russian detection implemented

## Next Actions

1. Implement Phase 1: Foundation (models, breakpoints, tokens)
2. Implement Phase 2: Controllers (settings, audio)
3. Continue through remaining phases
