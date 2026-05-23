# ADR-003: Songbook Markdown Format

## Meta

- **Number**: ADR-003
- **Type**: constraining
- **Status**: APPROVED
- **Created**: 2026-05-23
- **Decided**: 2020 (legacy decision, documented retroactively)
- **Author**: Legacy analysis, documented by /legacy
- **Reviewers**: Migration team

## Context

The songbook ecosystem needs a standardized content format for storing sacred Vaishnava music (kirtans, prayers, bhajans) across multiple language editions. Content must be:
- Human-readable and editable by translators with minimal technical skills
- Version-controllable for collaboration
- Machine-parseable for web generators and mobile apps
- Validated for consistency across editions

Unlike the book reader apps (ADR-001) which use XML for rich formatting and animations, the songbook content is primarily textual with simple structure: verses with original text and translations.

## Decision Drivers

- **Translator accessibility**: Translators should edit content directly without specialized tools
- **Version control**: Content changes must be trackable with standard Git workflows
- **Multi-target output**: Same source should produce web (HTML), mobile (JSON), and print (PDF)
- **Validation**: Content structure must be validated before publishing
- **Consistency**: All 8 songbook editions must follow identical format

## Considered Options

### Option 1: YAML Frontmatter + Markdown Body (chosen)

**Description**: Each song is a `.md` file with YAML metadata header and Markdown body for verses.

```markdown
---
title: Song Title
author: Author Name
tags: [prayer, morning]
---

## Verse 1

Original text here

Translation text here
```

**Pros**:
- Human-readable by translators
- Standard Markdown editors work out of the box
- Git diff shows meaningful changes
- YAML frontmatter is widely supported
- Extensible metadata without body changes

**Cons**:
- Requires custom parser for verse structure
- No built-in validation (needs JSON Schema)
- Learning curve for YAML syntax

**Estimated Effort**: Medium (initial parser), Low (ongoing)

### Option 2: Pure JSON Files

**Description**: Each song as a JSON file with structured fields.

**Pros**:
- No parsing needed
- Direct schema validation
- Machine-friendly

**Cons**:
- Hard for translators to edit
- Verbose and error-prone
- Poor diff readability in Git
- No visual formatting preview

**Estimated Effort**: Low

### Option 3: Database with CMS

**Description**: Store content in database with web-based CMS for editing.

**Pros**:
- Rich editing interface
- Built-in validation
- Role-based access control

**Cons**:
- Requires server infrastructure
- No offline editing
- Complex deployment
- Loses version control benefits

**Estimated Effort**: High

### Option 4: XML (like ADR-001)

**Description**: Use XML format similar to book reader content.

**Pros**:
- Consistent with book readers
- Schema validation available

**Cons**:
- Too complex for simple verse structure
- Verbose compared to Markdown
- Intimidating for translators
- Overkill for text-only content

**Estimated Effort**: Medium

## Decision

We will use **YAML Frontmatter + Markdown Body** because:

- Translators can edit content in any text editor without training
- Git diffs are readable and reviewable
- Markdown preview shows formatted verses
- YAML metadata is extensible for future requirements
- Single-source publishing to multiple targets via `songbook-md-json-parser`

## Consequences

### Positive

- All 8 songbook editions use consistent format
- Translators work independently without developer assistance
- Content changes are reviewed via standard PR workflow
- Markdown previews in GitHub/editors show verse formatting
- Audio resources link via metadata fields

### Negative

- Custom parser required (`songbook-md-json-parser`)
- JSON Schema validation adds build-time dependency
- Verse structure conventions must be documented

### Neutral

- Each song is one file (songs/ directory structure)
- File naming convention: `NNN-song-id.md`
- JSON output generated to json/ directory

## Implementation Notes

- Parser: `songbook-md-json-parser` npm package
- Validation: AJV with custom JSON Schema
- CLI commands: `songbook-build`, `songbook-validate`
- CI enforcement via GitHub Actions on every push

## Song File Structure

```markdown
---
# Required metadata
title: "Śrī Gurv-Aṣṭaka"
author: "Viśvanātha Cakravartī Ṭhākura"

# Optional metadata
language: ru
tags:
  - prayer
  - guru
  - morning
audio:
  - id: recording-001
    performer: Bhakti Sudhir Goswami
---

## Verse 1

saṁsāra-dāvānala-līḍha-loka-
trāṇāya kāruṇya-ghanāghanatvam
prāptasya kalyāṇa-guṇārṇavasya
vande guroḥ śrī-caraṇāravindam

Охваченный пламенем мирского бытия,
и жаждущий спасения от страданий,
я склоняюсь к лотосным стопам духовного учителя...

## Verse 2

...
```

## Related Decisions

- ADR-001: Book XML Format (different format for rich book content)
- ADR-002: Shared Architecture Pattern (pattern influences parser reuse)
- ADR-004: Per-Language Repository (each repo uses this format)
- ADR-005: Centralized Parser Library (implements this format)

## Related Specs

- `flows/legacy/understanding/content-ecosystem/`: Content analysis
- `flows/legacy/understanding/build-infrastructure/`: Parser analysis

## References

- `legacy/songbook-md-json-parser/`: Parser implementation
- `legacy/gaudiya-gitanjali-ru/songs/`: Example content
- `legacy/kirtan-guide-es/songs/`: Example content
- `legacy/songbook-md-json-parser/schema/song.source.js`: JSON Schema

## Tags

content markdown format songbook parser validation

---

## Approval

### Review History

| Date | Reviewer | Status | Comments |
|------|----------|--------|----------|
| 2026-05-23 | /legacy | approved | Documented from legacy analysis |

### Final Decision

- [x] Approved by: legacy analysis
- [x] Decided on: 2020 (retroactive documentation 2026-05-23)
- [x] Implementation assigned to: songbook-md-json-parser maintainers
