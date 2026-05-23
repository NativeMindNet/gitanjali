# ADR-004: Per-Language Repository Pattern

## Meta

- **Number**: ADR-004
- **Type**: enabling
- **Status**: APPROVED
- **Created**: 2026-05-23
- **Decided**: 2019 (legacy decision, documented retroactively)
- **Author**: Legacy analysis, documented by /legacy
- **Reviewers**: Migration team

## Context

The songbook ecosystem publishes sacred Vaishnava music in multiple languages. Each language edition has:
- Different translators with different workflows
- Different release schedules
- Different levels of completeness
- Different review processes

We need a strategy for organizing multilingual content across repositories.

## Decision Drivers

- **Independent releases**: Each language edition should release independently
- **Translator isolation**: Translators should work without affecting other editions
- **Attribution**: Each edition should clearly credit its translators
- **Consistency**: All editions must follow the same content format (ADR-003)
- **Aggregation**: Web generators must easily consume all editions

## Considered Options

### Option 1: Separate Repository Per Language (chosen)

**Description**: Each language edition is a standalone npm package in its own git repository.

```
gaudiya-gitanjali-lv/     # Latvian edition
gaudiya-gitanjali-ru/     # Russian edition
gaudiya-gitanjali-ua/     # Ukrainian edition
kirtan-guide-es/          # Spanish edition
kirtan-guide-pt/          # Portuguese edition
```

**Pros**:
- Complete isolation between editions
- Independent CI/CD pipelines
- Clear ownership and attribution
- Flexible release schedules
- Translators work without conflicts

**Cons**:
- More repositories to manage
- Format changes require updates across all repos
- Aggregation requires dependency management

**Estimated Effort**: Low per edition

### Option 2: Single Monorepo with Directories

**Description**: All editions in one repository with language subdirectories.

```
songbooks/
├── lv/
├── ru/
├── ua/
├── es/
└── pt/
```

**Pros**:
- Single repository to manage
- Format changes apply everywhere
- Easier cross-language search

**Cons**:
- Merge conflicts between translators
- Coupled release cycles
- Unclear ownership
- Large repository size

**Estimated Effort**: Medium

### Option 3: Branches Per Language

**Description**: Single repository with long-lived branches per language.

**Pros**:
- Single repository
- Separate history per language

**Cons**:
- Branch management complexity
- Difficult to merge shared changes
- Confusing contributor workflow
- Git antipattern for long-lived branches

**Estimated Effort**: High

### Option 4: i18n Keys with Translations File

**Description**: Single source with translation strings in JSON files.

**Pros**:
- Single source of truth
- Standard i18n tooling

**Cons**:
- Doesn't fit verse-based content
- Hard to manage prose translations
- Inappropriate for full text translation

**Estimated Effort**: High

## Decision

We will use **Separate Repository Per Language** because:

- Each edition operates as independent product with own translators
- Release independence prevents blocking between editions
- npm packages enable versioned dependency management
- Format consistency enforced by shared `songbook-md-json-parser`
- Clear translator attribution in each edition's README

## Consequences

### Positive

- Translators work without coordination
- Editions release on their own schedules
- CI validates each edition independently
- Clear ownership and attribution
- npm versioning enables stable dependencies

### Negative

- Format changes require updating multiple repositories
- Shared changes need propagation
- More repositories to monitor

### Neutral

- Web generators specify editions via `dependencies.json`
- Each edition published to npm for consumption
- Same directory structure in all editions

## Implementation Notes

### Repository Naming Convention

```
[series]-[language]/
```

Examples:
- `gaudiya-gitanjali-lv` (Latvian Gaudiya Gitanjali)
- `kirtan-guide-es` (Spanish Kirtan Guide)
- `kirtan-guide-pocket-edition` (English pocket format)

### Standard Directory Structure

```
[edition]/
├── package.json
├── README.md          # Credits and attribution
├── songs/
│   └── *.md           # Song content
├── json/
│   └── songs/         # Generated output
└── scripts/
```

### Web Generator Integration

```json
// kirtan-next/source/dependencies.json
{
  "songbooks": [
    {
      "name": "gaudiya-gitanjali-ru",
      "repo": "git+https://github.com/user/gaudiya-gitanjali-ru.git"
    },
    {
      "name": "kirtan-guide-es",
      "repo": "git+https://github.com/user/kirtan-guide-es.git"
    }
  ]
}
```

## Current Editions

| Edition | Language | Repository | Songs |
|---------|----------|------------|-------|
| Gaudiya Gitanjali | Latvian | gaudiya-gitanjali-lv | 50+ |
| Gaudiya Gitanjali | Russian | gaudiya-gitanjali-ru | 50+ |
| Gaudiya Gitanjali | Ukrainian | gaudiya-gitanjali-ua | 50+ |
| Gaudiya Gitanjali | Ukrainian (preview) | gaudiya-gitanjali-ua-preview | 50+ |
| Kirtan Guide | Spanish | kirtan-guide-es | 80+ |
| Kirtan Guide | Portuguese | kirtan-guide-pt | 80+ |
| Kirtan Guide | English (pocket) | kirtan-guide-pocket-edition | 80+ |

## Related Decisions

- ADR-003: Songbook Markdown Format (format used by all editions)
- ADR-005: Centralized Parser Library (validates all editions)
- ADR-008: AI Translation Pipeline (creates new editions)

## Related Specs

- `flows/legacy/understanding/content-ecosystem/`: Edition analysis

## References

- `legacy/gaudiya-gitanjali-lv/`: Latvian edition
- `legacy/gaudiya-gitanjali-ru/`: Russian edition
- `legacy/kirtan-guide-es/`: Spanish edition
- `legacy/kirtan-next/source/dependencies.json`: Aggregation config

## Tags

localization repository organization npm multi-language

---

## Approval

### Review History

| Date | Reviewer | Status | Comments |
|------|----------|--------|----------|
| 2026-05-23 | /legacy | approved | Documented from legacy analysis |

### Final Decision

- [x] Approved by: legacy analysis
- [x] Decided on: 2019 (retroactive documentation 2026-05-23)
- [x] Implementation assigned to: Songbook maintainers
