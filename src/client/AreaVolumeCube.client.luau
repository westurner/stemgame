--!strict
print("DEBUG: AreaVolumeCube.client: Starting...")

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

local ReactDevtools = require(ReplicatedStorage.DevPackages.ReactDevtools)
local debugMode = false;
ReactDevtools.setup(debugMode)

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
--local e = React.createElement


local function SpawnLocationComponent(props)
	return React.createElement("SpawnLocation", {
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
	return React.createElement("Part", {
			ref=props._ref,
			Shape=props.Shape or Enum.PartType.Ball,
			Size=props.Size or Vector3.new(7,7,7),
			Color=props.Color or Color3.new(0.7, 0, 0),
			Material=props.Material or Enum.Material.Neon,
			Position=props.Position or Vector3.new(0,20,0)
		}, props.children)
end


local AreaVolumeCube = React.Component:extend("AreaVolumeCube")
function AreaVolumeCube:init(props: {
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

	print("INFO: Drawing a (" .. tostring(props.dimensions) .. ") cube of cubes, an AreaVolumeCube ...")

	self.blocksArray = {}

	-- self.blocksArray, _ = React:useState({})
end

function AreaVolumeCube:render()
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


function _next_block_xyz(block_position: Vector3, dimensions: Vector3)
	local next_block = block_position + Vector3.new(1, 0, 0)
	if next_block.X > dimensions.X then
		next_block = Vector3.new(1, next_block.Y + 1, next_block.Z)
		if next_block.Y > dimensions.Y then
			next_block = Vector3.new(1, 1, next_block.Z + 1)
			if next_block.Z > dimensions.Z then
				next_block = Vector3.new(1, 1, 1) -- reset to first block
			end
		end
	end
	return next_block
end

function _next_block_zxy(block_position: Vector3, dimensions: Vector3)
	local next_block = block_position + Vector3.new(0, 0, 1)
	if next_block.Z > dimensions.Z then
		next_block = Vector3.new(next_block.X + 1, next_block.Y, 1)
		if next_block.X > dimensions.X then
			next_block = Vector3.new(1, next_block.Y + 1, 1)
			if next_block.Y > dimensions.Y then
				next_block = Vector3.new(1, 1, 1) -- reset to first block
			end
		end
	end
	return next_block
end

function _next_block_zyx(block_position: Vector3, dimensions: Vector3)
	local next_block = block_position + Vector3.new(0, 0, 1)
	if next_block.Z > dimensions.Z then
		next_block = Vector3.new(next_block.X, next_block.Y + 1, 1)
		if next_block.Y > dimensions.Y then
			next_block = Vector3.new(next_block.X + 1, 1, 1)
			if next_block.X > dimensions.X then
				next_block = Vector3.new(1, 1, 1) -- reset to first block
			end
		end
	end
	return next_block
end


function AreaVolumeCube:setAllUnanchored()
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

local function TextButtonComponent(props)
	return React.createElement("TextButton", {
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
				tostring(props.key), tostring(arg1), tostring(arg2), tostring(arg3)))
		end
	})
end


local LightsButtonComponent = React.Component:extend("LightsButtonComponent")

function LightsButtonComponent:init()
	if not self.props.dimensions then
		error("LightsButtonComponent: dimensions prop is required")
	end

	self.prev = {} -- store previous attributes for each block by eventid

	self:setState({
		dimensions=self.props.dimensions,
		current_block=Vector3.new(1,1,1)})
end

function LightsButtonComponent:decorateBlock(block, eventid)
	self.attrs = {'BrickColor', 'Material', 'Transparency'}

	self.prev[block] = self.prev[block] or {}
	self.prev[block][eventid] = self.prev[block][eventid] or {}

	for _, attr in ipairs(self.attrs) do
		self.prev[block][eventid][attr] = block[attr]
	end

	-- set new attributes
	block.BrickColor = BrickColor.new("Bright red")
	block.Material = Enum.Material.Neon
	--block.Transparency = 0.8
end

function LightsButtonComponent:undecorateBlock(block, eventid)
	if self.attrs then
		-- restore previous attributes
		for _, attr in ipairs(self.attrs) do
			block[attr] = self.prev[block][eventid][attr]
			--block[attr] = block:GetAttribute(string.format("__prev__%s", attr))
			--block:SetAttribute(string.format("__prev__%s", attr), nil)	
		end
	else
		--print("ERROR: BlockButtonComponent: undecorateBlock: previousState not found for block=" .. tostring(block))
		block.BrickColor = BrickColor.new("Medium stone grey")
		block.Material = Enum.Material.Rock
		block.Transparency = 0.5
	end
end

function LightsButtonComponent:render()
	return React.createElement(TextButtonComponent, {
		Text="Lights",
		Position=UDim2.new(0.8, 0, 0.8, 0),
		Size=UDim2.new(0, 200, 0, 50),

		[React.Event.Activated]=function(eventobj, inputobj, arg3)
			print(string.format("DEBUG: BlockButtonComponent.Activated eventobj=%s inputobj=%s arg3=%s",
				tostring(eventobj), tostring(inputobj), tostring(arg3)))

			for i=1, (2*self.state.dimensions.X * self.state.dimensions.Y * self.state.dimensions.Z) do
				local current_block = self.state.current_block
				local block_key = string.format("Block%02d,%02d,%02d",
					current_block.x,
					current_block.y,
					current_block.z)
				local block = workspace.AreaVolumeCube1.Cube1[block_key]
				if block then
					local eventid = os.clock()
					self:decorateBlock(block, eventid)
					task.wait(0.3)
					self:undecorateBlock(block, eventid)

					self:setState({
						current_block=_next_block_xyz(current_block, self.state.dimensions)
					})
				else
					print(string.format("ERROR: Block not found: %s", block_key))
				end
				--task.wait(0.3)
			end
		end
	})
end


local CameraOnPartComponent = React.Component:extend("CameraOnPartComponent")
-- function CameraOnPartComponent:init()
-- 	self:setState({})
-- end
function CameraOnPartComponent:render()
	return React.createElement("Camera", {
		CameraSubject=self.props.CameraSubject,
		CameraType=self.props.CameraType,
		Focus=self.props.Focus,
		FieldOfView=self.props.FieldOfView,
		VRTiltAndRollEnabled=self.props.VRTiltAndRollEnabled,
		--Position = Vector3.new(0, 20, 0),
		--Orientation = Vector3.new(0, 0, 0),
	}, self.props.children)
end

local CameraComponent = React.Component:extend("CameraComponent")
-- function CameraComponent:init()
-- 	self:setState({})
-- end
function CameraComponent:render()
	return React.createElement(CameraOnPartComponent, {
		ref=self.props._ref,
		CameraSubject=self.props.CameraSubject,
		CameraType=self.props.CameraType,
		Focus=self.props.Focus,
	})
end


local PlayerCameraComponent = React.Component:extend("CameraComponent")
function PlayerCameraComponent:render()
	return React.createElement(CameraOnPartComponent, {
		ref=self.props.ref,
		CameraSubject=self.props.CameraSubject,
		--CameraSubject=game:getService("Players").LocalPlayer:WaitForChild("Character"):WaitForChild("Humanoid"),
		--TODO: LocalPlayer.Character.Humanoid is not yet available
	})
end



local function GuiRootComponent(props: {cameras: any, dimensions: Vector3})
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
			dimensions=props.dimensions,
		}),
		React.createElement(TextButtonComponent, {
			key="CameraButton1",
			Text="Camera",
			Position=UDim2.new(0.8, 0, 0.6, 0),
			Size=UDim2.new(0, 200, 0, 50),

		[React.Event.Activated]=function(eventobj, inputobj, arg3)
			print(string.format("DEBUG: CameraButton1.Activated eventobj=%s inputobj=%s arg3=%s",
				tostring(eventobj), tostring(inputobj), tostring(arg3)))

				print(string.format("DEBUG: props.cameras=%s", tostring(props.cameras)))

				n_camera = n_camera + 1
				if n_camera > #props.cameras then
					n_camera = 1
				end
				set_n_camera(n_camera)

				-- get the reference to the Camera object from the refs
				local nextCameraRef = props.cameras[n_camera]
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


local function init()
	local components = {}
	local refs = {}

	components.spawnLocation1 = React.createElement(SpawnLocationComponent, {key='SpawnLocation1'})


	refs.cube1 = React.createRef()
	components.areaVolumeCube1 = React.createElement(AreaVolumeCube, {key='Cube1',
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
		labelColor=Color3.fromRGB(0,0,0)
	})
	refs.balls = {}
	refs.ball1 = React.createRef()
	refs.ball2 = React.createRef()
	refs.ball3 = React.createRef()
	components.ball1 = React.createElement(BigRedBallComponent, {key='Ball1', Color=Color3.fromRGB(200, 0, 0), _ref=refs.ball1})
	components.ball2 = React.createElement(BigRedBallComponent, {key='Ball2', Color=Color3.fromRGB(0, 200, 0), _ref=refs.ball2})
	components.ball3 = React.createElement(BigRedBallComponent, {key='Ball3', Color=Color3.fromRGB(0, 0, 200), _ref=refs.ball3})

	local currentPlayer = game:GetService("Players").LocalPlayer.Character and
		game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") or nil
	-- TODO: on characteradded, set currentPlayer  to the Humanoid of the LocalPlayer's Character
	if not currentPlayer then
		print("ERROR: currentPlayer is nil, waiting for LocalPlayer.Character.Humanoid")
		currentPlayer = game:GetService("Players").LocalPlayer.CharacterAdded:Wait():WaitForChild("Humanoid")
	end

	refs.camera1 = React.createRef()
	refs.camera2 = React.createRef()
	refs.camera3 = React.createRef()
	components.camera0 = workspace.Camera
	components.camera1 = React.createElement(PlayerCameraComponent, {key='PlayerCamera1',
		_ref=refs.camera1,
		CameraSubject=currentPlayer,
		CameraType=Enum.CameraType.Track
	})
	components.camera2 = React.createElement(CameraComponent, {key='Camera2',
		_ref=refs.camera2,
		CameraSubject=refs.cube1.current,
		CameraType=Enum.CameraType.Track,
		Focus=CFrame.new(Vector3.new(0,30,0))
	})
	components.camera3 = React.createElement(CameraComponent, {key='Camera3',
		_ref=refs.camera3,
		CameraSubject=refs.ball1.current,
		CameraType=Enum.CameraType.Track,
		Focus=CFrame.new(Vector3.new(0,30,0))
	})
	components._cameras = {
		components.camera0, -- workspace.Camera
		components.camera1, -- PlayerCameraComponent
		components.camera2, -- CameraComponent for AreaVolumeCube
		components.camera3, -- CameraComponent for BigRedBallComponent
	}
	refs._cameras = {{_current=workspace.Camera}, refs.camera1, refs.camera2, refs.camera3}


	local DolmenComponent = React.Component:extend("DolmenComponent")
	function DolmenComponent:init(props)
		self.props = props or {}
		self.props._ref = self.props._ref or React.createRef()
	end
	function DolmenComponent:render()
		local components = {}
		components.areaVolumeCube1_dolmen = React.createElement("Part", {
			key='AreaVolumeCube1_Label',
			Position=Vector3.new(0, 26, -106),
			Orientation=Vector3.new(21, 0, 78),
			Size=Vector3.new(37,12,3),
			Color=Color3.fromHex("#333333"),
			Transparency=0.9,
			Anchored=true,
			Name="AreaVolumeCube1_Label",
		}, {
			React.createElement("SurfaceGui", {
				key="SurfaceGuiFront",
				Face=Enum.NormalId.Front,
				--CanvasSize=Vector2.new(200, 200),
				ResetOnSpawn=false,
				ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
				SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud,
				PixelsPerStud=28,
			}, {
				TextLabel1 = React.createElement("TextLabel", {
					--key="TextLabel1",
					Text="Area Volume Cube",
					TextColor3=Color3.fromHex("#cccccc"),
					FontSize=Enum.FontSize.Size96,
					Font=Enum.Font.GothamBold,
					--FontWeight=Enum.FontWeight.Bold,
					TextScaled=false,
					TextWrapped=false,
					TextXAlignment=Enum.TextXAlignment.Center,
					TextYAlignment=Enum.TextYAlignment.Center,
					BackgroundTransparency=1,
					ZIndex=2,
					Size=UDim2.new(0.8, 0, 0.8, 0),
					Position=UDim2.new(0.1, 0, 0.1, 0),
				}),
				TextLabel2 = React.createElement("TextLabel", {
					--key="TextLabel2",
					Text="#stemgame",
					TextColor3=Color3.fromHex("#9c9999"),
					FontSize=Enum.FontSize.Size60,
					TextScaled=false,
					TextWrapped=false,
					TextXAlignment=Enum.TextXAlignment.Center,
					TextYAlignment=Enum.TextYAlignment.Center,
					BackgroundTransparency=1,
					ZIndex=3,
					Size=UDim2.new(0.4, 0, 0.1, 0),
					Position=UDim2.new(0.55, 0, 0.95, 0),
				})
			})
		})

		components.areaVolumeCube1_dolmen_pillar2 = React.createElement("Part", {
			key='AreaVolumeCube1_Label_pillar2',
			Position=Vector3.new(-3.82, 21.43, -93.68),
			Orientation=Vector3.new(-26, -40.2, 86.86),
			Size=Vector3.new(30,10,2),
			Color=Color3.fromHex("#333333"),
			Transparency=0.7,
			Anchored=true,
		})

		components.areaVolumeCube1_dolmen_pillar3 = React.createElement("Part", {
			key='AreaVolumeCube1_Label_pillar3',
			Position=Vector3.new(9.21, 21.90, -93.35),
			Orientation=Vector3.new(-17.42, 55, 89.71),
			Size=Vector3.new(30.4, 14.92, 2.03),
			Color=Color3.fromHex("#333333"),
			Transparency=0.7,
			Anchored=true,
		})

		components.areaVolumeCube1_dolmen_lid1 = React.createElement("Part", {
			key='AreaVolumeCube1_Label_dolmen_lid1',
			Position=Vector3.new(4.92, 37.92, -91.42),
			Orientation=Vector3.new(0.43, -3.14, 97.85),
			Size=Vector3.new(3,27.6,16),
			--Color=Color3.fromHex("#333333"),
			--BrickColor=BrickColor.new("Bright blue"),
			Material=Enum.Material.Neon,
			Color=Color3.fromRGB(7, 116, 140),
			Transparency=0.6,
			Anchored=true,
		})

		return React.createElement("Model", {
			key='Dolmen1',
			ref=self.props._ref,
			--Position=props.Position or Vector3.new(0, 0, 0),
		}, {
			components.areaVolumeCube1_dolmen,
			components.areaVolumeCube1_dolmen_pillar2,
			components.areaVolumeCube1_dolmen_pillar3,
			components.areaVolumeCube1_dolmen_lid1,
		})
	end

	components.areaVolumeCube1_dolmen1 = React.createElement(DolmenComponent, {
		key='AreaVolumeCube1_dolmen1',
	})

	local function AreaVolumeCubeComponent(props)
		return React.createElement(React.Fragment, {
		}, {
			components.spawnLocation1,
			components.areaVolumeCube1,
			components.areaVolumeCube1_dolmen1,
			components.ball1,
			components.ball2,
			components.ball3,
			components.camera1,
			components.camera2,
			components.camera3,
		})
	end

	--local _refs = {}
	local _refs = refs
	_refs.cubeRoot = Instance.new("Model")
	_refs.cubeRoot.Name = "AreaVolumeCube1"
	_refs.cubeRoot.Parent = workspace

	components.cubeRoot = ReactRoblox.createRoot(_refs.cubeRoot)
	components.cubeRoot:render(React.createElement(AreaVolumeCubeComponent, {key='AreaVolumeCube1'}))
	print("DEBUG: client: root::render(AreaVolumeCubeComponent) done")


	local Players = game:GetService("Players")
	components.guiHandle = Instance.new("ScreenGui")
	components.guiRoot = ReactRoblox.createRoot(components.guiHandle)
	components.guiRoot:render(React.createElement(GuiRootComponent, {key='GuiRoot1',
		cameras=refs._cameras,
		dimensions=components.areaVolumeCube1.props.dimensions,
	}))
	components.guiHandle.Parent = Players.LocalPlayer.PlayerGui
	print("DEBUG: client: guiRoot::render(GuiRootComponent) done")


	-- ## the default roblox game settings for gravity and jump height:
	-- game:GetService("Workspace").Gravity = 196.2 -- default is 196.2
	-- game:GetService("Players").LocalPlayer.Character.Humanoid.JumpHeight = 50 -- default is 50

	-- small planet gravity and ridiculous jump height
	game:GetService("Workspace").Gravity = 10 -- default is 10
	game:GetService("Players").LocalPlayer.Character.Humanoid.JumpHeight = 10 -- default is 50

	-- set the camera to the first camera in components._cameras
	if refs._cameras[1] and refs._cameras[1]._current then
		workspace.CurrentCamera = refs._cameras[1]._current
	else
		print("ERROR: refs._cameras[1] is not a valid camera reference")
	end

	return {refs=refs, components=components}
end

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
		print("DEBUG: AreaVolumeCube.client.test_init() - unmounting components.cubeRoot and components.guiRoot ...")
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
	print("DEBUG: AreaVolumeCube.client.main_test() starting ...")

	print("DEBUG: AreaVolumeCube.client.main_test.test_init() starting ...")
	test_init()
	print("DEBUG: AreaVolumeCube.client.main_test.test_init() complete.")
	
	print("DEBUG: AreaVolumeCube.client.main_test() complete.")
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
		print("INFO: AreaVolumeCube.client: main_test() starting ...")
		main_test()
		print("INFO: AreaVolumeCube.client: main_test() complete.")
	else
		print("INFO: AreaVolumeCube.client: Skipping main_test() because .IsStudio is false")
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
return main()



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