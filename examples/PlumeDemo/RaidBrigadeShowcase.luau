local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Builder = require(ReplicatedStorage:WaitForChild("Plume"):WaitForChild("Builder"))

local RaidBrigadeShowcase = {}

local RAID_BRIGADE_FLIPBOOKS = {
	moltenRune = "rbxassetid://111715885030423",
	moltenShockwave = "rbxassetid://103362459859088",
	moltenArc = "rbxassetid://114407872682053",
	moltenSlash = "rbxassetid://73287834800372",
}

local METEOR_STRIKE_DECAL_TEXTURES = {
	"rbxassetid://108192501357466",
	"rbxassetid://134935139452360",
	"rbxassetid://91416267955782",
}

local RAID_BRIGADE_MESH_ASSETS = {
	-- Fallback mesh IDs used only when the copied demo MeshParts are unavailable.
	meteors = {
		{
			meshId = "rbxassetid://97228951658265",
			sourceTemplate = "MeteorMesh_1",
			fallbackMaxSize = 0.55,
			size = Vector3.new(0.55, 0.55, 0.55),
		},
	},
	tankBusterRocks = {
		{
			meshId = "rbxassetid://93649869531301",
			sourceTemplate = "TankBusterRock_01",
			fallbackMaxSize = 4.8,
		},
		{
			meshId = "rbxassetid://94663417150302",
			sourceTemplate = "TankBusterRock_02",
			fallbackMaxSize = 4.8,
		},
		{
			meshId = "rbxassetid://86540954767052",
			sourceTemplate = "TankBusterRock_03",
			fallbackMaxSize = 4.8,
		},
	},
}

local RAID_BRIGADE_METEOR_FALL_HEIGHT = 76
local RAID_BRIGADE_METEOR_FALL_SECONDS = 2.15
local METEOR_UPLOADED_MODEL_CHANCE = 1
local METEOR_MODEL_TARGET_MIN_SIZE = 5.5
local METEOR_MODEL_TARGET_MAX_SIZE = 7.25
local GOLEM_TANK_BUSTER_LENGTH = 38
local GOLEM_TANK_BUSTER_WIDTH = 14
local GOLEM_TANK_BUSTER_STEP_DISTANCE = 3.4
local GOLEM_TANK_BUSTER_SEGMENT_SECONDS = 0.068
local GOLEM_TANK_BUSTER_ERUPTION_DELAY = 0.55
local GOLEM_TANK_BUSTER_ROCK_LIFETIME = 4.6

local meteorStrikeDecalRandom = Random.new()
local meteorRockRandom = Random.new()
local tankBusterRockRandom = Random.new()
local registeredManagers = setmetatable({}, { __mode = "k" })
local warned = {}

local function warnOnce(key, ...)
	if warned[key] == true then
		return
	end

	warned[key] = true
	warn("[PlumeFX Demo]", ...)
end

local function flipbook4x4(framerate)
	return {
		layout = "Grid4x4",
		mode = "OneShot",
		framerate = framerate or 24,
		startRandom = false,
		blendFrames = true,
	}
end

local function getMeteorStrikeDecalTexture()
	return METEOR_STRIKE_DECAL_TEXTURES[meteorStrikeDecalRandom:NextInteger(
		1,
		#METEOR_STRIKE_DECAL_TEXTURES
	)]
end

local function getEffectsFolder(parent)
	parent = parent or Workspace
	local folder = parent:FindFirstChild("PlumeFXRaidBrigadeEffects")
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "PlumeFXRaidBrigadeEffects"
		folder.Parent = parent
	end
	return folder
end

local function isDemoAssetRoot(candidate)
	return candidate ~= nil
		and (
			candidate:FindFirstChild("MeteorModels") ~= nil
			or candidate:FindFirstChild("TankBusterRockModels") ~= nil
		)
end

local function getAssetRoot(assetRoot)
	if isDemoAssetRoot(assetRoot) then
		return assetRoot
	end

	local plume = script:FindFirstAncestor("Plume")
	local plumeParent = plume and plume.Parent
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
	if plumeParent ~= nil then
		addCandidate(plumeParent:FindFirstChild("RaidBrigadeAssets"))
	end
	if plume ~= nil then
		addCandidate(plume:FindFirstChild("RaidBrigadeAssets"))
	end

	for _, candidate in ipairs(candidates) do
		if isDemoAssetRoot(candidate) then
			warnOnce("assetRoot", "Using demo asset root:", candidate:GetFullName())
			return candidate
		end
	end

	return nil
end

local function randomUnitVector(rng)
	local z = rng:NextNumber(-1, 1)
	local theta = rng:NextNumber(0, math.pi * 2)
	local radius = math.sqrt(math.max(0, 1 - z * z))
	return Vector3.new(math.cos(theta) * radius, z, math.sin(theta) * radius)
end

local function meteorRockColor(rng)
	local warm = rng:NextNumber()
	return Color3.new(0.13 + warm * 0.07, 0.105 + warm * 0.05, 0.08 + warm * 0.04)
end

local function makeMeteorPart(
	model,
	startCFrame,
	className,
	name,
	size,
	localCFrame,
	color,
	material,
	castShadow
)
	local part
	if className == "WedgePart" then
		part = Instance.new("WedgePart")
	else
		part = Instance.new("Part")
		if className == "Ball" then
			part.Shape = Enum.PartType.Ball
		elseif className == "Cylinder" then
			part.Shape = Enum.PartType.Cylinder
		end
	end

	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = castShadow ~= false
	part.Material = material
	part.Color = color
	part.Size = size
	part.CFrame = startCFrame * localCFrame
	part.Parent = model
	return part
end

local function normalizeAssetId(value)
	if value == nil or value == "" then
		return nil
	end

	if type(value) == "number" then
		return `rbxassetid://{value}`
	end

	local text = tostring(value)
	if string.find(text, "rbxasset", 1, true) then
		return text
	end

	if string.match(text, "^%d+$") then
		return `rbxassetid://{text}`
	end

	return text
end

local function findAssetModel(assetRoot, folderName, modelName)
	if assetRoot == nil or modelName == nil then
		return nil
	end

	local folder = assetRoot:FindFirstChild(folderName)
	return folder and folder:FindFirstChild(modelName)
end

local function createPublishedMeshModel(config, name, sourceModel, rng, material, color)
	local meshId = normalizeAssetId(if type(config) == "table" then config.meshId else config)
	if meshId == nil then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = name

	local part = Instance.new("MeshPart")
	part.Name = if type(config) == "table" and config.partName then config.partName else "Mesh"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = true
	part.Material = material or Enum.Material.Basalt
	part.Color = color or meteorRockColor(rng)
	part.Size = if type(config) == "table" and typeof(config.size) == "Vector3"
		then config.size
		else Vector3.new(4, 4, 4)
	if sourceModel ~= nil then
		local _, sourceSize = sourceModel:GetBoundingBox()
		if math.max(sourceSize.X, sourceSize.Y, sourceSize.Z) > 0.01 then
			part.Size = sourceSize
		end
	end
	part.MeshId = meshId

	local textureId = normalizeAssetId(if type(config) == "table" then config.textureId else nil)
	if textureId ~= nil then
		part.TextureID = textureId
	end

	part.Parent = model
	model.PrimaryPart = part
	return model
end

local function spawnPlumeVfx(manager, effectId, cframe, options)
	options = options or {}
	if manager == nil then
		return nil
	end

	return manager:Spawn(effectId, {
		cframe = cframe,
		parent = options.parent or getEffectsFolder(options.sceneParent),
		intensity = options.intensity or 1,
		priority = options.priority or 3,
	})
end

local function buildMoltenMeteorFallVfx()
	return Builder.system("RB_MoltenMeteorFall")
		:duration(RAID_BRIGADE_METEOR_FALL_SECONDS)
		:emitter("meteor_fire_streak", function(e)
			return e:duration(RAID_BRIGADE_METEOR_FALL_SECONDS)
				:lifetime(RAID_BRIGADE_METEOR_FALL_SECONDS)
				:color(Color3.new(1, 0.28, 0.04), { alpha = 0.72 })
				:alphaOverLife({
					{ 0, 0 },
					{ 0.08, 1 },
					{ 0.72, 0.72 },
					{ 1, 0 },
				})
				:sizeOverLife({
					{ 0, 0.45 },
					{ 0.28, 1.15 },
					{ 1, 0.75 },
				})
				:renderPartBeam({
					startOffset = Vector3.new(0, 0, 0),
					endOffset = Vector3.new(0, RAID_BRIGADE_METEOR_FALL_HEIGHT, 0),
					width = 4.6,
					width1 = 1.1,
					depth = 0.12,
					material = "Neon",
					transparency = 0.42,
				})
		end)
		:emitter("meteor_flame_trail", function(e)
			return e:duration(RAID_BRIGADE_METEOR_FALL_SECONDS)
				:capacity(180)
				:spawnRate(82)
				:lifetime({ min = 0.28, max = 0.62 })
				:position({
					shape = { kind = "sphere", radius = 0.34, thickness = 1 },
					moveTo = Vector3.new(0, RAID_BRIGADE_METEOR_FALL_HEIGHT, 0),
					moveDuration = RAID_BRIGADE_METEOR_FALL_SECONDS,
				})
				:velocity({ shape = { kind = "sphere" }, speed = { min = 0.8, max = 5.5 } })
				:size({ min = 1.7, max = 3.8 })
				:rotation(
					{ min = -math.pi, max = math.pi },
					{ angularVelocity = { min = -2.6, max = 2.6 } }
				)
				:color(Color3.new(1, 0.42, 0.08), { alpha = 0.86 })
				:gravity(Vector3.new(0, 7, 0))
				:drag(2.2)
				:sizeOverLife({
					{ 0, 0.2 },
					{ 0.2, 1.05 },
					{ 1, 0 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.08, 1 },
					{ 0.58, 0.78 },
					{ 1, 0 },
				})
				:colorOverLife({
					{ 0, Color3.new(1, 0.88, 0.36) },
					{ 0.42, Color3.new(1, 0.24, 0.04) },
					{ 1, Color3.new(0.24, 0.05, 0.02) },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/fire_main.dds",
					blending = "additive",
					brightness = 3.6,
					lightEmission = 1,
				})
		end)
		:emitter("meteor_smoke_trail", function(e)
			return e:duration(RAID_BRIGADE_METEOR_FALL_SECONDS)
				:capacity(120)
				:spawnRate(44)
				:lifetime({ min = 0.8, max = 1.45 })
				:position({
					shape = { kind = "sphere", radius = 0.5, thickness = 1 },
					moveTo = Vector3.new(0, RAID_BRIGADE_METEOR_FALL_HEIGHT, 0),
					moveDuration = RAID_BRIGADE_METEOR_FALL_SECONDS,
				})
				:velocity({ shape = { kind = "sphere" }, speed = { min = 1, max = 4.5 } })
				:size({ min = 2.2, max = 5.2 })
				:rotation(
					{ min = -math.pi, max = math.pi },
					{ angularVelocity = { min = -0.45, max = 0.45 } }
				)
				:color(Color3.new(0.18, 0.15, 0.13), { alpha = 0.48 })
				:gravity(Vector3.new(0, 3.5, 0))
				:drag(1.6)
				:sizeOverLife({
					{ 0, 0.3 },
					{ 0.38, 1 },
					{ 1, 1.25 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.2, 0.5 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/smoke_main.dds",
					blending = "alpha",
					brightness = 0.78,
					lightInfluence = 0.22,
				})
		end)
		:emitter("meteor_fall_light", function(e)
			return e:duration(RAID_BRIGADE_METEOR_FALL_SECONDS)
				:lifetime(RAID_BRIGADE_METEOR_FALL_SECONDS)
				:position({
					shape = { kind = "point" },
					moveTo = Vector3.new(0, RAID_BRIGADE_METEOR_FALL_HEIGHT, 0),
					moveDuration = RAID_BRIGADE_METEOR_FALL_SECONDS,
				})
				:color(Color3.new(1, 0.36, 0.08), { alpha = 1 })
				:renderLight({ range = 28, brightness = 4.8, shadows = false })
		end)
		:build()
end

local function buildMoltenMeteorImpactVfx()
	return Builder.system("RB_MoltenMeteorImpact")
		:duration(4.8)
		:emitter("meteor_scorch_decal", function(e)
			return e:capacity(3)
				:spawnBurst({ time = 0, count = 1 })
				:lifetime(2.2)
				:position({ shape = { kind = "disc", radius = 0.08, thickness = 0 } })
				:size({ min = 7.5, max = 10.5 })
				:rotation({ min = -math.pi, max = math.pi })
				:color(Color3.new(1, 1, 1), { alpha = 1 })
				:alphaOverLife({
					{ 0, 1 },
					{ 0.52, 1 },
					{ 1, 0 },
				})
				:renderDecal({
					texture = getMeteorStrikeDecalTexture(),
					surfaceOffset = 0.035,
					pixelsPerStud = 170,
					randomAspect = false,
					scorchScale = 1,
					scorchColor = Color3.new(1, 1, 1),
					scorchTransparency = 0,
					physicalScorchTransparency = 1,
					ringTransparency = 1,
					coreTransparency = 1,
					cracks = 0,
					lightInfluence = 0.35,
				})
		end)
		:emitter("meteor_flash_ring", function(e)
			return e:capacity(12)
				:spawnBurst({ time = 0, count = 3 })
				:lifetime(0.9)
				:position({ shape = { kind = "point" } })
				:size({ min = 10, max = 15 })
				:rotation({ min = -math.pi, max = math.pi })
				:color(Color3.new(1, 0.54, 0.12), { alpha = 0.92 })
				:sizeOverLife({
					{ 0, 0.22 },
					{ 0.28, 1.15 },
					{ 1, 1.45 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.04, 1 },
					{ 0.65, 0.72 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = RAID_BRIGADE_FLIPBOOKS.moltenShockwave,
					flipbook = flipbook4x4(28),
					blending = "additive",
					brightness = 4.2,
					lightEmission = 1,
				})
		end)
		:emitter("meteor_fireball_bloom", function(e)
			return e:capacity(70)
				:spawnBurst({ time = 0.02, count = 34 })
				:lifetime({ min = 0.28, max = 0.65 })
				:position({ shape = { kind = "sphere", radius = 0.28, thickness = 1 } })
				:velocity({ shape = { kind = "sphere" }, speed = { min = 9, max = 26 } })
				:size({ min = 0.85, max = 2.4 })
				:rotation(
					{ min = -math.pi, max = math.pi },
					{ angularVelocity = { min = -4, max = 4 } }
				)
				:color(Color3.new(1, 0.38, 0.08), { alpha = 0.9 })
				:gravity(Vector3.new(0, -6, 0))
				:drag(4.8)
				:sizeOverLife({
					{ 0, 0.18 },
					{ 0.28, 1.15 },
					{ 1, 0 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.05, 1 },
					{ 1, 0 },
				})
				:colorOverLife({
					{ 0, Color3.new(1, 0.92, 0.42) },
					{ 0.45, Color3.new(1, 0.24, 0.04) },
					{ 1, Color3.new(0.18, 0.04, 0.02) },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/fire_main.dds",
					blending = "additive",
					brightness = 4,
					lightEmission = 1,
				})
		end)
		:emitter("meteor_rock_shrapnel", function(e)
			return e:capacity(90)
				:spawnBurst({ time = 0.02, count = 38 })
				:lifetime({ min = 0.55, max = 1.35 })
				:position({ shape = { kind = "sphere", radius = 0.35, thickness = 1 } })
				:velocity({ shape = { kind = "sphere" }, speed = { min = 12, max = 34 } })
				:size({ min = 0.22, max = 0.7 })
				:rotation(
					{ min = -math.pi, max = math.pi },
					{ angularVelocity = { min = 8, max = 22 } }
				)
				:color(Color3.new(0.92, 0.52, 0.24), { alpha = 1 })
				:gravity(Vector3.new(0, -38, 0))
				:drag(1.5)
				:colorOverLife({
					{ 0, Color3.new(1, 0.6, 0.25) },
					{ 0.34, Color3.new(0.44, 0.34, 0.25) },
					{ 1, Color3.new(0.18, 0.15, 0.12) },
				})
				:alphaOverLife({
					{ 0, 1 },
					{ 0.78, 1 },
					{ 1, 0 },
				})
				:renderMesh({
					partTypes = { "Wedge", "Block" },
					material = "Basalt",
					randomAspect = true,
					aspectX = { min = 0.5, max = 1.55 },
					aspectY = { min = 0.32, max = 0.88 },
					aspectZ = { min = 0.55, max = 1.65 },
					castShadow = true,
				})
		end)
		:emitter("meteor_smoke_column", function(e)
			return e:capacity(150)
				:spawnBurst({
					{ time = 0.04, count = 38 },
					{ time = 0.18, count = 26 },
					{ time = 0.38, count = 18 },
				})
				:lifetime({ min = 1.3, max = 2.8 })
				:position({ shape = { kind = "disc", radius = 3.2, thickness = 1 } })
				:velocity({
					shape = { kind = "cone", angle = math.rad(30), radius = 0.5 },
					speed = { min = 3, max = 8 },
				})
				:size({ min = 2.4, max = 6.4 })
				:rotation(
					{ min = -math.pi, max = math.pi },
					{ angularVelocity = { min = -0.45, max = 0.45 } }
				)
				:color(Color3.new(0.16, 0.14, 0.13), { alpha = 0.5 })
				:gravity(Vector3.new(0, 3.2, 0))
				:drag(2.1)
				:sizeOverLife({
					{ 0, 0.2 },
					{ 0.38, 0.95 },
					{ 1, 1.35 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.18, 0.56 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/smoke_main.dds",
					blending = "alpha",
					brightness = 0.72,
					lightInfluence = 0.35,
				})
		end)
		:emitter("meteor_impact_light", function(e)
			return e:duration(0.24)
				:lifetime(0.24)
				:color(Color3.new(1, 0.34, 0.08), { alpha = 1 })
				:renderLight({ range = 42, brightness = 9, shadows = false })
		end)
		:build()
end

local function buildMoltenImpactVfx()
	return Builder.system("RB_MoltenImpactBurst")
		:duration(1.25)
		:emitter("molten_impact_flipbook", function(e)
			return e:capacity(12)
				:spawnBurst({ time = 0, count = 3 })
				:lifetime(0.95)
				:position({ shape = { kind = "point" } })
				:size({ min = 7, max = 10 })
				:rotation({ min = -math.pi, max = math.pi })
				:color(Color3.new(1, 0.56, 0.14), { alpha = 0.9 })
				:sizeOverLife({
					{ 0, 0.3 },
					{ 0.32, 1.1 },
					{ 1, 1.28 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.08, 1 },
					{ 0.72, 0.68 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = RAID_BRIGADE_FLIPBOOKS.moltenShockwave,
					flipbook = flipbook4x4(26),
					blending = "additive",
					brightness = 3.8,
					lightEmission = 1,
				})
		end)
		:emitter("molten_impact_sparks", function(e)
			return e:capacity(180)
				:spawnBurst({ time = 0.02, count = 88 })
				:lifetime({ min = 0.34, max = 0.9 })
				:position({ shape = { kind = "sphere", radius = 0.25, thickness = 1 } })
				:velocity({ shape = { kind = "sphere" }, speed = { min = 8, max = 24 } })
				:size({ min = 0.08, max = 0.24 })
				:color(Color3.new(1, 0.56, 0.1), { alpha = 1 })
				:gravity(Vector3.new(0, -18, 0))
				:drag(2.4)
				:alphaOverLife({
					{ 0, 1 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/sparkles_main.dds",
					blending = "additive",
					brightness = 2.8,
					lightEmission = 1,
				})
		end)
		:emitter("molten_impact_light", function(e)
			return e:duration(0.22)
				:lifetime(0.22)
				:color(Color3.new(1, 0.38, 0.08), { alpha = 1 })
				:renderLight({ range = 24, brightness = 4, shadows = false })
		end)
		:build()
end

local function buildMoltenTankBusterWindupVfx()
	return Builder.system("RB_MoltenTankBusterWindup")
		:duration(3.05)
		:emitter("tankbuster_pressure_dust", function(e)
			return e:capacity(150)
				:spawnBurst({
					{ time = 0.06, count = 28 },
					{ time = 0.9, count = 24 },
					{ time = 1.78, count = 34 },
				})
				:lifetime({ min = 0.85, max = 1.65 })
				:position({ shape = { kind = "ring", radius = 5.8, thickness = 0.55 } })
				:velocity({ shape = { kind = "disc" }, speed = { min = 2, max = 8 } })
				:size({ min = 1.6, max = 4.8 })
				:rotation(
					{ min = -math.pi, max = math.pi },
					{ angularVelocity = { min = -0.45, max = 0.45 } }
				)
				:color(Color3.new(0.34, 0.28, 0.23), { alpha = 0.52 })
				:gravity(Vector3.new(0, 1.8, 0))
				:drag(3.8)
				:sizeOverLife({
					{ 0, 0.2 },
					{ 0.35, 1 },
					{ 1, 1.2 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.14, 0.58 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/smoke_main.dds",
					blending = "alpha",
					brightness = 0.68,
					lightInfluence = 0.4,
				})
		end)
		:emitter("tankbuster_molten_embers", function(e)
			return e:capacity(180)
				:spawnBurst({
					{ time = 0.12, count = 34 },
					{ time = 1.08, count = 42 },
					{ time = 2.25, count = 58 },
				})
				:lifetime({ min = 0.36, max = 0.95 })
				:position({
					shape = { kind = "box", size = Vector3.new(8, 1.4, 8) },
					offset = Vector3.new(0, 2.8, -2),
				})
				:velocity({ shape = { kind = "sphere" }, speed = { min = 4, max = 14 } })
				:size({ min = 0.08, max = 0.23 })
				:color(Color3.new(1, 0.5, 0.1), { alpha = 0.92 })
				:gravity(Vector3.new(0, -5, 0))
				:drag(2.5)
				:alphaOverLife({
					{ 0, 1 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/sparkles_main.dds",
					blending = "additive",
					brightness = 3.2,
					lightEmission = 1,
				})
		end)
		:emitter("tankbuster_heat_pulse", function(e)
			return e:capacity(8)
				:spawnBurst({
					{ time = 0.02, count = 1 },
					{ time = 1.35, count = 1 },
					{ time = 2.55, count = 1 },
				})
				:lifetime(0.72)
				:position({ shape = { kind = "point" } })
				:size({ min = 11, max = 16 })
				:rotation({ min = -math.pi, max = math.pi })
				:color(Color3.new(1, 0.28, 0.06), { alpha = 0.72 })
				:sizeOverLife({
					{ 0, 0.18 },
					{ 0.36, 1.1 },
					{ 1, 1.35 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.08, 0.86 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = RAID_BRIGADE_FLIPBOOKS.moltenShockwave,
					flipbook = flipbook4x4(20),
					blending = "additive",
					brightness = 3.4,
					lightEmission = 1,
				})
		end)
		:build()
end

local function buildMoltenTankBusterEruptionVfx()
	return Builder.system("RB_MoltenTankBusterEruption")
		:duration(1.35)
		:emitter("tankbuster_dust_slab", function(e)
			return e:capacity(120)
				:spawnBurst({ time = 0, count = 46 })
				:lifetime({ min = 0.68, max = 1.28 })
				:position({ shape = { kind = "disc", radius = 2.6, thickness = 0.7 } })
				:velocity({
					shape = { kind = "cone", angle = math.rad(34), radius = 0.8 },
					speed = { min = 6, max = 16 },
				})
				:size({ min = 1.8, max = 5.2 })
				:rotation(
					{ min = -math.pi, max = math.pi },
					{ angularVelocity = { min = -0.65, max = 0.65 } }
				)
				:color(Color3.new(0.36, 0.29, 0.24), { alpha = 0.62 })
				:gravity(Vector3.new(0, 4.2, 0))
				:drag(4.4)
				:sizeOverLife({
					{ 0, 0.22 },
					{ 0.36, 1 },
					{ 1, 1.28 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.1, 0.72 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/smoke_main.dds",
					blending = "alpha",
					brightness = 0.72,
					lightInfluence = 0.42,
				})
		end)
		:emitter("tankbuster_rubble_fan", function(e)
			return e:capacity(90)
				:spawnBurst({ time = 0.02, count = 28 })
				:lifetime({ min = 0.55, max = 1.18 })
				:position({ shape = { kind = "sphere", radius = 0.75, thickness = 1 } })
				:velocity({
					shape = { kind = "cone", angle = math.rad(26), radius = 1 },
					speed = { min = 15, max = 36 },
				})
				:size({ min = 0.22, max = 0.78 })
				:rotation(
					{ min = -math.pi, max = math.pi },
					{ angularVelocity = { min = 8, max = 24 } }
				)
				:color(Color3.new(0.36, 0.28, 0.22), { alpha = 1 })
				:gravity(Vector3.new(0, -42, 0))
				:drag(1.45)
				:colorOverLife({
					{ 0, Color3.new(1, 0.48, 0.18) },
					{ 0.22, Color3.new(0.38, 0.3, 0.24) },
					{ 1, Color3.new(0.14, 0.12, 0.1) },
				})
				:alphaOverLife({
					{ 0, 1 },
					{ 0.78, 1 },
					{ 1, 0 },
				})
				:renderMesh({
					partTypes = { "Wedge", "Block" },
					material = "Basalt",
					randomAspect = true,
					aspectX = { min = 0.45, max = 1.6 },
					aspectY = { min = 0.28, max = 0.85 },
					aspectZ = { min = 0.6, max = 1.8 },
					castShadow = true,
				})
		end)
		:emitter("tankbuster_hot_sparks", function(e)
			return e:capacity(110)
				:spawnBurst({ time = 0.015, count = 46 })
				:lifetime({ min = 0.22, max = 0.62 })
				:position({ shape = { kind = "sphere", radius = 0.35, thickness = 1 } })
				:velocity({ shape = { kind = "sphere" }, speed = { min = 14, max = 34 } })
				:size({ min = 0.06, max = 0.18 })
				:color(Color3.new(1, 0.5, 0.1), { alpha = 0.94 })
				:gravity(Vector3.new(0, -28, 0))
				:drag(3.4)
				:alphaOverLife({
					{ 0, 1 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = "rbxasset://textures/particles/sparkles_main.dds",
					blending = "additive",
					brightness = 3,
					lightEmission = 1,
				})
		end)
		:emitter("tankbuster_ground_flash", function(e)
			return e:capacity(5)
				:spawnBurst({ time = 0, count = 1 })
				:lifetime(0.5)
				:position({ shape = { kind = "point" } })
				:size({ min = 8.5, max = 11 })
				:rotation({ min = -math.pi, max = math.pi })
				:color(Color3.new(1, 0.42, 0.08), { alpha = 0.82 })
				:sizeOverLife({
					{ 0, 0.24 },
					{ 0.32, 1.05 },
					{ 1, 1.24 },
				})
				:alphaOverLife({
					{ 0, 0 },
					{ 0.05, 1 },
					{ 1, 0 },
				})
				:renderSprite({
					texture = RAID_BRIGADE_FLIPBOOKS.moltenShockwave,
					flipbook = flipbook4x4(26),
					blending = "additive",
					brightness = 3.8,
					lightEmission = 1,
				})
		end)
		:emitter("tankbuster_erupt_light", function(e)
			return e:duration(0.18)
				:lifetime(0.18)
				:color(Color3.new(1, 0.32, 0.06), { alpha = 1 })
				:renderLight({ range = 18, brightness = 3.8, shadows = false })
		end)
		:build()
end

local function getUploadedMeteorTemplates(assetRoot)
	assetRoot = getAssetRoot(assetRoot)
	local meteorFolder = assetRoot and assetRoot:FindFirstChild("MeteorModels")
	if meteorFolder == nil then
		warnOnce(
			"missingMeteorModels",
			"Missing MeteorModels under PlumeFXDemoAssets; using fallback meteor model."
		)
		return {}
	end

	local templates = {}
	for _, child in ipairs(meteorFolder:GetChildren()) do
		if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
			table.insert(templates, child)
		end
	end
	if #templates == 0 then
		warnOnce("emptyMeteorModels", "MeteorModels exists but contains no usable model templates.")
	else
		warnOnce("usingMeteorModels", `Using {#templates} meteor model template(s).`)
	end
	return templates
end

local prepareUploadedMeteorModel
local animateMeteorRockModel

local function spawnPublishedMeteorRockModel(
	rng,
	folder,
	startPosition,
	endPosition,
	baseRotation,
	assetRoot
)
	if #RAID_BRIGADE_MESH_ASSETS.meteors == 0 then
		return nil
	end
	warnOnce("publishedMeteorFallback", "Using published meteor mesh fallback.")

	local config =
		RAID_BRIGADE_MESH_ASSETS.meteors[rng:NextInteger(1, #RAID_BRIGADE_MESH_ASSETS.meteors)]
	local sourceModel = findAssetModel(
		getAssetRoot(assetRoot),
		"MeteorModels",
		if type(config) == "table" then config.sourceTemplate else nil
	)
	local model = createPublishedMeshModel(
		config,
		"RB_PublishedMeteorRock",
		sourceModel,
		rng,
		Enum.Material.Basalt,
		meteorRockColor(rng)
	)
	if model == nil then
		return nil
	end

	model.Parent = folder
	model:SetAttribute(
		"SourceTemplate",
		if type(config) == "table"
			then config.sourceTemplate or "PublishedMeteor"
			else "PublishedMeteor"
	)
	if not prepareUploadedMeteorModel(model, rng) then
		return nil
	end

	local uploadedBaseRotation = baseRotation
	if model:GetAttribute("SourceTemplate") == "MeteorMesh_2" then
		uploadedBaseRotation = CFrame.Angles(0, rng:NextNumber(-math.pi, math.pi), 0)
	end

	return animateMeteorRockModel(model, rng, startPosition, endPosition, uploadedBaseRotation)
end

function prepareUploadedMeteorModel(model, rng)
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if primaryPart == nil then
		model:Destroy()
		return nil
	end

	model.PrimaryPart = primaryPart
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = true
			descendant.Transparency = 0
			local hasAuthoredSurface = descendant:IsA("MeshPart")
				and descendant:FindFirstChildWhichIsA("SurfaceAppearance") ~= nil
			if not hasAuthoredSurface then
				descendant.Material = Enum.Material.Basalt
				descendant.Color = meteorRockColor(rng)
			end
		end
	end

	local _, boxSize = model:GetBoundingBox()
	local maxDimension = math.max(boxSize.X, boxSize.Y, boxSize.Z)
	if maxDimension > 0.01 then
		model:ScaleTo(
			rng:NextNumber(METEOR_MODEL_TARGET_MIN_SIZE, METEOR_MODEL_TARGET_MAX_SIZE)
				/ maxDimension
		)
	end

	return model
end

function animateMeteorRockModel(model, rng, startPosition, endPosition, baseRotation)
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if primaryPart == nil then
		model:Destroy()
		return nil
	end
	model.PrimaryPart = primaryPart

	local spinOnly = model:GetAttribute("SourceTemplate") == "MeteorMesh_2"
	local light = Instance.new("PointLight")
	light.Name = "MeteorGlow"
	light.Color = Color3.fromRGB(255, 94, 24)
	light.Brightness = rng:NextNumber(1.6, 2.8)
	light.Range = rng:NextNumber(14, 22)
	light.Shadows = false
	light.Parent = primaryPart

	model:PivotTo(CFrame.new(startPosition) * baseRotation)
	local spinAxis = if spinOnly then Vector3.yAxis else randomUnitVector(rng)
	local spinRate = rng:NextNumber(5.4, 8.8)
	local wobbleRate = rng:NextNumber(4.5, 7.5)
	local wobbleAmount = if spinOnly then 0 else rng:NextNumber(0.035, 0.085)
	local startedAt = os.clock()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if model.Parent == nil then
			if connection and connection.Connected then
				connection:Disconnect()
			end
			return
		end

		local elapsed = os.clock() - startedAt
		local alpha = math.clamp(elapsed / RAID_BRIGADE_METEOR_FALL_SECONDS, 0, 1)
		local position = startPosition:Lerp(endPosition, alpha)
		local rotation = baseRotation
			* CFrame.fromAxisAngle(spinAxis, elapsed * spinRate)
			* CFrame.Angles(
				math.sin(elapsed * wobbleRate) * wobbleAmount,
				math.cos(elapsed * wobbleRate * 0.7) * wobbleAmount,
				0
			)
		model:PivotTo(CFrame.new(position) * rotation)

		if alpha >= 1 then
			if connection and connection.Connected then
				connection:Disconnect()
			end
			model:Destroy()
		end
	end)

	Debris:AddItem(model, RAID_BRIGADE_METEOR_FALL_SECONDS + 0.35)
	return model
end

local function spawnUploadedMeteorRockModel(
	rng,
	folder,
	startPosition,
	endPosition,
	baseRotation,
	assetRoot
)
	if rng:NextNumber() > METEOR_UPLOADED_MODEL_CHANCE then
		return nil
	end

	local templates = getUploadedMeteorTemplates(assetRoot)
	if #templates == 0 then
		return nil
	end

	local template = templates[rng:NextInteger(1, #templates)]
	local model = template:Clone()
	local sourceTemplate = template.Name
	model.Name = "RB_UploadedMeteorRock"
	model.Parent = folder
	model:SetAttribute("SourceTemplate", sourceTemplate)

	if not prepareUploadedMeteorModel(model, rng) then
		return nil
	end

	local uploadedBaseRotation = baseRotation
	if sourceTemplate == "MeteorMesh_2" then
		uploadedBaseRotation = CFrame.Angles(0, rng:NextNumber(-math.pi, math.pi), 0)
	end

	return animateMeteorRockModel(model, rng, startPosition, endPosition, uploadedBaseRotation)
end

local function spawnProceduralMeteorRock(folder, rng, startPosition, endPosition, baseRotation)
	local startCFrame = CFrame.new(startPosition) * baseRotation
	local model = Instance.new("Model")
	model.Name = "RB_ProceduralMeteorRock"
	model.Parent = folder

	local root = Instance.new("Part")
	root.Name = "MeteorRockRoot"
	root.Anchored = true
	root.CanCollide = false
	root.CanTouch = false
	root.CanQuery = false
	root.CastShadow = false
	root.Transparency = 1
	root.Size = Vector3.new(0.2, 0.2, 0.2)
	root.CFrame = startCFrame
	root.Parent = model
	model.PrimaryPart = root

	makeMeteorPart(
		model,
		startCFrame,
		"Ball",
		"MeteorCore",
		Vector3.new(rng:NextNumber(2, 3), rng:NextNumber(1.65, 2.55), rng:NextNumber(2, 3.1)),
		CFrame.Angles(
			rng:NextNumber(-math.pi, math.pi),
			rng:NextNumber(-math.pi, math.pi),
			rng:NextNumber(-math.pi, math.pi)
		),
		meteorRockColor(rng),
		Enum.Material.Basalt,
		true
	)

	for index = 1, rng:NextInteger(8, 13) do
		local direction = randomUnitVector(rng)
		local localPosition = direction * rng:NextNumber(0.72, 1.45)
		makeMeteorPart(
			model,
			startCFrame,
			if rng:NextNumber() < 0.82 then "WedgePart" else "Block",
			"MeteorChunk" .. index,
			Vector3.new(
				rng:NextNumber(0.5, 1.45),
				rng:NextNumber(0.34, 1.15),
				rng:NextNumber(0.5, 1.55)
			),
			CFrame.new(localPosition)
				* CFrame.Angles(
					rng:NextNumber(-math.pi, math.pi),
					rng:NextNumber(-math.pi, math.pi),
					rng:NextNumber(-math.pi, math.pi)
				),
			meteorRockColor(rng),
			Enum.Material.Basalt,
			true
		)
	end

	for index = 1, rng:NextInteger(4, 8) do
		local direction = randomUnitVector(rng)
		makeMeteorPart(
			model,
			startCFrame,
			"Block",
			"MoltenVent" .. index,
			Vector3.new(
				rng:NextNumber(0.55, 1.25),
				rng:NextNumber(0.07, 0.16),
				rng:NextNumber(0.08, 0.2)
			),
			CFrame.new(direction * rng:NextNumber(0.92, 1.58))
				* CFrame.Angles(
					rng:NextNumber(-math.pi, math.pi),
					rng:NextNumber(-math.pi, math.pi),
					rng:NextNumber(-math.pi, math.pi)
				),
			Color3.new(1, rng:NextNumber(0.24, 0.52), rng:NextNumber(0.02, 0.08)),
			Enum.Material.Neon,
			false
		)
	end

	local light = Instance.new("PointLight")
	light.Name = "MeteorGlow"
	light.Color = Color3.fromRGB(255, 94, 24)
	light.Brightness = rng:NextNumber(1.6, 2.8)
	light.Range = rng:NextNumber(14, 22)
	light.Shadows = false
	light.Parent = root

	return animateMeteorRockModel(model, rng, startPosition, endPosition, baseRotation)
end

local function spawnMeteorRockModel(impactCFrame, folder, assetRoot)
	local impactPosition = impactCFrame.Position
	local rng = Random.new(meteorRockRandom:NextInteger(1, 2147483646))
	local startPosition = Vector3.new(
		impactPosition.X,
		impactPosition.Y + RAID_BRIGADE_METEOR_FALL_HEIGHT,
		impactPosition.Z
	)
	local endPosition = Vector3.new(impactPosition.X, impactPosition.Y + 1.25, impactPosition.Z)
	local baseRotation = CFrame.Angles(
		rng:NextNumber(-math.pi, math.pi),
		rng:NextNumber(-math.pi, math.pi),
		rng:NextNumber(-math.pi, math.pi)
	)

	return spawnUploadedMeteorRockModel(
		rng,
		folder,
		startPosition,
		endPosition,
		baseRotation,
		assetRoot
	) or spawnPublishedMeteorRockModel(
		rng,
		folder,
		startPosition,
		endPosition,
		baseRotation,
		assetRoot
	) or spawnProceduralMeteorRock(folder, rng, startPosition, endPosition, baseRotation)
end

local function makeMeteorBeamPart(name, position, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(position)
	part.Parent = parent
	return part
end

local function makeMeteorCameraBeam(name, attachment0, attachment1, config)
	local beam = Instance.new("Beam")
	beam.Name = name
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.FaceCamera = true
	beam.Width0 = config.width0 or 4
	beam.Width1 = config.width1 or 1
	beam.Segments = config.segments or 18
	beam.LightEmission = config.lightEmission or 1
	beam.LightInfluence = 0
	beam.Texture = config.texture or "rbxasset://textures/particles/fire_main.dds"
	beam.TextureLength = config.textureLength or 5.5
	beam.TextureSpeed = config.textureSpeed or -1.75
	pcall(function()
		beam.TextureMode = config.textureMode or Enum.TextureMode.Wrap
	end)
	beam.Color = config.colorSequence
		or ColorSequence.new(config.color or Color3.fromRGB(255, 120, 24))

	local alpha = config.alpha or 0.5
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.08, 1 - alpha),
		NumberSequenceKeypoint.new(0.38, 1 - alpha * 0.95),
		NumberSequenceKeypoint.new(0.72, 1 - alpha * 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	return beam
end

local function animateMeteorMagmaBeam(model, layers)
	task.spawn(function()
		local startedAt = os.clock()
		while model.Parent do
			local elapsed = os.clock() - startedAt
			local fadeIn = math.clamp(elapsed / 0.18, 0, 1)
			local fadeOut = math.clamp((RAID_BRIGADE_METEOR_FALL_SECONDS - elapsed) / 0.24, 0, 1)
			local visible = math.min(fadeIn, fadeOut)
			local slowPulse = 0.5 + math.sin(elapsed * math.pi * 4.2) * 0.5
			local fastPulse = 0.5 + math.sin(elapsed * math.pi * 9 + 1.4) * 0.5

			for _, layer in ipairs(layers) do
				local beam = layer.beam
				if beam.Parent then
					local pulse = if layer.fast then fastPulse else slowPulse
					local swell = visible * (1 + pulse * (layer.pulse or 0.08))
					beam.Width0 = layer.width0 * swell
					beam.Width1 = layer.width1 * math.max(0.35, swell)
					beam.TextureSpeed = layer.textureSpeed * (0.82 + fastPulse * 0.32)
				end
			end
			RunService.Heartbeat:Wait()
		end
	end)
end

local function spawnMeteorCameraFacingBeam(impactCFrame, folder)
	local position = impactCFrame.Position
	local groundPosition = Vector3.new(position.X, position.Y + 0.3, position.Z)
	local skyPosition =
		Vector3.new(position.X, position.Y + RAID_BRIGADE_METEOR_FALL_HEIGHT, position.Z)

	local model = Instance.new("Model")
	model.Name = "MeteorMagmaCameraBeam"
	model.Parent = folder

	local groundPart = makeMeteorBeamPart("GroundAnchor", groundPosition, model)
	local skyPart = makeMeteorBeamPart("SkyAnchor", skyPosition, model)

	local groundAttachment = Instance.new("Attachment")
	groundAttachment.Name = "MeteorBeamGround"
	groundAttachment.Parent = groundPart

	local skyAttachment = Instance.new("Attachment")
	skyAttachment.Name = "MeteorBeamSky"
	skyAttachment.Parent = skyPart

	local glow = makeMeteorCameraBeam("MagmaGlowShell", groundAttachment, skyAttachment, {
		width0 = 8.2,
		width1 = 2.2,
		alpha = 0.28,
		texture = "rbxasset://textures/particles/smoke_main.dds",
		textureLength = 9.5,
		textureSpeed = -0.72,
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 18, 4)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 56, 10)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 28)),
		}),
	})
	glow.Parent = groundPart

	local body = makeMeteorCameraBeam("MagmaFlowBody", groundAttachment, skyAttachment, {
		width0 = 5.6,
		width1 = 1.35,
		alpha = 0.54,
		texture = "rbxasset://textures/particles/fire_main.dds",
		textureLength = 6.8,
		textureSpeed = -1.3,
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(82, 12, 2)),
			ColorSequenceKeypoint.new(0.28, Color3.fromRGB(210, 38, 5)),
			ColorSequenceKeypoint.new(0.68, Color3.fromRGB(255, 104, 14)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 188, 48)),
		}),
	})
	body.Parent = groundPart

	local vein = makeMeteorCameraBeam("MagmaHotVeins", groundAttachment, skyAttachment, {
		width0 = 3.2,
		width1 = 0.72,
		alpha = 0.68,
		texture = "rbxasset://textures/particles/fire_main.dds",
		textureLength = 3.6,
		textureSpeed = -2.65,
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 82, 8)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 195, 42)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 242, 126)),
		}),
	})
	vein.Parent = groundPart

	local core = makeMeteorCameraBeam("MagmaWhiteHotCore", groundAttachment, skyAttachment, {
		width0 = 1.15,
		width1 = 0.24,
		alpha = 0.74,
		texture = "rbxasset://textures/particles/sparkles_main.dds",
		textureLength = 2.5,
		textureSpeed = -3.2,
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 145, 24)),
			ColorSequenceKeypoint.new(0.58, Color3.fromRGB(255, 230, 96)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 210)),
		}),
	})
	core.Parent = groundPart

	animateMeteorMagmaBeam(model, {
		{ beam = glow, width0 = 8.2, width1 = 2.2, textureSpeed = -0.72, pulse = 0.05 },
		{ beam = body, width0 = 5.6, width1 = 1.35, textureSpeed = -1.3, pulse = 0.08 },
		{
			beam = vein,
			width0 = 3.2,
			width1 = 0.72,
			textureSpeed = -2.65,
			pulse = 0.12,
			fast = true,
		},
		{
			beam = core,
			width0 = 1.15,
			width1 = 0.24,
			textureSpeed = -3.2,
			pulse = 0.18,
			fast = true,
		},
	})

	Debris:AddItem(model, RAID_BRIGADE_METEOR_FALL_SECONDS + 0.25)
	return model
end

local function getGroundedTankBusterModelCFrame(model, desiredCFrame)
	model:PivotTo(desiredCFrame)
	local boundingCFrame, boundingSize = model:GetBoundingBox()
	local bottomY = boundingCFrame.Position.Y - boundingSize.Y * 0.5
	return desiredCFrame + Vector3.new(0, desiredCFrame.Position.Y - bottomY, 0), boundingSize
end

local function createTankBusterRockSegment(rng, segmentCFrame, index, scale, _assetRoot)
	local model = Instance.new("Model")
	model.Name = "MoltenTankBusterRockSegment"
	local height = rng:NextNumber(4.6, 7.4) * scale
	local width = rng:NextNumber(3.1, 5.0) * scale
	local depth = rng:NextNumber(1.8, 3.1) * scale
	local shardCount = rng:NextInteger(2, 4)
	local primary = nil

	for shardIndex = 1, shardCount do
		local shardHeight = height * rng:NextNumber(0.56, 1.02)
		local shardWidth = width * rng:NextNumber(0.42, 0.8)
		local shardDepth = depth * rng:NextNumber(0.45, 0.9)
		local localRotation = CFrame.Angles(
			rng:NextNumber(math.rad(-12), math.rad(15)),
			rng:NextNumber(-math.pi, math.pi),
			rng:NextNumber(math.rad(-12), math.rad(12))
		)

		local shard = makeMeteorPart(
			model,
			segmentCFrame,
			if (index + shardIndex) % 3 == 0 then "WedgePart" else "Block",
			if shardIndex == 1 then "BasaltShard" else "BasaltShard" .. shardIndex,
			Vector3.new(shardWidth, shardHeight, shardDepth),
			CFrame.new(
				rng:NextNumber(-width * 0.25, width * 0.25),
				shardHeight * 0.46,
				rng:NextNumber(-depth * 0.3, depth * 0.3)
			) * localRotation,
			meteorRockColor(rng),
			Enum.Material.Basalt,
			true
		)
		primary = primary or shard
	end

	model.PrimaryPart = primary

	if index % 2 == 0 then
		local glow = makeMeteorPart(
			model,
			segmentCFrame,
			"Block",
			"MoltenCrackGlow",
			Vector3.new(width * 0.82, rng:NextNumber(0.08, 0.16), depth * 0.9),
			CFrame.new(
				rng:NextNumber(-width * 0.12, width * 0.12),
				height * rng:NextNumber(0.38, 0.7),
				-depth * 0.42
			) * CFrame.Angles(0, rng:NextNumber(-0.22, 0.22), rng:NextNumber(-0.18, 0.18)),
			Color3.fromRGB(255, rng:NextInteger(70, 138), 14),
			Enum.Material.Neon,
			false
		)
		glow.Transparency = 0.08
	end

	local light = Instance.new("PointLight")
	light.Name = "TankBusterRockGlow"
	light.Color = Color3.fromRGB(255, 93, 24)
	light.Brightness = rng:NextNumber(0.55, 1.1)
	light.Range = rng:NextNumber(8, 14)
	light.Shadows = false
	light.Parent = primary

	return model
end

local function popTankBusterRockSegment(manager, folder, rng, segmentCFrame, index, assetRoot)
	local scale = if index % 4 == 0 then 1.18 else rng:NextNumber(0.8, 1.08)
	local model = createTankBusterRockSegment(rng, segmentCFrame, index, scale, assetRoot)
	model.Parent = folder
	local finalCFrame, modelSize = getGroundedTankBusterModelCFrame(model, segmentCFrame)
	local hiddenCFrame = finalCFrame * CFrame.new(0, -math.max(5.2 * scale, modelSize.Y * 0.85), 0)
	model:PivotTo(hiddenCFrame)

	if index % 3 == 0 then
		spawnPlumeVfx(manager, "rb-molten-impact", finalCFrame, {
			intensity = 0.24 + scale * 0.08,
			priority = 2,
			parent = folder,
		})
	end

	local riseSeconds = 0.24
	local holdSeconds = GOLEM_TANK_BUSTER_ROCK_LIFETIME
	local startedAt = os.clock()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if model.Parent == nil then
			if connection and connection.Connected then
				connection:Disconnect()
			end
			return
		end

		local elapsed = os.clock() - startedAt
		if elapsed < riseSeconds then
			local alpha = math.clamp(elapsed / riseSeconds, 0, 1)
			alpha = alpha * alpha * (3 - 2 * alpha)
			model:PivotTo(hiddenCFrame:Lerp(finalCFrame, alpha))
			return
		end

		if elapsed > riseSeconds + holdSeconds then
			local sinkAlpha = math.clamp((elapsed - riseSeconds - holdSeconds) / 0.28, 0, 1)
			sinkAlpha = sinkAlpha * sinkAlpha * (3 - 2 * sinkAlpha)
			model:PivotTo(finalCFrame:Lerp(hiddenCFrame, sinkAlpha))
			if sinkAlpha >= 1 then
				if connection and connection.Connected then
					connection:Disconnect()
				end
				model:Destroy()
			end
		end
	end)

	Debris:AddItem(model, riseSeconds + holdSeconds + 0.45)
end

function RaidBrigadeShowcase.Register(manager)
	if manager == nil or registeredManagers[manager] == true then
		return manager
	end

	manager:Register("rb-molten-meteor-fall", buildMoltenMeteorFallVfx)
	manager:Register("rb-molten-meteor-impact", buildMoltenMeteorImpactVfx)
	manager:Register("rb-molten-impact", buildMoltenImpactVfx)
	manager:Register("rb-molten-tankbuster-windup", buildMoltenTankBusterWindupVfx)
	manager:Register("rb-molten-tankbuster-eruption", buildMoltenTankBusterEruptionVfx)
	registeredManagers[manager] = true
	return manager
end

function RaidBrigadeShowcase.PlayMeteorImpact(manager, impactCFrame, options)
	options = options or {}
	RaidBrigadeShowcase.Register(manager)
	local folder = getEffectsFolder(options.parent)
	local assetRoot = options.assetRoot
	local position = impactCFrame.Position
	local fallCFrame = CFrame.new(
		position.X,
		position.Y + RAID_BRIGADE_METEOR_FALL_HEIGHT,
		position.Z
	) * CFrame.Angles(math.pi, 0, 0)

	spawnMeteorRockModel(impactCFrame, folder, assetRoot)
	spawnMeteorCameraFacingBeam(impactCFrame, folder)
	spawnPlumeVfx(manager, "rb-molten-meteor-fall", fallCFrame, {
		intensity = options.intensity or 1,
		priority = options.priority or 3,
		parent = folder,
	})

	task.delay(RAID_BRIGADE_METEOR_FALL_SECONDS, function()
		spawnPlumeVfx(manager, "rb-molten-meteor-impact", impactCFrame, {
			intensity = (options.intensity or 1) * 1.05,
			priority = (options.priority or 3) + 1,
			parent = folder,
		})
	end)
end

function RaidBrigadeShowcase.PlayTankBuster(manager, lineCFrame, options)
	options = options or {}
	RaidBrigadeShowcase.Register(manager)
	local folder = getEffectsFolder(options.parent)
	local assetRoot = options.assetRoot
	local rng = tankBusterRockRandom

	spawnPlumeVfx(manager, "rb-molten-tankbuster-windup", lineCFrame, {
		intensity = options.intensity or 1.04,
		priority = options.priority or 3,
		parent = folder,
	})

	local segmentCount = math.floor(GOLEM_TANK_BUSTER_LENGTH / GOLEM_TANK_BUSTER_STEP_DISTANCE)
	local forward = Vector3.new(lineCFrame.LookVector.X, 0, lineCFrame.LookVector.Z)
	forward = if forward.Magnitude < 0.001 then Vector3.new(0, 0, -1) else forward.Unit
	local right = Vector3.new(forward.Z, 0, -forward.X)
	right = if right.Magnitude < 0.001 then Vector3.xAxis else right.Unit
	local startPosition = lineCFrame.Position

	task.delay(GOLEM_TANK_BUSTER_ERUPTION_DELAY, function()
		for index = 1, segmentCount do
			task.delay((index - 1) * GOLEM_TANK_BUSTER_SEGMENT_SECONDS, function()
				local distance = index * GOLEM_TANK_BUSTER_STEP_DISTANCE
				local centerPosition = startPosition + forward * distance
				local eruptionCFrame = CFrame.lookAt(centerPosition, centerPosition + forward)
				spawnPlumeVfx(manager, "rb-molten-tankbuster-eruption", eruptionCFrame, {
					intensity = 0.7 + index / segmentCount * 0.18,
					priority = (options.priority or 3) + 1,
					parent = folder,
				})

				local laneSpread = GOLEM_TANK_BUSTER_WIDTH * 0.34
				local lateralOffsets = {
					rng:NextNumber(-GOLEM_TANK_BUSTER_WIDTH * 0.08, GOLEM_TANK_BUSTER_WIDTH * 0.08),
					-laneSpread + rng:NextNumber(-0.75, 0.75),
					laneSpread + rng:NextNumber(-0.75, 0.75),
				}
				for rockIndex, lateral in ipairs(lateralOffsets) do
					if rockIndex == 1 or index % 2 == rockIndex % 2 or index % 4 == 0 then
						local rockPosition = centerPosition + right * lateral
						local segmentCFrame = CFrame.lookAt(rockPosition, rockPosition + forward)
							* CFrame.Angles(0, rng:NextNumber(-0.24, 0.24), 0)
						popTankBusterRockSegment(
							manager,
							folder,
							rng,
							segmentCFrame,
							index + rockIndex * 17,
							assetRoot
						)
					end
				end
			end)
		end
	end)
end

return RaidBrigadeShowcase
