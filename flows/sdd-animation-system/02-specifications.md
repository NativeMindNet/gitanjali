# Specifications: Animation System

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-04-29
> Requirements: `flows/sdd-animation-system/01-requirements.md`

## Overview

The animation system renders animated background elements on book pages. Animations are defined in XML within `<background><animation>` elements and consist of targets (what to animate) and actions (how to animate it).

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| XML Parser | Read | Parse `<animation>`, `<target>`, `<actions>` |
| Domain Models | Define | `BackgroundAnimation`, `AnimationTarget`, `AnimationAction` |
| Asset Resolver | Integrate | Resolve keyframe folder to frame list |
| Reader Screen | Render | Display animated backgrounds |

## Architecture

### Component Diagram

```text
XML <background><animation>
        |
        v
BookRepository.parseBackground(...)
        |
        v
BackgroundAnimation model
  ├── AnimationTarget (keyframe | image)
  └── List<AnimationAction> (fade | scale | rotation)
        |
        v
ReaderPage -> AnimatedBackground widget
        |
        ├── KeyframePlayer (for keyframe targets)
        │     └── Timer-driven frame cycling
        │
        └── TransformAnimator (for actions)
              └── AnimationController-driven transforms
```

### Data Flow

```text
Parse phase:
  XML background element
    -> extract animation elements
    -> for each animation:
       -> parse center, start-delay, repeat
       -> parse target type and content
       -> for keyframe: resolve folder to frame paths
       -> parse action list
    -> attach to BookPage.backgroundAnimations

Render phase:
  ReaderPage builds AnimatedBackground
    -> For each BackgroundAnimation:
       -> Position at animation.center
       -> Create appropriate player/animator
       -> Start after startDelay

Update phase:
  Timer tick or AnimationController tick
    -> Update target (next keyframe frame)
    -> Update actions (fade/scale/rotation values)
    -> Apply to widget transform/opacity
```

## Data Models

### BackgroundAnimation

```dart
class BackgroundAnimation {
  final AnimationTarget target;
  final List<AnimationAction> actions;
  final Offset center;
  final double startDelay;
  final double delayBetweenCycles;
  final bool repeat;
  final bool autostart;
  final String? name;
}
```

### AnimationTarget (sealed hierarchy)

```dart
sealed class AnimationTarget {}

class KeyframeTarget extends AnimationTarget {
  final List<String> framePaths;
  final double imagesPerSecond;
  final int? repeatCount;
}

class ImageTarget extends AnimationTarget {
  final String imagePath;
}
```

### AnimationAction (sealed hierarchy)

```dart
sealed class AnimationAction {
  final double duration;
  final bool autoreverse;
  final int repeatCount;
}

class FadeAction extends AnimationAction {
  final double startAlpha;
  final double endAlpha;
}

class ScaleAction extends AnimationAction {
  final double startScale;
  final double endScale;
}

class RotationAction extends AnimationAction {
  final double startAngle;
  final double endAngle;
}
```

## Interfaces

### KeyframePlayer Widget

```dart
class KeyframePlayer extends StatefulWidget {
  final List<String> framePaths;
  final double framesPerSecond;
  final int? repeatCount;
  final Duration startDelay;
  final VoidCallback? onComplete;
}
```

### TransformAnimator Widget

```dart
class TransformAnimator extends StatefulWidget {
  final Widget child;
  final List<AnimationAction> actions;
  final Duration startDelay;
}
```

## Behavior Specifications

### Happy Path

1. XML is parsed and animations are extracted from `<background>`
2. Keyframe folders are resolved to sorted frame path lists
3. Page renders with AnimatedBackground containing all animations
4. After startDelay, animations begin
5. Keyframes cycle through frames at specified rate
6. Actions animate opacity/scale/rotation
7. On repeat=true, animations restart after delayBetweenCycles
8. On repeatCount reached, animation stops on final state

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Empty keyframe folder | Folder has no images | Show nothing, log warning |
| Missing frame file | File in folder missing | Skip frame, continue |
| Zero frames per second | Invalid XML value | Default to 10 fps |
| Negative start delay | Invalid XML value | Clamp to 0 |
| Page change during animation | User navigates | Dispose animation, no memory leak |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| Frame load failure | Asset missing | Skip frame, continue |
| Invalid action type | Unknown XML value | Skip action, log warning |
| Memory pressure | Too many animations | Dispose non-visible animations |

## XML Schema

```xml
<background color="#FFFFFF">
  <animation center="{384, 512}" start-delay="0.5" repeat="true" delay-between-cycles="1.0" autostart="true" name="main">
    <target type="keyframe" images-per-second="12" repeat-count="0">($APP_BUNDLE)/keyframes_folder</target>
    <actions>
      <action type="fade" duration="1.0" autoreverse="false" repeats-count="1" start-alpha="0" end-alpha="1"/>
      <action type="scale" duration="0.5" start-scale="0.5" end-scale="1.0"/>
      <action type="rotation" duration="2.0" start-angle="0" end-angle="360"/>
    </actions>
  </animation>
  <animation center="{100, 200}">
    <target type="image">($APP_BUNDLE)/static_image.png</target>
  </animation>
</background>
```

## Legacy Mapping

| Legacy ObjC | Flutter |
|-------------|---------|
| `BAnimation` | `BackgroundAnimation` |
| `BAnimationTarget` | `AnimationTarget` sealed class |
| `BKeyframeAnimationTarget` | `KeyframeTarget` + `KeyframePlayer` |
| `BImageAnimationTarget` | `ImageTarget` + standard Image |
| `BBasicAction` | `AnimationAction` sealed class |
| `BFadeAction` | `FadeAction` |
| `BScaleAction` | `ScaleAction` |
| `BRotationAction` | `RotationAction` |
| `update:(float)delta` | Timer.periodic or AnimationController |
| `_currentProgress` | AnimationController.value |

## Key Implementation Details

### Keyframe Frame Resolution

Legacy code reads folder contents at runtime:

```objc
NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: _imagesFolder error: nil];
```

Flutter approach: resolve at parse time using AssetManifest or pre-defined asset list.

### Frame Rate Calculation

Legacy formula:
```objc
_currentProgress += delta * _imagesPerSecond / _images.count;
int index = _currentProgress * _images.count;
```

Flutter equivalent: Timer with interval = 1000ms / imagesPerSecond, advance index on each tick.

### Center Point Format

Legacy uses `CGPointFromString("{x, y}")` format. Parser must handle this string format.

## Dependencies

### Requires

- Asset resolver for path resolution
- Keyframe frame list builder
- XML parser for animation elements

### Blocks

- Full visual parity with legacy backgrounds
- Page rendering with animations

## Testing Strategy

### Unit Tests

- [ ] Parse keyframe target from XML
- [ ] Parse fade action parameters
- [ ] Resolve keyframe folder to frame list
- [ ] Calculate frame index from progress

### Integration Tests

- [ ] Keyframe animation cycles through frames
- [ ] Start delay works correctly
- [ ] Repeat count stops animation

---

## Approval

- [x] Reviewed by: /legacy analysis
- [x] Approved on: 2026-04-29
- [x] Notes: Documented from legacy codebase analysis
