--!strict
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
  React.useRef, React.createRef()
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

local ReactDevtools = require(ReplicatedStorage.DevPackages.ReactDevtools)
local debugMode = false;
ReactDevtools.setup(debugMode)

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
--local e = React.createElement


local function SpawnLocationComponent(props: {_key: string})
	return React.createElement("SpawnLocation", {
			key=props._key,
			Position=Vector3.new(0, 10, 0),
			Rotation=Vector3.new(45, 0, 45),
			Size=Vector3.new(20,1,20),
			Material=Enum.Material.Ground,
		}, {
			[1]=React.createElement("Decal", {
				key="Decal1",
				Texture = "rbxasset://textures/SpawnLocation.png",
				Face = Enum.NormalId.Top
			})
		})
end

local function BigRedBallComponent(props)
--[[: {
	_key: string,
	xmin: number,
	xmax: number,
}]]--,
	return React.forwardRef(function (props, ref) 
		React.createElement("Part", {
			key=props._key,
			ref=ref,
			Shape=Enum.PartType.Ball,
			Size=Vector3.new(4,4,4),
			Color=Color3.new(0.7, 0, 0),
			Position=Vector3.new(0,20,0)
		}, props.children)
	end)
end

function AreaVolumeCube(props)

	local cubeRef = props.cubeRef
	--local props = table.clone(_props)
	--local props = {_key=_props._key}
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
				--blockdata._key = string.format("%02d,%02d,%02d", x,y,z)
				blockdata._key = n
				blocksArray[blockdata._key] = blockdata

				blockdata.loc = Vector3.new(x,y,z)
				blockdata.color1 = Color3.new((x)/dimensions.X, (y)/dimensions.Y, (z)/dimensions.Z) -- TODO: merge with AreaVolumeCube from
				--blockdata.labelColor = labelColor
				blockdata.labelText = string.format("%d,%d,%d\n%d", x, y, z, n)
				blockdata.Size = UDim2.new(1,0,1,0)
				--print(string.format("DEBUG: _blocks[%s]=%s", blockindex, tostring(_blocks[blockindex])))

				blockdata.partRef = React.createRef()

				local m = 0
				local blockSurfaceGuis = {}
				for _, Face in Enum.NormalId:GetEnumItems() do
					m += 1
					-- print("DEBUG: Face.Name=" .. Face.Name)
					blockSurfaceGuis[m] = React.createElement("SurfaceGui", {
						key = Face.Name,
						--Name = string.format("SurfaceGui_%s", Face.Name),
						Face = Face,
					}, {
							React.createElement("TextLabel", {
								key = Face.Name,
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
				end
				local blockPart = React.createElement("Part", {
					key = blockdata._key,
					ref = blockdata.partRef,
					--Name = string.format("Block_%02d,%02d,%02d", x, y, z),
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
					CanCollide = false,
				}, blockSurfaceGuis)
				blockdata.part = blockPart
				--table.insert(areaVolumeCubeParts, blockPart) -- TODO: this is not DRY
				areaVolumeCubeParts[blockdata._key] = blockPart
			end
		end
	end
	print("DEBUG: #_blocks=" .. #blocksArray)

	for i, block in ipairs(blocksArray) do
		for j, otherBlock in ipairs(blocksArray) do
			if i ~= j then
				local constraint = Instance.new("RigidConstraint")
				local attach1 = Instance.new("Attachment")
				local attach2 = Instance.new("Attachment")
				attach1.Parent = block.partRef.current
				attach2.Parent = otherBlock.partRef.current
				constraint.Attachment0 = attach1
				constraint.Attachment1 = attach2
				constraint.Parent = block.partRef.current
			end
		end
	end

	return React.createElement("Model", {
		key=props._key,
		ref=props.ref,
		--Name = string.format("AreaVolumeCube%d", props._key),
		--Size = Vector3.new(200, 200, 200), -- TODO: volumetric .size/.extentsSize (?) of cube assembly
		--CanCollide = false,
		--Anchored = true,
	}, areaVolumeCubeParts)
end


local function CameraOnPartComponent(props: {
	_key: string,
	CameraSubject: any?,
	CameraType: any?,
	FieldOfView: number?,
	ref: any?,
	VRTiltAndRollEnabled: boolean?})
	return React.createElement("Camera", {
		key=props._key,
		ref=props.ref,
		--Name=string.format("Camera_%s", props._key),
		CameraSubject=props.CameraSubject,
		CameraType=props.CameraType or Enum.CameraType.Follow,
		FieldOfView=props.FieldOfView or 70,
		VRTiltAndRollEnabled=props.VRTiltAndRollEnabled,
	})
end


local function FrameComponent(props) 
	return React.createElement("Frame", {
		key=props.key,
		Position=props.Position,
		Size=props.Size,
		BorderSizePixel=4,
		Visible=true,
		Active=true,
		BackgroundTransparency=0.5,
	})
end

local function TextButtonComponent(props)
	return React.createElement("TextButton", {
		key=props._key,
		--Name=props._key,
		Text=props.Text,
		TextSize=32,
		Position=props.Position,
		Size=props.Size,
		BorderSizePixel=4,
		Visible=true,
		Active=true,
		BackgroundTransparency=0.5,
		[React.Event.Activated]=props[React.Event.Activated] or function(arg1, arg2, arg3)
			print(string.format("DEBUG: TextButton{key=%s}.Activated=%s =%s =%s",
				tostring(props._key), tostring(arg1), tostring(arg2), tostring(arg3)))
		end
	})
end

local function init()
	local spawnLocation = React.createElement(SpawnLocationComponent, {_key=1})


	local cubeRef = React.createRef()
	local AreaVolumeCube_ForwardRef = React.forwardRef(function (props, ref)
		return React.createElement(AreaVolumeCube, {_key=2, ref=ref}, props.children)
	end)
	local areaVolumeCube = React.createElement(AreaVolumeCube_ForwardRef, {ref=cubeRef})


	local ball1Ref = React.createRef()
	local ball1 = React.createElement(BigRedBallComponent, {_key=3, ref=ball1Ref})
	local ball2 = React.createElement(BigRedBallComponent, {_key=4})
	local ball3 = React.createElement(BigRedBallComponent, {_key=5})


	local PlayerCameraComponent = React.forwardRef(function (props, ref)
		return React.createElement(CameraOnPartComponent, {_key=props._key,
			ref=ref,
			CameraSubject=props.CameraSubject,
			--CameraSubject=game:getService("Players").LocalPlayer:WaitForChild("Character"):WaitForChild("Humanoid"),
			--TODO: LocalPlayer.Character.Humanoid is not yet available
		}, props.children)
	end)


	-- local CameraComponent2 = React.PureComponent:extend("CameraComponent")
	-- function CameraComponent2:init()
	-- 	self:setState({})
	-- end
	-- function CameraComponent2:render()
	-- 	return React.createElement(CameraOnPartComponent, {_key=self.props._key,
	-- 		ref=self.props._ref,
	-- 		CameraSubject=self.props.CameraSubject,
	-- 	})
	-- end


	local CameraComponent = React.forwardRef(function (props, ref)
		return React.createElement(CameraOnPartComponent, {_key=props._key,
			ref=ref,
			CameraSubject=props.CameraSubject,
		}, props.children)
	end)

	local camera1_ref = React.createRef()
	local camera2_ref = React.createRef()
	local camera3_ref = React.createRef()
	local camera1 = React.createElement(PlayerCameraComponent, {_key=6, CameraSubject=cubeRef.current, ref=camera1_ref})
	local camera2 = React.createElement(CameraComponent, {_key=7, CameraSubject=cubeRef.current, ref=camera2_ref})
	local camera3 = React.createElement(CameraComponent, {_key=8, CameraSubject=ball1Ref.current, ref=camera3_ref})

	local cameraRefs = {{current=workspace.Camera}, camera1_ref, camera2_ref, camera3_ref}
	local refs = {cubeRef=cubeRef, ball1Ref=ball1Ref, cameras=cameraRefs}


	local function AreaVolumeCubeComponent(props: {_key: number})
		return React.createElement("Model", {
			key=props._key,
			--Name=string.format("AppRoot%d", props._key)
		}, {
			[1]=spawnLocation,
			[2]=areaVolumeCube,
			[3]=ball1,
			[4]=ball2,
			[5]=ball3,
			[6]=camera1,
			[7]=camera2,
			[8]=camera3,
		})
	end


	local handle = Instance.new("Model")
	handle.Name = "AppRoot"
	handle.Parent = workspace


	local root = ReactRoblox.createRoot(handle)
	root:render(React.createElement(AreaVolumeCubeComponent, {_key=1}))
	print("DEBUG: client: root::render(AreaVolumeCubeComponent) done")


	local function GuiRootComponent(props: {_key: number, cameras: any})
		return React.createElement(React.Fragment, {
			--key=props._key,
			--Name=string.format("AppRoot%d", props._key)
		}, {
			[1]=React.createElement(FrameComponent, {
				_key=1,
				Position=UDim2.new(0.8, 0, 0.7, 0),
				Size = UDim2.new(0, 200, 0, 20),
			}),
			[2]=React.createElement(TextButtonComponent, {
				_key=2,
				Text="Press me!",
				Position=UDim2.new(0.8, 0, 0.8, 0),
				Size=UDim2.new(0, 200, 0, 50),

				[React.Event.Activated]=function(arg1, arg2, arg3)
					print(string.format("DEBUG: TextButton{key=%s}.Activated=%s =%s =%s",
						tostring(props._key), tostring(arg1), tostring(arg2), tostring(arg3)))

					print(string.format("DEBUG: props.cameras=%s", tostring(props.cameras)))

					local n_camera = 1;
					local n_prevCamera = n_camera
					local nextCameraRef = props.cameras[n_camera]
					local nextCamera = nextCameraRef and nextCameraRef.current
					if nextCamera ~= nil then
						workspace.CurrentCamera = nextCamera
						task.wait(5)
						print("INFO: switched cameras. camera=%s" .. tostring(nextCamera))
						workspace.CurrentCamera = props.cameras[n_prevCamera].current
					else
						print(string.format("ERROR: Camera is not true; camera=%s", tostring(nextCamera)))
					end
				end
			})
		})  -- TODO: shouldn't this raise because [1] and .key=1?
	end

	local Players = game:GetService("Players")
	local guiHandle = Instance.new("ScreenGui")
	local guiRoot = ReactRoblox.createRoot(guiHandle)
	guiRoot:render(React.createElement(GuiRootComponent, {_key=1, cameras=cameraRefs}))
	guiHandle.Parent = Players.LocalPlayer.PlayerGui
	print("DEBUG: client: guiRoot::render(GuiRootComponent) done")


	refs.root=root
	refs.guiRoot=guiRoot
	return refs
end

local exports = init()

-- Run jest tests
-- src: https://jsdotlua.github.io/jest-lua/ : MIT
function main_test()

	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	--local runCLI = require("@DevPackages/Jest").runCLI
	local runCLI = require(ReplicatedStorage.DevPackages.Jest).runCLI
	
	local processServiceExists, ProcessService = pcall(function()
		return game:GetService("ProcessService")
	end)

	local StarterPlayer = game:GetService("StarterPlayer")
	local clientTests = StarterPlayer.StarterPlayerScripts
	
	local status, result = runCLI(clientTests, {
		verbose = false,
		ci = false
	}, { clientTests }):awaitStatus()
	
	if status == "Rejected" then
		print(result)
	end
	
	if status == "Resolved" and result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0 then
		if processServiceExists then
			ProcessService:ExitAsync(0)
		end
	end
	
	if processServiceExists then
		ProcessService:ExitAsync(1)
	end
	
	return nil
end

if game:GetService("RunService").IsStudio then
	print("INFO: AreaVolumeCube.client: main_test() starting ...")
	main_test()
	print("INFO: AreaVolumeCube.client: main_test() complete.")
else
	print("INFO: AreaVolumeCube.client: Skipping main_test() because .IsStudio is false")
end

return exports



--[[

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

--]]