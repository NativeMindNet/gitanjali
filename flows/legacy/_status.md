# Legacy Analysis Status

## Mode

- **Current**: EXPLORING
- **Type**: BFS (breadth-first analysis)

## Source

- **Path**: /legacy/
- **Focus**: All 17 legacy projects

## Traversal State

> See _traverse.md for full recursion stack

- **Current Node**: / (root)
- **Current Phase**: SPAWNING
- **Stack Depth**: 1
- **Pending Children**: 5 domains

## Progress

- [x] Root node created
- [x] Existing flows indexed (7 flows found)
- [x] All 17 legacy projects identified
- [x] Understanding tree created (5 domain nodes)
- [ ] ADRs generated (DRAFT) - 7 candidates
- [ ] SDDs generated (DRAFT) - 2 candidates
- [ ] Review complete

## Statistics

- **Projects analyzed**: 17
- **Nodes created**: 6 (root + 5 domains)
- **Nodes completed**: 5 (domain analysis done)
- **Max depth reached**: 1
- **Existing flows found**: 7
- **ADR candidates**: 7 (ADR-003 through ADR-009)
- **SDD candidates**: 2

## Domain Summary

| Domain | Projects | Status | ADRs |
|--------|----------|--------|------|
| content-ecosystem | 8 songbooks + resources | EXPLORED | ADR-003, ADR-004 |
| build-infrastructure | parser + md2html | EXPLORED | ADR-005, ADR-006 |
| web-publishing | kirtan-mate, kirtan-next | EXPLORED | ADR-007 |
| ai-translation | translate-en-ua-ai | EXPLORED | ADR-008, ADR-009 |
| web-components | audio-player | EXPLORED | - |
| legacy-ios-apps | 2 Swift apps | DONE | ADR-001, ADR-002 |

## Last Action

2026-05-23: Extended legacy analysis
- Scanned 17 legacy projects
- Created understanding nodes for 5 domains
- Identified 7 new ADR candidates
- Updated _traverse.md with existing flows index

## Next Actions

1. Create ADR-003: Songbook Markdown Format
2. Create ADR-004: Per-Language Repository Pattern
3. Create SDD for songbook-md-json-parser
4. Create SDD for kirtan-next architecture
5. Update ADR-001, ADR-002 with cross-references

---

*Updated by /legacy - 2026-05-23*
