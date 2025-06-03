-- # AappRootComponent.luau
-- This component serves as the root for the #stemgame application.
-- It initializes the application, sets up the root component, and renders it.

--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Workspace = game:GetService("Workspace")

local debugMode = false
if (debugMode) then
    local ReactDevtools = require(ReplicatedStorage.DevPackages.ReactDevtools)
    ReactDevtools.setup(debugMode)
end

local React = require(ReplicatedStorage.Packages.React)


local Scene001 = require(script.Parent.Scene001)
--local SpawnLocationComponent = require(script.Parent.SpawnLocationComponent)
--local FallbackComponent = require(script.Parent.FallbackComponent)


local AappRootComponent = React.Component:extend("AappRootComponent")

function AappRootComponent:init()
    print("DEBUG: AappRootComponent:init() starting...")
    self.props = self.props or {}
    print("DEBUG: AappRootComponent:init() done.")
end

function AappRootComponent:render()
    print("DEBUG: AappRootComponent:render() starting...")

    local aappRoot1 = React.createElement(React.Fragment, {key='AappRoot1',
    }, {
        scene001 = React.createElement(Scene001, {}),
        -- billboardAnswersComponent1 = 
        --     React.createElement(BillboardAnswersComponent, {
        --     Position = Vector3.new(0, 0, 0) }),
    })
    print("DEBUG: AappRootComponent:render() done.")
    return aappRoot1
end

print("DEBUG: AappRootComponent: done.")
return AappRootComponent
