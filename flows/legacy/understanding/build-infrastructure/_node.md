# Understanding: Build Infrastructure

> Core parsing library and conversion tools

## Phase: EXPLORING

## Hypothesis

The build infrastructure provides shared tooling for processing songbook content. The core is `songbook-md-json-parser` - an npm package that defines the content format schema and provides CLI commands for parsing, validation, and rendering.

## Sources

| Path | Type | Purpose |
|------|------|---------|
| legacy/songbook-md-json-parser/ | npm package | Core parsing library |
| legacy/md2html/ | Gulp project | Hari-katha conversion tool |

## Validated Understanding

### songbook-md-json-parser

Core library providing CLI commands and JavaScript API:

```
songbook-md-json-parser/
├── package.json          # Exports bin commands
├── lib/
│   ├── Song.js           # Song object model
│   ├── parse-songs.js    # MD → JSON parsing
│   ├── render.js         # JSON → MD rendering
│   ├── Contents.js       # Contents management
│   ├── validate.js       # Schema validation
│   ├── parse-meta.js     # YAML extraction
│   ├── embeds.js         # Embed code handling
│   └── process-files.js  # File pipeline
├── schema/
│   ├── song.source.js    # JSON Schema definition
│   └── build-schema.js   # Schema builder
├── bin commands:
│   ├── songbook-build        → build.js
│   ├── songbook-parse-songs  → parse-songs.js
│   ├── songbook-parse-contents → parse-contents.js
│   ├── songbook-parse-index  → parse-index.js
│   ├── songbook-validate     → validate.js
│   ├── songbook-list-authors → list-authors.js
│   └── songbook-test-authors → test-authors.sh
└── test-fixtures/
    ├── valid/
    └── invalid/
```

### CLI Commands

| Command | Purpose |
|---------|---------|
| `songbook-build` | Full build pipeline (parse → validate → output) |
| `songbook-parse-songs` | Convert Markdown songs to JSON |
| `songbook-parse-contents` | Parse table of contents |
| `songbook-parse-index` | Generate song index |
| `songbook-validate` | Validate JSON against schema |
| `songbook-list-authors` | Extract author list |

### Song Schema (Simplified)

```javascript
// schema/song.source.js
{
  type: "object",
  properties: {
    id: { type: "string" },
    title: { type: "string" },
    author: { type: "string" },
    language: { type: "string" },
    tags: { type: "array", items: { type: "string" } },
    verses: {
      type: "array",
      items: {
        original: { type: "string" },
        translation: { type: "string" }
      }
    }
  },
  required: ["id", "title"]
}
```

### md2html (Hari-katha Converter)

Different purpose - converts spiritual lectures (Hari-kathas) to HTML/MongoDB:

```
md2html/
├── gulpfile.js           # Gulp build config
├── scripts/
│   ├── md-to-html.js     # Markdown → HTML
│   ├── html-to-json.js   # HTML → MongoDB JSON
│   └── validate.js       # HTML validation
├── import/
│   └── *.sh              # MongoDB import scripts
├── styles/
│   └── *.scss            # Output styling
└── fixtures/
    └── test data
```

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| parser-api | Song.js + parse functions | DOCUMENTED below |
| validation-system | AJV + JSON Schema | DOCUMENTED below |
| cli-interface | bin commands | DOCUMENTED below |

## Dependencies

- **Uses**: AJV (JSON Schema validator), js-yaml
- **Used by**: All songbook packages, kirtan-mate, kirtan-next

## Key Insights

1. **Central Schema Authority**: `songbook-md-json-parser` defines THE schema
2. **Bi-directional**: Can parse MD→JSON AND render JSON→MD
3. **CI Integration**: GitHub Actions validates on every push
4. **Testable**: Includes valid/invalid fixtures for testing
5. **Decoupled**: Parsing separate from web generators

## ADR Candidates

1. **ADR-005: Centralized Parser Library**
   - Decision: Single npm package for all parsing/validation
   - Alternatives: Copy-paste parsing code, per-project parsers
   - Rationale: Single source of truth, consistent validation

2. **ADR-006: JSON Schema for Content Validation**
   - Decision: Use AJV with JSON Schema
   - Alternatives: TypeScript types only, manual validation
   - Rationale: Runtime validation, CI enforcement

## Flow Recommendation

- **Type**: SDD
- **Confidence**: HIGH
- **Rationale**: Pure technical library with clear API contract

### SDD Structure Recommendation

```
flows/sdd-songbook-parser/
├── 01-requirements.md    # CLI commands, API functions
├── 02-specifications.md  # Song schema, parsing rules
├── 03-plan.md
└── _status.md
```

## Synthesis

### Combined Understanding

The build infrastructure consists of:

1. **songbook-md-json-parser**: Core library
   - Parses YAML+MD → structured JSON
   - Validates against JSON Schema
   - Provides CLI for automation
   - Used by ALL songbook packages

2. **md2html**: Separate tool for lectures
   - Converts Hari-katha lectures to HTML
   - Imports to MongoDB
   - Different content type than songbooks

### Integration Points

```
                     ┌───────────────────────┐
                     │songbook-md-json-parser│
                     └──────────┬────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│gaudiya-git-lv │    │kirtan-guide-es│    │kirtan-next    │
└───────────────┘    └───────────────┘    └───────────────┘
```

## Bubble Up

- `songbook-md-json-parser` is THE core library for content processing
- Defines JSON Schema for song validation
- Provides CLI for build automation
- All songbooks + web generators depend on it
- `md2html` is separate tool for lecture content (different domain)

---

*Phase: EXPLORING | Depth: 1 | Parent: root*
