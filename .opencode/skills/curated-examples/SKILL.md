---
name: curated-examples
description: Guides on the curated Rive-Flutter example app with liquid_swipe-inspired animations. Use when the user asks about curated examples, the curated-examples branch, or the animated app.
---

# Curated Rive-Flutter Examples

Branch `curated-examples` — app animada con estética minimalista tipo liquid_swipe.

## Selected Features

| Section | Features |
|---|---|
| **Getting Started** | Shared Texture, Manual Shared Texture Management |
| **Rive Features** | Audio |
| **Asset Loading** | Network .riv Asset, Out-of-band Assets (x3) |
| **Painters [Advanced]** | Single Animation Painter |
| **Flutter Concepts** | Flutter Ticker Mode, Flutter Time Dilation |
| **Legacy Features** | Inputs [Nested], Text Runs [Nested] |

## Animation Techniques Applied

| Technique | Source | Location |
|---|---|---|
| Staggered entrance (fadeIn + slideY + scale) | liquid_swipe | Nav buttons + section headers |
| Glassmorphism (BackdropFilter + blur) | liquid_swipe | Nav buttons, factory bar |
| Liquid wave decorative (CustomPainter + sine waves + glow) | liquid_swipe | Home background |
| Wave reveal page transition (ClipPath + custom clipper) | liquid_swipe | Page transitions |
| Light/dark mode toggle (SharedPreferences) | liquid_swipe | AppBar button |
| Factory selector bar (glassmorphism bottom bar) | liquid_swipe | Bottom of home screen |
| Minimalist palette (#6C63FF / #FF6584) | liquid_swipe | Global theme |

## App Icon

Tomado de `liquid_swipe/assets/icon.svg` — gota degradado púrpura/rosa.

## Files

- `.riv` assets: todos intactos
- `TAREAS.md`: lista de tareas completadas y pendientes
- `VERSION`: `1.0.2`

## Build & Install

```sh
cd example
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```
