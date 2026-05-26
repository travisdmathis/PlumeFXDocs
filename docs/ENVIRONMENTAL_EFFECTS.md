# Persistent Environmental Effects

Use `Plume.Environment` for persistent anchored VFX: candles, torches, braziers, lanterns, magic auras, vents, mist, dust motes, waterfalls, energy fields, portal loops, ambient sparks, and other scene effects that should live on artist-placed anchors.

The environment helper preserves your anchors. It follows the `Attachment` or `BasePart` you pass in, but it does not set the anchor's `Position`, `CFrame`, parent, or name.

## Generic Layered Effect

`Plume.Environment.effect(config)` builds a persistent layered system from sprite/flipbook and light layers:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plume = require(ReplicatedStorage.Plume)

local manager = Plume.Manager.new({
	parent = workspace,
	maxActive = 128,
	overflowPolicy = "recycleOldest",
})

Plume.Environment.registerEffect(manager, "magic-vent", {
	name = "MagicVent",
	flickerGroup = "magic-vent",
	layers = {
		{
			name = "core-swirl",
			texture = "rbxassetid://YOUR_FLIPBOOK_TEXTURE",
			rate = 2.5,
			lifetime = { min = 2.4, max = 3.2 },
			size = { min = 0.7, max = 1.1 },
			color = Color3.fromRGB(105, 190, 255),
			alpha = 0.55,
			flipbook = {
				layout = "Grid4x4",
				mode = "Loop",
				startRandom = false,
				blendFrames = true,
				framerate = { min = 8, max = 12 },
				timeScale = 0.8,
			},
			alphaOverLife = {
				{ 0, 0 },
				{ 0.25, 0.55 },
				{ 1, 0 },
			},
			lightEmission = 0.7,
			flicker = {
				rateWeight = 0.08,
				brightnessWeight = 0.06,
			},
		},
		{
			kind = "light",
			name = "soft-pulse",
			color = Color3.fromRGB(95, 175, 255),
			range = 9,
			brightness = 1.4,
			flicker = {
				brightnessWeight = 0.6,
				rangeWeight = 0.12,
			},
		},
	},
})

local effect = Plume.Environment.attachEffect(manager, ventAttachment, "magic-vent", {
	intensity = 1,
	seed = ventAttachment:GetFullName(),
})
```

Destroy the effect when the prop unloads:

```lua
if effect ~= nil then
	effect:Destroy()
end
```

## Layer Types

Sprite layers are the default. They support:

- `texture`, `textureId`, or shared top-level `texture`.
- `flipbook` settings: `layout`, `mode`, `framerate`, `startRandom`, `blendFrames`, `timeScale`.
- `rate`, `lifetime`, `position`, `velocity`, `size`, `rotation`, `rotSpeed`, `color`, `alpha`, `gravity`, and `drag`.
- `sizeOverLife`, `alphaOverLife`, and `colorOverLife`.
- `orientation`, `lockedToPart`, `lightEmission`, `brightness`, `zOffset`, and `flicker`.

Light layers use `kind = "light"` and support `lightType`, `color`, `range`, `brightness`, `shadows`, `offset`, and `flicker`.

You can also pass a custom layer builder for advanced cases:

```lua
{
	name = "custom-layer",
	builder = function(e)
		return e
			:loop(true)
			:spawnRate(1)
			:lifetime(2)
			:position({ shape = { kind = "point" } })
			:size(1)
			:color(Color3.new(1, 1, 1), { alpha = 1 })
			:renderSprite({ texture = "rbxassetid://YOUR_TEXTURE" })
	end,
}
```

## Flame Convenience

Flames are a convenience use case on top of persistent environmental effects:

```lua
Plume.Environment.registerFlame(manager, "candle-flame", {
	texture = "rbxassetid://100169118546440",
	scale = 1,
})

local flame = Plume.Environment.attachFlame(manager, candleAttachment, "candle-flame", {
	seed = candleAttachment:GetFullName(),
})
```

`registerFlame()` builds a layered flipbook core, soft glow, optional embers, optional smoke, and optional point-light flicker. Use `registerEffect()` when you want a non-flame persistent effect or a fully custom layer stack.

## Flicker Controller

`attachEffect()` and `attachFlame()` start a smoothed flicker controller unless you pass `flicker = false`. For custom Plume systems, tag sprite or light renderers with `render.flicker`, then attach a controller:

```lua
:renderSprite({
	texture = "rbxassetid://YOUR_TEXTURE",
	flicker = {
		group = "lantern",
		role = "core",
		rateWeight = 0.08,
		brightnessWeight = 0.05,
	},
})
```

```lua
local controller = Plume.Runtime.FlickerController.attach(effect, {
	group = "lantern",
	seed = attachment:GetFullName(),
	smoothing = 4.5,
	slowSpeed = 0.72,
	fastSpeed = 2.4,
})
```

The controller uses seeded slow noise plus a tiny faster variation, then eases toward the target pulse every frame. Multiple anchored effects seeded from different anchor names animate independently without harsh snapping.
