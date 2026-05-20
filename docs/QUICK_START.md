# Quick Start

Get PlumeFX on the Roblox Creator Store:

https://create.roblox.com/store/asset/93706653529943/PlumeFX-VFX-Toolkit-Effects-Library

1. Insert the `PlumeFX` model into your place.
2. Move `PlumeFX.Plume` into `ReplicatedStorage`.
3. Keep, archive, or delete the empty `PlumeFX` container after moving the module.
4. Require `ReplicatedStorage.Plume` from your own server or client scripts.

`Plume` contains the lean runtime, authoring APIs, presets, and example modules. The Creator Store model is intentionally library-only so it does not add auto-running demo scripts to production games.

Optional demo: this docs repo includes `examples/PlumeDemo`. Copy that folder into `StarterPlayer > StarterPlayerScripts` in a sandbox place if you want the in-game button panel and showcase tests. Keep production games on the library-only install unless you intentionally want the demo UI.

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

`manager:Preload(id)` validates the registered effect, collects texture/content IDs, and calls `ContentProvider:PreloadAsync()` for those dependencies. Omit `id` to preload every registered effect.

For surface effects, pass a raycast hit position and normal:

```lua
manager:Spawn("bullet-impact", {
	position = result.Position,
	normal = result.Normal,
})
```

## v0.2.0 Library Features

- Use `Plume.Validator.validate(effectDef)` to catch common authoring mistakes before shipping.
- Use `Plume.Serialization.toJSON(effectDef)` and `fromJSON(json)` to save or share authored definitions.
- Use spawn `seed` values for repeatable previews and support repros.
- Use `spawnFromEvents(...)` to build event-driven effects that react to timeline, lifecycle, manual, or gameplay events.
