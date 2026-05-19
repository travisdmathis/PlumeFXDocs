# PlumeFX Documentation

Public documentation for **PlumeFX VFX Toolkit & Effects Library**, a Roblox-native VFX toolkit with a chainable Luau authoring API, runtime manager, event triggers, attachment/socket spawning, mesh debris, texture-first surface decals, optional procedural impact details, flipbook particles, beams, trails, lights, part beams, and polished starter effects.

Get PlumeFX on the Roblox Creator Store:

https://create.roblox.com/store/asset/93706653529943/PlumeFX-VFX-Toolkit-Effects-Library

Current documented package version: `0.1.6`.

## Start Here

- [Quick Start](docs/QUICK_START.md)
- [Authoring API](docs/AUTHORING_API.md)
- [Customizing Presets](docs/CUSTOMIZING_PRESETS.md)
- [Preset Catalog](docs/PRESET_CATALOG.md)
- [Events And Triggers](docs/EVENTS_AND_TRIGGERS.md)
- [Flipbook Textures](docs/FLIPBOOK_TEXTURES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Release Notes](docs/RELEASE_NOTES.md)
- [Changelog](CHANGELOG.md)

## What This Repo Contains

This repository contains public documentation and supporting flipbook preview images only.

It does not include the paid Roblox model, runtime source package, internal launch notes, moderation notes, release zips, or build artifacts.

## Install Summary

1. Insert the `PlumeFX` model from the Roblox Creator Store.
2. Move `PlumeFX.Plume` into `ReplicatedStorage`.
3. Optional: move `PlumeFX.PlumeDemo` into `StarterPlayer > StarterPlayerScripts`.
4. Keep, archive, or delete the empty `PlumeFX` container after moving the modules.
5. Require `ReplicatedStorage.Plume` and register/spawn presets from your own scripts.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plume = require(ReplicatedStorage.Plume)

local manager = Plume.Manager.new({
	parent = workspace,
	maxActive = 128,
	overflowPolicy = "recycleOldest",
})

manager:Register("impact-explosion", Plume.Presets.Combat.impactExplosion)

manager:Spawn("impact-explosion", {
	position = Vector3.new(0, 4, 0),
	intensity = 1,
})
```
