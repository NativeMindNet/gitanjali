# Requirements: Animation System

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-04-29
> Source: Legacy analysis of `legacy/legacy-cookbook/Classes/Data Core/Animations/`

## Problem Statement

The legacy book reader applications support rich page backgrounds with animated elements. These include:
- **Keyframe sequences**: Multiple images cycling at a specified frame rate
- **Image animations**: Single images with fade, scale, and rotation effects
- **Video animations**: Video playback as background elements

The animation system is defined in XML and supports configurable timing (start delay, repeat count, delay between cycles) and transform actions (fade, scale, rotation).

The Flutter migration needs to reproduce this animation system to maintain visual parity with legacy apps.

## User Stories

### Primary

**As a** content author
**I want** to define background animations in XML with keyframes and effects
**So that** pages have engaging animated backgrounds without code changes

### Secondary

**As a** reader
**I want** animations to start automatically when I navigate to a page
**So that** I experience the intended visual presentation

**As a** maintainer
**I want** animation system separated from page rendering
**So that** animation logic can be updated independently

## Acceptance Criteria

### Must Have

1. **Given** XML defines `<target type="keyframe">` with folder path
   **When** the page renders
   **Then** images from the folder cycle at the specified `images-per-second` rate

2. **Given** XML defines `<animation start-delay="N">`
   **When** the page loads
   **Then** animation begins N seconds after page is visible

3. **Given** XML defines `repeat-count="1"` on keyframe target
   **When** the animation completes one cycle
   **Then** it stops on the last frame

4. **Given** XML defines `<action type="fade" start-alpha="0" end-alpha="1">`
   **When** the animation runs
   **Then** the target fades from transparent to opaque

5. **Given** multiple animations defined in `<background>`
   **When** the page renders
   **Then** all animations run simultaneously at their specified positions

### Should Have

- Animations should support scale actions
- Animations should support rotation actions
- Animations should support `autostart="false"` for manual trigger

### Won't Have (This Iteration)

- Video animation targets
- Complex easing curves (linear only for v1)
- Interactive animation triggers beyond control buttons

## Constraints

- **Technical**: Animation definitions come from XML, not from code
- **Performance**: Must not impact scrolling/navigation performance
- **Platform**: Must work on all Flutter targets

## Animation Types (from Legacy)

| Target Type | XML Value | Behavior |
|-------------|-----------|----------|
| Keyframe | `keyframe` | Cycle through folder of images |
| Image | `image` | Single image with transform actions |
| Video | `video` | Video playback (deferred) |

| Action Type | XML Value | Parameters |
|-------------|-----------|------------|
| Fade | `fade` | `start-alpha`, `end-alpha`, `duration`, `autoreverse`, `repeats-count` |
| Scale | `scale` | `start-scale`, `end-scale`, `duration`, `autoreverse`, `repeats-count` |
| Rotation | `rotation` | `start-angle`, `end-angle`, `duration`, `autoreverse`, `repeats-count` |

## References

- `legacy/legacy-cookbook/Classes/Data Core/Animations/BAnimation.h`
- `legacy/legacy-cookbook/Classes/Data Core/Animations/BKeyframeAnimationTarget.m`
- `legacy/legacy-cookbook/Classes/Data Core/Animations/BFadeAction.m`
- `legacy/legacy-cookbook/Resources/example.xml` - Example usage

---

## Approval

- [x] Reviewed by: /legacy analysis
- [x] Approved on: 2026-04-29
- [x] Notes: Documented from legacy codebase analysis
