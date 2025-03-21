
-- jest_example.spec.luau
--[[
## References
- https://github.com/Roblox/jest-roblox/blob/master/README.md
- https://github.com/Roblox/jest-roblox/blob/0dede7df592d5a1a0e02b59e20b489de243f4e84/docs/docs/GettingStarted.md
- https://github.com/Roblox/jest-roblox/blob/master/docs/docs/Deviations.md
- https://github.com/Roblox/jest-roblox/blob/master/docs/docs/ExpectAPI.md#reference
- https://github.com/Roblox/jest-roblox/blob/master/docs/docs/GlobalAPI.md#beforeeachfn-timeout

]]--

local Workspace = script.Parent.Parent
local Packages = Workspace.Parent

local JestGlobals = require(Packages.Dev.JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local sum = require(Workspace.sum)

it('adds 1 + 2 to equal 3', function()
	expect(sum(1, 2)).toBe(3)
end)



it('creates a table with React.createElement', function()

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local React = require(ReplicatedStorage.Packages.React)
    --local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

    local elem = React.createElement("Part", {
        thing1="thing1_value"
    })

    print({elem=elem})
    expect(elem.type).toBe("Part")
    expect(elem['$$typeof']).toBe(60103)
    expect(elem.props.thing1).toBe("thing1_value")
end)

it('creates an AppRoot with TODO', function()


end)