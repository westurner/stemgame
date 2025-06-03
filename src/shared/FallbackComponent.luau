
-- FallbackComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

--local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)
--local FallbackComponent: React.FC<ReactErrorBoundary.FallbackProps> = function(_props)
local FallbackComponent = function(_props)
    return React.createElement("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromScale(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Text = "ERROR: " .. tostring(_props.error),
        TextColor3 = Color3.fromRGB(72, 42, 42),
    })
end

return FallbackComponent

--[[
Next, in your app, wrap an ErrorBoundary where needed.

local ReactErrorBoundary = require(ReplicatedStorage.Packages.ReactErrorBoundary)
local FallbackComponent = require(ReplicatedStorage.Packages.Shared.FallbackComponent)
--local FallbackComponent = require(script.Parent.FallbackComponent)

local App: React.FC<{}> = function(_props)
    return React.createElement(ReactErrorBoundary.ErrorBoundary, {
        FallbackComponent = Fallback,
    }, {
        ComponentThatMightError = React.createElement(ComponentThatMightError),
    })
end

--]]