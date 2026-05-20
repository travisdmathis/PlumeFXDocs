# Changelog

## v0.2.0

Authoring and production toolkit update for **PlumeFX VFX Toolkit & Effects Library**.

### Added

- Added `Plume.Serialization` with `toTable`, `fromTable`, `clone`, `toJSON`, and `fromJSON`.
- Added `Plume.Validator` with warnings, errors, unsupported module detection, rough cost stats, texture collection, and duration estimates.
- Added real `Manager:Preload(id?)` support using validation, texture/content collection, and `ContentProvider:PreloadAsync()`.
- Added seeded runtime randomness through `manager:Spawn(id, { seed = ... })` and emitter `:seed(...)`.
- Added Roblox-native lifecycle events: `onStart`, `onBurst`, `onEmitterStart`, `onEmitterEnd`, and `onEffectEnd`.
- Added real `spawnFromEvents(...)` support for timeline, lifecycle, manual, and namespaced emitter events.

### Changed

- `emitEvents()` is now treated as a Roblox-native lifecycle-event authoring hook instead of an unsupported API marker.

## v0.1.6

Pre-publish runtime parity update for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Fixed

- Confirmed the store package includes the live-tested builder APIs for decals, beams, part beams, spiral ribbons, lights, and mesh debris.
- Confirmed the store package includes the Roblox compatibility helpers used by the new renderers.
- Confirmed the store package includes the generic scalar/range helper fix for decal sizing and mesh aspect randomization.
- Confirmed the store package includes the cleanup fix for cyclic `BindableEvent` payloads.
- Confirmed the store package keeps texture-first decals from v0.1.5.
- Beam, part-beam, and light renderers now honor `render.lifetime` when scheduling their own cleanup.
- Beam `FaceCamera` and light renderer properties now use guarded property assignment.
- Light renderer class selection now falls back to `PointLight` unless `PointLight`, `SpotLight`, or `SurfaceLight` is requested.

### Included Runtime Surfaces

- `renderSprite`
- `renderBeam`
- `renderPartBeam`
- `renderSpiralRibbon`
- `renderRibbon`
- `renderMesh`
- `renderDecal`
- `renderLight`

## v0.1.5

Texture-first decal renderer update for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Changed

- `renderDecal()` now renders the supplied texture by default without adding procedural scorch, ring, core, or crack artwork over it.
- Procedural ring/core/crack details now require `procedural = true`.
- Physical scorch/core/crack parts now require `physical = true`.
- Bullet Impact and Void Dissolve Impact decal presets now use generic `textureScale`, `textureTransparency`, and `textureRotationJitter` fields.

## v0.1.4

Decal renderer fix for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Fixed

- Fixed decal/scorch effects erroring when renderer defaults use range tables for randomized size or aspect values.
- Hardened the shared random range helper so missing optional values can safely fall back to `{ min, max }` ranges.

## v0.1.3

Runtime cleanup fix for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Fixed

- Stopped firing cyclic effect instance tables through Roblox `BindableEvent` signals during effect destruction and trigger dispatch.
- Preserved the higher-level `effect:On(...)` callback API, including access to the effect instance from direct handler callbacks.
- Prevented auto-destroyed effects from throwing cleanup errors after their lifecycle completes.

## v0.1.2

Moderation-safe package update for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Changed

- Removed long embedded markdown documentation ModuleScripts from the Roblox model package.
- Kept buyer documentation as normal external markdown files in the repo/release bundle instead of runtime ModuleScripts.
- Kept `Plume.Examples.CustomBurstExample` as a normal local ModuleScript example with no embedded markdown string.
- Runtime behavior and VFX presets are unchanged from v0.1.1.

## v0.1.1

Documentation and buyer onboarding update for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Added

- Public buyer documentation for Quick Start, Authoring API, Customizing Presets, Events And Triggers, Flipbook Textures, Preset Catalog, and Troubleshooting.
- `Plume.Examples.CustomBurstExample` as a copyable custom-effect starter pattern.
- Store docs updated to make clear that PlumeFX includes the tools and docs needed to build custom VFX, not only starter presets.

## v0.1.0

Initial Creator Store release for **PlumeFX VFX Toolkit & Combat Effects Library**.

### Included

- Chainable code-first VFX authoring API.
- Runtime manager with prefab registration, spawning, intensity, cleanup, and overflow recycling.
- Timeline events, manual trigger hooks, gameplay events, sub-effect chains, and socket/attachment spawning.
- Native Roblox renderers for sprites, beams, part beams, ribbon-style trails, lights, mesh debris, texture decals, and optional procedural impact details.
- Spiral wind ribbon renderer for readable funnel/tornado silhouettes.
- 7 original transparent 4x4 flipbook PNG sheets with usage examples.
- Corrected, bottom-aligned tornado flipbook sheet for stable grounded playback.
- 16 starter presets: Arcane Starburst, Cinematic Fire Plume, Impact Explosion, Void Dissolve Impact, Fireworks Burst, Lightning Strike, Ground Slam, Combo Cascade, Sword Slash, Muzzle Flash, Bullet Impact, Frost Mist, Healing Aura, Poison Cloud, Reward Burst, and Whirling Tornado.
- In-game demo panel with buttons and keyboard shortcuts.
- First-person shooting demo with reticle, muzzle flash, projectile travel, bullet-impact decals, sparks, smoke, and mesh debris.

### Build Artifacts

- `build/PlumeFX.rbxm` - Creator Store model package.
- `build/PlumeFXDemo.rbxlx` - demo place for testing and video capture.
