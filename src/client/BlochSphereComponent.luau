-- BlochSphereComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local SharedStateManager = require(game.StarterPlayer.StarterPlayerScripts.Client.SharedStateManager)

local BlochSphereComponent = React.Component:extend("BlochSphereComponent")

function BlochSphereComponent:init()
    self.props = self.props or {}
    self.props.drawLabels = self.props.drawLabels or true
    self.props.axisColorX = self.props.axisColorX or Color3.fromRGB(0, 0, 255)
    self.props.axisColorY = self.props.axisColorY or Color3.fromRGB(255, 0, 0)
    self.props.axisColorZ = self.props.axisColorZ or Color3.fromRGB(0, 255, 255)
    self.props.axisMaterial = self.props.axisMaterial or Enum.Material.Neon
    self.props.axisThickness = self.props.axisThickness or 0.1
    self.props.axisTransparencyX = self.props.axisTransparencyX or self.props.axisTransparency or 0
    self.props.axisTransparencyY = self.props.axisTransparencyY or self.props.axisTransparency or 0
    self.props.axisTransparencyZ = self.props.axisTransparencyZ or self.props.axisTransparency or 0
    self.props.labelOffset = self.props.labelOffset or 1.5
    self.props.ringColorXY = self.props.ringColorXY or self.props.ringColor or Color3.fromRGB(100, 100, 100)
    self.props.ringColorXZ = self.props.ringColorXZ or self.props.ringColor or Color3.fromRGB(100, 100, 100)
    self.props.ringColorYZ = self.props.ringColorYZ or self.props.ringColor or Color3.fromRGB(100, 100, 100)
    self.props.ringMaterial = self.props.ringMaterial or Enum.Material.Neon
    self.props.ringThickness = self.props.ringThickness or 0.1
    self.props.ringTransparency = self.props.ringTransparency or 0
    self.props.sphereColor = self.props.sphereColor or Color3.fromRGB(0, 0, 255)
    self.props.sphereMaterial = self.props.sphereMaterial or Enum.Material.Neon
    self.props.sphereRadius = self.props.sphereRadius or self.props.Scale or 5
    self.props.sphereTransparency = self.props.sphereTransparency or 0.5
end

function BlochSphereComponent:render()
    local props = self.props
    local AXIS_COLOR_X = props.axisColorX
    local AXIS_COLOR_Y = props.axisColorY
    local AXIS_COLOR_Z = props.axisColorZ
    local AXIS_MATERIAL = props.axisMaterial
    local AXIS_THICKNESS = props.axisThickness
    local AXIS_TRANSPARENCY_X = props.axisTransparencyX
    local AXIS_TRANSPARENCY_Y = props.axisTransparencyY
    local AXIS_TRANSPARENCY_Z = props.axisTransparencyZ
    local CENTER_POSITION = props.Position
    local LABEL_OFFSET = props.labelOffset or 1.5
    local RING_COLOR_XY = props.ringColorXY
    local RING_COLOR_XZ = props.ringColorXZ
    local RING_COLOR_YZ = props.ringColorYZ
    local RING_MATERIAL = props.ringMaterial
    local RING_THICKNESS = props.ringThickness
    local RING_TRANSPARENCY_XY = props.ringTransparency
    local RING_TRANSPARENCY_XZ = props.ringTransparency
    local RING_TRANSPARENCY_YZ = props.ringTransparency
    local SPHERE_COLOR = props.sphereColor
    local SPHERE_MATERIAL = props.sphereMaterial
    local SPHERE_RADIUS = props.sphereRadius
    local SPHERE_TRANSPARENCY = props.sphereTransparency

    local sphere = React.createElement("Part", {
        key = "BlochSphere",
        Shape = Enum.PartType.Ball,
        Size = Vector3.new(SPHERE_RADIUS * 2, SPHERE_RADIUS * 2, SPHERE_RADIUS * 2),
        Color = SPHERE_COLOR,
        Material = SPHERE_MATERIAL,
        Transparency = SPHERE_TRANSPARENCY,
        Anchored = true,
        CanCollide = false,
        CFrame = CFrame.new(CENTER_POSITION),
        TopSurface = Enum.SurfaceType.Smooth
    })

    local axisLength = SPHERE_RADIUS * 2.2
    local axisSize = Vector3.new(AXIS_THICKNESS, axisLength, AXIS_THICKNESS)

    local xAxis = React.createElement("Part", {
        key = "XAxis",
        Shape = Enum.PartType.Cylinder,
        Size = axisSize,
        Color = AXIS_COLOR_X,
        Material = AXIS_MATERIAL,
        Transparency = AXIS_TRANSPARENCY_X,
        Anchored = true,
        CanCollide = false,
        CFrame = CFrame.new(CENTER_POSITION) * CFrame.Angles(0, 0, math.rad(90)),
    })
    local yAxis = React.createElement("Part", {
        key = "YAxis",
        Shape = Enum.PartType.Cylinder,
        Size = axisSize,
        Color = AXIS_COLOR_Y,
        Material = AXIS_MATERIAL,
        Transparency = AXIS_TRANSPARENCY_Y,
        Anchored = true,
        CanCollide = false,
        CFrame = CFrame.new(CENTER_POSITION) * CFrame.Angles(0, 0, 0),
    })
    local zAxis = React.createElement("Part", {
        key = "ZAxis",
        Shape = Enum.PartType.Cylinder,
        Size = axisSize,
        Color = AXIS_COLOR_Z,
        Material = AXIS_MATERIAL,
        Transparency = AXIS_TRANSPARENCY_Z,
        Anchored = true,
        CanCollide = false,
        CFrame = CFrame.new(CENTER_POSITION) * CFrame.Angles(math.rad(90), 0, 0),
    })


    local function createLabel(name, text, position, textColor)
        return React.createElement("BillboardGui", {
            key = name .. "LabelGui",
            Size = UDim2.new(3, 0, 4, 0),
            StudsOffsetWorldSpace = position,
            --AlwaysOnTop = true,
            LightInfluence = 0,
        }, {
            TextLabel = React.createElement("TextLabel", {
                Name = name .. "Label",
                BackgroundColor3 = Color3.new(0,0,0),
                BackgroundTransparency = 0.7,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.SourceSansBold,
                Text = text,
                TextColor3 = textColor or Color3.fromRGB(255, 255, 255),
                TextScaled = true,
            })
        })
    end

    local labelDist = SPHERE_RADIUS + LABEL_OFFSET
    local sqrt2 = "√2"
    local function blockSphereLabels()
        local row1 = {"X+",   "X-",    "Y+",   "Y-",    "Z+",   "Z-"}
        local row3 = {string.format("[[%s] \n [%s]]", sqrt2, sqrt2), 
                      string.format("[[ %s] \n [%s]]", sqrt2, "-" .. sqrt2), 
                      string.format("[[%s] \n [%s]]", sqrt2, "i"), 
                      string.format("[[%s] \n [%s]]", sqrt2, "-i"), 
                      string.format("[[%s] \n [%s]]", "1", "0"), 
                      string.format("[[%s] \n [%s]]", "0", "1")} 
        local color = {AXIS_COLOR_X, AXIS_COLOR_X, AXIS_COLOR_Y, AXIS_COLOR_Y, AXIS_COLOR_Z, AXIS_COLOR_Z}
        local offsets = {
            Vector3.new(labelDist, 0, 0),
            Vector3.new(-labelDist, 0, 0),
            Vector3.new(0, 0, -labelDist),
            Vector3.new(0, 0, labelDist),
            Vector3.new(0, labelDist, 0),
            Vector3.new(0, -labelDist, 0)
        }
        local labels = {}
        for i, label in ipairs(row1) do
            labels[i] = {row1=label, row3=row3[i],
                        all=string.format("%s\n%s", row1[i], row3[i]),
                        offset=offsets[i],
                        color=color[i]
                    }
        end
        return labels
    end

    local labels = {}
    if self.props.drawLabels then
        for i, label in ipairs(blockSphereLabels()) do
            labels[i] = createLabel(label.row1 .. "Label", label.all, label.offset, label.color)
        end
    end

    local ringDiameter = SPHERE_RADIUS * 2
    local xyRing = React.createElement("Part", {
        key = "XY_Ring",
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(RING_THICKNESS, ringDiameter, ringDiameter),
        Color = RING_COLOR_XY,
        Material = RING_MATERIAL,
        Transparency = RING_TRANSPARENCY_XY,
        Anchored = true,
        CanCollide = false,
        CFrame = CFrame.new(CENTER_POSITION) * CFrame.Angles(math.rad(90), 0, 0),
    })
    local xzRing = React.createElement("Part", {
        key = "XZ_Ring",
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(RING_THICKNESS, ringDiameter, ringDiameter),
        Color = RING_COLOR_XZ,
        Material = RING_MATERIAL,
        Transparency = RING_TRANSPARENCY_XZ,
        Anchored = true,
        CanCollide = true,
        CFrame = CFrame.new(CENTER_POSITION) * CFrame.Angles(0, 0, math.rad(90)),
    })
    local yzRing = React.createElement("Part", {
        key = "YZ_Ring",
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(RING_THICKNESS, ringDiameter, ringDiameter),
        Color = RING_COLOR_YZ,
        Material = RING_MATERIAL,
        Transparency = RING_TRANSPARENCY_YZ,
        Anchored = true,
        CanCollide = false,
        CFrame = CFrame.new(CENTER_POSITION) * CFrame.Angles(0, math.rad(90), 0),
    })

    return React.createElement("Model", {
        key = "BlochSphere1",
        ref = self.props._ref,
    }, {
        sphere,
        yAxis,
        zAxis,
        xAxis,
        xyRing,
        xzRing,
        yzRing,
        unpack(labels),
    })
end

return BlochSphereComponent