# Legacy Analysis Log

## Session History

### 2026-05-23 - Extended Analysis (17 Projects)

**Mode**: BFS
**Target**: /legacy/ (all projects)

**New Projects Analyzed**:

| Project | Type | Domain |
|---------|------|--------|
| ddd-architecture-specification | Documentation | Architecture guidance |
| gaudiya-gitanjali-lv | npm | Latvian songbook |
| gaudiya-gitanjali-ru | npm | Russian songbook |
| gaudiya-gitanjali-ua | npm | Ukrainian songbook |
| gaudiya-gitanjali-ua-preview | npm | Ukrainian transliteration |
| kirtan-guide-es | npm | Spanish Kirtan Guide |
| kirtan-guide-pt | npm | Portuguese Kirtan Guide |
| kirtan-guide-pocket-edition | npm | Pocket reference |
| kirtan-mate | Gulp | Legacy web generator |
| kirtan-next | Next.js 16 | Modern web generator |
| md2html | Gulp | Hari-katha converter |
| songbook-md-json-parser | npm | Core parsing library |
| songbook-resources | npm | Audio metadata |
| songbook-translate-en-ua-ai | Node.js | AI translation pipeline |
| standalone-browser-audio-player | HTML/JS | Audio widget |

**Key Findings**:
1. **Two content formats**: XML (iOS/Flutter) and Markdown (web songbooks)
2. **Core library**: `songbook-md-json-parser` defines content schema
3. **Multi-language**: 8 songbook editions in 6 languages
4. **Two-generation web**: Gulp (kirtan-mate) → Next.js (kirtan-next)
5. **AI translation**: 10-stage Gemini pipeline for EN→UA
6. **3500+ performers** in audio resources database

**Understanding Tree Created**:
```
understanding/
├── _root.md (updated)
├── content-ecosystem/_node.md
├── build-infrastructure/_node.md
├── web-publishing/_node.md
├── ai-translation/_node.md
└── web-components/_node.md
```

**ADR Candidates Identified**:
- ADR-003: Songbook Markdown Format
- ADR-004: Per-Language Repository Pattern
- ADR-005: Centralized Parser Library
- ADR-006: JSON Schema for Content Validation
- ADR-007: Next.js Migration
- ADR-008: AI Translation Pipeline
- ADR-009: Translation Caching Strategy

**SDD Candidates**:
- sdd-songbook-parser: Core parsing library API
- sdd-kirtan-next: Modern web generator architecture

**Flows Updated**:
- `_traverse.md`: Full index of existing flows + legacy projects

**Next Actions**:
1. Create ADR-003: Songbook Markdown Format
2. Create ADR-004: Per-Language Repository Pattern
3. Create SDD for songbook-md-json-parser
4. Update existing ADRs with cross-references

---

### 2026-03-26 - Depth 0 (Root)

**Mode**: BFS
**Target**: /legacy/csv

**Analyzed**:
- `/legacy/csv/Books/db_languages.csv`: 4 language records (en, ru, de, spa)
- `/legacy/csv/Books/db_books.csv`: 6 book editions across 4 languages
- `/legacy/csv/Books/db_chapters.csv`: 143 chapter records (18 chapters × books)
- `/legacy/csv/Books/Gita_Slokas.csv`: 700+ slokas with Sanskrit, transliteration, translation, audio
- `/legacy/csv/Books/Gita_Vocabularies.csv`: 5000+ word-by-word vocabulary entries
- `/legacy/csv/Books/db_quoutes.csv`: 150+ inspirational quotes
- `/legacy/csv/devices/Gita_Devices.csv`: 50,000+ mobile device analytics records

**Key Findings**:
1. Two distinct domains: Content (spiritual texts) and Analytics (device tracking)
2. Content hierarchy: Language → Book → Chapter → Sloka → Vocabulary
3. Multi-lingual support with 4 languages, 6 book editions
4. Audio support for each sloka (reading + Sanskrit recitation)
5. Mobile-first application (Android with Firebase push)
6. Data quality issues: ID gaps, delimiter inconsistency, multiline values

**Data Quality Issues**:
- File naming inconsistent (db_*.csv vs Gita_*.csv)
- Delimiter inconsistent (comma vs semicolon)
- Missing IDs in sequences
- German chapters have embedded newlines
- Typo: "db_quoutes.csv" instead of "db_quotes.csv"

**Created**:
- `understanding/_root.md`: Full ER model and entity schemas

**Next depth**:
- Content domain: Validate foreign key relationships
- Analytics domain: Analyze device distribution patterns

---

*Append new entries at the top.*
