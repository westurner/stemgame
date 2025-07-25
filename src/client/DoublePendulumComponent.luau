--[[
## Prompts:
Create a double pendulum React component with props defaults in :init().
Show fading motion trails where the end of the pendulum was.

Set the motion trail fade time to 3.5 seconds


]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local SharedStateManager = require(game.StarterPlayer.StarterPlayerScripts.Client.SharedStateManager)

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
    self.props.ball0_Transparency = self.props.ball0_Transparency or 0.3
    self.props.ball1_Transparency = self.props.ball1_Transparency or 0.3
    self.props.ball2_Transparency = self.props.ball2_Transparency or 0
    self.state = {}
    self.state.angle1 = self.props.angle1
    self.state.angle2 = self.props.angle2
    self.state.vel1 = 0
    self.state.vel2 = 0
    self.state.trail = {}
    self._running = true
end

function DoublePendulumComponent:willUnmount()
    self._running = false
    if self.unsubscribe then
        self.unsubscribe()
    end
end

function DoublePendulumComponent:didMount()
    print("DEBUG: DoublePendulumComponent:didMount() called.")
    print('props')
    print(self.props)
    print('state')
    print(self.state)
    --print(string.format("DEBUG: Raw self.props.length1: %s (type: %s)", tostring(self.props.length1), type(self.props.length1)))
    --print(string.format("DEBUG: Raw self.props.mass1: %s (type: %s)", tostring(self.props.mass1), type(self.props.mass1)))
    --print(string.format("DEBUG: Raw self.props.angle1: %s (type: %s)", tostring(self.props.angle1), type(self.props.angle1)))

    if self.props.isSharedMode then
        self._running = false -- Stop local simulation
        self.unsubscribe = SharedStateManager:subscribe("doublePendulum", function(pendulumState)
            self:setState({
                angle1 = pendulumState.angle1,
                angle2 = pendulumState.angle2,
                vel1 = pendulumState.vel1,
                vel2 = pendulumState.vel2,
                trail = pendulumState.trail or {},
            })
        end)
    else
        coroutine.wrap(function()
            local g = 9.81
            while self._running do
                local origin = self.props.origin or Vector3.new(0,0,0)

                local a1 = type(self.state.angle1) == "number" and self.state.angle1 or self.props.angle1
                local a2 = type(self.state.angle2) == "number" and self.state.angle2 or self.props.angle2
                local v1 = type(self.state.vel1) == "number" and self.state.vel1 or 0
                local v2 = type(self.state.vel2) == "number" and self.state.vel2 or 0
                local m1 = type(self.props.mass1) == "number" and self.props.mass1 or 1
                local m2 = type(self.props.mass2) == "number" and self.props.mass2 or 1
                local l1 = type(self.props.length1) == "number" and self.props.length1 or 10
                local l2 = type(self.props.length2) == "number" and self.props.length2 or 10

                -- Debugging print statement
                --print(string.format("DEBUG: didMount loop - l1: %s (%s), m1: %s (%s), m2: %s (%s), a1: %s (%s)",
                --    tostring(l1), type(l1), tostring(m1), type(m1), tostring(m2), type(m2), tostring(a1), type(a1)))

                -- Explicit check for nil values before calculation
                assert(type(g) == "number", "g is not a number: " .. tostring(g))
                assert(type(m1) == "number", "m1 is not a number: " .. tostring(m1))
                assert(type(m2) == "number", "m2 is not a number: " .. tostring(m2))
                assert(type(a1) == "number", "a1 is not a number: " .. tostring(a1))
                assert(origin ~= nil, "origin should not be nil: " .. tostring(origin))

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

                -- Check for NaN or Inf and reset if necessary
                if acc1 ~= acc1 or acc1 == math.huge or acc1 == -math.huge then
                    print("DEBUG: DoublePendulumComponent: acc1 is NaN or Inf, resetting simulation.")
                    a1 = self.props.angle1
                    a2 = self.props.angle2
                    v1 = 0
                    v2 = 0
                    self:setState({
                        angle1 = a1,
                        angle2 = a2,
                        vel1 = v1,
                        vel2 = v2,
                        trail = {},
                    })
                    task.wait(0.1) -- Give it a moment to reset
                    continue -- Skip the rest of this iteration
                end
                if acc2 ~= acc2 or acc2 == math.huge or acc2 == -math.huge then
                    print("DEBUG: DoublePendulumComponent: acc2 is NaN or Inf, resetting simulation.")
                    a1 = self.props.angle1
                    a2 = self.props.angle2
                    v1 = 0
                    v2 = 0
                    self:setState({
                        angle1 = a1,
                        angle2 = a2,
                        vel1 = v1,
                        vel2 = v2,
                        trail = {},
                    })
                    task.wait(0.1) -- Give it a moment to reset
                    continue -- Skip the rest of this iteration
                end

                v1 = v1 + acc1 * 0.03
                v2 = v2 + acc2 * 0.03
                a1 = a1 + v1 * 0.03
                a2 = a2 + v2 * 0.03

                -- Calculate positions
                local p1 = origin + Vector3.new(
                    l1 * math.sin(a1),
                    -l1 * math.cos(a1),
                    0)
                local p2 = p1 + Vector3.new(
                    l2 * math.sin(a2),
                    -l2 * math.cos(a2),
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
                    origin = origin,
                })
                task.wait(0.03)
            end
        end)()
    end
end

function DoublePendulumComponent:render()

    --print("DEBUG: DoublePendulumComponent:render() called.")
    --print('props')
    --print(self.props)
    --print('state')
    --print(self.state)

    local origin = self.state.origin or self.props.origin
    assert(origin ~= nil, "origin should not be nil: " .. tostring(origin))


    local l1 = self.state.length1 or self.props.length1 or 1
    local l2 = self.state.length2 or self.props.length2 or 1
    local a1 = type(self.state.angle1) == "number" and self.state.angle1 or self.props.angle1
    local a2 = type(self.state.angle2) == "number" and self.state.angle2 or self.props.angle2
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
