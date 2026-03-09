# DevDesign

**A designer and developer toolkit for iOS** — offline-first, no backend, no ads.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Design Decisions](#2-architecture--design-decisions)
3. [Feature Catalog](#3-feature-catalog)
4. [Project Setup & Requirements](#4-project-setup--requirements)
5. [Folder Structure](#5-folder-structure)
6. [Key Patterns & Conventions](#6-key-patterns--conventions)
7. [AI Palette Feature](#7-ai-palette-feature)
8. [Testing](#8-testing)
9. [Known Limitations & v2 Considerations](#9-known-limitations--v2-considerations)
10. [Changelog](#10-changelog)

---

## 1. Project Overview

DevDesign is a native iPhone app for iOS 17+ that gives developers and designers an all-in-one reference toolkit — color palettes, typography, spacing, gradients, shadows, component snippets, layout tools, asset generators, and AI-powered palette generation — all without a network connection (except the optional AI feature).

**Core philosophy:**
- Offline-first. Everything works without a connection except AI Palette.
- No backend. SwiftData + CloudKit for persistence, no custom server.
- Free now. Paywall hooks are built in but inactive.
- One audience. Designed for both developers and designers equally.

---

## 2. Architecture & Design Decisions

### Pattern: MVVM + Feature Modules

Each feature lives in its own folder under `Features/` with its own `View`, `ViewModel`, and any supporting files. There is no shared "mega-ViewModel."

```
Features/
└── PaletteGenerator/
    ├── PaletteGeneratorView.swift
    ├── PaletteGeneratorViewModel.swift
    └── PaletteGeneratorTests.swift
```

### State Management: `@Observable`

All ViewModels use the Swift 5.9 `@Observable` macro (not `ObservableObject`). This requires care when mutating arrays of structs — see [Key Patterns](#6-key-patterns--conventions).

### Persistence: SwiftData + CloudKit

- `SavedPalette` and `SavedColor` are the only persisted models.
- CloudKit sync is configured but not actively tested in v1.
- API keys and prompt history use `UserDefaults` (see Known Limitations).

### Navigation: Home Dashboard

A single `ContentView` card grid routes to each feature. No tab bar. No deep link routing in v1.

### Why no animations on gradient fills?

Using `.animation(value:)` on a gradient that updates from user interaction causes render feedback loops. Gradients are updated without animation; transitions between states use opacity only.

---

## 3. Feature Catalog

| # | Feature | Phase | Accent | Description |
|---|---------|-------|--------|-------------|
| 1 | Palette Generator | 1 | `#7B6EF6` | Complementary, triadic, analogous & more |
| 2 | Color Picker | 1 | `#FF6B6B` | HEX · RGB · HSB · SwiftUI export |
| 3 | Contrast Checker | 1 | `#34C759` | WCAG AA & AAA compliance |
| 4 | Saved Palettes | 1 | `#FF9F0A` | Bookmarked collections via SwiftData |
| 5 | Type Scale | 2 | `#30D158` | Modular scale generator |
| 6 | Font Pairing | 2 | `#FF6B6B` | Google Fonts + system fonts pairing |
| 7 | Spacing System | 2 | `#0A84FF` | 4pt grid system visualizer |
| 8 | SF Symbols Browser | 2 | `#BF5AF2` | Search & copy SF Symbols |
| 9 | Shadow Playground | 3 | `#FF9F0A` | Multi-layer shadow builder |
| 10 | Gradient Builder | 3 | `#7B6EF6` | Linear & radial gradient editor |
| 11 | Component Snippets | 3 | `#FF6B6B` | ~80 SwiftUI snippets across 10 categories |
| 12 | Layout Inspector | 3 | `#34C759` | Safe area / padding visualizer |
| 13 | App Icon Generator | 4 | `#0A84FF` | All 14 iOS icon sizes, export to PNG & JSON |
| 14 | Animation Playground | 4 | `#FF6B6B` | Spring & easing curve builder with live preview |
| 15 | Border & Decoration | 4 | `#FF9F0A` | Corners, strokes, glows & patterns |
| 16 | Design Token Exporter | 4 | `#30D158` | Swift · JSON · CSS from your design system |
| 17 | AI Palette | 5 | `#BF5AF2` | Generate palettes from any text prompt |

---

## 4. Project Setup & Requirements

### Requirements

| Requirement | Value |
|-------------|-------|
| Xcode | 15.0+ |
| iOS Deployment Target | iOS 17.0+ |
| Swift | 5.9+ |
| Device | iPhone only (no iPad layout in v1) |
| Dependencies | None (no SPM packages) |

### First-time setup

```bash
git clone <repo-url>
cd DevDesign
open DevDesign.xcodeproj
```

Select your development team in **Signing & Capabilities**, then build and run on a simulator or device.

### Required Info.plist entries

The Font Pairing feature loads fonts from Google Fonts and requires ATS exceptions:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>fonts.googleapis.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
        <key>fonts.gstatic.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

> All connections use HTTPS. These entries are required because Apple's default ATS policy blocks some CDN subdomains.

---

## 5. Folder Structure

```
DevDesign/
├── App/
│   ├── DevDesignApp.swift          — entry point, SwiftData container setup
│   └── ContentView.swift           — dashboard grid, all feature cards
│
├── Core/
│   ├── Models/
│   │   ├── DevColor.swift          — core color model (HSB/RGB/HEX)
│   │   ├── SavedPalette.swift      — SwiftData model
│   │   └── SavedColor.swift        — SwiftData model
│   ├── Extensions/
│   │   ├── Color+Hex.swift         — Color(hex:) initializer
│   │   ├── Color+Harmony.swift     — complementary/triadic/etc.
│   │   └── Color+Contrast.swift    — WCAG luminance & ratio
│   └── Services/
│       ├── HarmonyEngine.swift     — palette harmony algorithms
│       ├── ContrastEngine.swift    — WCAG AA/AAA calculations
│       └── ExportService.swift     — HEX/RGB/SwiftUI code strings
│
├── Features/
│   ├── Dashboard/                  — ContentView lives here
│   ├── PaletteGenerator/
│   ├── ColorPicker/
│   ├── ContrastChecker/
│   ├── SavedPalettes/
│   ├── TypeScale/
│   ├── FontPairing/
│   ├── SpacingSystem/
│   ├── SFSymbols/
│   ├── ShadowPlayground/
│   ├── GradientBuilder/
│   ├── ComponentSnippets/
│   ├── LayoutInspector/
│   ├── AppIconGenerator/
│   ├── AnimationPlayground/
│   ├── BorderDecoration/
│   ├── DesignTokenExporter/
│   └── AIPalette/
│       ├── Models/                 — one type per file
│       ├── Networking/             — one API types file per provider
│       ├── Errors/
│       ├── Providers/
│       ├── Services/
│       ├── ViewModels/
│       └── Views/
│           ├── Components/
│           └── Sheets/
│
├── DesignSystem/
│   ├── DSColors.swift              — semantic color tokens
│   ├── DSTypography.swift          — type scale tokens
│   └── DSSpacing.swift             — spacing & radius tokens
│
└── Shared/                         — reusable views used across features
```

---

## 6. Key Patterns & Conventions

### `@Observable` + array of structs mutation

Never mutate a struct inside an `@Observable` array directly. SwiftUI won't detect the change. Always copy, mutate, reassign:

```swift
// ❌ Wrong — change not detected
layers[i].opacity = 0.5

// ✅ Correct
var updated = layers
updated[i].opacity = 0.5
layers = updated
```

### `forceSyncTrigger` counter

Some views need to force a UI sync after programmatic state changes (e.g. applying a preset). A plain `Int` counter is incremented to signal downstream views:

```swift
var forceSyncTrigger: Int = 0

func applyPreset(_ preset: Preset) {
    config = preset.config
    forceSyncTrigger += 1
}
```

### `updateInPlace()` vs `regenerate()`

- `updateInPlace()` — mutates existing items preserving their UUIDs, so SwiftUI list diffing produces smooth in-place animations.
- `regenerate()` — replaces items with new UUIDs, triggering insertion animations. Use when the user explicitly asks for a new result.

### `onUpdate` closure type in row components

Row components that need to mutate their parent's array use this exact type signature:

```swift
var onUpdate: ((inout LayerType) -> Void) -> Void
```

This avoids binding ambiguity and keeps mutations clean.

### `ColorPicker` binding — extract to `let`

SwiftUI's `ColorPicker` has trailing closure ambiguity when used with inline `Binding`. Always extract:

```swift
// ❌ Causes trailing closure ambiguity
ColorPicker("Color", selection: Binding(get: { ... }, set: { ... }))

// ✅ Extract first
let binding = Binding(get: { config.color }, set: { config.color = $0 })
ColorPicker("Color", selection: binding)
```

### Google Fonts loading

`FontPairing` uses an `actor`-based loader with request coalescing to avoid duplicate network calls. Fonts are registered via CoreText after download. UIFont is used as a fallback if SwiftUI's `.custom` fails before registration completes.

### `AppIconCanvasView` — side-effect free

This view is used both as a live preview and as an `ImageRenderer` source. It must never trigger side effects (no `onAppear` writes, no ViewModel calls) so it renders identically in both contexts.

### `.scrollDismissesKeyboard(.immediately)`

Applied to every `ScrollView` that sits below a search field or text input. Without it, keyboard dismissal on scroll requires two swipes on some devices.

### Design token accent colors (Border & Decoration)

Each tab has a fixed accent color baked into the UI:

| Tab | Color |
|-----|-------|
| Corners | `#FF9F0A` |
| Borders | `#7B6EF6` |
| Glow | `#BF5AF2` |
| Patterns | `#30D158` |

### Design Token Exporter — SwiftData sync

`updateColors(from:)` is called in both `.onChange(of: allPalettes)` and `.onAppear` to keep the token list in sync with SwiftData. Typography and spacing tokens use deterministic defaults (no SwiftData backing).

---

## 7. AI Palette Feature

The AI Palette feature (`Features/AIPalette/`) is the only feature that requires a network connection. It supports three AI providers.

### Providers

| Provider | Model | API Key Required | Free Tier |
|----------|-------|-----------------|-----------|
| Claude (Anthropic) | claude-sonnet-4-5 | Yes | No |
| Gemini (Google) | gemini-2.5-flash | Yes | Yes (rate limited) |
| OpenRouter | llama-3.3-70b-instruct:free | No | Yes |

> OpenRouter is the default provider. Users can generate palettes immediately without any setup.

### Getting an API key

| Provider | URL |
|----------|-----|
| Anthropic | https://console.anthropic.com/settings/keys |
| Gemini | https://aistudio.google.com/app/apikey |
| OpenRouter | https://openrouter.ai/keys |

### How generation works

1. User enters a text prompt (e.g. *"sunset over the ocean"*) and selects a style and color count.
2. The app calls the selected provider's API with a structured system prompt that constrains output to a specific JSON schema.
3. The response is parsed and validated. Invalid hex values or malformed JSON trigger a recovery attempt before failing.
4. Colors are revealed with a staggered spring animation (0.12s per color).
5. The generated palette can be saved to SwiftData (appears in Saved Palettes) or re-prompted.

### JSON schema contract

The system prompt instructs the model to return only this structure:

```json
{
  "name": "Palette name, 2–5 words",
  "mood": "3–5 comma-separated keywords",
  "colors": [
    {
      "hex": "#RRGGBB",
      "name": "Poetic color name",
      "role": "primary | background | accent | surface | text | highlight",
      "usage": "Short practical hint, ≤8 words"
    }
  ]
}
```

### Key storage

API keys are stored in `UserDefaults` in v1. This is intentional for simplicity — see [Known Limitations](#9-known-limitations--v2-considerations) for the v2 upgrade path.

### File structure

```
Features/AIPalette/
├── Models/
│   ├── GenerationState.swift
│   ├── PaletteStyle.swift        (+ ColorCount)
│   ├── AIColor.swift
│   ├── AIGeneratedPalette.swift
│   ├── PromptHistoryEntry.swift
│   └── PromptSuggestion.swift    (+ SuggestionCategory + Library)
├── Networking/
│   ├── AnthropicAPITypes.swift
│   ├── GeminiAPITypes.swift
│   └── OpenRouterAPITypes.swift
├── Errors/
│   └── AIPaletteError.swift
├── Providers/
│   ├── AIProvider.swift
│   └── ProviderKeyStore.swift
├── Services/
│   ├── AIPaletteService.swift
│   └── PromptHistoryStore.swift
├── ViewModels/
│   └── AIPaletteViewModel.swift
└── Views/
    ├── AIPaletteView.swift
    ├── Components/
    │   └── ShimmerView.swift
    └── Sheets/
        ├── APIKeySetupSheet.swift
        ├── ColorDetailSheet.swift
        └── PromptHistorySheet.swift  (+ HistoryPaletteDetailView)
```

---

## 8. Testing

All tests live in `DevDesignTests/`. Each feature has a dedicated test file.

### Test count by feature

| Feature | Tests | File |
|---------|-------|------|
| Core Models | 29 | `DevColorTests` |
| Palette Generator | 20 | `PaletteGeneratorTests` |
| Color Picker | 22 | `ColorPickerTests` |
| Contrast Checker | 28 | `ContrastCheckerTests` |
| Saved Palettes | 20 | `SavedPalettesTests` |
| Type Scale | 34 | `TypeScaleTests` |
| Font Pairing | 30 | `FontPairingTests` |
| Spacing System | 36 | `SpacingSystemTests` |
| SF Symbols | 33 | `SFSymbolsTests` |
| Shadow Playground | 38 | `ShadowPlaygroundTests` |
| Gradient Builder | 52 | `GradientBuilderTests` |
| Component Snippets | 44 | `ComponentSnippetsTests` |
| Layout Inspector | 56 | `LayoutInspectorTests` |
| App Icon Generator | 55 | `AppIconGeneratorTests` |
| Animation Playground | 58 | `AnimationPlaygroundTests` |
| Border & Decoration | 62 | `BorderDecorationTests` |
| Design Token Exporter | 76 | `DesignTokenExporterTests` |
| AI Palette | 68 | `AIPaletteTests` |
| **Total** | **~741** | |

### Running tests

```bash
Cmd + U      # run all tests in Xcode
```

Or via CLI:

```bash
xcodebuild test -scheme DevDesign -destination 'platform=iOS Simulator,name=iPhone 15'
```

### What is and isn't covered

**Covered:** model logic, service parsing, ViewModel state transitions, export string generation, hex validation, history store, API key store, WCAG contrast ratios, harmony algorithms.

**Not covered:** UI tests (no XCUITest suite in v1), CloudKit sync, network integration tests (AI Palette tests mock the error paths only — no live API calls).

---

## 9. Known Limitations & v2 Considerations

### API keys in UserDefaults

AI provider keys are stored in `UserDefaults` for simplicity. In production, they should be migrated to the iOS Keychain. The `ProviderKeyStore` enum is the only place to change — the rest of the app is already abstracted.

```swift
// v2 upgrade: replace UserDefaults calls in ProviderKeyStore with KeychainItem
```

### No iPad layout

All layouts are designed for iPhone only. Compact width classes are assumed throughout. iPadOS support would require SplitView navigation and adaptive grid layouts.

### Google Fonts — ATS exceptions required

The Font Pairing feature requires manual Info.plist entries (see [Setup](#4-project-setup--requirements)). This is a known friction point for new contributors.

### Paywall hooks inactive

Paywall logic is stubbed but not wired to any purchase flow. Several ViewModels check a `isPro` flag that always returns `false`. StoreKit integration is the primary v2 prerequisite.

### CloudKit sync untested

SwiftData's CloudKit container is configured but not tested against a real iCloud account. Conflict resolution behavior is undefined.

### OpenRouter free tier latency

The OpenRouter free tier can be slower than Anthropic or Gemini during peak hours. The timeout is set to 60 seconds (vs 30 for other providers). Users may see "Generation failed" on slow connections — a retry is always safe.

---

## 10. Changelog

### v1.0.0

**Phase 1 — Color Tools**
- Palette Generator: complementary, triadic, analogous, split-complementary, tetradic
- Color Picker: HEX · RGB · HSB · SwiftUI code export
- Contrast Checker: WCAG AA & AAA with suggested passing colors
- Saved Palettes: SwiftData persistence with CloudKit sync

**Phase 2 — Typography & Spacing**
- Type Scale Generator: modular scale with 8 ratio presets
- Font Pairing: Google Fonts + system fonts with live preview
- Spacing System: 4pt grid visualizer with comparison tool
- SF Symbols Browser: search, filter by category, copy name or SwiftUI code

**Phase 3 — Components & Layout**
- Shadow Playground: multi-layer shadow builder with code export
- Gradient Builder: linear & radial gradient editor
- Component Snippets: ~80 SwiftUI snippets across 10 categories with `{{ACCENT}}` substitution
- Layout Inspector: safe area, padding playground, and device presets

**Phase 4 — Assets & Motion**
- App Icon Generator: all 14 iOS sizes, Contents.json, PNG export
- Animation Playground: spring & easing curve builder with 6 live preview targets
- Border & Decoration: corners, borders, glows, and overlay patterns
- Design Token Exporter: Swift enum · W3C JSON · CSS custom properties

**Phase 5 — AI**
- AI Palette: text-prompt palette generation via Claude, Gemini, or OpenRouter (free)
- Multi-provider support with per-provider key storage
- Prompt suggestion library (25 suggestions across 5 categories)
- Prompt history with palette snapshots and re-generation
- Staggered color reveal animation
- Save generated palettes directly to Saved Palettes

---

*DevDesign v1.0 · iOS 17+ · iPhone only · Offline-first*
