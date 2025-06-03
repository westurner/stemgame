
-- AxisComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)


local lightenColor = function(color, shift:IntValue) 
    return Color3.new(color.R*shift, color.G*shift, color.B*shift)
end

local AxisComponent = React.Component:extend("AxisComponent")
function AxisComponent:init()
    self.props = self.props or {}
end
function AxisComponent:render()
    local axis = self.props.axis or "X"
    local axisLength = self.props.axisLength or 2000
    local axisThickness = self.props.axisThickness or 0.5
    local origin = self.props.origin or Vector3.new(0, 15, 0)
    local halfLength = axisLength / 2

    local size, position, position2, color, color2
    if axis == "X" then
        size = Vector3.new(axisLength, axisThickness, axisThickness)
        position = origin + Vector3.new(halfLength, 0, 0)
        position2 = origin + Vector3.new(-1*halfLength, 0, 0)
        color = self.props.colorX or Color3.fromRGB(0, 0, 255)
        color2 = self.props.colorX2 or lightenColor(color, 0.4)
    elseif axis == "Y" then
        size = Vector3.new(axisThickness, axisLength, axisThickness)
        position = origin + Vector3.new(0, halfLength, 0)
        position2 = origin + Vector3.new(0, -1*halfLength, 0)
        color = self.props.colorY or Color3.fromRGB(0, 255, 255)
        color2 = self.props.colorY2 or lightenColor(color, 0.3)
    elseif axis == "Z" then
        size = Vector3.new(axisThickness, axisThickness, axisLength)
        position = origin + Vector3.new(0, 0, halfLength)
        position2 = origin + Vector3.new(0, 0, -1*halfLength)
        color = self.props.colorZ or Color3.fromRGB(255, 0, 0)
        color2 = self.props.colorZ2 or lightenColor(color, 0.3)
    else
        error("Invalid axis: " .. tostring(axis))
    end

    return React.createElement(React.Fragment, {}, {
        positive=React.createElement("Part", {
            Name = "Positive" .. axis,
            Size = size,
            Color = color,
            Material = Enum.Material.Neon,
            Anchored = true,
            CanCollide = false,
            Position = position,
            ref = self.props._ref,
            [React.Event.Touched] = self.props.onTouched or function(hit)
                if hit.Parent:FindFirstChild("Humanoid") then
                    print("Touched by: " .. hit.Parent.Name)
                end
            end,
            -- [React.Event.MouseButton1Click] = self.props.onClick or function()
            --     print("Clicked on axis: " .. axis)
            -- end,
            -- [React.Event.TouchTap] = self.props.onClick or function()
            --     print("TouchTap on axis: " .. axis)
            -- end,
            -- [React.Event.MouseEnter] = self.props.onMouseEnter or function()
            --     print("Mouse entered axis: " .. axis)
            -- end,
            -- [React.Event.MouseLeave] = self.props.onMouseLeave or function()
            --     print("Mouse left axis: " .. axis)
            -- end,
        }),
        negative=React.createElement("Part", {
            Name = "Negative" .. axis,
            Size = size,
            Color = color2,
            Material = Enum.Material.Neon,
            Anchored = true,
            CanCollide = false,
            Position = position2,
            ref = self.props._ref,
            [React.Event.Touched] = self.props.onTouched or function(hit)
                if hit.Parent:FindFirstChild("Humanoid") then
                    print("Touched by: " .. hit.Parent.Name)
                end
            end,
        })
    })
end

return AxisComponent
