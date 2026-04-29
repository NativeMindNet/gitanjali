# ADR-001: Book XML Content Format

## Meta

- **Number**: ADR-001
- **Type**: constraining
- **Status**: APPROVED
- **Created**: 2026-04-29
- **Decided**: 2022-01-20 (legacy decision, documented retroactively)
- **Author**: Dmitry Panin (legacy), documented by /legacy analysis
- **Reviewers**: Migration team

## Context

The legacy iOS applications (`legacy_gitanjajali_swift`, `legacy-gitanjali-swift`, `legacy-sgg-ru-v1`, `legacy-cookbook`) all use a custom XML format for defining book content, structure, styling, navigation controls, and multimedia assets. This format has been the source of truth for all book reader applications since 2011.

The format needed to support:
- Hierarchical book structure (sections, pages, paragraphs)
- Rich styling with custom fonts
- Background animations (keyframe sequences, image animations, fade effects)
- Audio playback per page
- Interactive controls (navigation, search, bookmarks, audio)
- Multi-language support
- Comments and annotations

## Decision Drivers

- **Content portability**: Same content format works across all legacy apps
- **Offline-first**: All content must be bundled and work without network
- **Rich media**: Background animations, custom fonts, audio playback
- **Flexible controls**: Different apps have different navigation/feature buttons
- **XML tooling**: Standard XML parsers available in all platforms

## Considered Options

### Option 1: Custom XML Format (chosen)

**Description**: Define a proprietary XML schema `book version="1.0"` with nested elements for head, body, sections, pages, paragraphs, controls, backgrounds, animations, and audio.

**Pros**:
- Full control over schema evolution
- Compact representation for book-specific concepts
- Single file contains all structural metadata
- Asset paths use `($APP_BUNDLE)/` placeholder for platform abstraction

**Cons**:
- Requires custom parser implementation per platform
- No schema validation tooling
- Learning curve for content authors

**Estimated Effort**: Medium (initial), Low (ongoing)

### Option 2: EPUB Standard

**Description**: Use industry-standard EPUB format for ebook content.

**Pros**:
- Industry standard with tooling support
- Validation and conversion tools available
- Content portability across readers

**Cons**:
- Does not support keyframe animations
- Limited control positioning
- Would require extensions for audio/animation features
- Over-engineered for single-book apps

**Estimated Effort**: High

### Option 3: JSON Format

**Description**: Use JSON for content definition.

**Pros**:
- Native parsing in modern platforms
- More concise than XML

**Cons**:
- Less readable for hierarchical content
- No attribute syntax (controls would be verbose)
- Limited tooling in 2011 era when format was designed

**Estimated Effort**: Medium

## Decision

We will use **Custom XML Format** because:

- It provides exact control over book-specific features (keyframe animations, control positioning, audio mapping)
- All legacy apps already implement this format consistently
- The format is stable (version 1.0 since 2011)
- Asset path abstraction `($APP_BUNDLE)/` works across iOS and Flutter

## Consequences

### Positive

- Single XML file describes entire book structure
- All legacy content is immediately compatible
- Format supports all required features natively
- Clear separation between structure (XML) and assets (images, audio, fonts)

### Negative

- Requires custom parser for each target platform (ObjC legacy, Dart Flutter)
- No schema validation tooling
- Version migration requires parser updates

### Neutral

- XML file size is reasonable for typical books (100KB - 400KB)
- Parser complexity is manageable with recursive deserialization

## Implementation Notes

- XML uses libxml2 in legacy ObjC code via `BXMLDeserializableObject` protocol
- Flutter migration should use `xml` package with similar recursive parsing
- Asset path placeholder `($APP_BUNDLE)/` must be resolved at runtime to platform-specific asset location
- Format version check is mandatory: `<book version="1.0">`

## Schema Overview

```xml
<book version="1.0">
  <head>
    <id>...</id>
    <book-title>...</book-title>
    <lang>...</lang>
    <src-lang>...</src-lang>
    <orientation>portrait|landscape</orientation>
    <author>...</author>
    <translator>...</translator>
    <isbn>...</isbn>
    <genre>...</genre>
    <publish-info>...</publish-info>
    <controls>
      <control type="prev-page|next-page|page-link|search|bookmarks|add-bookmark|play-sound|stop-sound|toggle-player">
        <center><x>...</x><y>...</y></center>
        <image>...</image>
        <highlighted-image>...</highlighted-image>
        <arg>...</arg>
      </control>
    </controls>
  </head>
  <body>
    <styles>
      <style name="..." font-size="..." text-alignment="..." text-color="..."/>
    </styles>
    <section>
      <title><p>...</p></title>
      <page>
        <background color="...">
          <animation center="{x, y}" start-delay="...">
            <target type="keyframe|image" repeat-count="..." images-per-second="...">...</target>
            <actions>
              <action type="fade|scale|rotation" duration="..." .../>
            </actions>
          </animation>
        </background>
        <p style="...">...</p>
        <comments>...</comments>
        <audio>...</audio>
        <show-number>0|1</show-number>
        <controls>...</controls>
      </page>
    </section>
  </body>
</book>
```

## Related Decisions

- ADR-002: Shared Architecture Pattern (enables consistent parsing approach)

## Related Specs

- `flows/sdd-gitanjali-flutter-refactoring/`: Primary migration implementation
- `flows/sdd-gitanjali-flutter-refactoring-v2/`: Keyframe animation support

## References

- `legacy/legacy_gitanjajali_swift/Gitanjali/Resources/example.xml`
- `legacy/legacy-sgg-ru-v1/Resources/example.xml`
- `legacy/legacy-cookbook/Resources/example.xml`
- `legacy/legacy_gitanjajali_swift/Gitanjali/Classes/Data Core/BBook.m` - Parser implementation

## Tags

architecture content xml parser legacy migration

---

## Approval

### Review History

| Date | Reviewer | Status | Comments |
|------|----------|--------|----------|
| 2026-04-29 | /legacy | approved | Documented from legacy analysis |

### Final Decision

- [x] Approved by: legacy analysis
- [x] Decided on: 2022 (retroactive documentation 2026-04-29)
- [x] Implementation assigned to: Migration team
