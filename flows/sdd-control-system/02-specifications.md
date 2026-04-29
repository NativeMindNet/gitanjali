# Specifications: Control System

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-04-29
> Requirements: `flows/sdd-control-system/01-requirements.md`

## Overview

The control system provides a unified approach to interactive buttons in the book reader. Controls are parsed from XML, stored as data models, and rendered as positioned UI elements. Each control type triggers a specific action when tapped.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| XML Parser | Read | Parses `<control>` elements from XML |
| Domain Models | Define | `ControlInfo` and `ControlType` types |
| Reader Controller | Handle | Responds to control tap events |
| Reader Screen | Render | Displays controls at specified positions |
| Audio Service | Integrate | Handles audio control actions |
| Navigation | Integrate | Handles page navigation controls |

## Architecture

### Component Diagram

```text
XML <control type="...">
        |
        v
BookRepository.parseControl(...)
        |
        v
ControlInfo model
        |
        v
ReaderScreen -> ControlOverlay widget
        |
        v
ControlButton widget (per control)
        |
        v
onTap -> ReaderController.handleControl(type, arg)
        |
        v
[Navigate | Search | Bookmark | Audio]
```

### Data Flow

```text
Parse phase:
  XML control element
    -> extract type, center, images, arg
    -> resolve image paths via asset resolver
    -> create ControlInfo object
    -> attach to BookPage or BookHeader

Render phase:
  ReaderScreen builds ControlOverlay
    -> ControlOverlay positions each ControlButton
    -> ControlButton displays image, handles state

Interaction phase:
  User tap on ControlButton
    -> GestureDetector fires
    -> ReaderController.handleControl(controlInfo)
    -> Switch on controlInfo.type
    -> Execute corresponding action
```

## Data Models

### ControlType Enum

```dart
enum ControlType {
  prevPage,
  nextPage,
  pageLink,
  search,
  bookmarks,
  addBookmark,
  playSound,
  stopSound,
  togglePlayer,
  toggleAnimations,
}
```

### ControlInfo Model

```dart
class ControlInfo {
  final ControlType type;
  final double centerX;
  final double centerY;
  final String normalImage;
  final String? highlightedImage;
  final String? disabledImage;
  final String? argument;  // page number for page-link
  final bool enabled;
}
```

## Interfaces

### Control Handler

```dart
abstract class ControlHandler {
  void handleControl(ControlInfo control);
}
```

### Implementation in ReaderController

```dart
void handleControl(ControlInfo control) {
  switch (control.type) {
    case ControlType.prevPage:
      goToPreviousPage();
      break;
    case ControlType.nextPage:
      goToNextPage();
      break;
    case ControlType.pageLink:
      goToPage(int.parse(control.argument!));
      break;
    case ControlType.search:
      openSearch();
      break;
    case ControlType.bookmarks:
      openBookmarks();
      break;
    case ControlType.addBookmark:
      addBookmark();
      break;
    case ControlType.playSound:
      audioService.play();
      break;
    case ControlType.stopSound:
      audioService.stop();
      break;
    case ControlType.togglePlayer:
      togglePlayerVisibility();
      break;
    case ControlType.toggleAnimations:
      toggleAnimations();
      break;
  }
}
```

## Behavior Specifications

### Happy Path

1. XML is parsed and controls are extracted from `<head><controls>` and `<page><controls>`
2. Control images are resolved to Flutter asset paths
3. Reader screen renders ControlOverlay with positioned ControlButtons
4. User taps a control
5. Control changes to highlighted state
6. On release, action is executed
7. Control returns to normal state

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Missing image | XML points to nonexistent image | Use placeholder or hide control |
| Invalid page-link arg | `<arg>999</arg>` exceeds page count | Clamp to valid range or ignore tap |
| Audio control without audio | Play on page without audio | Control is disabled |
| Unknown control type | XML has unsupported type | Skip control, log warning |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| Image load failure | Asset missing | Show transparent/placeholder |
| Parse failure | Malformed XML | Skip control, continue parsing |
| Action failure | Feature not available | Show non-blocking message |

## XML Schema

```xml
<control type="prev-page|next-page|page-link|search|bookmarks|add-bookmark|play-sound|stop-sound|toggle-player|toggle-animations">
  <center>
    <x>123</x>
    <y>456</y>
  </center>
  <image>($APP_BUNDLE)/button.png</image>
  <highlighted-image>($APP_BUNDLE)/button_h.png</highlighted-image>
  <disabled-image>($APP_BUNDLE)/button_d.png</disabled-image>
  <arg>42</arg>  <!-- for page-link: target page number -->
</control>
```

## Legacy Mapping

| Legacy ObjC | Flutter |
|-------------|---------|
| `BControlType` enum | `ControlType` enum |
| `BControlInfo` | `ControlInfo` class |
| `BUIControl` | `ControlButton` widget |
| `BUIControlDidPressedNotification` | `ReaderController.handleControl()` |
| `_centersDict` | `centerX`, `centerY` fields |

## Dependencies

### Requires

- Asset resolver for `($APP_BUNDLE)/` path resolution
- XML parser for control element extraction
- Reader controller for action handling

### Blocks

- Reader screen control rendering
- Audio playback integration

## Testing Strategy

### Unit Tests

- [ ] Parse control type strings to enum values
- [ ] Parse control center coordinates
- [ ] Resolve control image paths
- [ ] Handle missing optional fields (highlighted-image, arg)

### Integration Tests

- [ ] Tap prev-page control navigates backward
- [ ] Tap page-link control navigates to specified page
- [ ] Tap search control opens search screen

---

## Approval

- [x] Reviewed by: /legacy analysis
- [x] Approved on: 2026-04-29
- [x] Notes: Documented from legacy codebase analysis
