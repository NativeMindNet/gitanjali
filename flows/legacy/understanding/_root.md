# Understanding: Legacy Ecosystem Root

> Entry point for analysis of all legacy projects in /legacy/

## Project Overview

The legacy folder contains a **comprehensive multi-platform ecosystem** for publishing and distributing Vaishnava sacred music and devotional content. The system spans:

- **Native iOS apps** (Objective-C book readers - already documented in ADR-001, ADR-002)
- **Web applications** (Gulp and Next.js static site generators)
- **NPM packages** (content repositories and tooling)
- **AI-powered translation pipelines**
- **Shared infrastructure** (parsers, validators, audio resources)

## Ecosystem Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTENT ECOSYSTEM                             │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │ Songbook Sources │    │ Audio Resources  │                   │
│  │  (Markdown/YAML) │    │   (resources/)   │                   │
│  └────────┬─────────┘    └────────┬─────────┘                   │
│           │                       │                              │
│           ▼                       ▼                              │
│  ┌─────────────────────────────────────────┐                    │
│  │       songbook-md-json-parser           │                    │
│  │    (validation + JSON generation)       │                    │
│  └────────────────────┬────────────────────┘                    │
│                       │                                          │
│           ┌───────────┼───────────┐                              │
│           ▼           ▼           ▼                              │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐                   │
│  │kirtan-mate │ │kirtan-next │ │ Flutter App│                   │
│  │  (Gulp)    │ │ (Next.js)  │ │(app/gitanj)│                   │
│  └────────────┘ └────────────┘ └────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    LEGACY iOS APPS                               │
│                                                                  │
│  ┌──────────────────┐                                            │
│  │   Book XML       │   ─── ADR-001: Custom XML format           │
│  └────────┬─────────┘                                            │
│           ▼                                                      │
│  ┌──────────────────┐                                            │
│  │ Shared Classes   │   ─── ADR-002: Shared architecture         │
│  │ (BBook, BUI*)    │                                            │
│  └────────┬─────────┘                                            │
│           ▼                                                      │
│  ┌──────────────────┐   ┌──────────────────┐                    │
│  │  English Reader  │   │  Russian Reader  │                    │
│  └──────────────────┘   └──────────────────┘                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    AI TRANSLATION                                │
│                                                                  │
│  English songs ──► Gemini API ──► Ukrainian songs               │
│                    (10-stage pipeline)                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Legacy Projects Discovered (2026-05-23)

| Project | Type | Domain | Status |
|---------|------|--------|--------|
| ddd-architecture-specification | Documentation | Architecture | NEW |
| gaudiya-gitanjali-lv | Songbook (npm) | Latvian content | NEW |
| gaudiya-gitanjali-ru | Songbook (npm) | Russian content | NEW |
| gaudiya-gitanjali-ua | Songbook (npm) | Ukrainian content | NEW |
| gaudiya-gitanjali-ua-preview | Songbook (npm) | Ukrainian transliteration | NEW |
| kirtan-guide-es | Songbook (npm) | Spanish content | NEW |
| kirtan-guide-pt | Songbook (npm) | Portuguese content | NEW |
| kirtan-guide-pocket-edition | Songbook (npm) | Pocket reference | NEW |
| kirtan-mate | Web App (Gulp) | Multi-songbook aggregator | NEW |
| kirtan-next | Web App (Next.js) | Modern songbook portal | NEW |
| md2html | Tool (Gulp) | Markdown to HTML/JSON | NEW |
| songbook-md-json-parser | Library (npm) | Parsing/validation core | NEW |
| songbook-resources | Data (npm) | Shared audio metadata | NEW |
| songbook-translate-en-ua-ai | Pipeline (Node) | AI translation | NEW |
| standalone-browser-audio-player | Widget (HTML/JS) | Audio player component | NEW |
| legacy-gitanjali-en-swift | iOS App (ObjC) | English reader | DOCUMENTED (ADR-001, ADR-002) |
| legacy-gitabjali-ru-swift | iOS App (ObjC) | Russian reader | DOCUMENTED (ADR-001, ADR-002) |

## Key Patterns Identified

1. **Content-as-Code**: All songbook content stored in Markdown with YAML frontmatter
2. **Multi-target Publishing**: Same content published to web (Gulp, Next.js) and mobile (Flutter)
3. **Centralized Parsing**: `songbook-md-json-parser` is single source of truth for content validation
4. **Localization Strategy**: Separate repositories per language (not i18n within single repo)
5. **Audio Resource Management**: Centralized `songbook-resources` with performer database
6. **AI-Assisted Translation**: Automated pipeline with human oversight for Ukrainian content

## Domain Boundaries

| Domain | Projects | Pattern |
|--------|----------|---------|
| Content | gaudiya-gitanjali-*, kirtan-guide-* | npm packages with songs/ + json/ |
| Infrastructure | songbook-md-json-parser, songbook-resources | npm libraries |
| Web Publishing | kirtan-mate, kirtan-next | Static site generators |
| Mobile | legacy-*-swift, app/gitanjali | Native iOS, Flutter |
| Translation | songbook-translate-en-ua-ai | AI pipeline |
| Tools | md2html | Hari-katha conversion |
| Components | standalone-browser-audio-player | Embeddable widgets |
| Documentation | ddd-architecture-specification | Architecture guidance |

## Children Spawned

```
understanding/
├── content-ecosystem/        # Songbooks + audio resources
│   └── _node.md
├── build-infrastructure/     # Parser + tools
│   └── _node.md
├── web-publishing/           # kirtan-mate, kirtan-next
│   └── _node.md
├── ai-translation/           # Translation pipeline
│   └── _node.md
└── web-components/           # Audio player widget
    └── _node.md
```

## Flow Recommendations

### New ADRs Needed

| Topic | Type | Confidence | Rationale |
|-------|------|------------|-----------|
| Songbook Markdown Format | ADR | HIGH | Defines content-as-code pattern |
| Multi-Edition Localization | ADR | HIGH | Per-language repository strategy |
| AI Translation Pipeline | ADR | MEDIUM | Novel automation approach |

### Existing Flows to Update

| Flow | Topics to Add |
|------|---------------|
| ADR-001 (XML Format) | Note: XML for iOS/Flutter, Markdown for web |
| ADR-002 (Shared Architecture) | Pattern applies to npm package reuse too |

### New SDDs Needed

| Topic | Type | Priority |
|-------|------|----------|
| songbook-md-json-parser API | SDD | HIGH - core library |
| kirtan-next architecture | SDD | MEDIUM - modern stack |

## Synthesis

The legacy ecosystem spans 17 projects across 5 distinct domains:
- **Two content formats**: XML (iOS/Flutter readers) and Markdown (web songbooks)
- **Core infrastructure**: `songbook-md-json-parser` npm package
- **Multi-language support**: Separate content repositories per language
- **AI translation**: Automates EN→UA conversion with 10-stage pipeline
- **Web publishing**: Both legacy (Gulp) and modern (Next.js 16) approaches

---

*Updated by /legacy - 2026-05-23*
