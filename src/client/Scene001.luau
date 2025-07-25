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
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

--local AnswerPadComponent = require(script.Parent.AnswerPadComponent)
local AreaVolumeCubeSceneComponent = require(script.Parent.AreaVolumeCube).AreaVolumeCubeSceneComponent
local AxesComponent = require(script.Parent.AxesComponent)
--local BallComponent = require(script.Parent.BallComponent)
--local BillboardAnswersComponent = require(script.Parent.BillboardAnswersComponent)
local BlochSphereComponent = require(script.Parent.BlochSphereComponent)
local SurfaceSphereComponent = require(script.Parent.SurfaceSphereComponent)
--local GlowingOrbComponent = require(script.Parent.GlowingOrbComponent)
local MultiJumpComponent = require(script.Parent.MultiJumpComponent)
local SeesawComponent = require(script.Parent.SeesawComponent)
--local SpawnLocationComponent = require(script.Parent.SpawnLocationComponent)
local WireframeCubeComponent = require(script.Parent.WireframeCubeComponent)
local TreeComponent = require(script.Parent.TreeComponent)
local TextButtonComponent = require(script.Parent.TextButtonComponent)
local DoublePendulumComponent = require(script.Parent.DoublePendulumComponent)
local AirHockeyComponent = require(script.Parent.AirHockeyComponent)

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
	-- Workspace.Gravity = 196.2 -- default is 196.2
	-- Players.LocalPlayer.Character.Humanoid.JumpHeight = 50 -- default is 50

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
        self.state = {}
    self.state.isSharedMode = true

    -- Create a ScreenGui for our UI elements
    self.playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "Scene001_UI"
    self.uiRoot = ReactRoblox.createRoot(self.screenGui)
    self.screenGui.Parent = self.playerGui

    self:renderUI()

    self.init_lighting(self.props)
    --self.init_lighting_strobe(self.props)
	self.init_cameras(self.props)
	self.init_gravity(self.props)

    print("DEBUG: Scene001:init() done.")
end

function Scene001:didUpdate(prevProps, prevState)
    if self.state.isSharedMode ~= prevState.isSharedMode then
        self:renderUI()
    end
end

function Scene001:willUnmount()
    self.uiRoot:unmount()
    self.screenGui:Destroy()
end

function Scene001:renderUI()
    local ui = React.createElement(React.Fragment, {}, {
        ModeToggleButton = React.createElement(TextButtonComponent, {
            Text = self.state.isSharedMode and "Switch to Local Mode" or "Switch to Shared Mode",
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0, 200, 0, 50),
            [React.Event.Activated] = function()
                local newMode = not self.state.isSharedMode
                self:setState({ isSharedMode = newMode })
                -- Fire event to server to notify of the change
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                ReplicatedStorage.PlayerAction:FireServer({
                    component = "modeToggle",
                    isSharedMode = newMode,
                })
            end,
        }),
    })
    self.uiRoot:render(ui)
end

function Scene001:render()
    print("DEBUG: Scene001:render() starting...")
    -- Initialize refs
    --local refs = self.props.refs or {}

    local sceneRoot = React.createElement(React.Fragment, {key='Scene001',
    }, {
        AreaVolumeCube1 =
            React.createElement(AreaVolumeCubeSceneComponent, {
            Position = Vector3.new(0, 0, 0) }),
        Axes1 =
            React.createElement(AxesComponent, {
            origin = Vector3.new(0, 12, 0) }),
        BlochSphere1 =
            React.createElement(BlochSphereComponent, {
            Position=Vector3.new(0, 20, 0),
            sphereRadius = 10,
            Color=Color3.fromRGB(255, 0, 0),
            Material=Enum.Material.Neon,
        }),
        SurfaceSphere1 =
            React.createElement(SurfaceSphereComponent, {
                Position = Vector3.new(30, 15+10, 0),
                sphereRadius = 10,
                arrowLength = 12
            }),
        MultiJump1 =
            React.createElement(MultiJumpComponent, {
            Position = Vector3.new(0, 0, 0) }),
        Seesaw1 =
            React.createElement(SeesawComponent, {
            Position = Vector3.new(0, 0, 0) }),

        -- WireframeCube1 =
        --     React.createElement(WireframeCubeComponent, {
        --         --Position = Vector3.new(-40, 25, 40),
        --         Position = Vector3.new(140, 25, -150),
        --         Size = Vector3.new(25, 25, 25)
        --     }),

        -- AxisCube1 =
        --     React.createElement(WireframeCubeComponent, {
        --         Name = "AxisCube1",
        --         Position = Vector3.new(0, 15, 400),
        --         Size = Vector3.new(10, 10, 10),
        --         lineColor = Color3.fromRGB(0, 143, 200),
        --         Material = Enum.Material.Neon,
        --     }),
        -- AxesCube2 =
        --     React.createElement(WireframeCubeComponent, {
        --         Name = "AxisCube2",
        --         Position = Vector3.new(0, 15, -400),
        --         Size = Vector3.new(10, 10, 10),
        --         lineColor = Color3.fromRGB(0*0.3, 143*0.3, 200*0.3),
        --         Material = Enum.Material.Neon,
        --     }),

        -- GlowingOrb1 =
        --     React.createElement(GlowingOrbComponent, {
        --         Position = Vector3.new(0, 15, 400),
        --         Size = Vector3.new(10, 10, 10),
        --         Color = Color3.fromRGB(0, 143, 200),
        --         Material = Enum.Material.Neon,
        --     }),
        -- GlowingOrb2 =
        --     React.createElement(GlowingOrbComponent, {
        --         Position = Vector3.new(0, 15, -400),
        --         Size = Vector3.new(10, 10, 10),
        --         Color = Color3.fromRGB(0*0.3, 143*0.3, 200*0.3),
        --         Material = Enum.Material.Neon,
        --     }),
        Tree1 =
            React.createElement(TreeComponent, {
                Position = Vector3.new(250, 5, 250)
            }),

        DoublePendulum1 =
            React.createElement(DoublePendulumComponent, {
                Position = Vector3.new(-100, 32, 42)
            }),

        AirHockey1 =
            React.createElement(AirHockeyComponent, {
                Position = Vector3.new(-100, 10, -100),
                isSharedMode = self.state.isSharedMode,
            }),

        --BillboardAnswers1 =
        --    React.createElement(BillboardAnswersComponent, {
        --    Position = Vector3.new(0, 0, 0),
        --    isSharedMode = self.state.isSharedMode,
        --}),
    })
    print("DEBUG: Scene001:render() done.")
    return sceneRoot
end

print("DEBUG: Scene001: done.")
return Scene001
