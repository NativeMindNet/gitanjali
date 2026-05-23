# Understanding: AI Translation Pipeline

> Automated English to Ukrainian translation with Gemini API

## Phase: EXPLORING

## Hypothesis

`songbook-translate-en-ua-ai` is a Node.js pipeline that automates translation of English songs to Ukrainian using Google's Gemini API. The pipeline has multiple stages with caching and human oversight.

## Sources

| Path | Purpose |
|------|---------|
| legacy/songbook-translate-en-ua-ai/ | AI translation pipeline |

## Validated Understanding

### Pipeline Structure

10-stage sequential processing pipeline:

```
songbook-translate-en-ua-ai/
├── 01-translate.js           # Stage 1: Gemini API translation
├── 02-extract-names.js       # Stage 2: Extract proper names
├── 03-cache-to-parts-files.js # Stage 3: Cache management
├── 04-fix-words.js           # Stage 4: Word-level fixes
├── 05-parts-to-out-songs.js  # Stage 5: Assemble songs
├── 06-fix-symbols.js         # Stage 6: Symbol corrections
├── 07-extract-vocabluary.js  # Stage 7: Build vocabulary
├── 08-improve-vocabluary-debug.js # Stage 8: Debug vocab
├── 09-fix-grammar.js         # Stage 9: Grammar fixes
├── 10-extract-human-translated-parts.js # Stage 10: Human edits
├── config.json               # API configuration
├── debug.js                  # Debugging utilities
├── song-verses-utils.js      # Verse processing
├── sort-lines.js             # Line sorting
├── cache/                    # Translation cache
├── cache-extract-names/      # Name extraction cache
├── cache-extract-names-v0/   # Version 0 cache
├── cache-extract-vocabulary/ # Vocabulary cache
├── readme-01-translate.md    # Stage docs
├── readme-02-extract-names.md
└── readme-03-cache-to-parts-files.md
```

### Stage Details

| Stage | Script | Purpose |
|-------|--------|---------|
| 1 | 01-translate.js | Send songs to Gemini API, cache results |
| 2 | 02-extract-names.js | Identify proper names (Krishna, Radha...) |
| 3 | 03-cache-to-parts-files.js | Organize cache into parts |
| 4 | 04-fix-words.js | Apply word-level corrections |
| 5 | 05-parts-to-out-songs.js | Assemble parts into complete songs |
| 6 | 06-fix-symbols.js | Fix encoding and special characters |
| 7 | 07-extract-vocabluary.js | Build vocabulary dictionary |
| 8 | 08-improve-vocabluary-debug.js | Debug vocabulary issues |
| 9 | 09-fix-grammar.js | Apply grammar corrections |
| 10 | 10-extract-human-translated-parts.js | Merge human overrides |

### Configuration

```json
// config.json (example)
{
  "gemini": {
    "apiKey": "...",
    "model": "gemini-pro"
  },
  "source": "kirtan-guide-en",
  "target": "gaudiya-gitanjali-ua"
}
```

### Caching Strategy

Multiple cache directories for different stages:
- `cache/` - Raw translation results from Gemini
- `cache-extract-names/` - Proper name extraction
- `cache-extract-vocabulary/` - Dictionary building

Cache enables:
1. Resume after interruption
2. Avoid duplicate API calls
3. Debug intermediate results
4. Version control progress

### Human Oversight Points

1. **Stage 2**: Review extracted proper names
2. **Stage 4**: Provide word-level corrections
3. **Stage 9**: Review grammar fixes
4. **Stage 10**: Override AI translations with human versions

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| gemini-integration | API calls + rate limiting | DOCUMENTED |
| caching-system | Multi-stage cache | DOCUMENTED |
| human-review-loop | Manual override mechanism | DOCUMENTED |

## Dependencies

- **Uses**: Google Gemini API, source songbooks (English)
- **Used by**: gaudiya-gitanjali-ua (output)

## Key Insights

1. **Staged Pipeline**: Not single-shot - 10 discrete stages
2. **Heavy Caching**: Each stage caches results for resume/debug
3. **Human-in-Loop**: Multiple points for manual corrections
4. **Vocabulary Building**: Creates dictionary from translations
5. **Name Preservation**: Special handling for sacred names

## ADR Candidates

1. **ADR-008: AI Translation Pipeline**
   - Decision: Use staged pipeline with Gemini API
   - Alternatives: Single-shot translation, manual only
   - Rationale: Quality control, cost management, human oversight

2. **ADR-009: Translation Caching Strategy**
   - Decision: Per-stage file-based caching
   - Alternatives: Database, single cache
   - Rationale: Resume capability, debugging, versioning

## Flow Recommendation

- **Type**: DDD (Document-Driven Development)
- **Confidence**: HIGH
- **Rationale**: Pipeline documentation benefits translators (stakeholders), not just developers

### DDD Structure Recommendation

```
flows/ddd-ai-translation/
├── 01-requirements.md    # Translation goals, quality metrics
├── 02-specifications.md  # Pipeline stages, API contracts
├── readme.md             # Translator guide (stakeholder doc)
└── _status.md
```

## Synthesis

### Combined Understanding

AI translation pipeline with:

1. **10-stage processing**: From raw API call to final song
2. **Gemini API integration**: Google's LLM for translation
3. **Multi-level caching**: Resume, debug, version control
4. **Human oversight**: Corrections at multiple stages
5. **Vocabulary extraction**: Builds dictionary for consistency

### Workflow

```
English Songs ─► Gemini API ─► Cache ─► Corrections ─► Ukrainian Songs
                     │            │           ▲
                     ▼            ▼           │
               names.json   parts/*.json   human edits
```

## Bubble Up

- 10-stage AI translation pipeline using Google Gemini
- Heavy caching enables resume/debug/versioning
- Human-in-loop at multiple stages for quality control
- Extracts vocabulary for translation consistency
- Two ADRs needed: Pipeline Architecture, Caching Strategy

---

*Phase: EXPLORING | Depth: 1 | Parent: root*
