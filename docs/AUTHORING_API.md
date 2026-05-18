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

Good effects are usually layered: flash, main particles, directional streaks, smoke/dust, debris, decals, and light.
