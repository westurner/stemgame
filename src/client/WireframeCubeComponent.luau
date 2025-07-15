-- WireframeCubeComponent

print("DEBUG: WireframeCubeComponent: Starting...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local WireframeCubeComponent = React.Component:extend("WireframeCubeComponent")

function WireframeCubeComponent:init()
    print("DEBUG: WireframeCubeComponent:init() ... Starting")
    self.props = self.props or {}
    self.props.Name = self.props.Name or self.props.key or "WireframeCube1"
    self.props.blockCenter = self.props.Position or Vector3.new(0, 20, 15)
    self.props.blockSize = self.props.Size or Vector3.new(12, 12, 12)
    self.props.lineThickness = self.props.lineThickness or 0.2
    self.props.lineColor = self.props.lineColor or Color3.fromRGB(0, 255, 0)
    self.props.blockColor = self.props.blockColor or Color3.fromRGB(220, 220, 220) -- Light grey/white
    self.props.lineMaterial = self.props.lineMaterial or Enum.Material.Neon
    self.props.Transparency = self.props.Transparency or 0.8
    self.props.Material = self.props.Material or Enum.Material.Glass
    self.props.Anchored = self.props.Anchored or true
    self.props.CanCollide = self.props.CanCollide or false

    print("DEBUG: WireframeCubeComponent:init() ... Done")
end

function WireframeCubeComponent:render()
    print("DEBUG: WireframeCubeComponent:render() ... Starting")

    local props = self.props

    local blockCenter = props.blockCenter
    local blockSize = props.blockSize
    local lineThickness = props.lineThickness
    local lineColor = props.lineColor

    local model = Instance.new("Model")
    --model.Name = self.props.Name

    -- Create the main glass block part
    local block = Instance.new("Part")
    block.Name = "GlassBlock"
    block.Size = blockSize
    block.Color = props.blockColor
    block.Material = props.Material
    block.Transparency = props.Transparency
    block.Anchored = props.Anchored
    block.CanCollide = props.CanCollide
    block.TopSurface = Enum.SurfaceType.Smooth
    block.BottomSurface = Enum.SurfaceType.Smooth

    block.Parent = model
    block:PivotTo(CFrame.new(blockCenter))

    -- Calculate vertex positions in world space
    local blockCFrame = block:GetPivot()
    local halfSize = block.Size / 2
    local vertices = props.vertices or {
        blockCFrame * Vector3.new(halfSize.X, halfSize.Y, halfSize.Z),   -- +++ 1
        blockCFrame * Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),  -- ++- 2
        blockCFrame * Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),  -- +-+ 3
        blockCFrame * Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z), -- +-- 4
        blockCFrame * Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),  -- -++ 5
        blockCFrame * Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z), -- -+- 6
        blockCFrame * Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z), -- --+ 7
        blockCFrame * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z) -- --- 8
    }

    local edges = props.edges or {
        {1, 2}, {3, 4}, {5, 6}, {7, 8}, -- Edges along Z
        {1, 3}, {2, 4}, {5, 7}, {6, 8}, -- Edges along Y
        {1, 5}, {2, 6}, {3, 7}, {4, 8}, -- Edges along X
    }

    local edgesAdditional = props.edgesAdditional or {}

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
        edgePart.Material = props.lineMaterial
        edgePart.Color = lineColor
        edgePart.Size = Vector3.new(lineThickness, lineThickness, distance)
        edgePart.Anchored = props.Anchored
        edgePart.CanCollide = props.CanCollide
        edgePart.TopSurface = Enum.SurfaceType.Smooth
        edgePart.BottomSurface = Enum.SurfaceType.Smooth
        edgePart.Parent = model

        -- Position and orient the edge part
        local edgeCFrame = CFrame.lookAt(midpoint, v2)
        edgePart:PivotTo(edgeCFrame)
    end

    -- Set the primary part for easier manipulation (optional)
    --model.PrimaryPart = block

    local children = model:GetChildren()
    print("DEBUG: WireframeCubeComponent: children=" .. tostring(children))
    print(children)
    print("DEBUG: WireframeCubeComponent:render() ... Done")

    -- Convert children to React elements
    local reactChildren = {}
    for i, child in ipairs(children) do
        reactChildren[i] = React.createElement(child.ClassName, {
            Name = child.Name,
            Size = child.Size,
            Color = child.Color,
            Material = child.Material,
            Transparency = child.Transparency,
            Anchored = child.Anchored,
            CanCollide = child.CanCollide,
            TopSurface = child.TopSurface,
            BottomSurface = child.BottomSurface,
            CFrame = child:GetPivot(),
        })
    end

    return React.createElement("Model", {
        Name = self.props.Name,
        ref = self.props._ref,
    }, reactChildren)
end

return WireframeCubeComponent
