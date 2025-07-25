-- GlowingOrbComponent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local TweenService = game:GetService("TweenService")
--local RunService = game:GetService("RunService")
--local Players = game:GetService("Players")
local TweenInfo  = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0)


local GlowingOrbComponent = React.Component:extend("GlowingOrbComponent")

function GlowingOrbComponent:init()
    self.props = self.props or {}
    self.props.glowColor = self.props.glowColor or Color3.fromRGB(120, 0, 0)
    self.props.Size = self.props.Size or Vector3.new(10, 10, 10)
    self.props.Transparency = self.props.Transparency or 0
    self.props.Anchored = self.props.Anchored or true
    self.props.CanCollide = self.props.CanCollide or false
    self.props.Material = self.props.Material or Enum.Material.Neon
    -- self.state = self.state or {}
    -- self.state.isGlowing = self.state.isGlowing or false
    -- self.state.glowTween = nil
    self.state = {}
    self.state.isGlowing = false
    self.state.glowTween = nil
end

function GlowingOrbComponent:didMount()
    self:setupGlowTween()
end

function GlowingOrbComponent:willUnmount()
    if self.state.glowTween then
        self.state.glowTween:Cancel()
    end
end

function GlowingOrbComponent:setupGlowTween()
    local glowTween = TweenService:Create(self.props.orb, TweenInfo, { Color = self.props.glowColor })
    glowTween.Completed:Connect(function()
        self:setState({ isGlowing = not self.state.isGlowing })
        if self.state.isGlowing then
            self:setupGlowTween()
        end
    end)
    glowTween:Play()
    self:setState({ glowTween = glowTween })
end

function GlowingOrbComponent:render()

    return React.createElement("Part", {
        ref = function(ref)
            self.props.orb = ref
        end,
        Size = self.props.Size,
        Color = self.props.glowColor,
        Position = self.props.Position,
        Anchored = self.props.Anchored,
        CanCollide = self.props.CanCollide,
        Material = self.props.Material,
        Transparency = self.props.Transparency,
    })
end

return GlowingOrbComponent