# Release Notes

## v0.1.2

Moderation-safe package update for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Changed

- Removed long embedded markdown documentation ModuleScripts from the Roblox model package.
- Kept buyer documentation as normal external markdown files in the repo/release bundle instead of runtime ModuleScripts.
- Kept `Plume.Examples.CustomBurstExample` as a normal local ModuleScript example with no embedded markdown string.
- Runtime behavior and VFX presets are unchanged from v0.1.1.

### Recommended Store Update Notes

Version 0.1.2:

- Repackaged the model to remove embedded markdown documentation strings from runtime ModuleScripts.
- Documentation now lives in the external README/docs bundle instead of inside the Roblox model source.
- No VFX runtime behavior changes.
- No remote module loading, `loadstring`, `InsertService`, `AssetService`, LinkedSource, HTTP calls, or obfuscated code.

## v0.1.1

Documentation and buyer onboarding update for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Added

- Built-in Studio-visible buyer documentation under `ReplicatedStorage.Plume.Documentation`
- `Plume.Documentation.list()` and `Plume.Documentation.get(key)` helpers for browsing docs from code
- Quick Start, Authoring API, Customizing Presets, Events And Triggers, Flipbook Textures, Preset Catalog, and Troubleshooting pages inside the model asset
- `Plume.Examples.CustomBurstExample` as a copyable custom-effect starter pattern
- Store docs updated to make clear that PlumeFX includes the tools and docs needed to build custom VFX, not only starter presets

### Recommended Store Update Notes

Version 0.1.1:

- Added built-in Studio documentation inside `ReplicatedStorage.Plume.Documentation`
- Added quick start, authoring API, custom preset, events, flipbook, preset catalog, and troubleshooting pages
- Added `Plume.Documentation` helpers for reading docs from code
- Added `Plume.Examples.CustomBurstExample` for building custom layered VFX
- Refreshed README and store docs so buyers know exactly how to install, test, customize, and build their own effects

## v0.1.0

Initial Creator Store release for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Included

- Chainable code-first VFX authoring API
- Runtime manager with prefab registration, spawning, intensity, cleanup, and overflow recycling
- Timeline events, manual trigger hooks, gameplay events, sub-effect chains, and socket/attachment spawning
- Native Roblox renderers for sprites, beams, part beams, ribbon-style trails, lights, mesh debris, and procedural decals
- Spiral wind ribbon renderer for readable funnel/tornado silhouettes
- 7 original transparent 4x4 flipbook PNG sheets with usage examples
- Corrected, bottom-aligned tornado flipbook sheet for stable grounded playback
- 16 starter presets:
  - Arcane Starburst
  - Cinematic Fire Plume
  - Impact Explosion
  - Void Dissolve Impact
  - Fireworks Burst
  - Lightning Strike
  - Ground Slam
  - Combo Cascade
  - Sword Slash
  - Muzzle Flash
  - Bullet Impact
  - Frost Mist
  - Healing Aura
  - Poison Cloud
  - Reward Burst
  - Whirling Tornado
- In-game demo panel with buttons and keyboard shortcuts
- First-person shooting demo with reticle, muzzle flash, projectile travel, bullet-impact decals, sparks, smoke, and mesh debris

### Recommended Store Positioning

PlumeFX is a VFX toolkit/runtime plus starter library. The presets are included so buyers can ship quickly, but the main value is that developers can build and trigger their own custom VFX with clean, reusable modules.
