local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

warn("[PlumeFX Demo] LocalScript starting:", script:GetFullName())

local Plume = require(ReplicatedStorage:WaitForChild("Plume"))

local function applyDemoTextureIds()
	local module = script:FindFirstChild("DemoTextureIds")
	if module == nil then
		warn("[PlumeFX Demo] DemoTextureIds was not found; flipbook examples will use fallback textures.")
		return
	end

	local ok, textureIds = pcall(require, module)
	if not ok then
		warn("[PlumeFX Demo] DemoTextureIds failed to load:", textureIds)
		return
	end

	local flipbooks = textureIds.flipbooks
	if type(flipbooks) ~= "table" then
		return
	end

	Plume.Presets.Textures.flipbooks = Plume.Presets.Textures.flipbooks or {}
	for key, value in pairs(flipbooks) do
		Plume.Presets.Textures.flipbooks[key] = value
	end
end

applyDemoTextureIds()

local function loadRaidBrigadeShowcase()
	local module = script:WaitForChild("RaidBrigadeShowcase", 5)
	if module == nil then
		warn("[PlumeFX Demo] RaidBrigadeShowcase was not found; demo will use generic presets.")
		return nil
	end

	local ok, showcase = pcall(require, module)
	if not ok then
		warn("[PlumeFX Demo] RaidBrigadeShowcase failed to load:", showcase)
		return nil
	end

	return showcase
end

local RaidBrigadeShowcase = loadRaidBrigadeShowcase()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local manager = Plume.Manager.new({
	parent = workspace,
	maxActive = 192,
	overflowPolicy = "recycleOldest",
	globalIntensity = 1,
})

local function isDemoAssetRoot(candidate)
	return candidate ~= nil
		and (
			candidate:FindFirstChild("MeteorModels") ~= nil
			or candidate:FindFirstChild("TankBusterRockModels") ~= nil
		)
end

local function demoAssetRoot()
	local candidates = {}
	local function addCandidate(candidate)
		if candidate ~= nil then
			candidates[#candidates + 1] = candidate
		end
	end

	addCandidate(script:FindFirstChild("RaidBrigadeAssets"))
	if script.Parent ~= nil then
		addCandidate(script.Parent:FindFirstChild("RaidBrigadeAssets"))
	end
	addCandidate(ReplicatedStorage:FindFirstChild("PlumeFXDemoAssets"))
	addCandidate(ReplicatedStorage:FindFirstChild("RaidBrigadeAssets"))
	addCandidate(Workspace:FindFirstChild("PlumeFXDemoAssets"))
	addCandidate(Workspace:FindFirstChild("RaidBrigadeAssets"))

	for _, candidate in ipairs(candidates) do
		if isDemoAssetRoot(candidate) then
			warn("[PlumeFX Demo] Using demo asset root:", candidate:GetFullName())
			return candidate
		end
	end

	return nil
end

for id, factory in pairs(Plume.Presets.all()) do
	manager:Register(id, factory)
end

if RaidBrigadeShowcase ~= nil then
	RaidBrigadeShowcase.Register(manager)
end

manager:RegisterEvent("demo-spawn", function(activeManager, payload)
	payload.priority = payload.priority or 1
	return activeManager:Spawn(payload.id, payload)
end)

local presets = {
	{ id = "arcane-starburst", label = "Arcane Starburst", intensity = 1 },
	{ id = "cinematic-fire-plume", label = "Fire Plume", intensity = 1 },
	{ id = "impact-explosion", label = "Impact Explosion", intensity = 1 },
	{ id = "fireworks-burst", label = "Fireworks Burst", intensity = 1 },
	{ id = "lightning-strike", label = "Lightning Strike", intensity = 1 },
	{ id = "ground-slam", label = "Ground Slam", intensity = 1 },
	{ id = "meteor-impact", label = "Meteor Impact", intensity = 1 },
	{ id = "ground-rupture", label = "Ground Rupture", intensity = 1 },
	{ id = "combo-cascade", label = "Combo Cascade", intensity = 1 },
	{ id = "sword-slash", label = "Sword Slash", intensity = 1.15 },
	{ id = "shoot", label = "Shoot", intensity = 1 },
	{ id = "frost-mist", label = "Frost Mist", intensity = 1 },
	{ id = "healing-aura", label = "Healing Aura", intensity = 1 },
	{ id = "poison-cloud", label = "Poison Cloud", intensity = 1 },
	{ id = "reward-burst", label = "Reward Burst", intensity = 1 },
	{ id = "whirling-tornado", label = "Whirling Tornado", intensity = 1 },
	{ id = "void-dissolve-impact", label = "Void Dissolve Impact", intensity = 1 },
	{ id = "flipbook-shockwave", label = "Flipbook Shockwave", intensity = 1 },
	{ id = "flipbook-dissolve-impact", label = "Flipbook Dissolve", intensity = 1 },
}

local groundPresetIds = {
	["ground-slam"] = true,
	["ground-rupture"] = true,
	["impact-explosion"] = true,
	["meteor-impact"] = true,
	["void-dissolve-impact"] = true,
	["flipbook-shockwave"] = true,
	["flipbook-dissolve-impact"] = true,
}

local keyLabels = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
}

local keyToPresetIndex = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
	[Enum.KeyCode.Zero] = 10,
}

local cycleIndex = 1
local demoGunModel = nil
local demoGunParts = nil
local demoGunMuzzle = nil
local demoGunConnection = nil
local demoGunRecoilUntil = 0
local demoRangeModel = nil
local reticleGui = nil
local shootingMode = false
local savedCameraMode = nil
local savedMouseBehavior = nil
local savedMouseIconEnabled = nil
local presetButtons = {}
local shootingIntensity = 1

local function characterRoot()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function characterCFrame()
	local root = characterRoot()
	if root then
		return root.CFrame * CFrame.new(0, 0, -7)
	end

	return CFrame.new(0, 4, 0)
end

local function cameraAimDirection()
	local camera = Workspace.CurrentCamera
	if camera ~= nil then
		local ray =
			camera:ViewportPointToRay(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
		if ray.Direction.Magnitude > 0 then
			return ray.Direction.Unit
		end
	end

	local root = characterRoot()
	if root ~= nil then
		return root.CFrame.LookVector
	end

	return Vector3.new(0, 0, -1)
end

local function horizontalDirection(direction)
	local flat = Vector3.new(direction.X, 0, direction.Z)
	if flat.Magnitude <= 1e-5 then
		local root = characterRoot()
		return if root ~= nil then root.CFrame.LookVector else Vector3.new(0, 0, -1)
	end

	return flat.Unit
end

local function groundYAt(position)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclusions = {}
	if player.Character ~= nil then
		exclusions[#exclusions + 1] = player.Character
	end
	if demoRangeModel ~= nil then
		exclusions[#exclusions + 1] = demoRangeModel
	end
	if demoGunModel ~= nil then
		exclusions[#exclusions + 1] = demoGunModel
	end
	params.FilterDescendantsInstances = exclusions

	local result =
		Workspace:Raycast(position + Vector3.new(0, 40, 0), Vector3.new(0, -160, 0), params)
	return if result ~= nil then result.Position.Y else 0
end

local function characterGroundCFrame()
	local base = characterCFrame()
	local position = base.Position
	local groundPosition = Vector3.new(position.X, groundYAt(position), position.Z)
	local direction = horizontalDirection(base.LookVector)
	return CFrame.lookAt(groundPosition, groundPosition + direction)
end

local function aimedGroundCFrame()
	local base = characterCFrame()
	local position = base.Position
	local groundPosition = Vector3.new(position.X, groundYAt(position), position.Z)
	local direction = horizontalDirection(cameraAimDirection())
	return CFrame.lookAt(groundPosition, groundPosition + direction)
end

local function placeImpactWall(force)
	if force ~= true and demoRangeModel ~= nil and demoRangeModel.Parent ~= nil then
		return
	end

	local root = characterRoot()
	local direction = horizontalDirection(cameraAimDirection())
	local origin = if root ~= nil then root.Position else Vector3.new(0, 0, 0)
	local wallHeight = 13
	local baseHeight = 0.4
	local centerXZ = origin + direction * 28
	local groundY = groundYAt(centerXZ)
	local center = Vector3.new(centerXZ.X, groundY + baseHeight + wallHeight * 0.5, centerXZ.Z)
	local wallCFrame = CFrame.lookAt(center, center - direction)

	if demoRangeModel == nil or demoRangeModel.Parent == nil then
		demoRangeModel = Instance.new("Model")
		demoRangeModel.Name = "PlumeFXDemoShootingRange"
		demoRangeModel.Parent = workspace

		local wall = Instance.new("Part")
		wall.Name = "ImpactWall"
		wall.Anchored = true
		wall.CanCollide = true
		wall.CanTouch = false
		wall.CanQuery = true
		wall.CastShadow = true
		wall.Material = Enum.Material.Concrete
		wall.Color = Color3.fromRGB(92, 97, 105)
		wall.Size = Vector3.new(24, wallHeight, 1)
		wall.Parent = demoRangeModel
		demoRangeModel.PrimaryPart = wall

		local base = Instance.new("Part")
		base.Name = "RangeBase"
		base.Anchored = true
		base.CanCollide = true
		base.CanTouch = false
		base.CanQuery = true
		base.CastShadow = true
		base.Material = Enum.Material.Asphalt
		base.Color = Color3.fromRGB(38, 42, 48)
		base.Size = Vector3.new(26, 0.4, 10)
		base.Parent = demoRangeModel

		local target = Instance.new("SurfaceGui")
		target.Name = "ImpactTarget"
		target.Face = Enum.NormalId.Front
		target.LightInfluence = 0.35
		target.PixelsPerStud = 90
		target.Parent = wall

		local targetFrame = Instance.new("Frame")
		targetFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		targetFrame.Position = UDim2.fromScale(0.5, 0.5)
		targetFrame.Size = UDim2.fromScale(0.22, 0.38)
		targetFrame.BackgroundTransparency = 1
		targetFrame.Parent = target

		for index = 1, 3 do
			local ring = Instance.new("Frame")
			ring.AnchorPoint = Vector2.new(0.5, 0.5)
			ring.Position = UDim2.fromScale(0.5, 0.5)
			ring.Size = UDim2.fromScale(1 - index * 0.24, 1 - index * 0.24)
			ring.BackgroundTransparency = 1
			ring.Parent = targetFrame

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = ring

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(190, 205, 226)
			stroke.Transparency = 0.28
			stroke.Thickness = 2
			stroke.Parent = ring
		end
	end

	local wall = demoRangeModel:FindFirstChild("ImpactWall")
	if wall ~= nil and wall:IsA("BasePart") then
		wall.CFrame = wallCFrame
	end

	local base = demoRangeModel:FindFirstChild("RangeBase")
	if base ~= nil and base:IsA("BasePart") then
		base.CFrame = wallCFrame * CFrame.new(0, -6.7, -3.6)
	end
end

local function createGunPart(name, size, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = true
	part.Massless = true
	part.Material = material or Enum.Material.Metal
	part.Color = color
	part.Size = size
	part.Parent = demoGunModel
	return part
end

local function gunBaseCFrame()
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return characterCFrame()
	end

	local recoil = 0
	if os.clock() < demoGunRecoilUntil then
		recoil = 0.24
	end

	return camera.CFrame
		* CFrame.new(0.62, -0.56, -1.15 + recoil)
		* CFrame.Angles(math.rad(-2), math.rad(3), math.rad(-1))
end

local function updateDemoGun()
	if demoGunParts == nil then
		return
	end

	local base = gunBaseCFrame()
	demoGunParts.handle.CFrame = base
		* CFrame.new(0, -0.3, 0.26)
		* CFrame.Angles(math.rad(-10), 0, 0)
	demoGunParts.barrel.CFrame = base * CFrame.new(0, 0.05, -0.48)
	demoGunParts.slide.CFrame = base * CFrame.new(0, 0.2, -0.22)
	demoGunParts.triggerGuard.CFrame = base * CFrame.new(0, -0.14, -0.18)
	demoGunParts.sight.CFrame = base * CFrame.new(0, 0.42, -0.33)
end

local function ensureDemoGun()
	if demoGunModel ~= nil and demoGunModel.Parent ~= nil then
		return demoGunMuzzle
	end

	demoGunModel = Instance.new("Model")
	demoGunModel.Name = "PlumeFXFirstPersonBlaster"
	demoGunModel.Parent = Workspace

	demoGunParts = {
		barrel = createGunPart(
			"Barrel",
			Vector3.new(0.2, 0.2, 1.18),
			Color3.fromRGB(24, 27, 32),
			Enum.Material.Metal
		),
		slide = createGunPart(
			"Slide",
			Vector3.new(0.36, 0.24, 0.82),
			Color3.fromRGB(54, 61, 72),
			Enum.Material.Metal
		),
		handle = createGunPart(
			"Handle",
			Vector3.new(0.3, 0.78, 0.34),
			Color3.fromRGB(20, 22, 27),
			Enum.Material.SmoothPlastic
		),
		triggerGuard = createGunPart(
			"TriggerGuard",
			Vector3.new(0.08, 0.28, 0.34),
			Color3.fromRGB(35, 39, 48),
			Enum.Material.Metal
		),
		sight = createGunPart(
			"Sight",
			Vector3.new(0.12, 0.08, 0.26),
			Color3.fromRGB(12, 14, 18),
			Enum.Material.Metal
		),
	}
	demoGunModel.PrimaryPart = demoGunParts.barrel

	demoGunMuzzle = Instance.new("Attachment")
	demoGunMuzzle.Name = "Muzzle"
	demoGunMuzzle.Position = Vector3.new(0, 0, -0.66)
	demoGunMuzzle.Parent = demoGunParts.barrel

	updateDemoGun()

	if demoGunConnection ~= nil then
		demoGunConnection:Disconnect()
	end

	demoGunConnection = RunService.RenderStepped:Connect(updateDemoGun)
	return demoGunMuzzle
end

local function destroyDemoGun()
	if demoGunConnection ~= nil then
		demoGunConnection:Disconnect()
		demoGunConnection = nil
	end

	if demoGunModel ~= nil then
		demoGunModel:Destroy()
	end

	demoGunModel = nil
	demoGunParts = nil
	demoGunMuzzle = nil
end

local function ensureReticle()
	if reticleGui ~= nil and reticleGui.Parent ~= nil then
		return reticleGui
	end

	reticleGui = Instance.new("ScreenGui")
	reticleGui.Name = "PlumeFXReticleGui"
	reticleGui.IgnoreGuiInset = true
	reticleGui.ResetOnSpawn = false
	reticleGui.DisplayOrder = 500
	reticleGui.Parent = playerGui

	local holder = Instance.new("Frame")
	holder.Name = "Reticle"
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.Position = UDim2.fromScale(0.5, 0.5)
	holder.Size = UDim2.fromOffset(42, 42)
	holder.BackgroundTransparency = 1
	holder.Parent = reticleGui

	local function line(name, position, size)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = position
		frame.Size = size
		frame.BackgroundColor3 = Color3.fromRGB(245, 252, 255)
		frame.BackgroundTransparency = 0.08
		frame.BorderSizePixel = 0
		frame.Parent = holder

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(22, 30, 38)
		stroke.Transparency = 0.25
		stroke.Thickness = 1
		stroke.Parent = frame
	end

	line("Top", UDim2.fromScale(0.5, 0.18), UDim2.fromOffset(2, 10))
	line("Bottom", UDim2.fromScale(0.5, 0.82), UDim2.fromOffset(2, 10))
	line("Left", UDim2.fromScale(0.18, 0.5), UDim2.fromOffset(10, 2))
	line("Right", UDim2.fromScale(0.82, 0.5), UDim2.fromOffset(10, 2))

	local dot = Instance.new("Frame")
	dot.Name = "Dot"
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.fromScale(0.5, 0.5)
	dot.Size = UDim2.fromOffset(4, 4)
	dot.BackgroundColor3 = Color3.fromRGB(255, 217, 92)
	dot.BorderSizePixel = 0
	dot.Parent = holder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = dot

	return reticleGui
end

local function updateShootButtonLabel()
	local button = presetButtons.shoot
	if button ~= nil then
		button.Text = if shootingMode then "9. Exit Shooting" else "9. Shoot"
	end
end

local function enterShootingMode(intensity)
	if shootingMode then
		shootingIntensity = intensity or shootingIntensity
		return
	end

	shootingMode = true
	shootingIntensity = intensity or 1
	savedCameraMode = player.CameraMode
	savedMouseBehavior = UserInputService.MouseBehavior
	savedMouseIconEnabled = UserInputService.MouseIconEnabled

	player.CameraMode = Enum.CameraMode.LockFirstPerson
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false

	ensureReticle()
	ensureDemoGun()
	placeImpactWall(true)
	updateShootButtonLabel()
end

local function exitShootingMode()
	if not shootingMode then
		return
	end

	shootingMode = false
	player.CameraMode = savedCameraMode or Enum.CameraMode.Classic
	UserInputService.MouseBehavior = savedMouseBehavior or Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = if savedMouseIconEnabled == nil
		then true
		else savedMouseIconEnabled

	if reticleGui ~= nil then
		reticleGui:Destroy()
		reticleGui = nil
	end

	destroyDemoGun()
	updateShootButtonLabel()
end

local function toggleShootingMode(intensity)
	if shootingMode then
		exitShootingMode()
	else
		enterShootingMode(intensity)
	end
end

local function makeAnchor(cframe)
	local anchor = Instance.new("Part")
	anchor.Name = "PlumeSlashDemoAnchor"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.CastShadow = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.15, 0.15, 0.15)
	anchor.CFrame = cframe
	anchor.Parent = workspace
	return anchor
end

local function spawnSlash(preset)
	local base = characterCFrame() * CFrame.new(0, 1.5, 0)
	local anchor = makeAnchor(base * CFrame.new(-2.1, 0.3, 0.4) * CFrame.Angles(0, 0, math.rad(22)))

	manager:Spawn(preset.id, {
		parent = anchor,
		follow = anchor,
		intensity = preset.intensity,
	})

	local tween = TweenService:Create(
		anchor,
		TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			CFrame = base
				* CFrame.new(2.1, -0.35, -0.9)
				* CFrame.Angles(0, math.rad(18), math.rad(-32)),
		}
	)

	tween:Play()
	task.delay(0.85, function()
		if anchor.Parent ~= nil then
			anchor:Destroy()
		end
	end)
end

local function shootRaycastParams()
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclusions = {}
	if player.Character ~= nil then
		exclusions[#exclusions + 1] = player.Character
	end
	if demoGunModel ~= nil then
		exclusions[#exclusions + 1] = demoGunModel
	end
	params.FilterDescendantsInstances = exclusions
	return params
end

local function cameraAimPoint(params)
	local camera = Workspace.CurrentCamera
	if camera == nil then
		local root = characterRoot()
		if root ~= nil then
			return root.Position + Vector3.new(0, 1.6, 0) + root.CFrame.LookVector * 140
		end

		return Vector3.new(0, 4, -140)
	end

	local ray = camera:ViewportPointToRay(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
	local result = Workspace:Raycast(ray.Origin, ray.Direction * 180, params)
	if result ~= nil then
		return result.Position
	end

	placeImpactWall(true)
	result = Workspace:Raycast(ray.Origin, ray.Direction * 180, params)
	return if result ~= nil then result.Position else ray.Origin + ray.Direction * 180
end

local function shootRaycast(muzzlePosition)
	placeImpactWall(false)

	local params = shootRaycastParams()
	local aimPoint = cameraAimPoint(params)
	local direction = aimPoint - muzzlePosition
	if direction.Magnitude <= 1e-5 then
		direction = cameraAimDirection() * 140
	end

	local result = Workspace:Raycast(muzzlePosition, direction.Unit * 180, params)
	if result ~= nil then
		return result
	end

	placeImpactWall(true)
	aimPoint = cameraAimPoint(params)
	direction = aimPoint - muzzlePosition
	if direction.Magnitude <= 1e-5 then
		direction = cameraAimDirection() * 140
	end

	return Workspace:Raycast(muzzlePosition, direction.Unit * 180, params)
end

local function spawnProjectile(startPosition, hitPosition, hitNormal, intensity)
	local delta = hitPosition - startPosition
	local distance = delta.Magnitude
	if distance <= 1e-5 then
		manager:Spawn("bullet-impact", {
			position = hitPosition,
			normal = hitNormal,
			intensity = intensity,
			priority = 2,
		})
		return
	end

	local direction = delta.Unit
	local bullet = Instance.new("Part")
	bullet.Name = "PlumeFXDemoBullet"
	bullet.Anchored = true
	bullet.CanCollide = false
	bullet.CanTouch = false
	bullet.CanQuery = false
	bullet.CastShadow = false
	bullet.Material = Enum.Material.Neon
	bullet.Color = Color3.fromRGB(255, 205, 92)
	bullet.Shape = Enum.PartType.Block
	bullet.Size = Vector3.new(0.035, 0.035, 0.18)
	bullet.CFrame = CFrame.lookAt(startPosition, startPosition + direction)
	bullet.Parent = workspace

	local trailFront = Instance.new("Attachment")
	trailFront.Position = Vector3.new(0, 0, -0.09)
	trailFront.Parent = bullet

	local trailBack = Instance.new("Attachment")
	trailBack.Position = Vector3.new(0, 0, 0.12)
	trailBack.Parent = bullet

	local trail = Instance.new("Trail")
	trail.Name = "BulletTrail"
	trail.Attachment0 = trailFront
	trail.Attachment1 = trailBack
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 32)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.LightEmission = 1
	trail.Lifetime = 0.065
	trail.MinLength = 0
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.22),
		NumberSequenceKeypoint.new(1, 0),
	})
	trail.Parent = bullet

	local travelTime = math.clamp(distance / 320, 0.035, 0.11)
	local tween = TweenService:Create(
		bullet,
		TweenInfo.new(travelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			CFrame = CFrame.lookAt(hitPosition, hitPosition + direction),
		}
	)

	tween.Completed:Connect(function()
		if bullet.Parent ~= nil then
			bullet:Destroy()
		end

		manager:Spawn("bullet-impact", {
			position = hitPosition,
			normal = hitNormal,
			intensity = intensity,
			priority = 2,
		})
	end)

	tween:Play()
end

local function fireShot(intensity)
	if not shootingMode then
		return
	end

	local muzzle = ensureDemoGun()
	local camera = Workspace.CurrentCamera
	local fallbackPosition = if camera ~= nil
		then (camera.CFrame * CFrame.new(0.62, -0.56, -1.82)).Position
		else characterCFrame().Position
	local muzzlePosition = if muzzle ~= nil then muzzle.WorldPosition else fallbackPosition
	local result = shootRaycast(muzzlePosition)

	demoGunRecoilUntil = os.clock() + 0.08
	local hitPosition = if result ~= nil
		then result.Position
		else muzzlePosition + cameraAimDirection() * 34
	local shotCFrame = CFrame.lookAt(muzzlePosition, hitPosition)

	manager:Spawn("muzzle-flash", {
		cframe = shotCFrame,
		intensity = intensity or shootingIntensity,
		priority = 4,
	})

	if result ~= nil then
		spawnProjectile(
			muzzlePosition,
			result.Position,
			result.Normal,
			intensity or shootingIntensity
		)
	else
		local direction = cameraAimDirection()
		spawnProjectile(
			muzzlePosition,
			muzzlePosition + direction * 34,
			-direction,
			intensity or shootingIntensity
		)
	end
end

local function spawnShoot(preset)
	toggleShootingMode(preset.intensity)
end

local function spawnPreset(index)
	local preset = presets[index]
	if preset == nil then
		return
	end

	if preset.id == "sword-slash" then
		spawnSlash(preset)
		return
	end

	if preset.id == "shoot" then
		spawnShoot(preset)
		return
	end

	if preset.id == "meteor-impact" then
		if RaidBrigadeShowcase ~= nil then
			local assetRoot = demoAssetRoot()
			RaidBrigadeShowcase.PlayMeteorImpact(manager, characterGroundCFrame(), {
				intensity = preset.intensity,
				parent = workspace,
				priority = 4,
				assetRoot = assetRoot,
			})
			return
		end
		warn("[PlumeFX Demo] RaidBrigadeShowcase unavailable; meteor uses generic preset.")
	end

	if preset.id == "ground-rupture" then
		if RaidBrigadeShowcase ~= nil then
			local assetRoot = demoAssetRoot()
			RaidBrigadeShowcase.PlayTankBuster(manager, aimedGroundCFrame(), {
				intensity = preset.intensity,
				parent = workspace,
				priority = 4,
				assetRoot = assetRoot,
			})
			return
		end
		warn("[PlumeFX Demo] RaidBrigadeShowcase unavailable; ground rupture uses generic preset.")
	end

	manager:Trigger("demo-spawn", {
		id = preset.id,
		cframe = if groundPresetIds[preset.id] then characterGroundCFrame() else characterCFrame(),
		intensity = preset.intensity,
	})
end

local function spawnNext()
	spawnPreset(cycleIndex)
	cycleIndex = (cycleIndex % #presets) + 1
end

local function createButton(parent, text, order, callback)
	local button = Instance.new("TextButton")
	button.Name = text:gsub("%W", "")
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 34)
	button.AutoButtonColor = true
	button.BackgroundColor3 = Color3.fromRGB(31, 37, 48)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamMedium
	button.Text = text
	button.TextColor3 = Color3.fromRGB(242, 246, 255)
	button.TextSize = 13
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = parent

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = button

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	button.MouseButton1Click:Connect(callback)

	return button
end

local function createDemoUi()
	local existing = playerGui:FindFirstChild("PlumeDemoGui")
	if existing ~= nil then
		existing:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "PlumeDemoGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(1, 0.5)
	panel.Position = UDim2.new(1, -18, 0.5, 18)
	panel.Size = UDim2.new(0, 260, 0.72, 0)
	panel.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
	panel.BackgroundTransparency = 0.08
	panel.BorderSizePixel = 0
	panel.Parent = gui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 8)
	panelCorner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(72, 87, 115)
	stroke.Transparency = 0.35
	stroke.Thickness = 1
	stroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(14, 14)
	title.Size = UDim2.new(1, -28, 0, 24)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "PlumeFX Test Panel"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local hint = Instance.new("TextLabel")
	hint.Name = "Hint"
	hint.Position = UDim2.fromOffset(14, 42)
	hint.Size = UDim2.new(1, -28, 0, 36)
	hint.BackgroundTransparency = 1
	hint.Font = Enum.Font.Gotham
	hint.Text = "Click a preset, press 9 for shooting mode, click to fire, Esc exits, C clears."
	hint.TextColor3 = Color3.fromRGB(174, 185, 205)
	hint.TextSize = 12
	hint.TextWrapped = true
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.TextYAlignment = Enum.TextYAlignment.Top
	hint.Parent = panel

	local list = Instance.new("ScrollingFrame")
	list.Name = "PresetList"
	list.Position = UDim2.fromOffset(14, 86)
	list.Size = UDim2.new(1, -28, 1, -166)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 5
	list.ScrollBarImageColor3 = Color3.fromRGB(120, 142, 184)
	list.Parent = panel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = list

	for index, preset in ipairs(presets) do
		local keyLabel = keyLabels[index] or "-"
		local button = createButton(list, `{keyLabel}. {preset.label}`, index, function()
			spawnPreset(index)
		end)
		presetButtons[preset.id] = button
	end
	updateShootButtonLabel()

	local footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.Position = UDim2.new(0, 14, 1, -68)
	footer.Size = UDim2.new(1, -28, 0, 54)
	footer.BackgroundTransparency = 1
	footer.Parent = panel

	local footerLayout = Instance.new("UIListLayout")
	footerLayout.FillDirection = Enum.FillDirection.Horizontal
	footerLayout.Padding = UDim.new(0, 8)
	footerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	footerLayout.Parent = footer

	local cycleButton = createButton(footer, "V. Cycle", 1, spawnNext)
	cycleButton.Size = UDim2.new(0.5, -4, 1, 0)
	cycleButton.BackgroundColor3 = Color3.fromRGB(42, 54, 77)

	local clearButton = createButton(footer, "C. Clear", 2, function()
		manager:Clear()
	end)
	clearButton.Size = UDim2.new(0.5, -4, 1, 0)
	clearButton.BackgroundColor3 = Color3.fromRGB(77, 42, 48)
end

local started, startupError = xpcall(function()
	placeImpactWall(true)
	createDemoUi()
	warn("[PlumeFX Demo] UI created in:", playerGui:GetFullName())
	task.delay(0.75, spawnNext)
end, debug.traceback)

if not started then
	warn("[PlumeFX Demo] startup failed:", startupError)
end

player.CharacterAdded:Connect(function()
	task.delay(0.5, function()
		placeImpactWall(true)
		if shootingMode then
			ensureDemoGun()
		end
	end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if shootingMode and input.KeyCode == Enum.KeyCode.Escape then
		exitShootingMode()
		return
	end

	if shootingMode and input.UserInputType == Enum.UserInputType.MouseButton1 then
		fireShot(shootingIntensity)
		return
	end

	if gameProcessed then
		return
	end

	local presetIndex = keyToPresetIndex[input.KeyCode]
	if presetIndex ~= nil then
		spawnPreset(presetIndex)
	elseif input.KeyCode == Enum.KeyCode.V then
		spawnNext()
	elseif input.KeyCode == Enum.KeyCode.C then
		manager:Clear()
	end
end)
