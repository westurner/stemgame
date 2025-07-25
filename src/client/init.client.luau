print("DEBUG: init.client: starting...")

print("INFO: init.client: Hello world, stemgame!")

_G.runTests = game:GetService("RunService"):IsStudio()

--_G.__DEV__ = false
--_G.__DEV__ = game:GetService("RunService"):IsStudio()
--print(string.format("DEBUG: init.client: _G.__DEV__=%s", tostring(_G.__DEV__)))

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local debugMode = false
--debugMode = game:GetService("RunService"):IsStudio()

if debugMode then
 local ReactDevtools = require(ReplicatedStorage.DevPackages.ReactDevtools);
 ReactDevtools.setup(debugMode)
end

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local SharedStateManager = require(game.StarterPlayer.StarterPlayerScripts.Client.SharedStateManager)
--local e = React.createElement

--local appRootModel = Instance.new("Model") -- WorldModel? TODO
local appRootModel = Instance.new("Folder") -- WorldModel? TODO
appRootModel.Name = "AppRoot1"
appRootModel.Parent = workspace

local appRoot
if _G.runTests then
    print("init.client: _G.runTests=True . Running TestRunnerComponent ...")
    local TestRunnerComponent = require(script.Parent.Client.TestRunner.TestRunnerComponent)
    appRoot = ReactRoblox.createRoot(appRootModel)
    local ref = React.createRef()
    appRoot:render(React.createElement(TestRunnerComponent, {key='TestRunner', ref=ref}))
    wait(2)
    ref.current:runTests()
    print("init.client: _G.runTests=True . TestRunnerComponent done.")
end

if 1 then
    local AappRootComponent = require(script.Parent.Client.AappRootComponent)  -- require()
    appRoot = ReactRoblox.createRoot(appRootModel)
    appRoot:render(React.createElement(AappRootComponent, {key='AappRoot1',
        appRoot = appRootModel,
        refs = {
             appRoot = appRootModel,
        },
    }))
end


print("DEBUG: init.client: done.")
local exports = {}
exports.appRoot = appRoot
return exports
