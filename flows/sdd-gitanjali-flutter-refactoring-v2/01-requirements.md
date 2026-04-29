# Requirements: gitanjali-flutter-refactoring-v2

> Version: 1.0  
> Status: APPROVED  
> Last Updated: 2026-04-29

## Problem Statement

The first migration slice moved core reader behavior from legacy iOS to Flutter, but some legacy behavior remained only partially implemented, especially animated keyframe backgrounds and migration traceability for legacy sources. We need a second refactoring pass to close these parity gaps while keeping the app stable and testable.

## User Stories

### Primary

**As a** reader using the Flutter app  
**I want** legacy visual behavior (including keyframe background animation) to work in reader pages  
**So that** the Flutter app feels closer to the original iOS experience.

### Secondary

**As a** developer continuing migration  
**I want** explicit documentation of legacy subfolders and their roles  
**So that** future migration tasks use the right source paths and avoid confusion between duplicate snapshots.

## Acceptance Criteria

### Must Have

1. **Given** a page that defines a `background` with keyframe target in legacy XML  
   **When** the page is rendered in Flutter  
   **Then** the UI cycles through resolved keyframe images instead of showing only one static preview.

2. **Given** keyframe background assets exist in the Flutter bundle  
   **When** XML is parsed  
   **Then** parser output exposes ordered frame assets for runtime animation.

3. **Given** repository contributors inspect `legacy/`  
   **When** they open documentation  
   **Then** they can understand each top-level legacy subfolder and its migration role.

### Should Have

- Keep existing reader behavior unchanged for pages without keyframe backgrounds.
- Preserve all existing tests and add targeted coverage for keyframe parsing/resolution.

### Won't Have (This Iteration)

- Full reimplementation of all legacy UIKit visual effects and custom transitions.
- Any App Store / Play Store release operations.

## Constraints

- **Technical**: Work inside current Flutter architecture (`app/gitanjali/lib/src/...`) and legacy XML schema.
- **Performance**: Keyframe rendering must be lightweight enough for regular page reading use.
- **Platform**: Must continue working with existing Flutter targets and current bundled assets.
- **Dependencies**: Depends on existing v1 parser/controller/UI foundations from `sdd-gitanjali-flutter-refactoring`.

## Open Questions

- [x] Is full keyframe parity in scope for this iteration?  
      Decision: implement a lightweight frame-cycling approach in reader UI for keyframe backgrounds.

## References

- `flows/sdd-gitanjali-flutter-refactoring/05-documentation.md`
- `legacy/legacy_gitanjajali_swift/Gitanjali/Resources/example.xml`

---

## Approval

- [x] Reviewed by: user
- [x] Approved on: 2026-04-29
- [x] Notes: Request explicitly asked to start this v2 flow and continue migration.
