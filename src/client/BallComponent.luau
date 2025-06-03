
-- BallComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local BallComponent = React.Component:extend("BallComponent")

function BallComponent:init()
    self.props = self.props or {}
    self.props._ref = self.props._ref or React.createRef()
    self.props.Size=self.props.Size or Vector3.new(7,7,7)
    self.props.Color=self.props.Color or Color3.new(0.7, 0, 0)
    self.props.Material=self.props.Material or Enum.Material.Neon
    self.props.Position=self.props.Position or Vector3.new(0,20,0)
    self.props.Shape=self.props.Shape or Enum.PartType.Ball
end

function BallComponent:render()
	return React.createElement("Part", {
			ref=self.props._ref,
			Shape=self.props.Shape,
			Size=self.props.Size,
			Color=self.props.Color,
			Material=self.props.Material,
			Position=self.props.Position,
            Shape=self.props.Shape,
		})
end

return BallComponent
