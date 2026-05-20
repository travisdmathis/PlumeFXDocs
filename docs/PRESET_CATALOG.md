# Preset Catalog

Register all included presets:

```lua
for id, factory in pairs(Plume.Presets.all()) do
	manager:Register(id, factory)
end
```

Included combat and gameplay presets:

- `arcane-starburst`
- `cinematic-fire-plume`
- `impact-explosion`
- `void-dissolve-impact`
- `fireworks-burst`
- `lightning-strike`
- `ground-slam`
- `meteor-impact`
- `ground-rupture`
- `combo-cascade`
- `sword-slash`
- `muzzle-flash`
- `bullet-impact`

Included atmosphere and reward presets:

- `frost-mist`
- `healing-aura`
- `poison-cloud`
- `reward-burst`
- `whirling-tornado`

Included flipbook examples:

- `flipbook-shockwave`
- `flipbook-dissolve-impact`

Optional demo-only showcase:

- `Plume.Examples.RaidBrigadeShowcase.PlayMeteorImpact(...)`
- `Plume.Examples.RaidBrigadeShowcase.PlayTankBuster(...)`

The showcase helpers are packaged under `Plume.Examples`. They do not install an auto-running demo script. If you want to use custom meteor or rock models, provide them from your own place through `Workspace.PlumeFXDemoAssets`, `Workspace.RaidBrigadeAssets`, `ReplicatedStorage.PlumeFXDemoAssets`, or `ReplicatedStorage.RaidBrigadeAssets`.
