# Specifications: gitanjali-flutter-refactoring-v2

> Version: 1.0  
> Status: APPROVED  
> Last Updated: 2026-04-29  
> Requirements: `flows/sdd-gitanjali-flutter-refactoring-v2/01-requirements.md`

## Overview

This iteration extends the existing Flutter migration by converting keyframe background metadata from legacy XML into runtime-renderable frame sequences, then rendering those sequences in the reader as simple looping animation. It also introduces explicit `legacy` folder documentation for migration continuity.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `app/gitanjali/lib/src/domain/models.dart` | Modify | Add background frame list in `BookPage`/`PageDraft` |
| `app/gitanjali/lib/src/data/legacy_asset_resolver.dart` | Modify | Expose resolved keyframe frame sequence |
| `app/gitanjali/lib/src/data/book_repository.dart` | Modify | Parse keyframe targets into frame lists |
| `app/gitanjali/lib/src/presentation/reader/reader_page.dart` | Modify | Render animated background for multi-frame pages |
| `app/gitanjali/test/*.dart` | Modify | Add parser/resolver test coverage updates |
| `legacy/README.md` | Create | Document legacy subfolders and purpose |

## Architecture

### Component Diagram

```text
Legacy XML <background><target type="keyframe">...</target>
        |
        v
BookRepository.parseBackground(...)
        |
        v
LegacyAssetResolver.resolveKeyframeFrames(...)
        |
        v
BookPage.backgroundFrames
        |
        v
ReaderPage._BackgroundImage -> _AnimatedBackground (Timer-driven frame cycle)
```

### Data Flow

```text
XML keyframe folder name
  -> resolver returns sorted asset frame list
  -> parser stores first frame as fallback backgroundAsset + full frame list
  -> reader uses:
       - static image when 0/1 frame
       - looped animated image when >1 frames
```

## Interfaces

### Modified Interfaces

- `LegacyAssetResolver`
  - Add `resolveKeyframeFrames(String? rawPath) -> List<String>`
  - Keep `resolveKeyframePreview(...)` for compatibility (implemented via frames API).

- `BookPage`
  - Add `backgroundFrames: List<String>` field for runtime background animation.

## Data Models

### Schema Changes

- In-memory model only:
  - `BookPage.backgroundFrames` (new)
  - `PageDraft.backgroundFrames` (new mutable collector)

No persisted storage schema changes are required.

## Behavior Specifications

### Happy Path

1. XML page defines keyframe background target.
2. Resolver finds matching frame assets under `assets/legacy/Images/<target>/`.
3. Parser assigns ordered frames to current page.
4. Reader UI detects `backgroundFrames.length > 1` and loops frames with fixed interval.

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| Missing keyframe directory | Target has no matching assets | Page falls back to static/default background |
| Single frame only | Keyframe target resolves one file | Render as static image, no animation loop |
| Asset read error | Damaged/missing frame file | Render fallback background color |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| Unsupported/malformed XML | Existing parser checks fail | Throw `StateError` as before |
| Invalid frame target | No assets found | Return empty frame list, continue gracefully |

## Dependencies

### Requires

- Existing parser and reader infrastructure from prior SDD flow.
- Existing asset bundle under `app/gitanjali/assets/legacy`.

### Blocks

- Visual parity follow-ups that depend on animated background support baseline.

## Testing Strategy

### Unit Tests

- [x] `legacy_asset_resolver_test.dart` - keyframe frame list resolution
- [x] `book_repository_test.dart` - keyframe backgrounds parsed to frame list

### Manual Verification

- [x] Launch app and open pages with keyframe backgrounds to confirm animation.

## Migration / Rollout

No rollout strategy required; bundled offline app behavior only.

## Open Design Questions

- [x] Frame timing value for v2?  
      Decision: fixed lightweight interval (`120ms`) for simple parity.

---

## Approval

- [x] Reviewed by: user
- [x] Approved on: 2026-04-29
- [x] Notes: Approved by direct implementation request.
