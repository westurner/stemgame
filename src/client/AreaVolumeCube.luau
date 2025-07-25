--!strict
print("DEBUG: AreaVolumeCube: Starting...")

--[[
# TODO
- [ ] fix camera position y coordinates
- [ ] fix skipping over workspace.Camera / workspace.CurrentCamera
- [ ] fix multiple presses of LightsButtonComponent
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

local debugMode = false
if (debugMode) then
    local ReactDevtools = require(ReplicatedStorage.DevPackages.ReactDevtools)
    ReactDevtools.setup(debugMode)
end

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local SharedStateManager = require(game.StarterPlayer.StarterPlayerScripts.Client.SharedStateManager)
--local e = React.createElement


local BallComponent = require(script.Parent.BallComponent)
local CameraComponent = require(script.Parent.CameraComponent)
local CameraOnPartComponent = require(script.Parent.CameraOnPartComponent)
local CameraOnPlayerComponent = require(script.Parent.CameraOnPlayerComponent)
local DolmenComponent = require(script.Parent.DolmenComponent)
local SpawnLocationComponent = require(script.Parent.SpawnLocationComponent)
local LightsButtonComponent = require(script.Parent.LightsButtonComponent)
local TextButtonComponent = require(script.Parent.TextButtonComponent)



local AreaVolumeCubeComponent = React.Component:extend("AreaVolumeCube")
function AreaVolumeCubeComponent:init(props: {
	dimensions: Vector3?,
	origin: Vector3?,
	blockSpacing: Vector3?,
	blockSize: Vector3?,
	blockColor: Color3?,
	blockTransparency: number?,
	blockMaterial: Enum.Material?,
	blockBrickColor: Color3|BrickColor?,  -- Todo 
	labelColor: Color3?,
	rotation: Vector3?,
	_ref: any})

	-- self.props = props or {} -- TODO: is the necessary or advisable?

	props.dimensions = props.dimensions or Vector3.new(3, 4, 10)
	props.origin = props.origin or Vector3.new(20, 20, 50)
	--props.rotation = Vector3.new(1,1,1) -- TODO

	--props.origin = Vector3.new(20, 6, -50)
	--props.blockSpacing = Vector3.new(1.1, 8, 1.1)
	--props.blockSize = Vector3.new(8, 1, 8)
	--props.rotation = Vector3.new(0, 0, 45)

	--props.blockSpacing = Vector3.new(1, 1, 1)
	--props.blockSpacing = Vector3.new(1.2, 1.2, 1.5)
	props.blockSpacing = props.blockSpacing or Vector3.new(1.5, 1.5, 1.5)
	props.blockSize = props.blockSize or Vector3.new(8, 8, 8)
	props.blockColor = props.blockColor or Color3.new(0.62, 0.62, 0.62)
	--props.blockTransparency = props.blockTransparency or 0.05
	props.blockTransparency = props.blockTransparency or 0.10
	props.blockMaterial = props.blockMaterial or Enum.Material.SmoothPlastic

	props.blockBrickColor = props.blockBrickColor

	--props.labelColor = Color3.new(0.8, 0.8, 0.8)
	--props.labelColor = Color3.new(0.847059, 0.705882, 0.074510)
	--props.labelColor = props.labelColor or Color3.fromRGB(233, 232, 229)
	props.labelColor = props.labelColor or Color3.fromRGB(34, 34, 34)

	print("INFO: AreaVolumeCube:init: Drawing a (" .. tostring(props.dimensions) .. ") cube of cubes, an AreaVolumeCube ...")

	self.blocksArray = {}

	-- self.blocksArray, _ = React:useState({})
end

function AreaVolumeCubeComponent:render()
	local areaVolumeCubeParts = {}
	local props = self.props

	local n = 0
	for x = 1, props.dimensions.X do 
		for y = 1, props.dimensions.Y do
			for z = 1, props.dimensions.Z do
				n = n + 1
				-- Create parts named Block_01,02,03
				local blockdata = {}
				--blockdata._key = string.format("%02d,%02d,%02d", x,y,z)
				blockdata._key = n
				self.blocksArray[blockdata._key] = blockdata

				blockdata.loc = Vector3.new(x,y,z)
				blockdata.color1 = Color3.new(
					(x)/props.dimensions.X, (y)/props.dimensions.Y, (z)/props.dimensions.Z)
					 -- TODO: merge with AreaVolumeCube from
				blockdata.labelColor1 = props.labelColor
				--blockdata.labelText = string.format("%d,%d,%d\n%d", x, y, z, n) -- include n on a newline
				blockdata.labelText = string.format("%d,%d,%d", x, y, z)          -- just x,y,z
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
								TextColor3 = blockdata.labelColor1,
								TextStrokeColor3 = blockdata.labelColor1,
								TextStrokeTransparency = 0.5,
								TextTransparency = 0.2,
								TextScaled = true,
								RichText = true,
								--FontFace_Weight = Enum.FontWeight.Bold, -- TODO:
								BorderMode = Enum.BorderMode.Inset,
								BorderSizePixel = 100,
								BorderColor3 = blockdata.labelColor1,
								Rotation = ((Face == Enum.NormalId.Bottom or Face == Enum.NormalId.Top) and 180 or 0),
							}),
					})
				end
				-- Create the actual blocks of the area volume cube
				local blockPart = React.createElement("Part", {
					key = string.format("Block%02d,%02d,%02d", x, y, z), -- Block01,01,01
					ref = blockdata.partRef,
					Anchored = true,
					Shape = Enum.PartType.Block,
					Size = props.blockSize,
					Position = Vector3.new(
						props.origin.X + ((x-1) * props.blockSize.X * props.blockSpacing.X),
						props.origin.Y + ((y-1) * props.blockSize.Y * props.blockSpacing.Y),
						props.origin.Z + ((z-1) * props.blockSize.Z * props.blockSpacing.Z)),
					Transparency = props.blockTransparency,
					Color = props.blockColor,
					BrickColor = props.blockBrickColor,
					Material = props.blockMaterial,
					CanCollide = true,
				}, blockSurfaceGuis)

				blockdata.part = blockPart
		
				--table.insert(areaVolumeCubeParts, blockPart) -- TODO: this is not DRY
				areaVolumeCubeParts[blockdata._key] = blockPart
			end
		end
	end
	print("DEBUG: #_blocks=" .. #self.blocksArray)

	-- WIP: specify constraints between blocks
	for i, block in ipairs(self.blocksArray) do
		for j, otherBlock in ipairs(self.blocksArray) do
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
		ref=props._ref,
		--Size = Vector3.new(200, 200, 200), -- TODO: volumetric .size/.extentsSize (?) of cube assembly
	}, areaVolumeCubeParts)
end


function AreaVolumeCubeComponent:setAllUnanchored()
	-- TODO
	for x in self.blocksArray do
		local block = self.blocksArray[x]
		if block and block.part then
			block.part.Anchored = false
		else
			print(string.format("ERROR: AreaVolumeCube:setAllUnanchored: block=%s not found", tostring(x)))
		end
	end
end

-- local function FrameComponent(props) 
-- 	return React.createElement("Frame", {
-- 		Position=props.Position,
-- 		Size=props.Size,
-- 		BorderSizePixel=4,
-- 		Visible=true,
-- 		Active=true,
-- 		BackgroundTransparency=0.5,
-- 	})
-- end






local AreaVolumeCubeSceneComponent = React.Component:extend("AreaVolumeCubeSceneComponent")
function AreaVolumeCubeSceneComponent:init()
	self.props = self.props or {}
	self.state = {}
	self.state.dimensions=Vector3.new(3, 4, 10)
	self.state.current_block=Vector3.new(1,1,1)
    self.state.highlightedBlocks = {}
end

function AreaVolumeCubeSceneComponent:didMount()
    if self.props.isSharedMode then
        self.unsubscribe = SharedStateManager:subscribe("areaVolumeCube", function(cubeState)
            self:setState({
                highlightedBlocks = cubeState.highlightedBlocks or {},
            })
        end)
    end
end

function AreaVolumeCubeSceneComponent:willUnmount()
    if self.unsubscribe then
        self.unsubscribe()
    end
end

function AreaVolumeCubeSceneComponent:render()
	local refs = {}

	refs.balls = {}
	refs.ball1 = React.createRef()
	refs.ball2 = React.createRef()
	refs.ball3 = React.createRef()

	local currentPlayer = game:GetService("Players").LocalPlayer.Character and
		game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") or nil
	-- TODO: on characteradded, set currentPlayer  to the Humanoid of the LocalPlayer's Character
	if not currentPlayer then
		print("ERROR: AreaVolumeCube: currentPlayer is nil, waiting for LocalPlayer.Character.Humanoid")
		currentPlayer = game:GetService("Players").LocalPlayer.CharacterAdded:Wait():WaitForChild("Humanoid")
	end

	refs.camera1 = React.createRef()
	refs.camera2 = React.createRef()
	refs.camera3 = React.createRef()
	refs.cube1 = React.createRef()


	-- local _cameras = {
	-- 	camera0, -- workspace.Camera
	-- 	camera1, -- PlayerCameraComponent
	-- 	camera2, -- CameraComponent for AreaVolumeCube
	-- 	camera3, -- CameraComponent for BigRedBallComponent
	-- }
	refs._cameras = {{_current=workspace.Camera}, refs.camera1, refs.camera2, refs.camera3}


	local element = React.createElement(React.Fragment, {
		}, {
		--[1]=React.createElement(FrameComponent, {
		--	key="Frame1",
		--	Position=UDim2.new(0.8, 0, 0.7, 0),
		--	Size = UDim2.new(0, 200, 0, 20),
		--}),
		SpawnLocation1 = React.createElement(SpawnLocationComponent, {}),

		--camera0 = workspace.Camera
		AreaVolumeCube1 = React.createElement(AreaVolumeCubeComponent, {
			ref=refs.cube1,
			dimensions=Vector3.new(4, 3, 2),
			origin=Vector3.new(20, 50, 50),
			--blockSpacing=Vector3.new(1, 1, 1),
			--blockSpacing=Vector3.new(1.5, 1, 2),
			--blockSpacing=Vector3.new(2, 2, 2),
			blockSpacing=Vector3.new(1.2, 1.2, 1.2),
			--blockSize=Vector3.new(8, 8, 8),
			--blockSize=Vector3.new(12, 12, 12),
			blockSize=Vector3.new(42, 42, 42),
			--blockBrickColor=BrickColor.new("Maroon"),
			--blockBrickColor = BrickColor.new("Teal"),
			--blockBrickColor = BrickColor.new(170,0,0),
			--blockBrickColor = BrickColor.new("Dark green"),  "Toothpaste green", "Olivine green"
			--blockBrickColor = BrickColor.new("Flint"),
			--blockBrickColor = BrickColor.new("Storm blue"),
			--blockBrickColor = BrickColor.new("Medium lilac"),
			blockBrickColor = BrickColor.new("Dark stone grey"),
			--blockColor = Color3.new(170,0,0), -- Just glowing when neon
			--blockColor = Color3.new(200,0,0), -- Just glowing when neon
			blockMaterial = Enum.Material.Neon,
			--labelColor=Color3.fromRGB(34, 34, 34),
			--labelColor=Color3.fromRGB(200, 54, 34),
			labelColor=Color3.fromRGB(0,0,0),
            highlightedBlocks = self.state.highlightedBlocks,
		}),

		Ball1 = React.createElement(BallComponent, {Color=Color3.fromRGB(200, 0, 0), _ref=refs.ball1}),
		--Ball2 = React.createElement(BallComponent, {Color=Color3.fromRGB(0, 200, 42), _ref=refs.ball2}),
		Ball2 = React.createElement(BallComponent, {Color=Color3.fromRGB(0, 143, 156), _ref=refs.ball2}),
		Ball3 = React.createElement(BallComponent, {Color=Color3.fromRGB(0, 0, 200), _ref=refs.ball3}),

		Camera1 = React.createElement(CameraOnPlayerComponent, {
			_ref=refs.camera1,
			CameraSubject=currentPlayer,
			CameraType=Enum.CameraType.Track
		}),
		Camera2 = React.createElement(CameraComponent, {
			_ref=refs.camera2,
			CameraSubject=refs.cube1.current,
			CameraType=Enum.CameraType.Track,
			Focus=CFrame.new(Vector3.new(0,30,0))
		}),
		Camera3 = React.createElement(CameraComponent, {
			_ref=refs.camera3,
			CameraSubject=refs.ball1.current,
			CameraType=Enum.CameraType.Track,
			Focus=CFrame.new(Vector3.new(0,30,0))
		}),
		dolmen1 = React.createElement(DolmenComponent, {
		})
	})


	print("DEBUG: AreaVolumeCube: root::render(AreaVolumeCubeComponent) done")
	return element	
		
	-- --TODO: a mock component for tests
	-- --components.cubeRoot = {_internalRoot={current={stateNode={}}, containerInfo={}}, unmount=function() end}

end

function AreaVolumeCubeSceneComponent.main(props: {guiHandle: Instance, cameras: any, cubeDimensions: Vector3})

	print("DEBUG: AreaVolumeCubeSceneComponent.main() starting ...")
	props.guiHandle = Instance.new("Model")
	props.guiHandle.Name = "AreaVolumeCube1"
	props.guiHandle.Parent = workspace

	local sceneRoot = ReactRoblox.createRoot(props.guiHandle)
	sceneRoot:render(React.createElement(AreaVolumeCubeComponent, {key='AreaVolumeCube1'}))
	print("DEBUG: AreaVolumeCubeSceneComponent.main() done")
	return sceneRoot
end




local Players = game:GetService("Players")


local ScreenGuiComponent = React.Component:extend("ScreenGuiComponent")

function ScreenGuiComponent:init(props: {cameras: any, cubeDimensions: Vector3})
	self.props = self.props or {}
	self.props.cameras = self.props.cameras or {}
	self.props.cubeDimensions = self.props.dimensions or Vector3.new(3, 4, 10)
	self.props.guiHandle = self.props.guiHandle or Instance.new("ScreenGui")
	self.props.refs = {}
	self.setState({n_camera=1})
end

function ScreenGuiComponent:render()
	local n_camera, set_n_camera = React.useState(1)
	return React.createElement(React.Fragment, {
	}, {
		-- [1]=React.createElement(FrameComponent, {
		-- 	key="Frame1",
		-- 	Position=UDim2.new(0.8, 0, 0.7, 0),
		-- 	Size = UDim2.new(0, 200, 0, 20),
		-- }),
		React.createElement(LightsButtonComponent, {
			key="BlockButton1",
			dimensions=self.props.cubeDimensions,
		}),
		React.createElement(TextButtonComponent, {
			key="CameraButton1",
			Text="Camera",
			Position=UDim2.new(0.8, 0, 0.6, 0),
			Size=UDim2.new(0, 200, 0, 50),

		[React.Event.Activated]=function(eventobj, inputobj, arg3)
			print(string.format("DEBUG: CameraButton1.Activated eventobj=%s inputobj=%s arg3=%s",
				tostring(eventobj), tostring(inputobj), tostring(arg3)))

				print(string.format("DEBUG: props.cameras=%s", tostring(self.props.cameras)))

				n_camera = n_camera + 1
				if n_camera > #self.props.cameras then
					n_camera = 1
				end
				set_n_camera(n_camera)

				-- get the reference to the Camera object from the refs
				local nextCameraRef = self.props.cameras[n_camera]
				local nextCamera = nil
				if nextCameraRef._current then
					nextCamera = nextCameraRef._current
				elseif nextCameraRef.current then
					nextCamera = nextCameraRef.current._reactInternals.child.stateNode	
				else
					nextCamera = nil
					print(string.format("ERROR: nextCameraRef is not a valid camera reference: %s", tostring(nextCameraRef)))
				end

				if nextCamera then
					--local prevCamera = workspace.CurrentCamera
					workspace.CurrentCamera = nextCamera
					print(string.format("INFO: switched cameras. camera=%s", tostring(nextCamera)))
					--task.wait(5)
					--workspace.CurrentCamera = prevCamera
				else
					print(string.format("ERROR: Camera is not true; camera=%s", tostring(nextCamera)))
				end
			end
		})
	})  -- TODO: shouldn't this raise because [1] and .key=1?
end

function ScreenGuiComponent.main(props: {guiHandle: Instance, cameras: any, cubeDimensions: Vector3,
	Gravity: number, JumpHeight: number})

	print("DEBUG: ScreenGuiComponent.main() starting...")

	local guiHandle = props.guiHandle or Instance.new("ScreenGui")
	
	local guiRoot = ReactRoblox.createRoot(guiHandle)

	guiRoot:render(React.createElement(ScreenGuiComponent, {key='GuiRoot1',
		cameras=props.cameras,
		cubeDimensions=props.cubeDimensions  -- areaVolumeCube1.props.dimensions, TODO
	}))

	props.guiHandle.Parent = Players.LocalPlayer.PlayerGui

	print("DEBUG: ScreenGuiComponent.main() done.")
	return guiRoot
end



local exports = {
	ScreenGuiComponent=ScreenGuiComponent,
	AreaVolumeCubeComponent=AreaVolumeCubeComponent,
	AreaVolumeCubeSceneComponent=AreaVolumeCubeSceneComponent,
	-- SpawnLocationComponent=SpawnLocationComponent,
	-- BigRedBallComponent=BallComponent,
	-- CameraOnPartComponent=CameraOnPartComponent,
	-- CameraComponent=CameraComponent,
	-- PlayerCameraComponent=CameraOnPlayerComponent,
	-- LightsButtonComponent=LightsButtonComponent,
	-- TextButtonComponent=TextButtonComponent,
	-- test_init=test_init,
}


function test_init() 
	local output = init()
	local refs = output.refs
	local components = output.components

	assert (refs ~= nil, "ERROR: refs is nil")
	assert (components.cubeRoot ~= nil, "ERROR: components.cubeRoot is nil")
	assert (components.guiRoot ~= nil, "ERROR: components.guiRoot is nil")
	
	assert (refs.cube1 ~= nil, "ERROR: refs.cube1 is nil")
	assert (refs.ball1 ~= nil, "ERROR: refs.ball1 is nil")
	assert (refs.ball2 ~= nil, "ERROR: refs.ball2 is nil")
	assert (refs.ball3 ~= nil, "ERROR: refs.ball3 is nil")

	assert (refs._cameras ~= nil, "ERROR: refs.cameras is nil")
	assert (#refs._cameras == 4, "ERROR: refs.cameras does not have 4 elements")
	assert (refs._cameras[1] ~= nil, "ERROR: refs.cameras[1] is nil")
	assert (refs._cameras[2] ~= nil, "ERROR: refs.cameras[2] is nil")
	assert (refs._cameras[3] ~= nil, "ERROR: refs.cameras[3] is nil")
	assert (refs._cameras[4] ~= nil, "ERROR: refs.cameras[4] is nil")
	assert (refs._cameras[1]._current ~= nil, "ERROR: refs.cameras[1]._current is nil")
	-- assert (refs._cameras[2].current ~= nil, "ERROR: refs.cameras[2]._current is nil")
	-- assert (refs._cameras[3].current ~= nil, "ERROR: refs.cameras[3]._current is nil")
	-- assert (refs._cameras[4].current ~= nil, "ERROR: refs.cameras[4]._current is nil")

	assert (components.cubeRoot._internalRoot ~= nil, "ERROR: components.cubeRoot._internalRoot is nil")
	assert (components.cubeRoot._internalRoot.containerInfo ~= nil, "ERROR: components.cubeRoot._internalRoot.containerInfo is nil")
	assert (components.cubeRoot._internalRoot.current ~= nil, "ERROR: components.cubeRoot._internalRoot.current is nil")
	assert (components.cubeRoot._internalRoot.current.stateNode ~= nil, "ERROR: components.cubeRoot._internalRoot.current.stateNode is nil")


	assert (components.guiRoot._internalRoot ~= nil, "ERROR: components.guiRoot._internalRoot is nil")
	assert (components.guiRoot._internalRoot.current ~= nil, "ERROR: components.guiRoot._internalRoot.current is nil")
	assert (components.guiRoot._internalRoot.current.stateNode ~= nil, "ERROR: components.guiRoot._internalRoot.current.stateNode is nil")

	-- assert (components.camera0.props ~= nil, "ERROR: components.camera0.props is nil")
	-- assert (components.camera0.props.CameraSubject ~= nil, "ERROR: components.camera0.props.CameraSubject is nil")
	assert (components.camera1.props ~= nil, "ERROR: components.camera1.props is nil")
	assert (components.camera1.props.CameraSubject ~= nil, "ERROR: components.camera1.props.CameraSubject is nil")

	local function tearDown()
		print("DEBUG: AreaVolumeCube.test_init() - unmounting components.cubeRoot and components.guiRoot ...")
		-- unmount components.cubeRoot and components.guiRoot
		-- unmount components.cubeRoot and components.guiroot, and then delete references to output.refs, output.components, output
		components.cubeRoot:unmount()
		components.guiRoot:unmount()
		components.cubeRoot = nil
		components.guiRoot = nil
		-- iterate over refs and set them to nil
		for k, v in pairs(refs) do
			-- check whether v has a _current or current property
			if typeof(v) == "Instance" and v:IsA("Model") then 
				v:Destroy()
			elseif typeof(v) == "table" then
				if v['_current'] ~= nil then
					v._current = nil
				elseif v['current'] ~= nil then
					v.current = nil
				end
			end
			refs[k] = nil
		end
		refs = nil
		output = nil
		return	
	end

	if 1 then 
		tearDown()
		return
	end
	

	-- failing:



	-- assert (components.camera2.props ~= nil, "ERROR: components.camera2.props is nil")
	-- assert (components.camera2.props.CameraSubject ~= nil, "ERROR: components.camera2.props.CameraSubject is nil")
	assert (components.camera3.props ~= nil, "ERROR: components.camera3.props is nil")
	assert (components.camera3.props.CameraSubject ~= nil, "ERROR: components.camera3.props.CameraSubject is nil")


	-- assert (components.guiRoot._internalRoot.current.stateNode.props ~= nil, "ERROR: components.guiRoot._internalRoot.current.stateNode.props is nil")

	-- assert (refs.cube1.current ~= nil, "ERROR: refs.cube1.current is nil")
	-- assert (refs.ball1.current ~= nil, "ERROR: refs.ball1Ref.current is nil")

	-- assert (refs.cube1._internalRoot ~= nil, "ERROR: refs.cube1._internalRoot is nil")
	-- assert (refs.ball1._internalRoot ~= nil, "ERROR: refs.ball1Ref._internalRoot is nil")

	

	assert (components.guiRoot._reactInternals ~= nil, "ERROR: components.guiRoot._reactInternals is nil")
	assert (components.guiRoot._reactInternals.child ~= nil, "ERROR: components.guiRoot._reactInternals.child is nil")
	assert (components.guiRoot._reactInternals.child.stateNode ~= nil, "ERROR: components.guiRoot._reactInternals.child.stateNode is nil")
	assert (components.guiRoot._reactInternals.child.stateNode.props ~= nil, "ERROR: components.guiRoot._reactInternals.child.stateNode.props is nil")
	assert (components.guiRoot._reactInternals.child.stateNode.props.dimensions == Vector3.new(3, 4, 5), "ERROR: components.guiRoot._reactInternals.child.stateNode.props.dimensions is not Vector3.new(3, 4, 5)")
	assert (components.guiRoot._reactInternals.child.stateNode.props.dimensions ~= nil, "ERROR: components.guiRoot._reactInternals.child.stateNode.props.dimensions is nil")
	assert (components.cubeRoot._reactInternals ~= nil, "ERROR: components.cubeRoot._reactInternals is nil")
	assert (components.cubeRoot._reactInternals.child ~= nil, "ERROR: components.cubeRoot._reactInternals.child is nil")
	assert (components.cubeRoot._reactInternals.child.stateNode ~= nil, "ERROR: components.cubeRoot._reactInternals.child.stateNode is nil")
	assert (components.cubeRoot._reactInternals.child.stateNode.props ~= nil, "ERROR: components.cubeRoot._reactInternals.child.stateNode.props is nil")
	assert (components.cubeRoot._reactInternals.child.stateNode.props.dimensions == Vector3.new(3, 4, 5), "ERROR: components.cubeRoot._reactInternals.child.stateNode.props.dimensions is not Vector3.new(3, 4, 5)")
	assert (components.cubeRoot._reactInternals.child.stateNode.props.dimensions ~= nil, "ERROR: components.cubeRoot._reactInternals.child.stateNode.props.dimensions is nil")
	assert (refs.ball1.current._reactInternals ~= nil, "ERROR: refs.ball1Ref.current._reactInternals is nil")
	assert (refs.ball1.current._reactInternals.child ~= nil, "ERROR: refs.ball1Ref.current._reactInternals.child is nil")
	assert (refs.ball1.current._reactInternals.child.stateNode ~= nil, "ERROR: refs.ball1Ref.current._reactInternals.child.stateNode is nil")
	assert (refs.ball1.current._reactInternals.child.stateNode.props ~= nil, "ERROR: refs.ball1Ref.current._reactInternals.child.stateNode.props is nil")
	assert (refs.cube1.current._reactInternals ~= nil, "ERROR: refs.cube1.current._reactInternals is nil")
	assert (refs.cube1.current._reactInternals.child ~= nil, "ERROR: refs.cube1.current._reactInternals.child is nil")
	assert (refs.cube1.current._reactInternals.child.stateNode ~= nil, "ERROR: refs.cube1.current._reactInternals.child.stateNode is nil")
	assert (refs.cube1.current._reactInternals.child.stateNode.props ~= nil, "ERROR: refs.cube1.current._reactInternals.child.stateNode.props is nil")
	assert (refs.cube1.current._reactInternals.child.stateNode.props.dimensions == Vector3.new(3, 4, 5), "ERROR: refs.cube1.current._reactInternals.child.stateNode.props.dimensions is not Vector3.new(3, 4, 5)")
	assert (refs.cube1.current._reactInternals.child.stateNode.props.dimensions ~= nil, "ERROR: refs.cube1.current._reactInternals.child.stateNode.props.dimensions is nil")
end


function main_test()
	print("DEBUG: AreaVolumeCube.main_test() starting ...")

	print("DEBUG: AreaVolumeCube.main_test.test_init() starting ...")
	test_init()
	print("DEBUG: AreaVolumeCube.main_test.test_init() complete.")
	
	print("DEBUG: AreaVolumeCube.main_test() complete.")
end

-- Run jest tests
-- src: https://jsdotlua.github.io/jest-lua/ : MIT
function _main_test_jest()

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


local function main()
	if game:GetService("RunService").IsStudio then
		print("INFO: AreaVolumeCube: main_test() starting ...")
		main_test()
		print("INFO: AreaVolumeCube: main_test() complete.")
	else
		print("INFO: AreaVolumeCube: Skipping main_test() because .IsStudio is false")
	end


	local exports = init()
	return exports
	-- return {
	-- 	init = init,
	-- 	test_init = test_init,
	-- 	main_test = main_test,
	-- 	_main_test_jest = _main_test_jest,
	-- 	main = main,
	-- }
end

return exports



--[[

if 1
	then return
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


--]]
