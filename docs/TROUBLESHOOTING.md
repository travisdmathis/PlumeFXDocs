# Troubleshooting

## Nothing Runs

Make sure `Plume` is in `ReplicatedStorage`.

The Creator Store model is library-only and does not install an auto-running demo panel. To test effects in your own place, require `ReplicatedStorage.Plume`, register a preset, and call `manager:Spawn(...)` from a server or client script.

## Spawn Stops Working When Spamming

Use a manager with recycling:

```lua
local manager = Plume.Manager.new({
	parent = workspace,
	maxActive = 128,
	overflowPolicy = "recycleOldest",
})
```

You can also clear active effects:

```lua
manager:Clear()
```

## Surface Impact Points The Wrong Way

Pass both `position` and `normal` from the raycast result.

## Flipbook Is White, Static, Or Missing

Check that:

- The texture value starts with `rbxassetid://`.
- The image asset is approved by Roblox moderation.
- The flipbook layout matches the sheet, such as `Grid4x4`.
- The image was uploaded as an image asset, not as a model.
- The ID is pasted into `Plume.Presets.Textures.flipbooks`.

## Cleanup

Finite PlumeFX effects clean up after their lifecycle ends. Persistent or looping effects should be manually destroyed when gameplay ends them.
