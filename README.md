# SUINavigationFusion Sample

This is a small iOS app demonstrating usage of the `SUINavigationFusion` library.

## What it covers

- `NavigationShell` usage (UIKit `UINavigationController` under the hood)
- `Navigator` stack operations:
  - `push`, `pop`, `popNonAnimated`, `popToRoot`, `pop(levels:)`
  - per-screen `disableBackGesture`
- Top bar APIs:
  - title/subtitle via `String` and `Text`
  - leading/trailing items (primary + secondary)
  - principal view (custom center content)
  - tint precedence (configuration tint vs environment tint)
  - visibility controls (`topNavigationBarVisibility`)
  - hiding the back button (`topNavigationBarHidesBackButton`)
- Scroll-dependent background opacity using `PositionObservingViewPreferenceKey`
- Update edge case for bar items: stable `id` + `updateKey` to refresh dynamic content
- A configuration playground for `TopNavigationBarConfiguration`:
  - background material vs color
  - divider, tint color
  - title/subtitle fonts, weights, colors, spacing
  - custom back icon (SF Symbol name)

## How to run

1. Open `SUINavigationCore-Sample/SUINavigationCore-Sample.xcodeproj`
2. Select the `SUINavigationCore-Sample` scheme
3. Run on an iOS Simulator

## Source

The sample lives in `SUINavigationCore-Sample/SUINavigationCore-Sample/ContentView.swift`.
