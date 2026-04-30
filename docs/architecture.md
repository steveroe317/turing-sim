# TuringSim Architecture

## Overview

TuringSim is a real-time interactive simulation of Gray-Scott reaction-diffusion systems, running on iOS and macOS. It visualises how two chemicals — an activator and an inhibitor — spread across a 201×201 toroidal grid and react with each other, producing the organic-looking patterns (spots, stripes, coral-like branching) that Alan Turing first described mathematically in 1952.

The app lets you watch patterns evolve live, tune the two key parameters (`f` and `k`) by hand or by picking from 13 named presets, and explore the parameter space on an interactive map.

---

## Project Structure

```
TuringSim/
├── Core/           # Simulation engine and shared state
├── Data/           # Preset pattern definitions
├── SimViews/       # Three interchangeable rendering backends
├── Views/          # All other UI (controls, info, parameter exploration)
├── Shaders/        # Metal shader source
├── TuringSimIos/   # iOS app entry point
├── TuringSimMac/   # macOS app entry point
├── TuringTool/     # Command-line diagnostic tool
├── TuringSimTests/ # (placeholder) unit tests
└── docs/           # This file
```

### Targets

| Target | Platform | Description |
|--------|----------|-------------|
| `TuringSimApp` | iOS 26.1 | Primary mobile app |
| `TuringSim` | macOS 26.1 | Desktop app |
| `TuringTool` | macOS | CLI tool for engine diagnostics |
| `TuringSimAppTests` / `TuringSimTests` | — | Placeholder unit test suites |

The `Core/`, `Data/`, `Views/`, `SimViews/`, and `Shaders/` folders are shared between the iOS and macOS targets. Each platform has its own `ContentView` that bootstraps `CoreView` with a chosen render mode.

---

## The Simulation: Gray-Scott Reaction-Diffusion

### What it models

A reaction-diffusion system tracks two chemical concentrations across a spatial grid. At each time step, both chemicals spread (diffuse) outward from areas of high concentration and react with each other locally. The interplay of different diffusion rates and reaction strengths can produce a rich variety of stable, self-organising patterns.

In the Gray-Scott model, the two chemicals are:
- **A** (activator) — starts everywhere at full concentration (1.0). Continuously replenished by a "feed" process from an infinite reservoir.
- **B** (inhibitor) — starts near zero, seeded in a small patch at the centre. Consumed by a "kill" (drain) process, and also consumed by its own reaction with A.

The key insight: B catalyses the conversion of A into more B (`A + 2B → 3B`), but B also degrades at a fixed rate. When these processes balance, a stable spatial pattern emerges.

### The update equations

Every generation, each cell `j` is updated in two stages.

**Stage 1 — Diffusion**

The discrete Laplacian is approximated using a 3×3 neighbourhood with toroidal (wrap-around) edges:

| Neighbour type | Weight for A | Weight for B |
|---------------|-------------|-------------|
| Centre (self) | −dA = −1.0 | −dB = −0.5 |
| Orthogonal (4 cells) | 0.2 × dA = 0.2 | 0.2 × dB = 0.1 |
| Diagonal (4 cells) | 0.05 × dA = 0.05 | 0.05 × dB = 0.025 |

These weights sum to zero, which is the defining property of a discrete Laplacian: a uniform field produces zero net flux. The different weights for orthogonal vs. diagonal neighbours arise from their different distances in the grid.

`diffusedA[j]` and `diffusedB[j]` are the weighted sums over all 9 neighbours (including self). They are precomputed as `DiffusionLink` arrays at initialisation and reused every generation.

**Stage 2 — Reaction**

```
a_only_evolve    = A[j] + diffusedA[j] + f × (1 − A[j])
b_only_evolve    = B[j] + diffusedB[j] − (f + k) × B[j]
a_to_b_transfer  = min(r × A[j] × B[j]², a_only_evolve)

A′[j] = a_only_evolve − a_to_b_transfer
B′[j] = max(b_only_evolve + a_to_b_transfer, 0)
```

Term by term:
- `f × (1 − A)` — feed: replenishes A toward 1.0 at rate `f`
- `−(f + k) × B` — kill: drains B at combined rate `f + k`
- `r × A × B²` — the autocatalytic reaction: B converts A into more B, but requires two B molecules, so the rate is proportional to B²
- The `min(…, a_only_evolve)` clamp prevents A from going negative
- The `max(…, 0)` clamp prevents B from going negative

### Parameters

| Parameter | Symbol | Fixed/Tunable | Default | Meaning |
|-----------|--------|--------------|---------|---------|
| Diffusion rate of A | `dA` | Fixed | 1.0 | How fast A spreads |
| Diffusion rate of B | `dB` | Fixed | 0.5 | How fast B spreads (always slower than A) |
| Reaction rate | `r` | Fixed | 1.0 | Scale of the A→B conversion |
| Feed rate | `f` | **Tunable** | 0.055 | Rate A is replenished; range 0.0–0.1 |
| Kill rate | `k` | **Tunable** | 0.062 | Rate B is removed; range 0.0–0.1 |

Small changes in `f` and `k` produce qualitatively different patterns — spots, stripes, spirals, or uniform steady states. The parameter space map (see [Parameter Space](#parameter-space--presets)) shows where interesting patterns live.

### Grid and initialisation

- **Grid**: 201×201 cells, stored as flat `[Double]` arrays indexed by `x × 201 + y`
- **Topology**: toroidal — edges wrap, so there are no boundary artefacts
- **Initial state**: A = 1.0 everywhere, B = 0.0 except a 11×11 patch (radius 5) at the centre where B = 1.0
- **Seeding**: `seedRandomly()` scatters additional B patches at random with probability 0.01% per cell

### Color mapping

Each cell's colour is derived from the ratio `level = B / (A + B)` (clamped to 1.0 when both are zero). This normalised value in [0, 1] drives three phase-shifted sine waves:

```
redPhase   = level × π
greenPhase = level × π + π/3
bluePhase  = level × π + 2π/3

R = (sin(redPhase)   + 1) / 2
G = (sin(greenPhase) + 1) / 2
B = (sin(bluePhase)  + 1) / 2
```

At `level = 0` (pure A) the colour is a warm pale yellow. At `level = 1` (pure B) it shifts through blue-green. Intermediate values cycle through a continuous hue spectrum, making the activator/inhibitor boundary highly visible even at small concentration gradients.

---

## Architecture Layers

### Core Layer (`Core/`)

The lowest layer — pure computation with no UI dependencies.

**`SimEngine`** (`SimEngine.swift`) — The Gray-Scott implementation, isolated on `@SimActor`. Owns the `A` and `B` concentration arrays, the precomputed `DiffusionLink` tables, and the generation counter. Its main entry point is `evolve(for:) -> SimSnapshot`, which runs N generations and returns a snapshot of the current state.

**`SimActor`** (`SimActor.swift`) — A custom `@globalActor` that gives `SimEngine` its own serial executor, independent of the main actor. All mutations to A/B happen here.

**`SimSnapshot`** (`SimSnapshot.swift`) — A `Sendable` value type (struct) carrying `generation`, `cellsPerEdge`, and the `A`/`B` arrays. Being `Sendable` makes it safe to pass across actor boundaries without copying concerns.

**`TuringMapPoint`** (`TuringMapPoint.swift`) — A lightweight `Hashable` struct pairing `(f, k)` with a Euclidean `distance(to:)` method, used for nearest-preset lookup.

### State / Model Layer (`Core/SimModel.swift`)

**`SimModel`** is an `@Observable` class that bridges the simulation engine and the SwiftUI view tree. It owns:

- The live `f` and `k` values (writable from the UI)
- A copy of the latest `A` and `B` arrays (read by the rendering views)
- Derived display values: `generation`, `generationRate`
- Boolean request flags: `startRequested`, `pauseRequested`, `seedRequested`, `resetRequested`

At init, `SimModel` creates a long-running `Task` that loops indefinitely:

1. If paused, sleeps briefly and loops
2. Detects whether `f` or `k` has changed and pushes the rounded value into the engine
3. Calls `await engine.evolve(for: 50)` — crossing the actor boundary into `@SimActor`
4. Receives the returned `SimSnapshot` and updates `generation`, `A`, `B`, and `generationRate`
5. Checks request flags and dispatches the corresponding engine calls (`start`, `stop`, `seedRandomly`, `resetGraph`)

`generationRate` is a rolling average over the last 10 frames (50 generations × 10 = 500 generations of history).

### View Layer (`Views/`)

All views read shared state via `@Environment(SimModel.self)` and `@Environment(TuringMapLabels.self)`. `CoreView` owns both and injects them.

| View | Role |
|------|------|
| `CoreView` | Root layout; owns `SimModel` and `TuringMapLabels`; manages modal visibility |
| `SimInformationView` | Read-only display of f, k, pattern name, generation, rate |
| `SimControlView` | Start/Pause, Reset, Seed, Select, Explore buttons |
| `SimSelectView` | Modal wheel picker over 13 preset patterns |
| `SimExploreView` | Modal parameter explorer with map and sliders |
| `TuringMapView` | Interactive (f, k) parameter space image with crosshair |
| `SimParameterView` | Reusable Slider + Stepper for a single Double parameter |
| `SimButtonStyle` | Capsule button style used app-wide |
| `SimColors` | Three named `Color` values used in the explorer UI |

`SimSelectView` and `SimExploreView` are mutually exclusive overlays inside a `ZStack` in `CoreView`. Each operates on local `@State` copies of `f` and `k`, pushing values into `SimModel` only on Confirm.

### Rendering Layer (`SimViews/`, `Shaders/`)

Three interchangeable `View` structs, all reading from `@Environment(SimModel.self)`:

| Type | View struct | Shader | Quality | CPU cost |
|------|-------------|--------|---------|----------|
| `.TILE` | `SimTileView` | None | Sharp cells | High |
| `.SHADER` | `SimShaderView` | `turingdrawblock` | Sharp cells | Low |
| `.SMOOTH_SHADER` | `SimSmoothShaderView` | `turingdrawsmooth` | Smooth interpolation | Low |

`SimViewType` is an enum with cases `TILE`, `SHADER`, `SMOOTH_SHADER`, and `NONE`. `CoreView` accepts two `SimViewType` values (`viewTypeA`, `viewTypeB`) to optionally show a side-by-side comparison. Currently both platform entry points use `viewTypeA: .TILE, viewTypeB: .NONE`.

---

## Data Flow

End-to-end, from engine compute to pixels on screen:

```
[User gesture / button tap]
        │
        ▼
SimModel (main actor)
  sets request flag or updates f/k
        │
        ▼
SimModel Task loop (crosses to @SimActor)
  engine.evolve(for: 50)  →  SimSnapshot
        │
        ▼
SimModel (main actor)
  updates A[], B[], generation, generationRate
  @Observable triggers SwiftUI invalidation
        │
        ▼
SimTileView / SimShaderView / SimSmoothShaderView
  reads simModel.getCellLevels()
  maps levels → [Color] (sinusoidal formula)
        │
        ▼
  ┌─────────────────────────────────┐
  │  TILE: Canvas draws 40,401 rects│
  │  SHADER: .colorArray → GPU      │
  │  SMOOTH_SHADER: .colorArray → GPU│
  └─────────────────────────────────┘
        │
        ▼
      Screen
```

The 50-generations-per-frame batch keeps the per-frame call overhead low while still producing a visible evolution rate. At typical speeds this yields several thousand generations per second.

---

## Rendering Modes

### Tile (CPU Canvas)

`SimTileView` uses a SwiftUI `Canvas` closure. For every frame, it iterates the full 201×201 grid, maps each cell level to a `Color`, then fills a `CGRect` sized to one cell. This is the simplest implementation but the most CPU-intensive — 40,401 path fill calls per frame.

### Block Shader (GPU)

`SimShaderView` converts levels to a `[Color]` array then passes it to the Metal shader `turingdrawblock` via the `.visualEffect { content.colorEffect(…) }` modifier. The shader maps each screen pixel to a grid cell index with integer truncation — each cell renders as a solid block.

```metal
float2 simCellPoint = (position / size) * simWidth;
int simCellOffset = int(simCellPoint.x) * simWidth + int(simCellPoint.y);
return colors[simCellOffset];
```

### Smooth Shader (GPU with interpolation)

`SimSmoothShaderView` uses the same data pipeline as the block shader but calls `turingdrawsmooth`. For each pixel, the shader:

1. Computes the fractional cell position within a cell
2. Identifies the 4 neighbouring cell centres (current, horizontal, vertical, diagonal), with toroidal wrapping
3. Calculates the Euclidean distance from the pixel to each centre
4. Applies a `smoothstep` falloff over one cell width to produce a weight for each neighbour
5. Blends the four neighbour colours proportionally by weight

This produces smooth gradient transitions across cell boundaries, giving the simulation a more organic appearance.

---

## Parameter Space & Presets

The `(f, k)` plane has a narrow band of parameter combinations that produce interesting self-sustaining patterns. Outside this band, the system either collapses to A = 1 / B = 0 or grows uncontrolled.

`TuringMapView` renders a precomputed 1500×1500 image of this space (the background `turing-space-1500x1500` asset) with a translucent overlay mask (`TuringMapMask_100x100_v1`) highlighting stable regions. The coordinate mapping is:

- **X axis** → K: 0.0 (left) to 0.1 (right)
- **Y axis** → F: 0.1 (top) to 0.0 (bottom)

Tap or drag on the map to jump to any `(f, k)` point. The crosshair reticle follows the current selection.

`TuringMapLabels` maps 13 specific `(f, k)` points to human-readable pattern names:

| Name | f | k |
|------|---|---|
| Cerebellum | 0.055 | 0.062 |
| Lace | 0.042 | 0.059 |
| Tiles | 0.038 | 0.061 |
| Strings | 0.034 | 0.061 |
| Mitosis | 0.034 | 0.063 |
| Mandala | 0.026 | 0.052 |
| Shimmer | 0.022 | 0.050 |
| Evolution | 0.026 | 0.056 |
| Tunnel | 0.022 | 0.048 |
| Reflections | 0.016 | 0.048 |
| Fog | 0.014 | 0.040 |
| Waves | 0.014 | 0.050 |
| Wavelets | 0.014 | 0.053 |

`SimInformationView` does a nearest-neighbour lookup (via `TuringMapPoint.distance(to:)`) across all 13 labels to show the closest preset name to the current parameters, even when the user is between presets.

`SimSelectView` lets the user pick a preset from a wheel picker. It initialises the picker to the closest preset to the current `(f, k)` values.

---

## Concurrency Design

```
Main Actor                    @SimActor
──────────────────────        ─────────────────────
SimModel (@Observable)        SimEngine
  f, k, A[], B[]    ◄──────── evolve(for:) → SimSnapshot
  generation                  set_f / set_k
  generationRate              start / stop
  request flags               resetGraph / seedRandomly
  simTask (Task)
```

**Why a custom global actor?** `@MainActor` would block the UI during diffusion computation. A background `Task` alone (without isolation) risks data races. `@SimActor` gives the engine its own serial executor — all reads and writes to the A/B arrays are safe by construction, and `await engine.evolve(…)` suspends the model's loop task until the engine completes.

**Why not AsyncStream?** `SimEngine` has a `snapshots()` method that wraps `evolve()` in an `AsyncStream`. The current design bypasses it, calling `evolve()` directly in `SimModel`'s loop. This gives `SimModel` tighter control over timing and request processing between frames.

**Request flag pattern**: Rather than calling engine methods directly from UI callbacks (which would require another actor hop), `SimModel` exposes simple Bool-setting methods (`start()`, `pause()`, `reset()`, `seedRandomly()`). The model's task loop checks these flags after each `evolve()` call, then calls the engine on the correct actor.

---

## Responsive Layout Strategy

The app targets a wide range of screen sizes (iPhone SE through iPad to Mac) without separate layout files. `ViewThatFits` is used throughout to pick the most compact layout that fits available space:

| View | Layouts tried |
|------|--------------|
| `SimInformationView` | Single HStack → 2-row HStack → VStack |
| `SimControlView` | Single HStack → 2×2 grid |
| `SimParameterView` | HStack → VStack |
| `SimExploreView` | 7 `mapScale` sizes (800→300) |
| `CoreView` | Side-by-side HStack → single view VStack |

`SimControlView` uses a `ButtonWidthPreferenceKey` to measure all button labels and apply a uniform width, keeping the control row visually balanced regardless of locale or Dynamic Type size.

---

## Key Files Quick Reference

| File | What to read it for |
|------|-------------------|
| `Core/SimEngine.swift` | The Gray-Scott update loop; diffusion link construction |
| `Core/SimModel.swift` | The simulation task loop; parameter change detection; request flag pattern |
| `Core/SimSnapshot.swift` | Cross-actor data transfer contract |
| `Core/SimActor.swift` | Why SimEngine is isolated and how |
| `Core/TuringMapPoint.swift` | Nearest-preset distance calculation |
| `Data/TuringMapLabels.swift` | All 13 preset (f, k) values and names |
| `SimViews/SimTileView.swift` | CPU Canvas renderer; color-mapping formula |
| `SimViews/SimShaderView.swift` | How levels become a Metal color array |
| `SimViews/SimSmoothShaderView.swift` | Same as above but with smooth shader |
| `Shaders/SimView.metal` | `turingdrawblock` and `turingdrawsmooth` implementations |
| `Views/CoreView.swift` | Root layout; environment injection; modal management |
| `Views/TuringMapView.swift` | Canvas-to-(f,k) coordinate mapping; gesture handling |
| `Views/SimExploreView.swift` | Local state pattern for parameter exploration |
| `Views/SimSelectView.swift` | Nearest-preset initialisation; wheel picker |
| `TuringSimIos/ContentView.swift` | iOS entry point; initial render mode selection |
| `TuringSimMac/ContentView.swift` | macOS entry point; initial render mode selection |
| `TuringTool/main.swift` | Minimal CLI harness for running the engine headlessly |

---

## Unused / Future Work

**`SimEngine.snapshots()`** — Returns an `AsyncStream<SimSnapshot>` wrapping the `evolve()` loop. Not called anywhere; `SimModel` calls `evolve()` directly instead. A potential future design if the model needs to consume frames at the engine's natural pace rather than in a polling loop.

**`SimModel.getAFloats()` / `getBFloats()`** — Accelerate-accelerated double-to-float conversions for the raw A and B arrays. Not consumed by any view (the shader views use the derived level/color arrays). Available if a future rendering mode needs direct access to concentrations rather than the B/(A+B) level.

**Dual-view comparison mode** — `CoreView` accepts `viewTypeA` and `viewTypeB` and can render two simulation views side by side. Both platform entry points currently pass `viewTypeB: .NONE`, so the slot is unused. The infrastructure is in place to enable split-screen comparison of different render modes or (with a separate engine) different parameter sets.
