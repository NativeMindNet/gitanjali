# Understanding: Content Ecosystem

> Songbook content repositories and audio resources

## Phase: EXPLORING

## Hypothesis

The content ecosystem consists of multiple npm packages containing sacred Vaishnava music in various languages. Each package follows the same structure: Markdown source files with YAML frontmatter, processed by `songbook-md-json-parser` to produce JSON output.

## Sources

| Path | Type | Contents |
|------|------|----------|
| legacy/gaudiya-gitanjali-lv/ | npm package | Latvian songbook (50+ songs) |
| legacy/gaudiya-gitanjali-ru/ | npm package | Russian songbook (50+ songs) |
| legacy/gaudiya-gitanjali-ua/ | npm package | Ukrainian songbook (50+ songs) |
| legacy/gaudiya-gitanjali-ua-preview/ | npm package | Ukrainian transliteration |
| legacy/kirtan-guide-es/ | npm package | Spanish Kirtan Guide (80+ songs) |
| legacy/kirtan-guide-pt/ | npm package | Portuguese Kirtan Guide (80+ songs) |
| legacy/kirtan-guide-pocket-edition/ | npm package | Pocket reference edition |
| legacy/songbook-resources/ | npm package | Shared audio metadata |

## Validated Understanding

### Songbook Structure Pattern

Each songbook npm package follows identical structure:

```
[songbook-name]/
├── package.json          # npm config, build scripts
├── README.md             # Credits, publication info
├── songs/                # Markdown source files
│   ├── 001-song-name.md
│   ├── 002-song-name.md
│   └── ...
├── json/                 # Generated output (not committed)
│   └── songs/
│       └── *.json
└── scripts/              # Build helpers
    └── render-with-first-line.js
```

### Song Markdown Format

Each song file uses YAML frontmatter + Markdown body:

```markdown
---
title: Song Title
author: Author Name
language: lv
tags:
  - prayer
  - morning
---

## Verse 1

Sanskrit/original text here

Translation text here
```

### Package Dependencies

All songbooks depend on `songbook-md-json-parser`:
- `songbook-build` - Main build command
- `songbook-parse-songs` - MD → JSON conversion
- `songbook-validate` - JSON schema validation

### Songbook Editions

| Edition | Languages | Songs | Purpose |
|---------|-----------|-------|---------|
| Gaudiya Gitanjali | lv, ru, ua | 50-60 | Full prayers with translations |
| Kirtan Guide | es, pt | 80-100 | Detailed guide with word-by-word |
| Pocket Edition | en | 80+ | Condensed reference |

### Audio Resources (songbook-resources)

Centralized audio metadata:

```
songbook-resources/
├── audio.md              # Human-edited source
├── resources.json        # Generated output
├── persons.json          # Performer database (3500+ entries)
└── scripts/
    ├── parse-audio-md.js
    └── test-resource-performers.js
```

Audio format in `audio.md`:
```markdown
## song-id

### Recording Name
- performer: Performer Name
- soundcloud: https://soundcloud.com/...
```

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| markdown-format | YAML frontmatter + verse structure | DOCUMENTED below |
| multilingual-editions | Per-language repo pattern | DOCUMENTED below |
| audio-integration | Resource linking mechanism | DOCUMENTED below |

## Dependencies

- **Uses**: `songbook-md-json-parser` (parsing/validation)
- **Used by**: `kirtan-mate`, `kirtan-next` (web publishing)

## Key Insights

1. **Content-as-Code**: All content in version-controlled Markdown, not database
2. **Per-Language Repos**: Localization via separate repositories (not i18n)
3. **Build-time Validation**: JSON schema ensures content quality
4. **Shared Audio**: Centralized performer database across all editions
5. **Translator Credits**: Each edition maintains detailed attribution

## ADR Candidates

1. **ADR-003: Songbook Markdown Format**
   - Decision: Use YAML frontmatter + Markdown for song content
   - Alternatives: JSON, XML, Database
   - Rationale: Human-readable, version-controllable, translator-friendly

2. **ADR-004: Per-Language Repository Pattern**
   - Decision: Separate npm package per language edition
   - Alternatives: Single repo with i18n, branches per language
   - Rationale: Independent release cycles, different translators

## Flow Recommendation

- **Type**: SDD
- **Confidence**: HIGH
- **Rationale**: Technical infrastructure for content management, not user-facing

## Synthesis

### Combined Understanding

The content ecosystem is a **multi-language spiritual music library** with:

1. **8 songbook packages** (Latvian, Russian, Ukrainian, Spanish, Portuguese, English)
2. **Standardized format** (YAML frontmatter + Markdown verses)
3. **Centralized audio metadata** with 3500+ performer entries
4. **Build-time validation** via songbook-md-json-parser
5. **Published to npm** for consumption by web generators

### Content Statistics

| Edition | Language | Songs | Status |
|---------|----------|-------|--------|
| gaudiya-gitanjali-lv | Latvian | 50+ | Published |
| gaudiya-gitanjali-ru | Russian | 50+ | Published |
| gaudiya-gitanjali-ua | Ukrainian | 50+ | Published |
| gaudiya-gitanjali-ua-preview | Ukrainian | 50+ | Preview (transliteration only) |
| kirtan-guide-es | Spanish | 80+ | Published |
| kirtan-guide-pt | Portuguese | 80+ | Published |
| kirtan-guide-pocket-edition | English | 80+ | Published |
| songbook-resources | - | - | Audio metadata |

## Bubble Up

- 8 npm packages containing songbook content in 6 languages
- Standardized YAML+Markdown format across all editions
- Centralized audio resources with 3500+ performers
- All depend on `songbook-md-json-parser` for build/validation
- Two ADRs needed: Markdown Format, Per-Language Repos

---

*Phase: EXPLORING | Depth: 1 | Parent: root*
