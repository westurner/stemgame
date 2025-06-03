print("DEBUG: init.client: starting...")

print("INFO: init.client: Hello world, stemgame!")

--_G.__DEV__ = false
--_G.__DEV__ = game:GetService("RunService"):IsStudio()
--print(string.format("DEBUG: init.client: _G.__DEV__=%s", tostring(_G.__DEV__)))

local debugMode = false
--debugMode = game:GetService("RunService"):IsStudio()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local ReactDevtools = require(ReplicatedStorage.DevPackages.ReactDevtools);
-- ReactDevtools.setup(debugMode)

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
--local e = React.createElement

local appRootModel = Instance.new("Model") -- WorldModel? TODO
appRootModel.Parent = workspace

local AappRootComponent = require(script.Parent.Client.AappRootComponent)  -- require()

local appRoot = ReactRoblox.createRoot(appRootModel)
appRoot:render(React.createElement(AappRootComponent, {key='AappRoot1',
    appRoot = appRootModel,
    refs = {
         appRoot = appRootModel,
    },
}))


print("DEBUG: init.client: done.")
local exports = {}
exports.appRoot = appRoot
return exports