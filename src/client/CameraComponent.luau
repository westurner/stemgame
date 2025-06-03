
-- CameraComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local CameraOnPartComponent = require(script.Parent.CameraOnPartComponent)
local CameraComponent = React.Component:extend("CameraComponent")
function CameraComponent:render()
	return React.createElement(CameraOnPartComponent, {
		ref=self.props._ref,
		CameraSubject=self.props.CameraSubject,
		CameraType=self.props.CameraType,
		Focus=self.props.Focus,
	})
end

return CameraComponent