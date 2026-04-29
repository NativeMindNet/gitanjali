# Requirements: Control System

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-04-29
> Source: Legacy analysis of `legacy/legacy-cookbook/Classes/` and XML content

## Problem Statement

The legacy book reader applications use a flexible control system that allows each book to define its own navigation buttons, audio controls, search triggers, and bookmark actions via XML configuration. The controls can appear at global level (shown on all pages) or at page level (shown only on specific pages). Controls support multiple states (normal, highlighted, disabled) with different positions and images per state.

The Flutter migration needs to reproduce this control system with the same flexibility while using modern UI patterns.

## User Stories

### Primary

**As a** content author
**I want** to define controls in XML with type, position, and images
**So that** each book can have its own navigation and feature buttons without code changes

### Secondary

**As a** reader
**I want** controls to visually respond to touch (highlighted state)
**So that** I get clear feedback when interacting with the app

**As a** maintainer
**I want** a single control implementation that handles all control types
**So that** new control types can be added without duplicating code

## Acceptance Criteria

### Must Have

1. **Given** XML defines a control with `type="prev-page"`
   **When** the reader renders the page
   **Then** a button appears at the specified coordinates that navigates to previous page

2. **Given** XML defines a control with `type="page-link"` and `<arg>N</arg>`
   **When** the user taps the control
   **Then** the reader navigates to page N

3. **Given** a control with `<image>` and `<highlighted-image>`
   **When** the user touches the control
   **Then** the image changes to highlighted state during touch

4. **Given** global controls in `<head><controls>` and page controls in `<page><controls>`
   **When** a page renders
   **Then** both global and page-level controls are visible

5. **Given** audio controls (`play-sound`, `stop-sound`, `toggle-player`)
   **When** the user taps them
   **Then** the corresponding audio action executes

### Should Have

- Controls should support disabled state with reduced opacity
- Controls should use `($APP_BUNDLE)/` path placeholder resolution
- Control positions should be absolute coordinates from XML

### Won't Have (This Iteration)

- Draggable controls (legacy feature rarely used)
- Checkmark toggle controls (legacy feature for specific books)

## Constraints

- **Technical**: Controls are defined in XML, not in code
- **Platform**: Must work on all Flutter targets
- **Dependencies**: Requires asset resolver for image paths

## Control Types (from Legacy)

| Type | XML Value | Behavior |
|------|-----------|----------|
| Previous Page | `prev-page` | Navigate to previous page |
| Next Page | `next-page` | Navigate to next page |
| Page Link | `page-link` | Navigate to page specified in `<arg>` |
| Search | `search` | Open search screen |
| Bookmarks | `bookmarks` | Open bookmarks screen |
| Add Bookmark | `add-bookmark` | Add current page to bookmarks |
| Play Sound | `play-sound` | Start audio playback |
| Stop Sound | `stop-sound` | Stop audio playback |
| Toggle Player | `toggle-player` | Show/hide audio player UI |
| Toggle Animations | `toggle-animations` | Enable/disable background animations |

## References

- `legacy/legacy-cookbook/Classes/Data Core/BControlInfo.h` - Control type enum
- `legacy/legacy-cookbook/Classes/Data Core/BControlInfo.m` - XML parsing
- `legacy/legacy-cookbook/Classes/Interface/BUIControl.h` - UI component
- `legacy/legacy-cookbook/Classes/Interface/BUIControl.m` - UI implementation

---

## Approval

- [x] Reviewed by: /legacy analysis
- [x] Approved on: 2026-04-29
- [x] Notes: Documented from legacy codebase analysis
