# Implementation Plan: Gitanjali Adaptive Layout

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-01
> Specifications: [03-specifications.md](./03-specifications.md)

## Summary

Имплементация адаптивной верстки Gitanjali в 6 фаз:
1. **Foundation** - модели данных, breakpoints, theme tokens
2. **Controllers** - SettingsController, AudioController с seek
3. **Shell** - AdaptiveShell, PhoneShell, TabletShell
4. **Screens** - Cover, Library/TOC, Settings, Audio pages
5. **Widgets** - MiniPlayerBar, VerseBlock, улучшенный Reader
6. **Testing** - unit, widget, integration tests

---

## Task Breakdown

### Phase 1: Foundation

#### Task 1.1: Add Data Models
- **Description**: Добавить enums и типы для настроек и layout
- **Files**:
  - `lib/src/domain/models.dart` - Modify (add enums)
- **Dependencies**: None
- **Verification**: Enums компилируются, используются в других файлах
- **Complexity**: Low

```dart
// Add to models.dart:
enum LanguageOption { auto, russian, english }
enum TextSizeOption { small, medium, large, extraLarge }
enum ThemeOption { light, dark, system }
enum LayoutMode { phone, tablet }
```

#### Task 1.2: Create Breakpoints Utility
- **Description**: Создать утилиту для определения LayoutMode
- **Files**:
  - `lib/src/presentation/common/breakpoints.dart` - Create
- **Dependencies**: None
- **Verification**: `layoutModeOf(context)` возвращает корректный режим
- **Complexity**: Low

#### Task 1.3: Create Theme Tokens
- **Description**: Централизовать цвета, размеры, spacing
- **Files**:
  - `lib/src/presentation/common/theme_tokens.dart` - Create
- **Dependencies**: None
- **Verification**: Токены используются в виджетах
- **Complexity**: Low

---

### Phase 2: Controllers

#### Task 2.1: Extend ReaderStore with Settings
- **Description**: Добавить методы для сохранения/загрузки настроек
- **Files**:
  - `lib/src/data/reader_store.dart` - Modify
- **Dependencies**: Task 1.1
- **Verification**: Settings persist между сессиями
- **Complexity**: Low

```dart
// Add methods:
Future<LanguageOption> loadLanguage() async { ... }
Future<void> saveLanguage(LanguageOption value) async { ... }
// ... textSize, theme
```

#### Task 2.2: Create SettingsController
- **Description**: Контроллер для управления настройками пользователя
- **Files**:
  - `lib/src/presentation/settings/settings_controller.dart` - Create
- **Dependencies**: Task 1.1, Task 2.1
- **Verification**: Изменение настроек вызывает notifyListeners
- **Complexity**: Medium

#### Task 2.3: Refactor AudioService to AudioController
- **Description**: Расширить AudioService: seek, position stream, timing toggle
- **Files**:
  - `lib/src/data/audio_service.dart` - Rename to `audio_controller.dart`, Modify
  - `lib/src/presentation/reader/reader_controller.dart` - Modify (update import)
- **Dependencies**: None
- **Verification**: Seek работает, timings обновляются
- **Complexity**: Medium

---

### Phase 3: Shell & Navigation

#### Task 3.1: Create AdaptiveShell
- **Description**: Контейнер, выбирающий PhoneShell или TabletShell
- **Files**:
  - `lib/src/presentation/shell/adaptive_shell.dart` - Create
- **Dependencies**: Task 1.2
- **Verification**: На разных ширинах рендерится нужный shell
- **Complexity**: Low

#### Task 3.2: Create PhoneShell (Model A)
- **Description**: Shell для телефонов с bottom toolbar
- **Files**:
  - `lib/src/presentation/shell/phone_shell.dart` - Create
- **Dependencies**: Task 3.1
- **Verification**: Toolbar отображается, навигация работает
- **Complexity**: Medium

#### Task 3.3: Create TabletShell (Model B)
- **Description**: Shell для планшетов с tab bar и mini player
- **Files**:
  - `lib/src/presentation/shell/tablet_shell.dart` - Create
- **Dependencies**: Task 3.1, Task 5.1 (MiniPlayerBar)
- **Verification**: 4 таба работают, mini player показывается
- **Complexity**: High

#### Task 3.4: Update GitanjaliApp
- **Description**: Интегрировать AdaptiveShell, ThemeProvider, routing
- **Files**:
  - `lib/src/app/gitanjali_app.dart` - Modify
- **Dependencies**: Task 2.2, Task 3.1
- **Verification**: Приложение запускается с новой архитектурой
- **Complexity**: Medium

---

### Phase 4: Screens

#### Task 4.1: Create CoverPage
- **Description**: Полноэкранная обложка с фоном и заголовком
- **Files**:
  - `lib/src/presentation/cover/cover_page.dart` - Create
- **Dependencies**: Task 1.3
- **Verification**: Обложка отображается, переход к TOC работает
- **Complexity**: Low

#### Task 4.2: Create LibraryPage (TOC)
- **Description**: Оглавление с категориями поверх фона
- **Files**:
  - `lib/src/presentation/library/library_page.dart` - Create
  - `lib/src/presentation/library/toc_list.dart` - Create
- **Dependencies**: Task 1.3
- **Verification**: Список категорий, tap → section/reader
- **Complexity**: Medium

#### Task 4.3: Create SectionCover
- **Description**: Обложка раздела с иллюстрацией
- **Files**:
  - `lib/src/presentation/library/section_cover.dart` - Create
- **Dependencies**: Task 4.2
- **Verification**: Отображается при входе в раздел
- **Complexity**: Low

#### Task 4.4: Create SettingsPage
- **Description**: Полноэкранные настройки для планшета
- **Files**:
  - `lib/src/presentation/settings/settings_page.dart` - Create
- **Dependencies**: Task 2.2, Task 1.3
- **Verification**: Язык/размер/тема меняются и сохраняются
- **Complexity**: Medium

#### Task 4.5: Create SettingsSheet
- **Description**: ModalBottomSheet настроек для телефона
- **Files**:
  - `lib/src/presentation/settings/settings_sheet.dart` - Create
- **Dependencies**: Task 4.4 (reuse SettingsContent)
- **Verification**: Sheet открывается, настройки работают
- **Complexity**: Low

#### Task 4.6: Create AudioPage
- **Description**: Страница Now Playing / Audio Library
- **Files**:
  - `lib/src/presentation/audio/audio_page.dart` - Create
- **Dependencies**: Task 2.3
- **Verification**: Показывает текущий трек, управление воспроизведением
- **Complexity**: Medium

---

### Phase 5: Widgets

#### Task 5.1: Create MiniPlayerBar
- **Description**: Компактный плеер с seek и timings
- **Files**:
  - `lib/src/presentation/audio/mini_player_bar.dart` - Create
- **Dependencies**: Task 2.3
- **Verification**: Play/Pause, seek slider, tap toggle timings
- **Complexity**: High

#### Task 5.2: Create VerseBlock
- **Description**: Блок стиха с номером, оригиналом и переводом
- **Files**:
  - `lib/src/presentation/reader/widgets/verse_block.dart` - Create
- **Dependencies**: Task 1.3
- **Verification**: Номер слева, оригинал центр, перевод серым
- **Complexity**: Medium

#### Task 5.3: Create DedicationContent
- **Description**: Компонент для страниц посвящения (портрет + цитата)
- **Files**:
  - `lib/src/presentation/reader/widgets/dedication_content.dart` - Create
- **Dependencies**: Task 1.3
- **Verification**: Портрет + текст с "книжным" ритмом
- **Complexity**: Low

#### Task 5.4: Update ReaderPage for Adaptive Layout
- **Description**: Адаптировать ReaderPage под новые breakpoints и типы страниц
- **Files**:
  - `lib/src/presentation/reader/reader_page.dart` - Modify
- **Dependencies**: Task 1.2, Task 5.2, Task 5.3
- **Verification**: Reader работает на всех breakpoints
- **Complexity**: High

#### Task 5.5: Update ReaderController for Settings
- **Description**: Интегрировать SettingsController для языка и textScale
- **Files**:
  - `lib/src/presentation/reader/reader_controller.dart` - Modify
- **Dependencies**: Task 2.2
- **Verification**: Смена языка перезагружает контент
- **Complexity**: Medium

---

### Phase 6: Testing & Polish

#### Task 6.1: Unit Tests for Controllers
- **Description**: Тесты для SettingsController, AudioController
- **Files**:
  - `test/settings_controller_test.dart` - Create
  - `test/audio_controller_test.dart` - Create
- **Dependencies**: Phase 2 complete
- **Verification**: Все тесты проходят
- **Complexity**: Medium

#### Task 6.2: Widget Tests
- **Description**: Тесты для AdaptiveShell, MiniPlayerBar, VerseBlock
- **Files**:
  - `test/adaptive_shell_test.dart` - Create
  - `test/mini_player_bar_test.dart` - Create
  - `test/verse_block_test.dart` - Create
- **Dependencies**: Phase 5 complete
- **Verification**: Все тесты проходят
- **Complexity**: Medium

#### Task 6.3: Manual QA on All Breakpoints
- **Description**: Проверка на реальных устройствах/эмуляторах
- **Files**: None (manual testing)
- **Dependencies**: All previous tasks
- **Verification**: Чеклист пройден
- **Complexity**: Low

```
Manual QA Checklist:
- [ ] iPhone SE (320px) - XS breakpoint
- [ ] iPhone 14 (390px) - SM breakpoint
- [ ] iPad (768px) - MD breakpoint
- [ ] iPad Pro (1024px) - LG breakpoint
- [ ] Portrait/Landscape rotation
- [ ] Dark theme all screens
- [ ] Language switch RU ↔ EN
- [ ] Text size S/M/L/XL
- [ ] Audio playback + seek
```

---

## Dependency Graph

```
Phase 1: Foundation
  1.1 Models ──┬──→ 2.1 Store ──→ 2.2 SettingsController
  1.2 Breakpoints ─────────────────→ 3.1 AdaptiveShell
  1.3 Tokens ──────────────────────→ 4.x Screens, 5.x Widgets

Phase 2: Controllers
  2.1 Store ────→ 2.2 SettingsController ──→ 3.4 GitanjaliApp
  2.3 AudioController ─────────────────────→ 5.1 MiniPlayerBar

Phase 3: Shell
  3.1 AdaptiveShell ──┬──→ 3.2 PhoneShell
                      └──→ 3.3 TabletShell ──→ 3.4 GitanjaliApp

Phase 4: Screens
  4.1 Cover ────→ 4.2 Library ────→ 4.3 SectionCover
  4.4 SettingsPage ──→ 4.5 SettingsSheet
  4.6 AudioPage

Phase 5: Widgets
  5.1 MiniPlayerBar ──→ 3.3 TabletShell
  5.2 VerseBlock ─────→ 5.4 ReaderPage
  5.3 DedicationContent → 5.4 ReaderPage
  5.4 ReaderPage ──────→ 5.5 ReaderController

Phase 6: Testing
  6.1 Unit Tests
  6.2 Widget Tests
  6.3 Manual QA
```

---

## File Change Summary

| File | Action | Reason |
|------|--------|--------|
| `lib/src/domain/models.dart` | Modify | Add settings enums |
| `lib/src/data/reader_store.dart` | Modify | Add settings persistence |
| `lib/src/data/audio_service.dart` | Rename → `audio_controller.dart` | Add seek, timings |
| `lib/src/app/gitanjali_app.dart` | Modify | ThemeProvider, routing |
| `lib/src/presentation/reader/reader_page.dart` | Modify | Adaptive layout |
| `lib/src/presentation/reader/reader_controller.dart` | Modify | Settings integration |
| `lib/src/presentation/common/breakpoints.dart` | Create | LayoutMode detection |
| `lib/src/presentation/common/theme_tokens.dart` | Create | Design tokens |
| `lib/src/presentation/shell/adaptive_shell.dart` | Create | Shell switcher |
| `lib/src/presentation/shell/phone_shell.dart` | Create | Model A navigation |
| `lib/src/presentation/shell/tablet_shell.dart` | Create | Model B navigation |
| `lib/src/presentation/cover/cover_page.dart` | Create | Cover screen |
| `lib/src/presentation/library/library_page.dart` | Create | TOC screen |
| `lib/src/presentation/library/toc_list.dart` | Create | Category list |
| `lib/src/presentation/library/section_cover.dart` | Create | Section cover |
| `lib/src/presentation/settings/settings_controller.dart` | Create | Settings state |
| `lib/src/presentation/settings/settings_page.dart` | Create | Tablet settings |
| `lib/src/presentation/settings/settings_sheet.dart` | Create | Phone settings |
| `lib/src/presentation/audio/audio_page.dart` | Create | Now playing |
| `lib/src/presentation/audio/mini_player_bar.dart` | Create | Mini player |
| `lib/src/presentation/reader/widgets/verse_block.dart` | Create | Verse layout |
| `lib/src/presentation/reader/widgets/dedication_content.dart` | Create | Dedication layout |

**Total: 6 modified, 16 created = 22 files**

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| TabletShell navigation complexity | Medium | Medium | Start with simple IndexedStack, refine later |
| Audio seek performance | Low | Medium | Use StreamBuilder for position, debounce slider |
| Theme switching flicker | Medium | Low | Wrap in AnimatedTheme |
| Settings not persisting | Low | High | Add error handling + fallback defaults |

---

## Rollback Strategy

1. Git checkout to previous commit
2. Remove new files in `presentation/shell/`, `cover/`, `library/`, `audio/`, `settings/`, `common/`
3. Revert changes to `models.dart`, `reader_store.dart`, `gitanjali_app.dart`
4. Rename `audio_controller.dart` back to `audio_service.dart`

---

## Checkpoints

### After Phase 1 (Foundation)
- [ ] Enums defined and imported
- [ ] Breakpoints utility works
- [ ] Theme tokens in place

### After Phase 2 (Controllers)
- [ ] Settings persist and load
- [ ] Audio seek works
- [ ] Timing toggle works

### After Phase 3 (Shell)
- [ ] Phone shell renders on narrow screens
- [ ] Tablet shell renders on wide screens
- [ ] Tab navigation works

### After Phase 4 (Screens)
- [ ] Cover page displays
- [ ] TOC navigation works
- [ ] Settings change language/theme

### After Phase 5 (Widgets)
- [ ] Mini player shows/hides correctly
- [ ] Verse block renders properly
- [ ] Reader adapts to all breakpoints

### After Phase 6 (Testing)
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Manual QA checklist complete

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-01
- [x] Notes: Plan approved, starting implementation
