-- SeesawComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local SeesawComponent = React.Component:extend("SeesawComponent")

function SeesawComponent:init()
    self.props = self.props or {}
    self.state = {}
end

function SeesawComponent:render()
    local spawnPosition = self.props.spawnPosition or Vector3.new(150, 15, 0)
    local fulcrumSize = self.props.fulcrumSize or Vector3.new(20, 10, 20)
    local fulcrumColor = self.props.fulcrumColor or Color3.fromRGB(25, 99, 184)
    local fulcrumTransparency = self.props.fulcrumTransparency or 0.1
    local leverSize = self.props.leverSize or Vector3.new(120, 0.1, 20)
    local leverColor = self.props.leverColor or Color3.fromRGB(210, 105, 30)
    local leverTransparency = self.props.leverTransparency or 0.25
    local hingeLimits = self.props.hingeLimits or { lower = -35, upper = 35 }

    local density = self.props.density or 0.7
    local friction = self.props.friction or 0.3
    local elasticity = self.props.elasticity or 0.5
    local frictionWeight = self.props.frictionWeight or 1
    local elasticityWeight = self.props.elasticityWeight or 1

    local targetAngle = self.props.targetAngle or 0
    local servoMaxTorque = self.props.servoMaxTorque or 10000
    local angularResponsiveness = self.props.angularResponsiveness or 15

    local customPhysicalProperties = PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight)

    return React.createElement("Model", {
        Name = self.props.Name or "Seesaw1",
        ref = self.props._ref,
    }, {
        Fulcrum = React.createElement("Part", {
            Name = "Fulcrum",
            Size = fulcrumSize,
            Color = fulcrumColor,
            Transparency = fulcrumTransparency,
            Material = Enum.Material.Neon,
            Anchored = true,
            Position = spawnPosition,
            Shape = Enum.PartType.Cylinder,
            --CustomPhysicalProperties = customPhysicalProperties,
        }),
        Lever = React.createElement("Part", {
            Name = "Lever",
            Size = leverSize,
            Color = leverColor,
            Transparency = leverTransparency,
            Material = Enum.Material.Neon,
            Anchored = false,
            Position = spawnPosition + Vector3.new(0, fulcrumSize.Y / 2 + leverSize.Y / 2, 0),
            Orientation = Vector3.new(0, 90, 0),
            CustomPhysicalProperties = customPhysicalProperties,
        }),
        HingeConstraint = React.createElement("HingeConstraint", {
            Name = "TeeterHinge",
            LimitsEnabled = true,
            LowerAngle = hingeLimits.lower,
            UpperAngle = hingeLimits.upper,
            ActuatorType = Enum.ActuatorType.Servo,
            TargetAngle = targetAngle,
            ServoMaxTorque = servoMaxTorque,
            AngularResponsiveness = angularResponsiveness,
        }),
    })
end

return SeesawComponent