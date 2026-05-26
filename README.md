# PlumeFX Documentation

Public documentation for **PlumeFX VFX Toolkit & Effects Library**, a Roblox-native VFX toolkit with a chainable Luau authoring API, runtime manager, validation, serialization, preload reports, seeded variation, event triggers, attachment/socket spawning, mesh debris, texture-first surface decals, optional procedural impact details, flipbook particles, beams, trails, lights, part beams, anchored persistent environmental effects, and polished starter effects.

Get PlumeFX on the Roblox Creator Store:

https://create.roblox.com/store/asset/93706653529943/PlumeFX-VFX-Toolkit-Effects-Library

Current documented package version: `0.3.0`.

## Start Here

- [Quick Start](docs/QUICK_START.md)
- [Authoring API](docs/AUTHORING_API.md)
- [Customizing Presets](docs/CUSTOMIZING_PRESETS.md)
- [Persistent Environmental Effects](docs/ENVIRONMENTAL_EFFECTS.md)
- [Preset Catalog](docs/PRESET_CATALOG.md)
- [Events And Triggers](docs/EVENTS_AND_TRIGGERS.md)
- [Flipbook Textures](docs/FLIPBOOK_TEXTURES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Optional Demo](examples/README.md)
- [Changelog](CHANGELOG.md)

## What This Repo Contains

This repository contains public documentation, supporting flipbook preview images, and an optional demo script buyers can copy into Studio after installing PlumeFX.

It does not include the paid Roblox model, runtime source package, internal launch notes, moderation notes, release zips, or build artifacts.

## Install Summary

1. Insert the `PlumeFX` model from the Roblox Creator Store.
2. Move `PlumeFX.Plume` into `ReplicatedStorage`.
3. Keep, archive, or delete the empty `PlumeFX` container after moving the module.
4. Require `ReplicatedStorage.Plume` and register/spawn presets from your own scripts.

Optional: copy `examples/PlumeDemo` into `StarterPlayer > StarterPlayerScripts` if you want the in-game test panel in a sandbox place. Do not add the demo script to production games unless you intentionally want that UI and camera behavior.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plume = require(ReplicatedStorage.Plume)

local manager = Plume.Manager.new({
	parent = workspace,
	maxActive = 128,
	overflowPolicy = "recycleOldest",
})

manager:Register("impact-explosion", Plume.Presets.Combat.impactExplosion)

local preloadReport = manager:Preload("impact-explosion")
if not preloadReport.ok then
	warn(preloadReport.errors)
end

manager:Spawn("impact-explosion", {
	position = Vector3.new(0, 4, 0),
	intensity = 1,
	seed = 12345,
})
```

## New In v0.3.0

- `Plume.Environment` helpers for persistent layered environment VFX attached to existing anchors.
- Sprite/flipbook and light layer stacks for auras, vents, mist, sparks, candles, torches, lanterns, braziers, portals, and other ambient loops.
- `Plume.Runtime.FlickerController` for smoothed seeded modulation across persistent particles and lights.
- Sprite `timeScale` support for smoother looped flipbook particles.

## New In v0.2.0

- `Plume.Serialization` for cloning, saving, and JSON round-tripping effect definitions.
- `Plume.Validator` for warnings, errors, rough cost stats, texture collection, and duration estimates.
- `Manager:Preload(id?)` for validating and preloading registered effect assets.
- Seeded effect variation through `manager:Spawn(id, { seed = ... })` and emitter `:seed(...)`.
- Roblox-native lifecycle events and `spawnFromEvents(...)` for chained, event-driven VFX.
