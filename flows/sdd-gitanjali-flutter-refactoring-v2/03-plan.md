# Implementation Plan: gitanjali-flutter-refactoring-v2

> Version: 1.0  
> Status: APPROVED  
> Last Updated: 2026-04-29  
> Specifications: `flows/sdd-gitanjali-flutter-refactoring-v2/02-specifications.md`

## Summary

Implement v2 as a focused parity refactor: add keyframe background frame support from legacy XML through parser/domain/UI, keep non-keyframe pages unchanged, and ship accompanying documentation for `legacy` subfolders.

## Task Breakdown

### Phase 1: Data and Model Parity

#### Task 1.1: Extend background model for frame sequences
- **Description**: Add frame list fields in page domain model and draft model.
- **Files**:
  - `app/gitanjali/lib/src/domain/models.dart` - Modify
- **Dependencies**: None
- **Verification**: App compiles and page model carries both static and animated background data.
- **Complexity**: Low

#### Task 1.2: Extend asset resolver for keyframe sequence resolution
- **Description**: Add API returning sorted keyframe frame paths; preserve preview helper behavior.
- **Files**:
  - `app/gitanjali/lib/src/data/legacy_asset_resolver.dart` - Modify
- **Dependencies**: Task 1.1
- **Verification**: Resolver unit tests pass for preview + full sequence paths.
- **Complexity**: Low

### Phase 2: Parser and UI Integration

#### Task 2.1: Parse keyframe background targets into frame list
- **Description**: Update XML background parsing to capture full keyframe sequence and set static fallback frame.
- **Files**:
  - `app/gitanjali/lib/src/data/book_repository.dart` - Modify
  - `app/gitanjali/test/book_repository_test.dart` - Modify
- **Dependencies**: Task 1.2
- **Verification**: Parser tests cover keyframe background behavior.
- **Complexity**: Medium

#### Task 2.2: Render animated backgrounds in reader
- **Description**: Update reader page background widget to animate when multiple frames are available.
- **Files**:
  - `app/gitanjali/lib/src/presentation/reader/reader_page.dart` - Modify
- **Dependencies**: Task 2.1
- **Verification**: Manual run confirms animated backgrounds on keyframe pages.
- **Complexity**: Medium

### Phase 3: Documentation and Validation

#### Task 3.1: Document legacy subfolders and migration purpose
- **Description**: Add clear docs for top-level `legacy` subdirectories.
- **Files**:
  - `legacy/README.md` - Create
- **Dependencies**: None
- **Verification**: Documentation clearly identifies each subfolder and use in migration.
- **Complexity**: Low

#### Task 3.2: Run static checks and tests
- **Description**: Validate app after v2 changes.
- **Files**:
  - `app/gitanjali/*` - Verify only
- **Dependencies**: Tasks 1.1-3.1
- **Verification**: `flutter analyze` and `flutter test` pass.
- **Complexity**: Low

## Dependency Graph

```text
Task 1.1 -> Task 1.2 -> Task 2.1 -> Task 2.2
                              |
Task 3.1 ---------------------|
                              v
                          Task 3.2
```

## File Change Summary

| File | Action | Reason |
|------|--------|--------|
| `app/gitanjali/lib/src/domain/models.dart` | Modify | Store background keyframe frame list |
| `app/gitanjali/lib/src/data/legacy_asset_resolver.dart` | Modify | Resolve all keyframe frames |
| `app/gitanjali/lib/src/data/book_repository.dart` | Modify | Parse keyframe targets into page data |
| `app/gitanjali/lib/src/presentation/reader/reader_page.dart` | Modify | Animate multi-frame backgrounds |
| `app/gitanjali/test/book_repository_test.dart` | Modify | Add keyframe parser coverage |
| `app/gitanjali/test/legacy_asset_resolver_test.dart` | Modify | Add keyframe sequence resolution coverage |
| `app/gitanjali/test/reader_controller_test.dart` | Modify | Align model ctor after background field extension |
| `legacy/README.md` | Create | Describe legacy migration sources |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Timer-based animation adds UI overhead | Medium | Medium | Use lightweight fixed cadence and only enable for multi-frame pages |
| Resolver ordering mismatch | Low | Medium | Sort resolved keyframe paths deterministically |

## Rollback Strategy

1. Revert v2 parser/model/UI deltas while retaining v1 static background behavior.
2. Keep `legacy/README.md` documentation regardless of animation decision.

## Checkpoints

- [x] Existing non-keyframe pages remain unchanged.
- [x] Keyframe pages render animated background sequence.
- [x] Tests and analysis are green after changes.

## Open Implementation Questions

- [x] Should keyframe speed be configurable in this slice?  
      Decision: no, fixed interval in v2.

---

## Approval

- [x] Reviewed by: user
- [x] Approved on: 2026-04-29
- [x] Notes: Direct execution request.
