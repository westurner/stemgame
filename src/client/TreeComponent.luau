-- TreeComponent.luau
-- Renders a tree using block parts, branching outward from the ground

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local Lighting = game:GetService("Lighting")

local TreeComponent = React.Component:extend("TreeComponent")

-- Helper to generate branches recursively
local function createBranches(props, position, direction, depth)
    local elements = {}
    if depth == 0 then return elements end

    local branchLength = props.branchLength or 40
    local branchThickness = props.branchThickness or 8
    local color = props.branchColor or Color3.fromRGB(101, 67, 33)
    local material = Enum.Material.SmoothPlastic
    local branchCount = props.branchCount or 3
    local splitAngle = math.rad(props.branchAngle or 30) -- max outward angle from center
    local tiltAngle = math.rad(props.branchTilt or 10)   -- upward tilt
    local up = Vector3.new(0, 1, 0)

    -- Compute end position for this branch
    local safeDir = direction.Magnitude > 0 and direction.Unit or up
    local endPos = position + safeDir * branchLength
    local midPos = (position + endPos) / 2
    -- For blocks, Y axis is up, so rotate so Y points from start to end
    local branchCFrame = CFrame.lookAt(midPos, endPos) * CFrame.Angles(math.rad(90), 0, 0)

    local brightness = 0
    if (Lighting.ClockTime > 20 or Lighting.ClockTime < 5) then
        brightness = 15
    else
        brightness = 0
    end

    table.insert(elements, React.createElement("Part", {
        Size = Vector3.new(branchThickness, branchLength, branchThickness),
        CFrame = branchCFrame,
        Color = color,
        Material = material,
        Anchored = true,
        CanCollide = props.CanCollide or true,
        Name = string.format("Branch_%d", depth)
    }, {
        spotlight=React.createElement("SpotLight", {
            Brightness=brightness,
            Color=Color3.fromRGB(255,255,255),
            Face=Enum.NormalId.Bottom,
        })
    }))

    if depth > 1 then
        -- Split into n branches, evenly distributed around Y axis, all tilted upward
        local baseCFrame = CFrame.lookAt(Vector3.new(), safeDir)
        for i = 1, branchCount do
            local t = (branchCount == 1) and 0 or (i - 1) / (branchCount - 1)
            local angleY = -splitAngle + (2 * splitAngle) * t
            local branchCFrameDir = baseCFrame * CFrame.Angles(-tiltAngle, angleY, 0)
            local branchDir = branchCFrameDir.LookVector
            for _, branch in ipairs(createBranches(props, endPos, branchDir, depth - 1)) do
                table.insert(elements, branch)
            end
        end
    end
    return elements
end

function TreeComponent:init(props)
    self.props = props or {}
    self.props.Position = self.props.Position or Vector3.new(0, 0, 0)
    self.props.depth = self.props.depth or 5
    self.props.direction = self.props.direction or Vector3.new(0, 1, 0)
end

function TreeComponent:render()
    local props = self.props
    local branches = createBranches(props, props.Position, props.direction, props.depth)
    return React.createElement("Model", {
        Name = props.Name or "TreeModel",
    }, branches)
end

return TreeComponent
