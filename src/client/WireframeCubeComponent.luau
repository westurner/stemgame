-- WireframeCubeComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local WireframeCubeComponent = React.Component:extend("WireframeCubeComponent")

function WireframeCubeComponent:init()
    self.props = self.props or {}
end

function WireframeCubeComponent:render()
    local blockCenter = self.props.centerPosition or Vector3.new(0, 20, 15)
    local blockSize = self.props.size or Vector3.new(12, 12, 12)
    local lineThickness = self.props.lineThickness or 0.1
    local lineColor = self.props.lineColor or Color3.fromRGB(0, 255, 0)

    local model = Instance.new("Model")
    model.Name = self.props.Name or "WireframeCube1"

    -- Create the main glass block part
    local block = Instance.new("Part")
    block.Name = "GlassBlock"
    block.Size = blockSize
    block.Color = Color3.fromRGB(220, 220, 220) -- Light grey/white
    block.Material = Enum.Material.Glass
    block.Transparency = 0.8
    block.Anchored = true
    block.CanCollide = false
    block.TopSurface = Enum.SurfaceType.Smooth
    block.BottomSurface = Enum.SurfaceType.Smooth
    block.Parent = model
    block:PivotTo(CFrame.new(blockCenter))

    -- Calculate vertex positions in world space
    local blockCFrame = block:GetPivot()
    local halfSize = block.Size / 2
    local vertices = {
        blockCFrame * Vector3.new(halfSize.X, halfSize.Y, halfSize.Z),   -- +++ 1
        blockCFrame * Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),  -- ++- 2
        blockCFrame * Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),  -- +-+ 3
        blockCFrame * Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z), -- +-- 4
        blockCFrame * Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),  -- -++ 5
        blockCFrame * Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z), -- -+- 6
        blockCFrame * Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z), -- --+ 7
        blockCFrame * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z) -- --- 8
    }

    local edges = self.props.edges or {
        {1, 2}, {3, 4}, {5, 6}, {7, 8}, -- Edges along Z
        {1, 3}, {2, 4}, {5, 7}, {6, 8}, -- Edges along Y
        {1, 5}, {2, 6}, {3, 7}, {4, 8}, -- Edges along X
    }

    local edgesAdditional = self.props.edgesAdditional or {}

    -- Combine edges and edgesAdditional
    for _, edge in ipairs(edgesAdditional) do
        table.insert(edges, edge)
    end

    -- Create line parts for each edge
    for i, edgeIndices in ipairs(edges) do
        local v1Index = edgeIndices[1]
        local v2Index = edgeIndices[2]
        local v1 = vertices[v1Index]
        local v2 = vertices[v2Index]

        local distance = (v1 - v2).Magnitude
        local midpoint = (v1 + v2) / 2

        local edgePart = Instance.new("Part")
        edgePart.Name = "Edge" .. i
        edgePart.Material = Enum.Material.Neon
        edgePart.Color = lineColor
        edgePart.Size = Vector3.new(lineThickness, lineThickness, distance)
        edgePart.Anchored = true
        edgePart.CanCollide = false
        edgePart.TopSurface = Enum.SurfaceType.Smooth
        edgePart.BottomSurface = Enum.SurfaceType.Smooth
        edgePart.Parent = model

        -- Position and orient the edge part
        local edgeCFrame = CFrame.lookAt(midpoint, v2)
        edgePart:PivotTo(edgeCFrame)
    end

    -- Set the primary part for easier manipulation (optional)
    model.PrimaryPart = block

    return React.createElement("Model", {
        Name = model.Name,
        ref = self.props._ref,
    }, model:GetChildren())
end

return WireframeCubeComponent
