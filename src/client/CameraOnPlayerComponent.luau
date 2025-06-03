
-- CameraOnPlayerComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local CameraOnPartComponent = require(script.Parent.CameraOnPartComponent)

local CameraOnPlayerComponent = React.Component:extend("CameraOnPlayerComponent")
function CameraOnPlayerComponent:init(props: {
	_ref: any, CameraSubject: any, CameraType: any, Focus: any, FieldOfView: any, VRTiltAndRollEnabled: any})
	self.props = self.props or {}
	self.props._ref = self.props._ref or React.createRef()
	self.props.CameraSubject=self.props.CameraSubject 
	self.props.CameraType=self.props.CameraType
	self.props.Focus=self.props.Focus
	self.props.FieldOfView=self.props.FieldOfView
	self.props.VRTiltAndRollEnabled=self.props.VRTiltAndRollEnabled
end

function CameraOnPlayerComponent:render()
	return React.createElement(CameraOnPartComponent, {
		ref=self.props.ref,
		CameraSubject=self.props.CameraSubject,
		--CameraSubject=game:getService("Players").LocalPlayer:WaitForChild("Character"):WaitForChild("Humanoid"),
		--TODO: LocalPlayer.Character.Humanoid is not yet available,
		CameraType=self.props.CameraType,
		Focus=self.props.Focus,
		FieldOfView=self.props.FieldOfView,
		VRTiltAndRollEnabled=self.props.VRTiltAndRollEnabled,
	})
end

return CameraOnPlayerComponent