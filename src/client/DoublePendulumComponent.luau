--[[
## Prompts:
Create a double pendulum React component with props defaults in :init().
Show fading motion trails where the end of the pendulum was.

Set the motion trail fade time to 3.5 seconds


]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local TRAIL_FADE_TIME = 3.5
--local TRAIL_LENGTH = 60

local DoublePendulumComponent = React.Component:extend("DoublePendulumComponent")

function DoublePendulumComponent:init()
    self.props = self.props or {}
    self.props.origin = self.props.Position or Vector3.new(0, 20, 0)
    self.props.length1 = self.props.length1 or 10
    self.props.length2 = self.props.length2 or 10
    self.props.mass1 = self.props.mass1 or 1
    self.props.mass2 = self.props.mass2 or 1
    self.props.angle1 = self.props.angle1 or math.pi / 2
    self.props.angle2 = self.props.angle2 or math.pi / 2
    --self.props.color1 = self.props.color1 or Color3.fromRGB(255, 152, 93)
    self.props.color1 = self.props.color1 or Color3.fromRGB(255, 21, 21)
    self.props.color2 = self.props.color2 or Color3.fromRGB(255, 21, 21)
    self.props.color3 = self.props.color3 or Color3.fromRGB(0, 200, 255)
    self.props.CanCollide = self.props.CanCollide or true
    self.props.rodThickness_x = self.props.rodThickness_x or 1
    self.props.rodThickness_z = self.props.rodThickness_z or 0.5
    self.props.rod1_Transparency = self.props.rod1_Transparency or 0.9
    self.props.rod2_Transparency = self.props.rod2_Transparency or 0.9
    self.props.ballRadius = self.props.ballRadius or 2
    self.props.ballRadiusTrail = self.props.ballRadiusTrail or (self.props.ballRadius*0.7)
    self.props.ball0_Transparency = self.props.ball1_Transparency or 0.3
    self.props.ball1_Transparency = self.props.ball1_Transparency or 0.3
    self.props.ball2_Transparency = self.props.ball2_Transparency or 0
    self:setState({
        angle1 = self.props.angle1,
        angle2 = self.props.angle2,
        vel1 = 0,
        vel2 = 0,
        trail = {},
    })
    self._running = true
end

function DoublePendulumComponent:willUnmount()
    self._running = false
end

function DoublePendulumComponent:didMount()
    coroutine.wrap(function()
        local g = 9.81
        while self._running do
            local a1 = self.state.angle1
            local a2 = self.state.angle2
            local v1 = self.state.vel1
            local v2 = self.state.vel2
            local m1 = self.props.mass1
            local m2 = self.props.mass2
            local l1 = self.props.length1
            local l2 = self.props.length2
            -- Equations of motion (simplified RK4 step)
            local num1 = -g * (2 * m1 + m2) * math.sin(a1)
            local num2 = -m2 * g * math.sin(a1 - 2 * a2)
            local num3 = -2 * math.sin(a1 - a2) * m2
            local num4 = v2 * v2 * l2 + v1 * v1 * l1 * math.cos(a1 - a2)
            local den = l1 * (2 * m1 + m2 - m2 * math.cos(2 * a1 - 2 * a2))
            local acc1 = (num1 + num2 + num3 * num4) / den

            num1 = 2 * math.sin(a1 - a2)
            num2 = v1 * v1 * l1 * (m1 + m2)
            num3 = g * (m1 + m2) * math.cos(a1)
            num4 = v2 * v2 * l2 * m2 * math.cos(a1 - a2)
            den = l2 * (2 * m1 + m2 - m2 * math.cos(2 * a1 - 2 * a2))
            local acc2 = (num1 * (num2 + num3 + num4)) / den

            v1 = v1 + acc1 * 0.03
            v2 = v2 + acc2 * 0.03
            a1 = a1 + v1 * 0.03
            a2 = a2 + v2 * 0.03

            -- Calculate positions
            local origin = self.props.origin
            local p1 = origin + Vector3.new(
                self.props.length1 * math.sin(a1),
                -self.props.length1 * math.cos(a1),
                0)
            local p2 = p1 + Vector3.new(
                self.props.length2 * math.sin(a2),
                -self.props.length2 * math.cos(a2),
                0)
            local now = os.clock()
            local newTrail = table.clone(self.state.trail)
            table.insert(newTrail, {pos = p2, time = now})
            while #newTrail > 0 and now - newTrail[1].time > TRAIL_FADE_TIME do
                table.remove(newTrail, 1)
            end
            self:setState({
                angle1 = a1,
                angle2 = a2,
                vel1 = v1,
                vel2 = v2,
                trail = newTrail,
            })
            task.wait(0.03)
        end
    end)()
end

function DoublePendulumComponent:render()
    local origin = self.props.origin
    local l1 = self.props.length1
    local l2 = self.props.length2
    local a1 = self.state.angle1
    local a2 = self.state.angle2
    local color1 = self.props.color1
    local color2 = self.props.color2
    local color3 = self.props.color3
    local rodThickness_x = self.props.rodThickness_x
    local rodThickness_z = self.props.rodThickness_z
    local rod1_Transparency = self.props.rod1_Transparency
    local rod2_Transparency = self.props.rod2_Transparency
    local ballRadius = self.props.ballRadius
    local ballRadiusTrail = self.props.ballRadiusTrail
    local ball0_Transparency = self.props.ball0_Transparency
    local ball1_Transparency = self.props.ball1_Transparency
    local ball2_Transparency = self.props.ball2_Transparency
    local canCollide = self.props.CanCollide
    local p1 = origin + Vector3.new(l1 * math.sin(a1), -l1 * math.cos(a1), 0)
    local p2 = p1 + Vector3.new(l2 * math.sin(a2), -l2 * math.cos(a2), 0)
    local children = {
        Ball0 = React.createElement("Part", {
            Anchored = true,
            CanCollide = false,
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(ballRadius, ballRadius, ballRadius),
            Position = origin,
            Color = color1,
            Material = Enum.Material.Neon,
            Transparency = ball0_Transparency,
        }),
        Rod1 = React.createElement("Part", {
            Anchored = true,
            CanCollide = canCollide,
            Size = Vector3.new(rodThickness_x, (p1 - origin).Magnitude, rodThickness_z),
            CFrame = CFrame.new((origin + p1)/2, p1) * CFrame.Angles(math.rad(90), math.rad(90), 0),
            Color = color1,
            Material = Enum.Material.Neon,
            Transparency = rod1_Transparency,
        }),
        Ball1 = React.createElement("Part", {
            Anchored = true,
            CanCollide = false,
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(ballRadius, ballRadius, ballRadius),
            Position = p1,
            Color = color2,
            Material = Enum.Material.Neon,
            Transparency = ball1_Transparency,
        }),
        Rod2 = React.createElement("Part", {
            Anchored = true,
            CanCollide = canCollide,
            Size = Vector3.new(rodThickness_x, (p2 - p1).Magnitude, rodThickness_z),
            CFrame = CFrame.new((p1 + p2)/2, p2) * CFrame.Angles(0, math.rad(90), math.rad(90)),
            Color = color2,
            Material = Enum.Material.Neon,
            Transparency = rod2_Transparency,
        }),
        Ball2 = React.createElement("Part", {
            Anchored = true,
            CanCollide = false,
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(ballRadius, ballRadius, ballRadius),
            Position = p2,
            Color = color3,
            Material = Enum.Material.Neon,
            Transparency = ball2_Transparency,
        }),
    }
    -- Fading trail
    for i, point in ipairs(self.state.trail) do
        local fade = math.clamp(1 - (os.clock() - point.time) / TRAIL_FADE_TIME, 0, 1)
        children["TrailPoint"..i] = React.createElement("Part", {
            Anchored = true,
            CanCollide = false,
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(ballRadiusTrail, ballRadiusTrail, ballRadiusTrail),
            Position = point.pos,
            Color = color3,
            Material = Enum.Material.Neon,
            Transparency = 1.2 - fade,
        })
    end
    return React.createElement("Model", nil, children)
end

return DoublePendulumComponent
