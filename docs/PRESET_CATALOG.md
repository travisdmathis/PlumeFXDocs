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
