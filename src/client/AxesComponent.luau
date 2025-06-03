
-- AxisComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local AxisComponent = require(script.Parent.AxisComponent)


local AxesComponent = React.Component:extend("AxisComponent")
function AxesComponent:init()
    self.props = self.props or {}
end
function AxesComponent:render()
    return React.createElement("Model", {
        Name="AxesComponent"
    }, {
        X=React.createElement(AxisComponent, {axis="X", origin=self.props.origin}),
        Y=React.createElement(AxisComponent, {axis="Y", origin=self.props.origin}),
        Z=React.createElement(AxisComponent, {axis="Z", origin=self.props.origin}),
    })
end

return AxesComponent
