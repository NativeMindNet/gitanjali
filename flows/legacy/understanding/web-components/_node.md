# Understanding: Web Components

> Standalone embeddable widgets

## Phase: EXPLORING

## Hypothesis

`standalone-browser-audio-player` is a zero-dependency web audio player that can be embedded on any page. Self-contained HTML/CSS/JS with no build step.

## Sources

| Path | Purpose |
|------|---------|
| legacy/standalone-browser-audio-player/ | Audio player widget |

## Validated Understanding

### Project Structure

```
standalone-browser-audio-player/
├── index.html            # Standalone HTML page
├── radio-player.js       # Main player implementation
├── styles.css            # Player styling
├── tracks.json           # Audio track metadata
├── CNAME                 # GitHub Pages domain (bhagavata.kirtan.site)
└── README.md             # Documentation
```

### Player Features

Vanilla JavaScript audio player with:

1. **Audio Controls**
   - Play/Pause toggle
   - Seek via progress bar
   - Volume control
   - Playback speed adjustment (0.5x - 2x)

2. **Playlist**
   - Track list from JSON
   - Next/previous navigation
   - Track title display

3. **UI Elements**
   - Progress bar with buffering indicator
   - Current time / duration display
   - Responsive layout

### Code Architecture (radio-player.js)

```javascript
// Simplified structure
class RadioPlayer {
  constructor(config) {
    this.audio = new Audio();
    this.tracks = config.tracks;
    this.currentTrack = 0;
  }

  play() { ... }
  pause() { ... }
  seek(time) { ... }
  setVolume(level) { ... }
  setSpeed(rate) { ... }
  loadTrack(index) { ... }
}
```

### tracks.json Format

```json
{
  "tracks": [
    {
      "title": "Track Name",
      "src": "path/to/audio.mp3",
      "duration": "12:34"
    }
  ]
}
```

### Deployment

- **GitHub Pages**: bhagavata.kirtan.site
- **Embeddable**: Can be iframe-embedded on other sites
- **No dependencies**: Pure vanilla JS, no npm

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| - | No children needed | COMPLETE |

## Dependencies

- **Uses**: Nothing (zero dependencies)
- **Used by**: External websites for embedding

## Key Insights

1. **Zero Dependencies**: Pure HTML/CSS/JS, no npm, no build
2. **Self-Contained**: Single page application
3. **Embeddable**: Can be iframe'd anywhere
4. **GitHub Pages**: Simple static hosting
5. **Minimal Scope**: Does one thing well

## ADR Candidates

No ADR needed - simple, standalone component without architectural decisions.

## Flow Recommendation

- **Type**: None needed
- **Confidence**: HIGH
- **Rationale**: Too simple for SDD/DDD. Self-explanatory code.

## Synthesis

### Combined Understanding

Simple, zero-dependency audio player:
- Pure vanilla JavaScript
- Deploys to GitHub Pages
- Embeddable via iframe
- Self-contained and maintainable

### Technical Stack

| Aspect | Implementation |
|--------|----------------|
| JavaScript | Vanilla ES6+ |
| Styling | Plain CSS |
| Audio | HTML5 Audio API |
| Data | JSON file |
| Hosting | GitHub Pages |
| Domain | bhagavata.kirtan.site |

## Bubble Up

- Zero-dependency audio player widget
- Deployed at bhagavata.kirtan.site
- Embeddable on external sites
- No flow documentation needed (simple enough)

---

*Phase: EXPLORING | Depth: 1 | Parent: root*
