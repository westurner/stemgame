-- BlochSphereComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local BlochSphereComponent = React.Component:extend("BlochSphereComponent")

function BlochSphereComponent:init()
    self.props = self.props or {}
    self.props.drawLabels = self.props.drawLabels or true
end

function BlochSphereComponent:render()
    local SPHERE_RADIUS = self.props.sphereRadius or 5
    local AXIS_THICKNESS = self.props.axisThickness or 0.1
    local RING_THICKNESS = self.props.ringThickness or 0.1
    local LABEL_OFFSET = self.props.labelOffset or 1.5
    local AXIS_COLOR_X = self.props.axisColorX or Color3.fromRGB(0, 0, 255)
    local AXIS_COLOR_Y = self.props.axisColorY or Color3.fromRGB(255, 0, 0)
    local AXIS_COLOR_Z = self.props.axisColorZ or Color3.fromRGB(0, 255, 255)
    local AXIS_TRANSPARENCY_X = self.props.axisTransparencyX or self.props.axisTransparency or 0
    local AXIS_TRANSPARENCY_Y = self.props.axisTransparencyY or self.props.axisTransparency or 0
    local AXIS_TRANSPARENCY_Z = self.props.axisTransparencyZ or self.props.axisTransparency or 0
    local RING_COLOR_XY = self.props.ringColorXY or self.props.ringColor or Color3.fromRGB(100, 100, 100) -- Color3.fromRGB(112, 245, 255)
    local RING_COLOR_XZ = self.props.ringColorXZ or self.props.ringColor or Color3.fromRGB(100, 100, 100) -- Color3.fromRGB(245, 108, 108)
    local RING_COLOR_YZ = self.props.ringColorYZ or self.props.ringColor or Color3.fromRGB(100, 100, 100) -- Color3.fromRGB(50, 81, 255) 
    local RING_TRANSPARENCY_XY = self.props.ringTransparency or 0
    local RING_TRANSPARENCY_XZ = self.props.ringTransparency or 0
    local RING_TRANSPARENCY_YZ = self.props.ringTransparency or 0
    local SPHERE_COLOR = self.props.sphereColor or Color3.fromRGB(0, 0, 255)
    local SPHERE_TRANSPARENCY = self.props.sphereTransparency or 0.5
    local CENTER_POSITION = self.props.Position

    local function createPart(name, shape, size, color, transparency, position, orientation)
        return React.createElement("Part", {
            key = name,
            Shape = shape,
            Size = size,
            Color = color,
            Material = Enum.Material.Neon,
            Transparency = transparency,
            Anchored = true,
            CanCollide = false,
            CFrame = CFrame.new(position) * orientation,
        })
    end

    local function createLabel(name, text, position, textColor)
        return React.createElement("BillboardGui", {
            key = name .. "LabelGui",
            Size = UDim2.new(3, 0, 4, 0),
            StudsOffsetWorldSpace = position,
            AlwaysOnTop = true,
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

    local sphere = createPart(
        "BlochSphere",
        Enum.PartType.Ball,
        Vector3.new(SPHERE_RADIUS * 2, SPHERE_RADIUS * 2, SPHERE_RADIUS * 2),
        SPHERE_COLOR,
        SPHERE_TRANSPARENCY,
        CENTER_POSITION,
        CFrame.new()
    )

    local axisLength = SPHERE_RADIUS * 2.2
    local axisSize = Vector3.new(AXIS_THICKNESS, axisLength, AXIS_THICKNESS)

    local xAxis = createPart("XAxis", Enum.PartType.Cylinder, axisSize, AXIS_COLOR_X, AXIS_TRANSPARENCY_X, CENTER_POSITION, CFrame.Angles(0, 0, math.rad(90)))
    local yAxis = createPart("YAxis", Enum.PartType.Cylinder, axisSize, AXIS_COLOR_Y, AXIS_TRANSPARENCY_Y, CENTER_POSITION, CFrame.Angles(0, 0, 0))
    local zAxis = createPart("ZAxis", Enum.PartType.Cylinder, axisSize, AXIS_COLOR_Z, AXIS_TRANSPARENCY_Z, CENTER_POSITION, CFrame.Angles(math.rad(90), 0, 0))

    local labelDist = SPHERE_RADIUS + LABEL_OFFSET
    -- local ket="⟩"
    local sqrt2 = "√2"

    local function blockSphereLabels()
        local row1 = {"X+",   "X-",    "Y+",   "Y-",    "Z+",   "Z-"}
        --local row2 = {"1\n1", "1\n-1", "1\ni", "1\n-i", "1\n0", "0\n1"}
        local row3 = {string.format("[[%s] \n [%s]]", sqrt2, sqrt2), 
                      string.format("[[ %s] \n [%s]]", sqrt2, "-" .. sqrt2), 
                      string.format("[[%s] \n [%s]]", sqrt2, "i"), 
                      string.format("[[%s] \n [%s]]", sqrt2, "-i"), 
                      string.format("[[%s] \n [%s]]", 1, 0), 
                      string.format("[[%s] \n [%s]]", 0, 1)} 
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
    local xyRing = createPart("XY_Ring", Enum.PartType.Cylinder, Vector3.new(RING_THICKNESS, ringDiameter, ringDiameter), RING_COLOR_XY, RING_TRANSPARENCY_XY, CENTER_POSITION, CFrame.Angles(math.rad(90), 0, 0))
    local xzRing = createPart("XZ_Ring", Enum.PartType.Cylinder, Vector3.new(RING_THICKNESS, ringDiameter, ringDiameter), RING_COLOR_XZ, RING_TRANSPARENCY_XZ, CENTER_POSITION, CFrame.Angles(0, 0, math.rad(90)))
    local yzRing = createPart("YZ_Ring", Enum.PartType.Cylinder, Vector3.new(RING_THICKNESS, ringDiameter, ringDiameter), RING_COLOR_YZ, RING_TRANSPARENCY_YZ, CENTER_POSITION, CFrame.Angles(0, math.rad(90), 0))

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