
-- TextButtonComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local TextButtonComponent = React.Component:extend("TextButtonComponent")

function TextButtonComponent:init()
    self.props = self.props or {}
    self.props._ref = self.props._ref or React.createRef()
    self.props.Size=self.props.Size or Vector3.new(7,7,7)
    self.props.Position=self.props.Position or Vector3.new(0,20,0)
    self.props.TextSize=self.props.TextSize or 32
    self.props.Text=self.props.Text or "Click Me"
    self.props.BorderSizePixel=self.props.BorderSizePixel or 4
    self.props.BackgroundTransparency=self.props.BackgroundTransparency or 0.5
    self.props.Visisble=self.props.Visible or true
end

function TextButtonComponent:render()
    return React.createElement("TextButton", {
        Text=tostring(self.props.Text),
        TextSize=self.props.TextSize,
        Position=self.props.Position,
        Size=self.props.Size,
        BorderSizePixel=self.props.BorderSizePixel,
        Visible=self.props.Visible,
        Active=true,
        BackgroundTransparency=self.props.BackgroundTransparency,
        [React.Event.Activated]=self.props[React.Event.Activated] or function(arg1, arg2, arg3)
            print(string.format("DEBUG: TextButton{key=%s}.Activated=%s =%s =%s",
                tostring(self.props.key), tostring(arg1), tostring(arg2), tostring(arg3)))
        end
    })
end

return TextButtonComponent
