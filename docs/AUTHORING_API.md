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
