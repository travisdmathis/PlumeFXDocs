# Examples

These files are optional helper examples for buyers who want to test PlumeFX in a blank place after installing the Creator Store model.

The Creator Store model is intentionally library-only. It includes `Plume`, but it does not include an auto-running demo script. This keeps production installs clean and avoids adding UI, camera controls, or showcase objects unless you choose to add them.

## PlumeDemo

`examples/PlumeDemo` contains the local test panel used for PlumeFX videos and QA.

To use it:

1. Install the `PlumeFX` model from Creator Store.
2. Move `PlumeFX.Plume` into `ReplicatedStorage`.
3. Copy `examples/PlumeDemo` into `StarterPlayer > StarterPlayerScripts`.
4. Press Play.

The demo registers the included presets, shows a scrollable button panel, supports number-key shortcuts, includes Candle Flame and Magic Vent persistent environment buttons, and includes the first-person shooting test for muzzle flash, projectile travel, bullet impacts, decals, sparks, smoke, and mesh debris.

`RaidBrigadeShowcase.luau` and the bundled `RaidBrigadeAssets.rbxm` file are only for the optional Meteor Impact and Ground Rupture showcase buttons. They are not part of the Creator Store library package, and you do not need them in production games.
