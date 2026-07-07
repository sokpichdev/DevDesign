<h1 align="center">DevDesign</h1>

<p align="center">
  <strong>Offline-first iOS toolkit for designers and developers — 17 tools, AI-powered palettes.</strong><br/>
  <sub>No backend, no ads, no account required. Only the AI Palette feature touches the network.</sub>
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/platform-iOS%2017%2B-blue"/>
  <img alt="Language" src="https://img.shields.io/badge/Swift-5.9-orange"/>
  <img alt="UI" src="https://img.shields.io/badge/UI-SwiftUI-green"/>
  <img alt="Status" src="https://img.shields.io/badge/status-stable-brightgreen"/>
</p>

---

## Table of Contents

- [Screenshots](#screenshots)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
- [Getting Started](#getting-started)
- [Testing](#testing)
- [Project Status](#project-status)
- [Roadmap](#roadmap)
- [License](#license)
- [Author](#author)

---

## Screenshots

### Dashboard

| Color & Typography | Components, Assets & AI |
|---|---|
| <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/home_color_typo.png" width="220"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/home_components_asset_ai.png" width="220"/> |
| Color & typography tools on the dashboard | Components, assets, and AI palette tools on the dashboard |

### Color & Palette

| Color Picker | Palette Generator | Gradient Builder |
|---|---|---|
| <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/color_picker.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/palette_generator.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/gradient_builder.gif" width="160"/> |
| HEX / RGB / HSB picker with SwiftUI export | Harmony-based palette generation | Linear and radial gradient editor |

### AI Features

| AI Palette Generator | Prompt History |
|---|---|
| <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/ai_palette_generator.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/ai_history.gif" width="160"/> |
| Text-prompt palette generation via Claude, Gemini, or OpenRouter | Prompt history with saved palette snapshots |

### Typography & Tokens

| Type Scale | Font Pairing | Token Exporter |
|---|---|---|
| <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/type_scale.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/font_pairings.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/token_explorer.gif" width="160"/> |
| Modular type scale with 8 ratio presets | Google Fonts + system font pairing with live preview | Swift enum, W3C JSON, and CSS export |

### Components & Accessibility

| Component Snippets | Contrast Checker | SF Symbols | SF Symbol Detail |
|---|---|---|---|
| <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/components.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/contrast_checker.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/sf_symbols.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/sf_symbols_detail.gif" width="160"/> |
| ~80 SwiftUI snippets across 10 categories | WCAG AA & AAA compliance with suggested fixes | Search and filter SF Symbols | Copy-as-SwiftUI symbol detail view |

### Layout & Spacing

| Layout Inspector | Safe Area | Spacing System |
|---|---|---|
| <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/layout_inspector.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/layout_inspector_safe_area.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/spacing_system.gif" width="160"/> |
| Padding playground with device presets | Safe area visualization | 4pt grid visualizer with comparison tool |

### Animations & Effects

| Animation Playground | Border & Decoration | Shadow Playground |
|---|---|---|
| <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/animation_playground.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/border_decorations.gif" width="160"/> | <img src="https://raw.githubusercontent.com/sokpichdev/sokpichdev/main/projects/assets/devdesign/shadow_playground.gif" width="160"/> |
| Spring & easing curve builder with 6 preview targets | Corners, borders, glows, and overlay patterns | Multi-layer shadow builder with code export |

---

## Features

### Color Tools
- **Palette Generator** — complementary, triadic, analogous, split-complementary, and tetradic harmonies
- **Color Picker** — HEX / RGB / HSB values with SwiftUI code export
- **Contrast Checker** — WCAG AA & AAA compliance with suggested passing colors
- **Saved Palettes** — persisted via SwiftData with CloudKit sync

### Typography & Spacing
- **Type Scale Generator** — 8 modular-scale ratio presets
- **Font Pairing** — Google Fonts and system fonts combined with live preview
- **Spacing System** — 4pt grid visualizer with a comparison tool
- **SF Symbols Browser** — search, category filter, and copy-as-SwiftUI

### Components & Layout
- **Shadow Playground** — multi-layer shadow builder with code export
- **Gradient Builder** — linear and radial gradient editor
- **Component Snippets** — ~80 SwiftUI snippets across 10 categories with `{{ACCENT}}` token substitution
- **Layout Inspector** — safe area, padding playground, and device presets

### Assets & Motion
- **App Icon Generator** — all 14 iOS sizes, `Contents.json`, and PNG export
- **Animation Playground** — spring & easing curve builder with 6 live preview targets
- **Border & Decoration** — corners, borders, glows, and overlay patterns
- **Design Token Exporter** — Swift enum, W3C JSON, and CSS custom properties

### AI Palette
- Text-prompt palette generation via Claude (Sonnet 4.5), Gemini (2.5 Flash), or OpenRouter (free Llama 3.3 70B)
- OpenRouter is the default — users generate immediately with no setup
- Structured JSON schema with name, mood, roles, and usage hints per color
- Prompt suggestion library (25 suggestions across 5 categories) and prompt history with palette snapshots
- Staggered spring color-reveal animation; save directly to Saved Palettes

<!-- Highlights: 17 tools in one app, fully offline except AI Palette. Zero external
     dependencies — no SPM packages, everything built on Apple frameworks. Multi-provider
     AI behind a single AIProvider protocol. @Observable + SwiftData + CloudKit stack. -->

---

## Tech Stack

| Layer | Choice |
|---|---|
| **Language** | Swift 5.9 |
| **UI** | SwiftUI (iOS 17+) |
| **State** | `@Observable` macro |
| **Architecture** | MVVM + Feature Modules |
| **Persistence** | SwiftData |
| **Sync** | CloudKit |
| **Networking** | URLSession (AI Palette only) |
| **AI Providers** | Anthropic (Claude), Google Gemini, OpenRouter |
| **Font Loading** | CoreText, actor-based loader with request coalescing |
| **Image Export** | `ImageRenderer` for app icons and shareable assets |
| **Dependencies** | None — zero SPM packages |
| **Min iOS** | 17.0 |
| **Device** | iPhone only |

---

## Architecture

DevDesign follows MVVM with strict feature isolation — every feature owns its own `View`,
`ViewModel`, and tests folder under `Features/`. There is no shared mega-ViewModel and no tab
bar; a single dashboard grid in `ContentView` routes to each feature.

```mermaid
graph TD
    UI["Presentation<br/>(View / ViewModel, @Observable)"] --> Core["Core Services<br/>(HarmonyEngine, ContrastEngine, ExportService)"]
    Core --> Data["SwiftData / CloudKit<br/>(SavedPalette, SavedColor)"]
```

**Key decisions**
- Every feature under `Features/` owns its `View`, `ViewModel`, and tests — no shared mega-ViewModel.
- No tab bar; a single dashboard grid in `ContentView` routes to each tool.
- State is managed with the `@Observable` macro (Swift 5.9), not Combine.
- Multi-provider AI sits behind one `AIProvider` protocol so Claude/Gemini/OpenRouter are interchangeable.

---

## Folder Structure

```
DevDesign/
├── App/                    # App entry point, ContentView dashboard grid
├── Core/                   # HarmonyEngine, ContrastEngine, ExportService, shared utilities
├── DesignSystem/           # Shared design tokens and reusable UI primitives
├── Features/               # One folder per tool (View + ViewModel + tests), e.g.
│                            # PaletteGenerator/, ColorPicker/, ContrastChecker/, TypeScale/,
│                            # FontPairing/, SpacingSystem/, SFSymbols/, ShadowPlayground/,
│                            # GradientBuilder/, ComponentSnippets/, LayoutInspector/,
│                            # AppIconGenerator/, AnimationPlayground/, BorderDecoration/,
│                            # DesignTokenExporter/, AIPalette/
├── DevDesignTests/          # ~741 unit tests across 18 feature files
└── DevDesignUITests/
```

---

## Getting Started

### Requirements
- macOS with Xcode 15+
- iOS 17+ Simulator or device
- No third-party dependencies to install

### Clone
```bash
git clone https://github.com/cobra-PICH/DevDesign.git
cd DevDesign
open DevDesign.xcodeproj
```

Select your development team in **Signing & Capabilities**, then build and run.

### AI Palette Setup (optional)

The AI Palette feature supports three providers. OpenRouter works out of the box with no API key.

| Provider | Model | Key Required |
|---|---|---|
| OpenRouter | Llama 3.3 70B (free) | No |
| Claude | Sonnet 4.5 | Yes — [console.anthropic.com](https://console.anthropic.com/settings/keys) |
| Gemini | 2.5 Flash | Yes — [aistudio.google.com](https://aistudio.google.com/app/apikey) |

---

## Testing

```bash
xcodebuild test -scheme DevDesign -destination 'platform=iOS Simulator,name=iPhone 15'
```

- **Coverage:** ~741 unit tests across 18 feature files in `DevDesignTests/`, plus `DevDesignUITests/`.

---

## Project Status

✅ Stable — all 17 tools and the AI Palette feature are shipped, with ~741 unit tests across 18
feature files.

---

## Roadmap

- [x] 17 core tools + AI Palette shipped
- [ ] Additional AI providers
- [ ] Additional export formats
- [ ] [Add more items here]

---

## License

MIT / Apache-2.0 / To be determined — add a LICENSE file before claiming a license.

---

## Author

**Sok Pich** — [@sokpichdev](https://github.com/sokpichdev)

<sub>iOS 17+ · iPhone only · Offline-first</sub>
