# Code Review — 2026-05-02

Reviewer: Claude  
Scope: New and modified files since code-review-2026-04-29.md  
Criteria: Correctness, organisation, Swift/SwiftUI style, SWIFTUI.md guidelines

All 31 findings from the previous review were resolved. This review documents issues introduced by that refactoring.

---

## Summary

| Severity | Count |
|----------|-------|
| Correctness / bugs | 1 |
| SWIFTUI.md style violations | 1 |
| Organisation & design | 2 |
| Minor / polish | 3 |

---

## Correctness / Bugs

### N5 — `ResetButton` lost its destructive role

**File:** `Views/SimControlView.swift` line 120

The original `SimControlView` used `Button("Reset", role: .destructive)`, which causes the platform to render the label in the system destructive style (red on iOS). The O3 refactor extracted the button into a private `ResetButton` sub-view but dropped the role:

```swift
// Before refactor — correct
Button("Reset", role: .destructive) { simModel.reset() }

// After refactor — role dropped
Button("Reset") { simModel.reset() }
```

Reset wipes the entire simulation state and should retain the destructive visual signal.

```swift
// Fix
Button("Reset", role: .destructive) {
    simModel.reset()
}
```

---

## SWIFTUI.md Style Violations

### N1 — `SimSelectPicker`: `Color.darkGray` / `Color.lightGray` are not SwiftUI colors

**File:** `Views/SimSelectPicker.swift` line 30

```swift
.foregroundStyle(colorScheme == .light ? Color.darkGray : Color.lightGray)
```

`Color.darkGray` and `Color.lightGray` are not static properties on SwiftUI's `Color` type — only `Color.gray` is standard. These resolve through UIKit/AppKit bridging, which is the same underlying violation that the previous review flagged as S3 (`Color(.darkGray)`). The fix changed the syntax but kept the same platform-specific colors.

SWIFTUI.md: *"Avoid using UIKit colors in SwiftUI code."*

Fix: Use SwiftUI semantic colors that adapt automatically to light and dark mode, eliminating the need for the `colorScheme` check:

```swift
// Fix
.foregroundStyle(Color.primary)
```

---

## Organisation & Design

### N3 — `SimView.swift`: dead code — unreferenced wrapper with unused `colorMap`

**File:** `SimViews/SimView.swift`

`SimView` is a new wrapper struct whose `body` simply delegates to `SimTileView()`. It defines a full `colorMap(level:)` function that is never called — `SimTileView` has its own copy and uses that one. `SimView` itself is not referenced anywhere in the project (`CoreView` and `SimViewType` switch directly to `SimTileView`, `SimShaderView`, or `SimSmoothShaderView`).

Fix: Remove `SimView.swift`. If a unified rendering facade is desired in the future, define it then and remove the `colorMap` duplication at that point.

### N4 — `DummySimView.swift` is unreferenced dead code

**File:** `Views/DummySimView.swift`

`DummySimView` is not imported, referenced, or used anywhere in the project. It was likely a placeholder from early development.

Fix: Remove the file.

---

## Minor / Polish

### N2 — `SimSelectView`: debug `print` in Cancel button action

**File:** `Views/SimSelectView.swift` line 71

```swift
Button("Cancel", role: .cancel) {
    showSelection = false
    print("no selection")   // ← remove
}
```

This was present before the previous review and was not caught at that time. It logs to the console on every cancel tap.

Fix: Delete `print("no selection")`.

### N6 — `makeMenuItems(from:)` sorts by `f` only — non-deterministic order for tied presets

**File:** `Views/SimSelectView.swift` lines 25–30

```swift
.sorted { $0.point.f > $1.point.f }
```

Three groups of presets share the same `f` value: `f=0.034` (Strings, Mitosis), `f=0.022` (Shimmer, Tunnel), and `f=0.014` (Fog, Waves, Wavelets). Because the source is a `Dictionary`, iteration order is not guaranteed, so the relative order of tied presets is non-deterministic and may vary between runs. The original hardcoded array had a stable order.

```swift
// Fix — sort by (f, k) as a stable composite key
.sorted { ($0.point.f, $0.point.k) > ($1.point.f, $1.point.k) }
```

### N7 — `SimModel.frame` property is declared but never used

**File:** `Core/SimModel.swift` line 19

```swift
var frame = 0
```

`frame` is never incremented or read anywhere in the file.

Fix: Remove it.
