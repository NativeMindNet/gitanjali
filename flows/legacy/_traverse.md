# Traversal State

> Persistent recursion stack for tree traversal. AI reads this to know where it is and what to do next.

## Mode

- **BFS** - Breadth-first analysis of all legacy projects

## Source Path

/legacy/

## Focus (DFS only)

[none - BFS mode]

## Existing Flows Index

| Flow Path | Type | Topics | Key Decisions |
|-----------|------|--------|---------------|
| flows/adr-001-book-xml-format/ | ADR | XML format, content structure, parser | Custom XML chosen over EPUB/JSON |
| flows/adr-002-shared-architecture-pattern/ | ADR | legacy patterns, code reuse, MVC | Shared architecture with content-only variation |
| flows/sdd-gitanjali-flutter-refactoring/ | SDD | Flutter migration, reader, audio, bookmarks | Direct XML parsing in Flutter |
| flows/sdd-gitanjali-flutter-refactoring-v2/ | SDD | keyframe animation, visual parity | Added background animation support |
| flows/sdd-control-system/ | SDD | controls, navigation, buttons, XML | Flexible XML-defined control system |
| flows/sdd-animation-system/ | SDD | keyframe, fade, scale, rotation | Animation defined in XML |
| flows/vdd-gitanjaly-layout/ | VDD | layout, responsive, reader, audio player | Adaptive layout for all devices |

## Legacy Projects Discovered

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

## Current Stack

```
/ (root)                                SYNTHESIZING
├── content-ecosystem                   DONE → ADR-003, ADR-004
│   ├── songbook-data-format            DONE (songs/, json/, markdown)
│   ├── multilingual-editions           DONE (lv, ru, ua, es, pt)
│   └── audio-resources                 DONE (recordings, performers)
├── build-infrastructure                DONE → ADR-005, ADR-006 candidates
│   ├── parser-library                  DONE (songbook-md-json-parser)
│   ├── web-generators                  DONE (kirtan-mate, kirtan-next)
│   └── conversion-tools                DONE (md2html)
├── ai-translation-pipeline             DONE → ADR-008, ADR-009 candidates
│   └── gemini-translation              DONE (en→ua, 10 stages)
├── web-components                      DONE (no ADR needed)
│   └── audio-player                    DONE (standalone-browser-audio-player)
├── architecture-docs                   DONE (reference only)
│   └── ddd-spec                        DONE
└── legacy-ios-apps                     DONE (ADR-001, ADR-002)
```

## Stack Operations Log

| # | Operation | Node | Phase | Result |
|---|-----------|------|-------|--------|
| 1 | INIT | / (root) | ENTERING | Started BFS analysis |
| 2 | UPDATE | / (root) | EXPLORING | Scanned 17 legacy projects |
| 3 | UPDATE | / (root) | SPAWNING | Created logical tree with 6 domains |
| 4 | ENTER | content-ecosystem | EXPLORING | Analyzed 8 songbook packages |
| 5 | ENTER | build-infrastructure | EXPLORING | Analyzed parser + md2html |
| 6 | ENTER | web-publishing | EXPLORING | Analyzed kirtan-mate, kirtan-next |
| 7 | ENTER | ai-translation | EXPLORING | Analyzed 10-stage pipeline |
| 8 | ENTER | web-components | EXPLORING | Analyzed audio player widget |
| 9 | CREATE | ADR-003 | EXITING | Songbook Markdown Format |
| 10 | CREATE | ADR-004 | EXITING | Per-Language Repository Pattern |
| 11 | UPDATE | ADR-001, ADR-002 | EXITING | Added cross-references |

## Current Position

- **Node**: / (root)
- **Phase**: SPAWNING
- **Depth**: 0
- **Path**: /legacy/

## Pending Children

```
1. content-ecosystem (songbook content and audio resources)
2. build-infrastructure (parsers, generators, converters)
3. ai-translation-pipeline (automated translation)
4. web-components (embeddable widgets)
5. architecture-docs (DDD specification)
```

## Visited Nodes

| Node Path | Summary | Flow Created |
|-----------|---------|--------------|
| legacy-ios-apps | Swift/ObjC book readers | ADR-001, ADR-002 |
| content-ecosystem | 8 songbook npm packages | ADR-003, ADR-004 |
| build-infrastructure | Parser + tools | (ADR-005, ADR-006 candidates) |
| web-publishing | Gulp + Next.js generators | (ADR-007 candidate) |
| ai-translation | 10-stage Gemini pipeline | (ADR-008, ADR-009 candidates) |
| web-components | Audio player widget | (none needed) |

## Next Action

```
1. OPTIONAL: Create remaining ADR candidates (005-009)
2. OPTIONAL: Create SDD for songbook-md-json-parser
3. OPTIONAL: Create SDD for kirtan-next
4. SYNTHESIS: Combine all domain insights into _root.md
5. EXIT: Mark traversal complete
```

---

## Phase Definitions

### ENTERING
- Just arrived at this node
- Create _node.md file
- Read relevant source files
- Form initial hypothesis

### EXPLORING
- Deep analysis of this node's scope
- Validate/refine hypothesis
- Identify what belongs here vs. children

### SPAWNING
- Identify child concepts that need deeper exploration
- Add children to Pending stack
- Children are LOGICAL concepts, not filesystem paths

### SYNTHESIZING
- All children completed (or no children)
- Combine insights from children
- Update this node's _node.md with full understanding

### EXITING
- Pop from stack
- Bubble up summary to parent
- Mark as visited

---

*Updated by /legacy - 2026-05-23*
