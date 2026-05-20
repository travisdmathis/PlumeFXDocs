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

- `examples/PlumeDemo/RaidBrigadeShowcase.luau`
- `RaidBrigadeShowcase.PlayMeteorImpact(...)`
- `RaidBrigadeShowcase.PlayTankBuster(...)`

The Raid Brigade showcase helpers are not part of the Creator Store library package. They live only in the optional docs repo demo so the paid model stays free of demo-specific asset dependencies. If you want to use custom meteor or rock models in your own sandbox, provide them through `Workspace.PlumeFXDemoAssets`, `Workspace.RaidBrigadeAssets`, `ReplicatedStorage.PlumeFXDemoAssets`, or `ReplicatedStorage.RaidBrigadeAssets`.
