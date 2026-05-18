# Quick Start

Get PlumeFX on the Roblox Creator Store:

https://create.roblox.com/store/asset/93706653529943/PlumeFX-VFX-Toolkit-Effects-Library

1. Insert the `PlumeFX` model into your place.
2. Move `PlumeFX.Plume` into `ReplicatedStorage`.
3. Optional: move `PlumeFX.PlumeDemo` into `StarterPlayer > StarterPlayerScripts`.
4. Keep, archive, or delete the empty `PlumeFX` container after moving the modules.
5. Press Play to test the demo panel.

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

For surface effects, pass a raycast hit position and normal:

```lua
manager:Spawn("bullet-impact", {
	position = result.Position,
	normal = result.Normal,
})
```
