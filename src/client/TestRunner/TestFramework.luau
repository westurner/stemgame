--!strict
-- src/client/TestRunner/TestFramework.luau

local TestFramework = {}

local TerminalOutputManager = require(script.Parent.TerminalOutputManager)

local testSuites = {}
local currentSuiteName = nil
local currentTests = nil

-- Mocking global functions/objects that tests might rely on
_G.game = game
_G.script = script
_G.Color3 = Color3
_G.Vector3 = Vector3
_G.UDim2 = UDim2
_G.CFrame = CFrame
_G.Instance = Instance
_G.Enum = Enum
_G.math = math
_G.string = string
_G.table = table
_G.tostring = tostring
_G.type = type
_G.assert = assert
_G.pcall = pcall
_G.task = task

-- Simple spy implementation for basic mocking
local spy = {}
function spy.on(obj, methodName)
    local originalMethod = obj[methodName]
    local calls = {}
    local newMethod = function(...)
        local args = {...}
        table.insert(calls, args)
        return originalMethod(...)
    end
    obj[methodName] = newMethod

    return {
        calls = calls,
        originalMethod = originalMethod,
        called_with = function(expectedArgs)
            for _, callArgs in ipairs(calls) do
                local allMatch = true
                for i, expectedArg in ipairs(expectedArgs) do
                    if callArgs[i] ~= expectedArg then
                        allMatch = false
                        break
                    end
                end
                if allMatch then
                    return true
                end
            end
            return false
        end,
        called_once = function()
            return #calls == 1
        end
    }
end

_G.spy = spy

-- Basic expect matchers
local Expect = {}
Expect.__index = Expect

function Expect.new(value)
    return setmetatable({ value = value }, Expect)
end

function Expect:to_be_ok()
    return self.value ~= nil and self.value ~= false
end

function Expect:to_equal(expected)
    return self.value == expected
end

function Expect:to_be_nil()
    return self.value == nil
end

function Expect:to_be_empty()
    if type(self.value) == "table" then
        return next(self.value) == nil
    elseif type(self.value) == "string" then
        return self.value == ""
    end
    return false
end

function Expect:to_contain(expected)
    if type(self.value) == "string" and type(expected) == "string" then
        return string.find(self.value, expected) ~= nil
    elseif type(self.value) == "table" then
        for _, v in ipairs(self.value) do
            if v == expected then
                return true
            end
        end
    end
    return false
end

_G.expect = Expect.new

-- Describe function to define test suites
function _G.describe(name, callback)
    local oldSuiteName = currentSuiteName
    local oldTests = currentTests

    currentSuiteName = name
    currentTests = {}
    testSuites[name] = { tests = currentTests, callback = callback }

    callback() -- Execute the suite callback to populate tests

    currentSuiteName = oldSuiteName
    currentTests = oldTests
end

-- It function to define individual tests
function _G.it(name, callback)
    if not currentTests then
        error("`it` must be called inside a `describe` block.")
    end
    table.insert(currentTests, { name = name, callback = callback })
end

-- Test runner function
function TestFramework.runAllTests()
    local results = {}
    TerminalOutputManager.print("\nRunning tests...")
    for suiteName, suiteData in pairs(testSuites) do
        TerminalOutputManager.print("\n  " .. suiteName)
        local suiteResults = { name = suiteName, tests = {} }
        for _, testData in ipairs(suiteData.tests) do
            local success, err = pcall(testData.callback)
            local status = testData.name .. ": " .. (success and "PASSED" or "FAILED")
            if not success and err then
                status = status .. " - " .. tostring(err)
            end
            TerminalOutputManager.print("    " .. status)
            table.insert(suiteResults.tests, {
                name = testData.name,
                passed = success,
                errorMessage = err
            })
        end
        table.insert(results, suiteResults)
    end
    TerminalOutputManager.print("\nTests finished.")
    return results
end

return TestFramework