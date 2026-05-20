# Customizing Presets

The fastest way to build your own VFX is to duplicate a preset, rename it, then adjust the layers.

Good starting points:

- Impact or explosion: `Presets.Combat.impactExplosion`
- Bullet hit: `Presets.Combat.bulletImpact`
- Magic burst: `Presets.Combat.arcaneStarburst`
- Weapon effect: `Presets.Combat.swordSlash` or `Presets.Combat.muzzleFlash`
- Tornado or wind: `Presets.Atmosphere.whirlingTornado`
- Aura or looping buff: `Presets.Atmosphere.healingAura`
- Flipbook effect: `Examples.FlipbookShowcase.shockwave`

Recommended workflow:

1. Create a ModuleScript for your game's effects, for example `ReplicatedStorage.GameVFX`.
2. Require `Plume`.
3. Create one function per effect.
4. Register those functions with a manager when your game starts.
5. Spawn by ID from combat, abilities, projectiles, UI rewards, or world events.
6. Validate and preload the effects you use in the current map, weapon, boss, or ability set.

Change these first:

- Colors
- Burst counts
- Particle lifetimes
- Velocity shape and speed
- Size ranges
- Alpha and size curves
- Renderer type
- Texture or flipbook ID

Most polished effects use several small layers instead of one giant emitter.

## Validate And Preload

Use the v0.2.0 validation and preload APIs after customizing a preset:

```lua
local customImpact = Plume.Presets.Combat.impactExplosion()

local validation = Plume.Validator.validate(customImpact)
if not validation.ok then
	warn(validation.errors)
end

manager:Register("custom-impact", customImpact)
manager:Preload("custom-impact")
```

## Save Or Share Definitions

Serialization lets you clone presets safely or round-trip definitions through JSON-friendly data:

```lua
local clone = Plume.Serialization.clone(customImpact)
local json = Plume.Serialization.toJSON(customImpact)
local restored = Plume.Serialization.fromJSON(json)
```

## Repeatable Variations

Pass a seed when you need deterministic preview captures, support repros, or repeatable gameplay moments:

```lua
manager:Spawn("custom-impact", {
	position = hit.Position,
	seed = 202402,
})
```
