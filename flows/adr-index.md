# ADR Index

Master index of all Architecture Decision Records.

## Active ADRs

| # | Name | Title | Type | Status | Created | Decided | File |
|---|------|-------|------|--------|---------|---------|------|
| 001 | book-xml-format | Book XML Content Format | constraining | APPROVED | 2026-04-29 | 2022 | [adr.md](adr-001-book-xml-format/adr.md) |
| 002 | shared-architecture | Shared Architecture Pattern | enabling | APPROVED | 2026-04-29 | 2011 | [adr.md](adr-002-shared-architecture-pattern/adr.md) |
| 003 | songbook-markdown | Songbook Markdown Format | constraining | APPROVED | 2026-05-23 | 2020 | [adr.md](adr-003-songbook-markdown-format/adr.md) |
| 004 | per-language-repo | Per-Language Repository Pattern | enabling | APPROVED | 2026-05-23 | 2019 | [adr.md](adr-004-per-language-repository/adr.md) |

### Types
- **constraining** - selects from options, closes alternatives
- **enabling** - adds new capabilities, expands scope

## Statistics

- **Total**: 4
- **Approved**: 4
- **Review**: 0
- **Draft**: 0
- **Rejected**: 0
- **Superseded**: 0

## Categories

### Content Formats
- ADR-001: Book XML Format (iOS/Flutter book readers)
- ADR-003: Songbook Markdown Format (web songbooks)

### Architecture Patterns
- ADR-002: Shared Architecture Pattern (code reuse across apps)
- ADR-004: Per-Language Repository Pattern (localization strategy)

### Legacy iOS
- ADR-001, ADR-002: Document legacy Objective-C book readers

### Songbook Ecosystem
- ADR-003, ADR-004: Document web songbook infrastructure

## Relationships

### Dependencies

```
ADR-003 (Markdown Format) ─► used by ─► ADR-004 (Per-Language Repos)
ADR-001 (XML Format) ─► related to ─► ADR-002 (Shared Architecture)
```

### Comparison

| Aspect | ADR-001 (XML) | ADR-003 (Markdown) |
|--------|---------------|-------------------|
| Use case | Book readers | Web songbooks |
| Platform | iOS, Flutter | Web, mobile JSON |
| Content | Rich (animations, controls) | Simple (verses) |
| Editors | Developers | Translators |
| Parser | BXMLDeserializableObject | songbook-md-json-parser |

### Cross-References

- ADR-001 and ADR-003 both address content format but for different systems
- ADR-002 and ADR-004 both address code/content organization but at different levels
- Songbook SDDs will reference ADR-003, ADR-004
- Flutter migration SDDs reference ADR-001, ADR-002

---

## Pending ADR Candidates

| # | Name | Topic | Source | Priority |
|---|------|-------|--------|----------|
| 005 | centralized-parser | Centralized Parser Library | legacy/songbook-md-json-parser | HIGH |
| 006 | json-schema-validation | JSON Schema for Content Validation | legacy/songbook-md-json-parser | HIGH |
| 007 | nextjs-migration | Kirtan Site Next.js Migration | legacy/kirtan-next | MEDIUM |
| 008 | ai-translation | AI Translation Pipeline | legacy/songbook-translate-en-ua-ai | MEDIUM |
| 009 | translation-caching | Translation Caching Strategy | legacy/songbook-translate-en-ua-ai | LOW |

---

## Index Maintenance

When creating/updating ADRs:
1. Add entry to table above
2. Update statistics
3. Add to relevant category
4. Note any relationships

**Last updated**: 2026-05-23
**Next ADR number**: 5
