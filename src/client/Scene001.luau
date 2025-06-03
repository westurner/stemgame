-- # Scene001.luau
-- This component serves as the root for the #stemgame application.
-- It initializes the application, sets up the root component, and renders it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local debugMode = false
if (debugMode) then
    local ReactDevtools = require(ReplicatedStorage.DevPackages.ReactDevtools)
    ReactDevtools.setup(debugMode)
end

local React = require(ReplicatedStorage.Packages.React)



--local AnswerPadComponent = require(script.Parent.AnswerPadComponent)
local AreaVolumeCubeSceneComponent = require(script.Parent.AreaVolumeCube).AreaVolumeCubeSceneComponent
local AxesComponent = require(script.Parent.AxesComponent)
--local BallComponent = require(script.Parent.BallComponent)
--local BillboardAnswersComponent = require(script.Parent.BillboardAnswersComponent)
local BlochSphereComponent = require(script.Parent.BlochSphereComponent)
local SurfaceSphereComponent = require(script.Parent.SurfaceSphereComponent)
local GlowingOrbComponent = require(script.Parent.GlowingOrbComponent)
local MultiJumpComponent = require(script.Parent.MultiJumpComponent)
local SeesawComponent = require(script.Parent.SeesawComponent)
--local SpawnLocationComponent = require(script.Parent.SpawnLocationComponent)
local WireframeCubeComponent = require(script.Parent.WireframeCubeComponent)
--local FallbackComponent = require(script.Parent.FallbackComponent)







local Scene001 = React.Component:extend("Scene001")

Scene001.init_lighting = function(_props)
    --local DEFAULT_CLOCKTIME = 20.4
    --local DEFAULT_CLOCKTIME = 6.17
    --local DEFAULT_CLOCKTIME = 5.15
    --local DEFAULT_CLOCKTIME = 17.42
    local DEFAULT_CLOCKTIME = 18.42

    local props = _props or {}
    local Lighting = game:GetService("Lighting")
    Lighting.ClockTime = props.ClockTime or DEFAULT_CLOCKTIME
    Lighting.Ambient = props.Ambient or Color3.fromRGB(111, 111, 101)
    Lighting.OutdoorAmbient = props.OutdoorAmbient or Color3.fromRGB(111, 111, 101)
    print(string.format("DEBUG: Scene001.init_lighting: ClockTime=%s", tostring(Lighting.ClockTime)))
end

Scene001.init_lighting_strobe = function(_props)
    print("DEBUG: Scene001.init_lighting_strobe: starting...")
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
    print("DEBUG: Scene001.init_lighting_strobe: done.")
end

Scene001.init_gravity = function(props)
	-- ## the default roblox game settings for gravity and jump height:
	-- game:GetService("Workspace").Gravity = 196.2 -- default is 196.2
	-- game:GetService("Players").LocalPlayer.Character.Humanoid.JumpHeight = 50 -- default is 50

	-- small planet gravity and ridiculous jump height
	Workspace.Gravity = props.Gravity or 196.2 -- default is 10
    task.wait(1) -- TODO: wait for Players.LocalPlayer.Character.Humanoid
	Players.LocalPlayer.Character.Humanoid.JumpHeight = props.JumpHeight or 50 -- default is 50
	print("DEBUG: Scene001:init_gravity: Gravity = " .. Workspace.Gravity)
	print("DEBUG: Scene001:init_gravity: Humanoid.JumpHeight = " .. Players.LocalPlayer.Character.Humanoid.JumpHeight)
end

Scene001.init_cameras = function(props)
	print("DEBUG: Scene001:init_cameras: CurrentCamera = " .. Workspace.CurrentCamera.Name)
	local n_camera = 1   --,  _ = React.useState(1)
    if (not props.cameras) then
        props.cameras = {[1]=workspace.CurrentCamera}
    end
	local camera = props.cameras[n_camera]
	if camera then -- and camera['_current'] then
		workspace.CurrentCamera = camera
	else
		print("ERROR: Scene001:init_cameras: props.cameras[n_camera] is not a valid camera reference")
	end
	print("DEBUG: Scene001:init_cameras: CurrentCamera = " .. Workspace.CurrentCamera.Name)
end

function Scene001:init()
    print("DEBUG: Scene001:init() starting...")
    self.props = self.props or {}

    self.init_lighting(self.props)
    --self.init_lighting_strobe(self.props)
	self.init_cameras(self.props)
	self.init_gravity(self.props)

    print("DEBUG: Scene001:init() done.")
end

function Scene001:render()
    print("DEBUG: Scene001:render() starting...")
    -- Initialize refs
    --local refs = self.props.refs or {}

    local sceneRoot = React.createElement(React.Fragment, {key='Scene001',
    }, {
        areaVolumeCube1 =
            React.createElement(AreaVolumeCubeSceneComponent, {
            Position = Vector3.new(0, 0, 0) }),
        axesComponent1 =
            React.createElement(AxesComponent, {
            origin = Vector3.new(0, 12, 0) }),
        blochSphereComponent1 =
            React.createElement(BlochSphereComponent, {
            Position=Vector3.new(0, 20, 0),
            Size=Vector3.new(10, 10, 10),
            Color=Color3.fromRGB(255, 0, 0),
            Material=Enum.Material.Neon,
        }),
        surfaceSphereComponent1 =
            React.createElement(SurfaceSphereComponent, {
                Position = Vector3.new(30, 15+10, 0),
                Scale = 10
            }),
        multiJumpComponent1 =
            React.createElement(MultiJumpComponent, {
            Position = Vector3.new(0, 0, 0) }),
        seesawComponent1 =
            React.createElement(SeesawComponent, {
            Position = Vector3.new(0, 0, 0) }),
        wireframeCubeComponent1 = 
            React.createElement(WireframeCubeComponent, {
            Position = Vector3.new(0, 0, 0) }),

        glowingOrbComponent1 = 
            React.createElement(GlowingOrbComponent, {
            Position = Vector3.new(0, 15, 400),
            Size = Vector3.new(10, 10, 10),
            Color = Color3.fromRGB(0, 143, 200),
            Material = Enum.Material.Neon,
        }),
        glowingOrbComponent2 = 
            React.createElement(GlowingOrbComponent, {
            Position = Vector3.new(0, 15, -400),
            Size = Vector3.new(10, 10, 10),
            Color = Color3.fromRGB(0*0.3, 143*0.3, 200*0.3),
            Material = Enum.Material.Neon,
        }),
        -- billboardAnswersComponent1 = 
        --     React.createElement(BillboardAnswersComponent, {
        --     Position = Vector3.new(0, 0, 0) }),
    })
    print("DEBUG: Scene001:render() done.")
    return sceneRoot
end

-- function init()
--     print("DEBUG: Scene001: init() starting...")

--     -- Initialize lighting
--     --init_lighting()

--     -- Load components
--     local exports = {}

--     -- Scene001


--     return exports
-- end

print("DEBUG: Scene001: done.")
return Scene001
