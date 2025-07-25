--!strict
-- src/client/TestRunner/TestRunnerComponent.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local TestFramework = require(script.Parent.TestFramework)
local TerminalOutputManager = require(script.Parent.TerminalOutputManager)
local TerminalComponent = require(script.Parent.Parent.TerminalComponent) -- Assuming TerminalComponent is in src/client/

local TestRunnerComponent = React.Component:extend("TestRunnerComponent")

function TestRunnerComponent:init()
    self.state = {
        isTerminalVisible = true,
    }
    self.terminalRef = React.createRef()
end

function TestRunnerComponent:didMount()
    -- Set the terminal component reference in the output manager
    TerminalOutputManager.setTerminalComponent(self.terminalRef.current)
    self:runTests()
end

function TestRunnerComponent:runTests()
    -- Discover test files
    local testFiles = script.Parent.Parent.__tests__:GetChildren()
    local success, err = pcall(function()
        for _, file in ipairs(testFiles) do
            if file:IsA("ModuleScript") and string.find(file.Name, ".spec.luau$") then
                require(file) -- This will populate the testSuites in TestFramework
            end
        end
    end)

    if not success then
        TerminalOutputManager.print("Error requiring test files: " .. tostring(err))
        return
    end

    TestFramework.runAllTests()
end

function TestRunnerComponent:render()
    return React.createElement(TerminalComponent, {
        ref = self.terminalRef,
        isVisible = self.state.isTerminalVisible,
        toggleVisibility = function()
            self:setState({ isTerminalVisible = not self.state.isTerminalVisible })
        end,
    })
end

return TestRunnerComponent
