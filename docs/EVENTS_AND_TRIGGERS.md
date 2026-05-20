# Events And Triggers

PlumeFX supports Roblox-native event composition. This is not GPU particle death events like Three.js Plume; Roblox native particles do not expose per-particle death callbacks. Instead, PlumeFX gives developers the gameplay-friendly version:

- Timeline events
- Lifecycle events
- Event-driven listener emitters
- Sub-effect chains
- Manual trigger hooks
- Gameplay event routing
- Attachment/socket spawning

## Timeline Events

Add named events to a system:

```lua
local effectDef = Plume.system("Combo")
	:duration(2)
	:event(0.2, "impact")
	:event(0.8, "finish", {
		offset = Vector3.new(0, 2, 0),
	})
	:emitter("seed", function(e)
		return e
			:spawnBurst({ time = 0, count = 30 })
			:lifetime(0.6)
			:position({ shape = { kind = "sphere", radius = 0.1 } })
			:velocity({ shape = { kind = "sphere" }, speed = { min = 4, max = 12 } })
			:size(0.12)
			:color(Color3.new(0.4, 0.8, 1), { alpha = 1 })
			:renderSprite({ blending = "additive" })
	end)
	:build()
```

Listen to them at runtime:

```lua
local effect = manager:Spawn("combo")

effect:On("impact", function(payload, instance)
	print("Impact event fired", payload, instance)
end)
```

## Lifecycle Events

PlumeFX emits Roblox-native lifecycle events that can drive listeners and sub-effects:

- `onStart`
- `onBurst`
- `onEmitterStart`
- `onEmitterEnd`
- `onEffectEnd`

Emitter lifecycle events include payload fields such as `emitter`, `renderer`, and `count` where applicable.

```lua
local effect = manager:Spawn("impact")

effect:On("onBurst", function(payload)
	print(payload.emitter, payload.count)
end)
```

Namespaced emitter events are also fired as `{emitterName}.{eventName}`, such as `sparks.onBurst`, when the emitter has a name.

## Spawn From Events

Emitter definitions can listen to timeline, lifecycle, manual, or gameplay events and emit only when the event fires.

```lua
local meteor = Plume.system("MeteorImpact")
	:duration(2.4)
	:event(0.9, "impact")
	:emitter("meteor_core", function(e)
		return e
			:duration(0.9)
			:emitEvents()
			:spawnRate(80)
			:lifetime(0.35)
			:position({
				shape = { kind = "sphere", radius = 0.08 },
				offset = Vector3.new(0, 8, -3),
				moveTo = Vector3.new(0, 0.3, 0),
				travelTime = 0.9,
			})
			:size(0.3)
			:color(Color3.new(1, 0.45, 0.15), { alpha = 1 })
			:renderSprite({ blending = "additive" })
	end)
	:emitter("impact_sparks", function(e)
		return e
			:spawnFromEvents({ event = "impact", count = 40 })
			:lifetime({ min = 0.2, max = 0.5 })
			:position({ shape = { kind = "sphere", radius = 0.2 } })
			:velocity({ shape = { kind = "sphere" }, speed = { min = 8, max = 24 } })
			:size(0.12)
			:color(Color3.new(1, 0.7, 0.25), { alpha = 1 })
			:renderSprite({ blending = "additive" })
	end)
	:build()
```

Shortcut form listens to another emitter's lifecycle event:

```lua
:spawnFromEvents("meteor_core", 12)
```

That defaults to `meteor_core.onBurst`. To listen to a different source lifecycle event:

```lua
:spawnFromEvents({
	source = "meteor_core",
	sourceEvent = "onEmitterEnd",
	count = 20,
})
```

This is Roblox-native event spawning. It is not Three.js Plume's GPU per-particle death event buffer, because Roblox does not expose particle death callbacks.

## Sub-Effect Chains

Spawn another registered PlumeFX preset when a time or trigger fires:

```lua
local combo = Plume.system("ComboCascade")
	:duration(2.2)
	:event(0.22, "impact")
	:event(0.75, "celebrate", {
		offset = Vector3.new(0, 2.2, 0),
	})
	:subEffect("impact-explosion", {
		trigger = "impact",
		intensity = 0.75,
	})
	:subEffect("reward-burst", {
		trigger = "celebrate",
	})
	:emitter("seed", function(e)
		return e
			:spawnBurst({ time = 0, count = 28 })
			:lifetime(0.6)
			:position({ shape = { kind = "sphere", radius = 0.12 } })
			:velocity({ shape = { kind = "sphere" }, speed = { min = 5, max = 13 } })
			:size(0.14)
			:color(Color3.new(0.45, 0.85, 1), { alpha = 1 })
			:renderSprite({ blending = "additive" })
	end)
	:build()
```

Sub-effects can also spawn on a timestamp:

```lua
:subEffect("fireworks-burst", {
	time = 0.4,
	offset = Vector3.new(0, 5, 0),
	intensity = 0.8,
})
```

## Manual Trigger Hooks

Manual hooks are useful for gameplay, animation markers, hit confirms, ability charge states, and custom code.

```lua
local effect = manager:Spawn("combo-cascade", {
	position = character.HumanoidRootPart.Position,
})

effect:On("detonate", function(payload)
	print(payload.damage)
end)

effect:Trigger("detonate", {
	damage = 50,
	offset = Vector3.new(0, 1, 0),
})
```

Use `Once` for one-shot listeners:

```lua
effect:Once("impact", function()
	print("Only runs once")
end)
```

Wildcard listeners receive every event:

```lua
effect:On("*", function(payload, instance, eventName)
	print(eventName, payload)
end)
```

## Gameplay Events

Managers can map gameplay event names to PlumeFX presets:

```lua
manager:RegisterEvent("projectile-hit", "impact-explosion", {
	intensity = 1,
})

manager:Trigger("projectile-hit", {
	position = hit.Position,
})
```

Events can also be custom handlers:

```lua
manager:RegisterEvent("critical-hit", function(manager, payload)
	manager:Spawn("impact-explosion", payload)
	return manager:Spawn("reward-burst", {
		position = payload.position,
		offset = Vector3.new(0, 2, 0),
	})
end)
```

## Attachment And Socket Spawning

Spawn directly at an attachment:

```lua
manager:SpawnAt("muzzle-flash", weapon.MuzzleAttachment)
```

Spawn at a named attachment under a model or part:

```lua
manager:SpawnOn("muzzle-flash", weaponModel, "Muzzle")
```

The same is available through spawn options:

```lua
manager:Spawn("sword-slash", {
	parent = character,
	socket = "SwordTip",
	followSocket = true,
})
```

For static impact placement, use `position` or `cframe`:

```lua
manager:Spawn("ground-slam", {
	position = hit.Position,
})
```

For moving effects, use `follow`:

```lua
manager:Spawn("healing-aura", {
	parent = character.HumanoidRootPart,
	follow = true,
})
```
