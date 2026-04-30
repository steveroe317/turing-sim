# Code Review — 2026-04-29

Reviewer: Claude  
Scope: All Swift and Metal source files  
Criteria: Correctness, organisation, Swift/SwiftUI style, SWIFTUI.md guidelines

---

## Summary

| Severity | Count |
|----------|-------|
| Correctness / bugs | 6 |
| Swift concurrency / API | 2 |
| SWIFTUI.md style violations | 8 |
| Organisation & design | 6 |
| Minor / polish | 9 |

---

## Correctness / Bugs

### C1 — `SimControlView`: `onPreferenceChange` attached to wrong view in VStack layout

**File:** `Views/SimControlView.swift` lines 212–214

In the VStack layout, `.onPreferenceChange(ButtonWidthPreferenceKey.self)` is attached to the second inner `HStack` (the Select / Explore row). The GeometryReaders in the first inner `HStack` (Start/Pause, Seed, Reset row) emit preferences that propagate up to the outer `VStack`, but no handler is there to receive them. As a result, `buttonMaxWidth` in the VStack layout is set only from the widths of "Select" and "Explore" — "Pause", "Seed", and "Reset" do not contribute.

```swift
// Current — handler on inner HStack only
VStack {
    HStack { /* Start/Pause, Seed, Reset — preferences emitted but not captured */ }
    HStack { /* Select, Explore */
        …
    }
    .onPreferenceChange(ButtonWidthPreferenceKey.self) { … }  // ← wrong level
}

// Fix — handler on the outer VStack
VStack {
    HStack { … }
    HStack { … }
}
.onPreferenceChange(ButtonWidthPreferenceKey.self) { … }
```

### C2 — `SimSelectView`: guard condition silently rejects f=0 or k=0

**File:** `Views/SimSelectView.swift` lines 70–75

After unwrapping `currentSelection`, there is an additional guard:

```swift
if currentSelection.point.f != 0 && currentSelection.point.k != 0 {
    simModel.f = currentSelection.point.f
    simModel.k = currentSelection.point.k
}
```

No current preset has f=0 or k=0, so this never fires — but it would silently discard any future preset or user-supplied parameter at those values. The intent seems to be "only apply if something is selected", but `currentSelection` is already fully unwrapped at that point. The condition is redundant and misleading.

```swift
// Fix — remove the inner guard
if let currentSelection = currentSelection {
    simModel.f = currentSelection.point.f
    simModel.k = currentSelection.point.k
}
```

### C3 — `CoreView`: duplicate `SimExploreView(mapScale: 800)` in `ViewThatFits`

**File:** `Views/CoreView.swift` lines 58–61

```swift
ViewThatFits {
    SimExploreView(mapScale: 800, …).aspectRatio(1.0, contentMode: .fit)
    SimExploreView(mapScale: 800, …).aspectRatio(1.0, contentMode: .fit)  // ← identical
    SimExploreView(mapScale: 700, …)…
    …
}
```

`ViewThatFits` tries each child in order and picks the first that fits. The second `mapScale: 800` entry is unreachable — it would only be tried if the first one did not fit, but they have identical size requirements.

Fix: Remove one of the two `mapScale: 800` entries.

### C4 — `SimEngine.snapshots()` leaks a Task on cancellation

**File:** `Core/SimEngine.swift` lines 165–175

```swift
func snapshots() -> AsyncStream<SimSnapshot> {
    return AsyncStream { continuation in
        Task {
            while true {
                let snapshot = self.evolve(for: 50)
                continuation.yield(snapshot)
            }
            continuation.finish()
        }
    }
}
```

The inner `Task` is created without a handle and runs an infinite loop with no cancellation check. If a consumer of the stream is cancelled or deallocated, the Task continues running forever and the `continuation` is never finished. The method is currently unused — `SimModel` calls `evolve()` directly — but the implementation is incorrect regardless.

Fix: Either remove the method, or rewrite it with proper cooperative cancellation:

```swift
func snapshots() -> AsyncStream<SimSnapshot> {
    AsyncStream { continuation in
        let task = Task {
            while !Task.isCancelled {
                continuation.yield(evolve(for: 50))
            }
            continuation.finish()
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}
```

### C5 — `TuringMapView`: debug `print` fires every frame

**File:** `Views/TuringMapView.swift` line 61

```swift
func mapParamsToCanvasPoint(f: Double, k: Double, size: CGSize) -> CGPoint {
    …
    print(x, y)   // ← fires on every Canvas draw pass
    return CGPoint(x: x, y: y)
}
```

`mapParamsToCanvasPoint` is called inside the `Canvas` closure, which runs every rendering frame. This spams the console at the simulation frame rate (potentially thousands of times per second) and adds synchronous I/O to the render path.

Fix: Delete `print(x, y)`.

### C6 — `SimEngine.seedRandomly()`: debug prints in production code

**File:** `Core/SimEngine.swift` lines 215 and 222

```swift
func seedRandomly() {
    print("SimEngineGraph: seeding random")  // ← remove
    …
    print("SimEngineGraph: seeded")          // ← remove
}
```

Fix: Delete both `print` statements.

---

## Swift Concurrency / API

### A1 — `Task.sleep(nanoseconds:)` used instead of `Task.sleep(for:)`

**File:** `Core/SimModel.swift` line 49

```swift
try await Task.sleep(nanoseconds: 10_000_000)
```

SWIFTUI.md explicitly forbids the nanoseconds variant. Additionally, 10 ms is far too short when the simulation is paused — the loop wakes up, makes several actor hops to check parameters and call `evolve()` (which returns immediately when paused), and then sleeps again, spinning at roughly 100 iterations per second for no purpose.

```swift
// Fix — use the modern API and a longer pause interval
try await Task.sleep(for: .milliseconds(100))
```

### A2 — Spin-wait when simulation is paused

**File:** `Core/SimModel.swift` lines 46–96

When paused, the `SimModel` task loop:
1. Sleeps 10 ms (see A1)
2. Makes two `await` hops to read `engine.f` and `engine.k`
3. Calls `await engine.evolve()`, which returns immediately (engine does nothing when stopped)
4. Updates `@Observable` properties
5. Checks request flags
6. Loops

This drives unnecessary actor traffic and main-actor `@Observable` updates at ~100 Hz while nothing is visually changing. The fix from A1 (longer sleep) mitigates this, but an explicit early-continue when paused would be cleaner:

```swift
while true {
    let running = await engine.isRunning()
    isSimRunning = running
    if !running {
        // Still check flags so user can restart without long delay
        await processRequestFlags(engine: engine)
        try await Task.sleep(for: .milliseconds(100))
        continue
    }
    // … normal evolve path
}
```

---

## SWIFTUI.md Style Violations

### S1 — `.cornerRadius()` used instead of `.clipShape(.rect(cornerRadius:))`

**Files:**
- `Views/SimExploreView.swift` lines 29, 32
- `Views/SimSelectView.swift` lines 63, 88

```swift
// Current (deprecated)
.cornerRadius(10)
.cornerRadius(25.0)

// Fix
.clipShape(.rect(cornerRadius: 10))
.clipShape(.rect(cornerRadius: 25))
```

### S2 — `.foregroundColor()` instead of `.foregroundStyle()`

**File:** `Views/SimSelectView.swift` line 60

```swift
// Current (deprecated)
.foregroundColor(colorScheme == .light ? Color(.darkGray) : Color(.lightGray))

// Fix
.foregroundStyle(colorScheme == .light ? Color.primary : Color.secondary)
```

(Also addresses S3 below.)

### S3 — UIKit colors in SwiftUI code

**File:** `Views/SimSelectView.swift` line 60

`Color(.darkGray)` and `Color(.lightGray)` wrap `UIColor` values. SWIFTUI.md prohibits UIKit colors in SwiftUI code.

Fix: Use SwiftUI semantic colors such as `Color.primary` / `Color.secondary`, or define named colors in the asset catalog.

### S4 — `.accentColor()` instead of `.tint()`

**File:** `Views/SimSelectView.swift` line 61

`.accentColor()` is deprecated since iOS 15.

```swift
// Current
.accentColor(colorScheme == .light ? .black : .white)

// Fix
.tint(colorScheme == .light ? .black : .white)
```

### S5 — C-style number formatting with `String(format:)`

**Files:**
- `Views/SimInformationView.swift` lines 19–23, 44–47, 65–67
- `Views/SimParameterView.swift` lines 19, 33

SWIFTUI.md states: *"Never use C-style number formatting such as `Text(String(format: "%.2f", …))`; always use the `FormatStyle` API."*

```swift
// Current
Text(String(format: "F %.3f, K %.3f", simModel.f, simModel.k))

// Fix
Text("F \(simModel.f, format: .number.precision(.fractionLength(3))), K \(simModel.k, format: .number.precision(.fractionLength(3)))")
```

For the `Stepper` label (a `String`, not `Text`):

```swift
// Current
Stepper(String(format: "\(label): %.3f", simParameter), …)

// Fix
Stepper("\(label): \(simParameter, format: .number.precision(.fractionLength(3)))", …)
```

### S6 — `edgesIgnoringSafeArea` instead of `ignoresSafeArea`

**File:** `TuringSimIos/ContentView.swift` line 14

```swift
// Current (deprecated)
Color(…).edgesIgnoringSafeArea(.all)

// Fix
Color(…).ignoresSafeArea()
```

### S7 — `SimViewType` enum cases use SCREAMING_SNAKE_CASE

**File:** `SimViews/SimViewType.swift`

Swift API Design Guidelines and Swift community conventions require lowerCamelCase for enum cases.

```swift
// Current
enum SimViewType { case TILE, SHADER, SMOOTH_SHADER, NONE }

// Fix
enum SimViewType { case tile, shader, smoothShader, none }
```

All switch statements and comparisons referencing these cases must be updated accordingly.

### S8 — `bold(true)` instead of `bold()`

**File:** `Views/SimSelectView.swift` line 47

`.bold(true)` is valid Swift but the idiomatic form when unconditionally bolding is `.bold()` (no argument).

```swift
// Fix
Text("Select Simulation Parameters").bold()
```

---

## Organisation & Design

### O1 — Preset data duplicated across `TuringMapLabels` and `SimSelectView`

`TuringMapLabels` (`Data/TuringMapLabels.swift`) and `SimSelectView` (`Views/SimSelectView.swift` lines 26–40) both hardcode the same 13 `(f, k)` pairs. Adding a preset or correcting a value requires updating two files.

Fix: `SimSelectView.menuItems` should be derived from `TuringMapLabels.labels`:

```swift
// In SimSelectView, computed from the environment rather than hardcoded
static func menuItems(from labels: TuringMapLabels) -> [TuringPointItem] {
    labels.labels.keys.enumerated().map { index, point in
        TuringPointItem(id: index, point: point)
    }
    .sorted { $0.point.f > $1.point.f }
}
```

### O2 — `TuringPointItem.label(point:mapLabels:)` ignores `self.point`

**File:** `Views/SimSelectView.swift` lines 21–23

```swift
func label(point: TuringMapPoint, mapLabels: TuringMapLabels) -> String {
    return mapLabels.getLabel(forPoint: point) ?? ""
}
```

The method takes a `point` parameter, but the call site always passes `self.point` back:

```swift
option.label(point: option.point, mapLabels: mapLabels)
```

The parameter is redundant and creates confusion about whether a different point could be passed.

```swift
// Fix
func label(mapLabels: TuringMapLabels) -> String {
    mapLabels.getLabel(forPoint: point) ?? ""
}
```

### O3 — `SimControlView` body is massively duplicated

**File:** `Views/SimControlView.swift`

The entire button set (5 buttons, each wrapped in a `GeometryReader`/`PreferenceKey`/`.frame(width:)` triple) is written out twice verbatim — once for the HStack layout and once for the VStack layout. This is ~200 lines of near-identical code. The structural buttons differ only in their arrangement, not their content.

Additionally, the `GeometryReader`-based width-measuring pattern is repeated 10 times (once per button per layout). This is a prime candidate for a custom `ViewModifier`.

Fix — extract a width-measuring modifier and a button sub-view:

```swift
struct MeasuredWidthModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo in
                Color.clear.preference(key: ButtonWidthPreferenceKey.self, value: geo.size.width)
            }
        )
    }
}

// Private sub-view for the start/pause toggle
private struct StartPauseButton: View { … }
```

### O4 — `CoreView`: switch vs if/else if inconsistency for `viewTypeB`

**File:** `Views/CoreView.swift` lines 42–48

`viewTypeA` uses a `switch` statement; `viewTypeB` uses an `if/else if` chain and does not handle `.NONE` explicitly (it simply produces no view, which is the desired behaviour, but the omission is silent).

```swift
// Fix — use switch for both, with explicit NONE handling
switch viewTypeB {
case .tile: SimTileView()
case .shader: SimShaderView()
case .smoothShader: SimSmoothShaderView()
case .none: EmptyView()
}
```

### O5 — `SimSelectView.menuItems` is an instance property, not `static`

**File:** `Views/SimSelectView.swift` line 26

`let menuItems: [TuringPointItem] = […]` is a constant array of static data that is re-allocated on every `SimSelectView` initialisation.

Fix: `static let menuItems: [TuringPointItem] = […]`

### O6 — `import Combine` unused in macOS `ContentView`

**File:** `TuringSimMac/ContentView.swift` line 8

`Combine` is imported but nothing from the framework is referenced in that file.

Fix: Delete the import.

---

## Minor / Polish

### P1 — `SimTileView`: redundant stroke after fill

**File:** `SimViews/SimTileView.swift` line 47

```swift
context.fill(path, with: .color(cellColor))
context.stroke(path, with: .color(cellColor))  // ← same color, no visual effect
```

Drawing a stroke in the same color as the fill is a no-op visually, but adds 40,401 extra draw calls per frame.

Fix: Remove the `context.stroke` call.

### P2 — `SimTileView`: `Path(roundedRect:cornerRadius:0:style:)` instead of `Path(rect:)`

**File:** `SimViews/SimTileView.swift` lines 40–44

```swift
let path = Path(roundedRect: cellRect, cornerRadius: CGFloat(0.0), style: .circular)
```

A rounded-rect with radius zero is a plain rectangle. The `style` parameter only has meaning when `cornerRadius > 0`.

```swift
// Fix
let path = Path(cellRect)
```

### P3 — `SimEngine.totalCells` re-assigned redundantly in `init()`

**File:** `Core/SimEngine.swift` lines 13 and 39

```swift
var totalCells = 201 * 201        // inline initialiser
…
init() {
    totalCells = cellsPerEdge * cellsPerEdge  // ← duplicates the above
```

`totalCells` is also never mutated after `init()`.

Fix: Remove the inline initialiser value and make it a computed or `let` property:

```swift
let totalCells: Int  // set once in init from cellsPerEdge * cellsPerEdge
```

Or simply remove the re-assignment in `init()` since the inline initialiser already sets it correctly.

### P4 — `SimEngine.maxA()` / `maxB()` are dead code

**File:** `Core/SimEngine.swift` lines 140–146

Neither method is called anywhere in the project.

Fix: Remove both methods. If they are needed for future debugging, a comment in the `evolve()` method noting how to inspect the arrays is more maintainable.

### P5 — `TuringMapPoint.distance(to:)` uses `pow()` for squaring

**File:** `Core/TuringMapPoint.swift` line 15

```swift
return sqrt(pow(f - other.f, 2) + pow(k - other.k, 2))
```

`pow(x, 2)` invokes a floating-point generalised power function. Simple multiplication is faster and equally readable.

```swift
// Fix
let df = f - other.f
let dk = k - other.k
return sqrt(df * df + dk * dk)
```

### P6 — `SimSelectView.currentSelection` initialised to hardcoded first preset

**File:** `Views/SimSelectView.swift` line 42

```swift
@State private var currentSelection: TuringPointItem? = TuringPointItem(id: 1, point: …)
```

This hardcodes "Cerebellum" as the initial picker state. The `.task` modifier then overwrites it with the nearest preset to the model's current parameters — but there is a brief frame where the picker shows the wrong value.

Fix: Initialise to `nil` and guard the `Picker` accordingly, or read the initial value from the environment in a custom `init`.

### P7 — `SimButtonStyle` preview has a trailing semicolon

**File:** `Views/SimButtonStyle.swift` line 22

```swift
}.buttonStyle(SimButtonStyle());   // ← trailing semicolon
```

Trailing semicolons are non-idiomatic Swift.

Fix: Remove the semicolon.

### P8 — `GeometryReader` used in iOS `ContentView` to fill available space

**File:** `TuringSimIos/ContentView.swift` lines 16–18

```swift
GeometryReader { geometry in
    CoreView(…).frame(width: geometry.size.width, height: geometry.size.height)
}
```

`GeometryReader` is used purely to obtain the available size and fill it. SWIFTUI.md recommends preferring `containerRelativeFrame()` or other modern alternatives when `GeometryReader` is only needed for sizing. The macOS version achieves the same result without `GeometryReader`.

Fix: Remove `GeometryReader` and use `.frame(maxWidth: .infinity, maxHeight: .infinity)` or `containerRelativeFrame(.horizontal, .vertical)`.

### P9 — `SimExploreView` and `SimSelectView`: initial local state doesn't match model

**Files:** `Views/SimExploreView.swift` line 16–17, `Views/SimSelectView.swift` line 42

Both views initialise their local `f`/`k` state to fixed defaults and rely on `.task` to sync from the model. For one layout pass the controls show stale values.

Fix: Provide a custom `init` that accepts the model's current `f` and `k` as parameters and uses them to initialise `@State`:

```swift
init(showExploreView: Binding<Bool>, initialF: Double, initialK: Double) {
    _showExploreView = showExploreView
    _f = State(initialValue: initialF)
    _k = State(initialValue: initialK)
}
```

---

## Files with No Issues

- `Core/SimActor.swift`
- `Core/SimSnapshot.swift`
- `SimViews/SimShaderView.swift`
- `SimViews/SimSmoothShaderView.swift`
- `Views/SimInformationView.swift` *(except S5)*
- `TuringTool/main.swift` *(diagnostic tool, no production standards apply)*
