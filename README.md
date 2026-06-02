# DevDesign

> Offline-first iOS toolkit for designers and developers — 17 tools, AI-powered palettes

<p align="center">
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/home_color_typo.png" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/home_components_asset_ai.png" width="160"/>
</p>

## Overview

DevDesign is a native iPhone app for iOS 17+ that bundles 17 reference and generation tools for designers and developers — color palettes, typography, spacing, gradients, shadows, component snippets, layout tools, asset generators, and AI-powered palette generation — all working without a network connection (except the optional AI feature). No backend, no ads, no account required.

## Features

### Color Tools
- Palette Generator: complementary, triadic, analogous, split-complementary, and tetradic harmonies
- Color Picker with HEX / RGB / HSB values and SwiftUI code export
- Contrast Checker with WCAG AA & AAA compliance and suggested passing colors
- Saved Palettes persisted via SwiftData with CloudKit sync

### Typography & Spacing
- Type Scale Generator with 8 modular-scale ratio presets
- Font Pairing combining Google Fonts and system fonts with live preview
- Spacing System: 4pt grid visualizer with a comparison tool
- SF Symbols Browser with search, category filter, and copy-as-SwiftUI

### Components & Layout
- Shadow Playground: multi-layer shadow builder with code export
- Gradient Builder: linear and radial gradient editor
- Component Snippets: ~80 SwiftUI snippets across 10 categories with `{{ACCENT}}` token substitution
- Layout Inspector: safe area, padding playground, and device presets

### Assets & Motion
- App Icon Generator: all 14 iOS sizes, `Contents.json`, and PNG export
- Animation Playground: spring & easing curve builder with 6 live preview targets
- Border & Decoration: corners, borders, glows, and overlay patterns
- Design Token Exporter: Swift enum, W3C JSON, and CSS custom properties

### AI Palette
- Text-prompt palette generation via Claude (Sonnet 4.5), Gemini (2.5 Flash), or OpenRouter (free Llama 3.3 70B)
- OpenRouter is the default — users generate immediately with no setup
- Structured JSON schema with name, mood, roles, and usage hints per color
- Prompt suggestion library (25 suggestions across 5 categories) and prompt history with palette snapshots
- Staggered spring color-reveal animation; save directly to Saved Palettes

## Screenshots

### Color & Palette
<p align="center">
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/color_picker.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/palette_generator.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/gradient_builder.gif" width="160"/>
</p>

### AI Features
<p align="center">
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/ai_palette_generator.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/ai_history.gif" width="160"/>
</p>

### Typography & Tokens
<p align="center">
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/type_scale.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/font_pairings.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/token_explorer.gif" width="160"/>
</p>

### Components & Accessibility
<p align="center">
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/components.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/contrast_checker.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/sf_symbols.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/sf_symbols_detail.gif" width="160"/>
</p>

### Layout & Spacing
<p align="center">
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/layout_inspector.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/layout_inspector_safe_area.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/spacing_system.gif" width="160"/>
</p>

### Animations & Effects
<p align="center">
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/animation_playground.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/border_decorations.gif" width="160"/>
  <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/shadow_playground.gif" width="160"/>
</p>

## Tech Stack

| Area | Technology |
|------|-----------|
| UI | SwiftUI (iOS 17+) |
| State | `@Observable` macro (Swift 5.9) |
| Architecture | MVVM + Feature Modules |
| Persistence | SwiftData |
| Sync | CloudKit |
| Networking | URLSession (AI Palette only) |
| AI Providers | Anthropic, Google Gemini, OpenRouter |
| Font Loading | CoreText with actor-based loader and request coalescing |
| Image Export | `ImageRenderer` for app icons and shareable assets |
| Min iOS | 17.0 |
| Device | iPhone only |
| Dependencies | None (zero SPM packages) |

## Architecture

DevDesign follows MVVM with strict feature isolation — every feature owns its own `View`, `ViewModel`, and tests folder under `Features/`. There is no shared mega-ViewModel and no tab bar; a single dashboard grid in `ContentView` routes to each feature.

```
View (SwiftUI)
  └─ ViewModel (@Observable)
       └─ Core Services (HarmonyEngine, ContrastEngine, ExportService)
            └─ SwiftData / CloudKit (SavedPalette, SavedColor)
```

## Setup

```bash
git clone https://github.com/cobra-PICH/DevDesign.git
cd DevDesign
open DevDesign.xcodeproj
```

Select your development team in **Signing & Capabilities**, then build and run. No dependencies to install.

## AI Palette Setup

The AI Palette feature supports three providers. OpenRouter works out of the box with no API key.

| Provider | Model | Key Required |
|----------|-------|-------------|
| OpenRouter | Llama 3.3 70B (free) | No |
| Claude | Sonnet 4.5 | Yes — [console.anthropic.com](https://console.anthropic.com/settings/keys) |
| Gemini | 2.5 Flash | Yes — [aistudio.google.com](https://aistudio.google.com/app/apikey) |

## Highlights

- **17 tools in one app, fully offline** — only the AI Palette feature touches the network
- **Zero external dependencies** — no SPM packages, everything built on Apple frameworks
- **~741 unit tests** across 18 feature files
- **Multi-provider AI** — Claude, Gemini, and OpenRouter behind a single `AIProvider` protocol
- **`@Observable` + SwiftData + CloudKit** — modern Swift 5.9 stack

---

*iOS 17+ · iPhone only · Offline-first*
