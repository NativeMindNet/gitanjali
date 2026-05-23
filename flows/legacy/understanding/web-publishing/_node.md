# Understanding: Web Publishing

> Static site generators for songbook web portals

## Phase: EXPLORING

## Hypothesis

Two generations of web generators exist: `kirtan-mate` (Gulp-based, legacy) and `kirtan-next` (Next.js 16, modern). Both consume the same songbook JSON data to generate static websites.

## Sources

| Path | Type | Stack |
|------|------|-------|
| legacy/kirtan-mate/ | Gulp project | Gulp 4, EJS, SASS |
| legacy/kirtan-next/ | Next.js project | Next.js 16, React 19, TypeScript |

## Validated Understanding

### kirtan-mate (Legacy Generator)

First-generation web generator using Gulp:

```
kirtan-mate/
├── gulpfile.js           # ~500 lines of Gulp tasks
├── package.json          # Gulp, EJS, Sass, Axios, Cheerio
├── songbooks.json        # Dynamic songbook config (git deps)
├── scripts/
│   ├── songConvertor.js      # Convert between formats
│   ├── indexGenerator.js     # Generate search index
│   ├── songbookLoader.js     # Load from git repos
│   ├── i18n.js               # Internationalization
│   └── telegraph/utils.js    # Telegraph integration
├── dev/                  # Development assets
├── docs/                 # Output (GitHub Pages)
└── .github/workflows/    # CI/CD
```

**Key Features**:
- Aggregates multiple songbook repositories
- Generates static HTML for GitHub Pages
- Telegraph integration for article publishing
- Live site: https://kirtan.site

### kirtan-next (Modern Generator)

Second-generation with modern stack:

```
kirtan-next/
├── package.json          # React 19, Next.js 16, TypeScript
├── app/                  # Next.js App Router
│   └── pages/...
├── components/           # React components
├── types/                # TypeScript definitions
│   ├── song.ts
│   ├── book.ts
│   ├── search.ts
│   ├── resources.ts
│   └── translations.ts
├── scripts/
│   ├── processSrc.js         # Source installation
│   ├── validate.js           # Validation pipeline
│   ├── fetchSharedResources.js
│   ├── createAZ.js           # A-Z index
│   ├── createAuthors.js      # Author index
│   ├── transformContents.js
│   └── validation/
│       ├── validateTranslations.js
│       └── validateSongbooks.js
├── source/
│   ├── dependencies.json     # Git repository refs
│   ├── translations.json     # i18n config
│   └── books/                # Generated data
├── other/
│   ├── bookContext.ts        # Context management
│   ├── hooks/                # React hooks
│   └── metadata/             # SEO generators
├── styles/               # SCSS
├── public/               # Static assets, SW
└── env/                  # Environment configs
```

**Key Features**:
- React 19 + Next.js 16 (App Router)
- TypeScript throughout
- Radix UI components
- Zod for validation
- Static export for deployment

### Architecture Comparison

| Aspect | kirtan-mate | kirtan-next |
|--------|-------------|-------------|
| Framework | Gulp + EJS | Next.js 16 |
| Templating | EJS | React/JSX |
| Styling | SASS | SCSS |
| Types | None | TypeScript |
| Validation | Manual | Zod + AJV |
| Deploy | GitHub Pages | Static export |
| Era | 2018-2022 | 2024+ |

### Data Flow

```
┌─────────────────────┐
│ Songbook npm pkgs   │
│ (gaudiya-*, kirtan-)│
└──────────┬──────────┘
           │ json/songs/*.json
           ▼
┌─────────────────────┐
│ dependencies.json   │
│ (git repo refs)     │
└──────────┬──────────┘
           │
   ┌───────┴───────┐
   ▼               ▼
┌──────────┐  ┌──────────┐
│kirtan-   │  │kirtan-   │
│mate      │  │next      │
│(Gulp)    │  │(Next.js) │
└────┬─────┘  └────┬─────┘
     │             │
     ▼             ▼
 kirtan.site   (new site?)
```

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| gulp-pipeline | Gulp task organization | DOCUMENTED |
| nextjs-architecture | App Router structure | DOCUMENTED |

## Dependencies

- **Uses**: songbook npm packages, songbook-resources
- **Used by**: End users (web browsers)

## Key Insights

1. **Two Generations**: Legacy Gulp → Modern Next.js migration
2. **Same Data Source**: Both consume songbook JSON
3. **Git-based Dependencies**: `dependencies.json` lists git repos
4. **Static Output**: Both generate static sites
5. **Progressive Enhancement**: kirtan-next adds SSR, types, better DX

## ADR Candidates

1. **ADR-007: Next.js Migration**
   - Decision: Move from Gulp to Next.js 16
   - Alternatives: Keep Gulp, use Astro, use Vite
   - Rationale: React ecosystem, TypeScript, better DX

## Flow Recommendation

- **Type**: SDD
- **Confidence**: MEDIUM
- **Rationale**: kirtan-next deserves SDD for architecture documentation

### SDD Structure Recommendation

```
flows/sdd-kirtan-next/
├── 01-requirements.md    # Features, pages, search
├── 02-specifications.md  # Component architecture
├── 03-plan.md
└── _status.md
```

## Synthesis

### Combined Understanding

Two-generation web publishing:

1. **kirtan-mate** (Legacy)
   - Gulp-based static generator
   - EJS templates, SASS styling
   - Currently powering kirtan.site
   - Telegraph integration

2. **kirtan-next** (Modern)
   - Next.js 16 with React 19
   - TypeScript + Zod validation
   - Radix UI components
   - App Router architecture

Both share:
- Same songbook JSON data source
- A-Z and author index generation
- Search functionality
- Multi-language support

## Bubble Up

- Two web generators: Gulp (legacy) and Next.js (modern)
- Both consume songbook npm packages via git dependencies
- kirtan-mate currently live at kirtan.site
- kirtan-next represents architectural modernization
- One ADR needed: Next.js Migration decision

---

*Phase: EXPLORING | Depth: 1 | Parent: root*
