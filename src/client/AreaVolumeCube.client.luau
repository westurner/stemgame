print("DEBUG: AreaVolumeCube.client: Starting...")

--[[
# TODO
- [ ] run jest cli
- [ ] correctly handle props and state
- [ ] lua stdlib?: OrderedTable w/ a list of keys?
- [ ] lua stdlib?: Doubly-linked list
- [ ] port animations to react with otter
- [ ] port animations to react without otter
- [ ] idea: build things in-game:
  - https://create.roblox.com/docs/resources/battle-royale/building-system
- [ ] DOC: README:
  https://github.com/jsdotlua/react-lua/blob/main/docs/migrating-from-legacy/adopt-new-features.md
  https://github.com/jsdotlua/react-lua/blob/main/docs/api-reference/react.md#reactusecontext
  https://github.com/jsdotlua/react-lua/blob/main/docs/api-reference/react.md#reactuseref
  https://github.com/jsdotlua/react-lua/blob/main/docs/api-reference/react.md#reactevent
  React.useRef
  React.useContext
  React.useReducer
  React.useState
  [React.Event.< >]
  [React.Change.< >]

  - https://create.roblox.com/docs/cloud-services/memory-stores/sorted-map#update-data
  - https://create.roblox.com/docs/cloud-services/data-stores/manage-data-stores#versioning
  - https://create.roblox.com/docs/cloud-services/data-stores/manage-data-stores#snapshots
  - https://create.roblox.com/docs/cloud-services/data-stores/best-practices#use-key-prefixes-to-organize-your-data
  - https://create.roblox.com/docs/projects/teleport#create-custom-teleport-screens
  - https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#pcall
  - https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#xpcall
  - https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#tonumber
  - https://create.roblox.com/docs/scripting/events/remote
  - https://create.roblox.com/docs/scripting/events/bindable#custom-callbacks
  - https://create.roblox.com/docs/scripting/capabilities#engine-api-capability-assignments
  - https://github.com/Roblox/jest-roblox/blob/master/src/roblox-shared/src/RobloxApiDump.lua
  - https://github.com/jsdotlua/jest-lua/pull/17/files
    - docs: https://github.com/jsdotlua/jest-lua/blob/4ce171b07e809f80388215b361d366c187828f71/docs/docs/CLI.md
    - docs: https://github.com/jsdotlua/jest-lua/blob/4ce171b07e809f80388215b361d366c187828f71/docs/docs/GettingStarted.md

	]]

--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
--local e = React.createElement


local function SpawnLocationComponent(props: {}, _: {})
	local spawnLocation = React.createElement("SpawnLocation", {
			Name="SpawnLocation1",
			Position=Vector3.new(0, 10, 0),
			Rotation=Vector3.new(45, 0, 45),
			Size=Vector3.new(20,1,20),
			Material=Enum.Material.Ground,
		}, {
			React.createElement("Decal", {
				Texture = "rbxasset://textures/SpawnLocation.png",
				Face = Enum.NormalId.Top
			})
		})
	return spawnLocation
end

local function BigRedBall(props: {
	xmin: number,
	xmax: number,
}, children)
	return React.createElement("Part", {
		Name="BigRedBall",
		Shape=Enum.PartType.Ball,
		Size=Vector3.new(4,4,4),
		Color=Color3.new(0.7, 0, 0),
		Position=Vector3.new(0,20,0)
	}, children)
end

local function MyTestFrame() 
	return React.createElement("Frame", {
		Size = UDim2.new(0,100,0,100),
	})
end




function AreaVolumeCube(props: {})
	local props = table.clone(props)
	props.dimensions = Vector3.new(3, 4, 10)
	props.origin = Vector3.new(20, 30, 50)
	--props.rotation = Vector3.new(1,1,1) -- TODO

	--props.origin = Vector3.new(20, 6, -50)
	--props.blockSpacing = Vector3.new(1.1, 8, 1.1)
	--props.blockSize = Vector3.new(8, 1, 8)
	--props.rotation = Vector3.new(0, 0, 45)

	--props.blockSpacing = Vector3.new(1, 1, 1)
	--props.blockSpacing = Vector3.new(1.2, 1.2, 1.5)
	props.blockSpacing = Vector3.new(2, 2, 3)
	props.blockSize = Vector3.new(8, 8, 8)

	--props.labelColor = Color3.new(0.8, 0.8, 0.8)
	props.labelColor = Color3.new(0.847059, 0.705882, 0.074510)
	props.labelColor = Color3.fromRGB(204, 192, 101)

	print("INFO: Drawing a (" .. tostring(props.dimensions) .. ") cube of cubes, an AreaVolumeCube ...")

	local blocksArray, setBlocksArray = React.useState({})
	local blockSpacing, _ = React.useState(props.blockSpacing) -- TODO
	local blockSize, _ = React.useState(props.blockSize) -- TODO
	local labelColor, _ = React.useState(props.labelColor)
	local dimensions, _ = React.useState(props.dimensions)

	local areaVolumeCubeParts = {}

	local n = 0
	for x = 1, dimensions.X do 
		for y = 1, dimensions.Y do
			for z = 1, dimensions.Z do
				n = n + 1
				-- Create parts named Block_01,02,03
				local blockdata = {}
				blockdata.key = string.format("%02d,%02d,%02d", x,y,z)
				blocksArray[blockdata.key] = blockdata

				blockdata.loc = Vector3.new(x,y,z)
				blockdata.color1 = Color3.new((x)/dimensions.X, (y)/dimensions.Y, (z)/dimensions.Z) -- TODO: merge with AreaVolumeCube from
				--blockdata.labelColor = labelColor
				blockdata.labelText = string.format("%d,%d,%d\n%d", x, y, z, n)
				blockdata.Size = UDim2.new(1,0,1,0)
				--print(string.format("DEBUG: _blocks[%s]=%s", blockindex, tostring(_blocks[blockindex])))

				local blockSurfaceGuis = {}
				for _, Face in Enum.NormalId:GetEnumItems() do
					-- print("DEBUG: Face.Name=" .. Face.Name)
					local surfaceGui = React.createElement("SurfaceGui", {
						Face = Face,
						Name = string.format("SurfaceGui_%s", Face.Name)}, {
							React.createElement("TextLabel", {
								key = blockdata.key,
								Text = blockdata.labelText,
								Size = blockdata.Size,
								BackgroundTransparency = 1,
								--TextColor3 = Color3.new((x-1)%2, (x-1)%2, (x-1)%2),
								TextColor3 = labelColor,
								TextStrokeTransparency = 0,
								TextScaled = true,
								RichText = true,
								--FontFace_Weight = Enum.FontWeight.Bold, -- TODO:
								BorderMode = Enum.BorderMode.Inset,
								BorderSizePixel = 100,
								BorderColor3 = labelColor,
								Rotation = ((Face == Enum.NormalId.Bottom or Face == Enum.NormalId.Top) and 180 or 0),
							}),
					})
					table.insert(blockSurfaceGuis, surfaceGui)
				end
				local blockPart = React.createElement("Part", {
					key = blockdata.key,
					Name = string.format("Block_%02d,%02d,%02d", x, y, z),
					Anchored = true,
					Shape = Enum.PartType.Block,
					Size = blockSize,
					Position = Vector3.new(
						props.origin.X + ((x-1) * blockSize.X * blockSpacing.X),
						props.origin.Y + ((y-1) * blockSize.Y * blockSpacing.Y),
						props.origin.Z + ((z-1) * blockSize.Z * blockSpacing.Z)),
					Transparency = 0.05,
					Color = Color3.new(
						0.9, 0.9, 0.9
					),
					}, blockSurfaceGuis)
				blockdata.part = blockPart
				table.insert(areaVolumeCubeParts, blockPart) -- TODO: this is not DRY
			end
		end
	end

	for i, block in ipairs(blocksArray) do
		for j, otherBlock in ipairs(blocksArray) do
			if i ~= j then
				local constraint = Instance.new("RigidConstraint")
				constraint.Attachment0 = Instance.new("Attachment", block.part)
				constraint.Attachment1 = Instance.new("Attachment", otherBlock.part)
				constraint.Parent = block
			end
		end
	end

	local areaVolumeCubePrimaryPart = React.createElement("Model", {
		Name = "AreaVolumeCube",
		--Size = Vector3.new(200, 200, 200), -- TODO: volumetric .size/.extentsSize (?) of cube assembly
		--CanCollide = false,
		--Anchored = true,
	}, areaVolumeCubeParts)


	print("DEBUG: #_blocks=" .. #blocksArray)  -- TODO: why is this always zero

	--return blocksArray, props.dimensions
	--setBlocksArray(blocksArray)
	return areaVolumeCubePrimaryPart
end


local function AreaVolumeCube_camera_primary(props)
	local cameraSubject = props.CameraSubject;
	return React.createElement("Camera", {
		Name="Camera_Player",
		FieldOfView=70,
		VRTiltAndRollEnabled=true,
		CameraSubject=cameraSubject,
	})
end

local function AreaVolumeCube_camera_cube(props: {CameraSubject: any?})
	local cameraSubject = props.CameraSubject
	return React.createElement("Camera", {
		Name="Camera_Cube",
		FieldOfView=90,
		VRTiltAndRollEnabled=true,
		CameraSubject=cameraSubject
	})
end

local function init()
	local spawnLocation = React.createElement(SpawnLocationComponent, {}, {})
	local bigRedBall = React.createElement(BigRedBall, {}, {})
	local areaVolumeCube = React.createElement(AreaVolumeCube, {}, {})
	local camera1 = React.createElement(AreaVolumeCube_camera_primary, {CameraSubject=bigRedBall}, {})
	--local camera2 = React.createElement(AreaVolumeCube_camera_cube, {CameraSubject=areaVolumeCube}), {}) 
	-- TODO: ..Cube.partFromCreateElement


	local function AppRoot(props: {children: any?})
		return React.createElement("Model", {
			Name="AppModel"
		}, {
			bigRedBall,
			spawnLocation,
			bigRedBall,
			bigRedBall,
			areaVolumeCube,
			camera1,
			--camera2,
		})
	end

	--local Players = game:GetService("Players")
	--local handle = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
	
	local handle = Instance.new("Folder")
	handle.Name = "AppRoot"
	handle.Parent = workspace

	local root = ReactRoblox.createRoot(handle)
	root:render(React.createElement(AppRoot, {}, {}))
	print("DEBUG: root:render(AppRoot)")
end

init()







if 1
	then return
end



function AreaVolumeCube_render()
	local blocks, dims = AreaVolumeCube_render_blocks()
	print("INFO: #blocks=" .. #blocks .. " dims=" .. tostring(dims))

	AreaVolumeCube_animate_strobe(blocks, dims) -- #TODO: state.blocks, state.blocks_dims
	return blocks, dims
end

function AreaVolumeCube_animate_strobe(blocks, dims) 
	--local lighting = game:GetService("Lighting")
	local TweenService = game:GetService("TweenService")
	--local targetColor = Color3.new(1, 0, 0) -- target color (red)

	local fadeDuration = 2
	local tweenInfo_fadeIn = TweenInfo.new(
		fadeDuration, 
		Enum.EasingStyle.Linear, 
		Enum.EasingDirection.InOut, 
		-1, 
		true, 
		0
	)
	for x = 1, dims.x do
		for y = 1, dims.y do
			for z = 1, dims.z do
				local targetColor = Color3.new((x-1)/dims.x, (y-1)/dims.y, (z-1)/dims.z)
				--local blockname = string.format("Block_%02d,%02d,%02d", x, y, z)
				local blockindex = string.format("%02d,%02d,%02d", x, y, z)
				--local blockindex = {x,y,z}
				local part = blocks[blockindex].part
				if part ~= nil then
					local tween1 = TweenService:Create(part, tweenInfo_fadeIn, { Color = targetColor })
					tween1:Play()
				else
					print("ERROR: part was nil. blocks[blockindex=" .. tostring(blockindex))
				end
			end
		end
	end
end

function AreaVolumeCube_setAllUnachored()
	local folder = workspace:FindFirstChild("AreaVolumeCubeModel").AreaVolumeCube
	if folder then
		for _, object in ipairs(folder:GetChildren()) do
			--print(object.Name)
			object.Anchored = false


		end
	else
		warn("Folder not found")
	end
end


function initLighting()
	local lighting = game:GetService("Lighting")
	lighting.ClockTime = 20
	--lighting.Ambient = Color3.new(0.4, 0, 0) -- sets the ambient color to red
	--lighting.OutdoorAmbient = Color3.new(0.4, 0, 0)
end
	
function initLighting_strobe() 
	local lighting = game:GetService("Lighting")
	local TweenService = game:GetService("TweenService")
	local targetColor = Color3.new(1, 0, 0) -- target color (red)

	local fadeDuration = 2
	local tweenInfo_fadeIn = TweenInfo.new(
		fadeDuration, 
		Enum.EasingStyle.Linear, 
		Enum.EasingDirection.InOut, 
		-1, 
		true, 
		0
	)
	local tween1 = TweenService:Create(lighting, tweenInfo_fadeIn, { Ambient = targetColor })
	tween1:Play()
end


function init()
	print("INFO: Area Volume Cube !")


	initLighting()	
	--initLighting_strobe()

	local blocks, dims = AreaVolumeCube_render()
	-- TODO: initAreaVolumeCube_animations1()
	AreaVolumeCube_animate_strobe(blocks, dims) 
	--wait(10)
	--destroyAreaVolumeCube()

	print("INFO: Done!")
end

local _ = workspace:WaitForChild("SpawnLocation")
init()
--wait(10)
--destroyAreaVolumeCube()



print("DEBUG: AreaVolumeCube.client: Done...")