
-- CameraOnPartComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local CameraOnPartComponent = React.Component:extend("CameraOnPartComponent")

function CameraOnPartComponent:init(props: {
	_ref: any, CameraSubject: any, CameraType: any, Focus: any, FieldOfView: any, VRTiltAndRollEnabled: any})
    self.props = self.props or {}
    self.props._ref = self.props._ref or React.createRef()
    self.props.CameraSubject=self.props.CameraSubject 
	self.props.CameraType=self.props.CameraType
	self.props.Focus=self.props.Focus
	self.props.FieldOfView=self.props.FieldOfView
	self.props.VRTiltAndRollEnabled=self.props.VRTiltAndRollEnabled
end

function CameraOnPartComponent:render()
	return React.createElement("Camera", {
		ref=self.props._ref,
		CameraSubject=self.props.CameraSubject,
		CameraType=self.props.CameraType,
		Focus=self.props.Focus,
		FieldOfView=self.props.FieldOfView,
		VRTiltAndRollEnabled=self.props.VRTiltAndRollEnabled,
		--Position = Vector3.new(0, 20, 0),
		--Orientation = Vector3.new(0, 0, 0),
	})
end	
	

return CameraOnPartComponent
