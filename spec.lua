-- spec.lua for jest-roblox
-- Adapted from:
-- - https://roblox.github.io/jest-roblox-internal/
-- - https://github.com/Roblox/jest-roblox/blob/0dede7df592d5a1a0e02b59e20b489de243f4e84/docs/docs/GettingStarted.md
--   (MIT License)

--local Packages = script.Parent.YourProject.Packages
local Packages = game:GetService("ReplicatedStorage").DevPackages
local runCLI = require(Packages.JestGlobals).runCLI

local processServiceExists, ProcessService = pcall(function()
    return game:GetService("ProcessService")
end)

local status, result = runCLI(Packages.Project, {
    verbose = false,
    ci = false
}, { Packages.Project }):awaitStatus()

if status == "Rejected" then
    print(result)
end

if status == "Resolved" and result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0 then
    if processServiceExists then
        ProcessService:ExitAsync(0)
    end
end

if processServiceExists then
    ProcessService:ExitAsync(1)
end

return nil