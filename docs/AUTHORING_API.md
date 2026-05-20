# Authoring API

PlumeFX effects are built from systems. A system contains one or more emitters, trails, timeline events, and sub-effects.

Common builder methods:

- `Plume.system(name)`
- `:duration(seconds)`
- `:emitter(name, callback)`
- `:trail(name, callback)`
- `:event(time, name, payload)`
- `:subEffect(id, config)`
- `:build()`

Common emitter methods:

- `:spawnBurst({ time = 0, count = 40 })`
- `:spawnRate(rate)`
- `:spawnFromEvents(sourceOrConfig, perEvent, maxEventsPerFrame)`
- `:seed(numberOrString)`
- `:emitEvents(config)`
- `:lifetime(secondsOrRange)`
- `:position({ shape = ... })`
- `:velocity({ shape = ..., speed = ... })`
- `:size(numberOrRange)`
- `:rotation(range, options)`
- `:color(color, { alpha = number })`
- `:gravity(vector)`
- `:drag(number)`
- `:sizeOverLife(curve)`
- `:alphaOverLife(curve)`
- `:colorOverLife(gradient)`

Supported renderer methods:

- `:renderSprite()`
- `:renderBeam()`
- `:renderRibbon()`
- `:renderPartBeam()`
- `:renderSpiralRibbon()`
- `:renderMesh()`
- `:renderDecal()`
- `:renderLight()`

`renderDecal()` is texture-first. By default it places the supplied texture on the target surface and does not add built-in scorch, ring, core, or crack artwork over it.

```lua
:renderDecal({
	texture = "rbxassetid://00000000000000",
	textureScale = 1,
	textureTransparency = 0.08,
	textureRotationJitter = { min = -12, max = 12 },
})
```

Procedural decal details are opt-in:

```lua
:renderDecal({
	texture = "rbxassetid://00000000000000",
	procedural = true,
	physical = true,
	cracks = 6,
})
```

Good effects are usually layered: flash, main particles, directional streaks, smoke/dust, debris, decals, and light.

## Validation

Validate custom definitions before shipping:

```lua
local report = Plume.Validator.validate(effectDef)
if not report.ok then
	warn(report.errors)
end

print(report.stats.emitterCount, report.stats.textureCount, report.stats.duration)
```

The validator reports missing renderers, unsupported or partial modules, large bursts, high spawn rates, texture dependencies, and estimated duration.

## Preload

After registering effects, preload one effect or all effects:

```lua
manager:Register("impact", effectDef)

local report = manager:Preload("impact")
-- manager:Preload() preloads every registered effect.
```

`Preload` validates effects, collects texture/content IDs, calls `ContentProvider:PreloadAsync()`, and returns a report with `ok`, `assets`, `warnings`, `errors`, and per-prefab validation reports.

## Serialization

PlumeFX definitions can be cloned or converted to JSON-friendly data:

```lua
local tableData = Plume.Serialization.toTable(effectDef)
local copy = Plume.Serialization.clone(effectDef)
local json = Plume.Serialization.toJSON(effectDef)
local restored = Plume.Serialization.fromJSON(json)
```

Serialization supports common Roblox datatypes used in PlumeFX definitions, including `Vector2`, `Vector3`, `Color3`, `CFrame`, `NumberRange`, `NumberSequence`, `ColorSequence`, and `EnumItem`.

## Seeded Variation

Use a seed for repeatable effect variation:

```lua
manager:Spawn("impact", {
	position = hit.Position,
	seed = 9876,
})
```

Emitter-level `:seed(...)` and spawn-level `seed` drive runtime randomization for mesh debris, decals, shape sampling, and other custom-rendered variations.
