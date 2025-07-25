local ReplicatedStorage = nil
local runCLI = nil

local isLune = (_VERSION:gmatch("Lune")() == "Lune")
if isLune then 
	local roblox = nil
	local roblox = require("@lune/roblox")
	local Instance = roblox.Instance

	local game = Instance.new("DataModel")
	local _workspace = game:GetService("Workspace")

	print("DEBUG: @lune/roblox: game=Instance.new('DataModel') => " .. tostring(game) .. " type=" .. typeof(game))
	assert(game ~= nil)

	-- Create ReplicatedStorage, DevPackages, and Packages folders
	ReplicatedStorage = Instance.new("Folder")
	ReplicatedStorage.Name = "ReplicatedStorage"
	game.ReplicatedStorage = ReplicatedStorage
	print("DEBUG: game.ReplicatedStorage after assignment:", tostring(game.ReplicatedStorage))
	print("DEBUG: game:GetService('ReplicatedStorage'):", tostring(game:GetService("ReplicatedStorage")))

	local DevPackages = Instance.new("Folder")
	DevPackages.Name = "DevPackages"
	DevPackages.Parent = ReplicatedStorage
	ReplicatedStorage.DevPackages = DevPackages

	local Packages = Instance.new("Folder")
	Packages.Name = "Packages"
	Packages.Parent = ReplicatedStorage
	ReplicatedStorage.Packages = Packages

	-- Insert Jest as a ModuleScript-like table
	local jestModule = require("./DevPackages/_Index/jsdotlua_jest@3.10.0/jest/src/init.lua")
	DevPackages.Jest = jestModule

	-- You may need to insert your Project module into Packages.Project here if your tests require it
	-- Example: Packages.Project = require("path/to/your/project/init.lua")

	runCLI = DevPackages.Jest.runCLI
else
	ReplicatedStorage = game:GetService("ReplicatedStorage")
	runCLI = require(ReplicatedStorage.DevPackages.Jest).runCLI
end

local processServiceExists, ProcessService = pcall(function()
	return game:GetService("ProcessService")
end)

local status, result = runCLI(ReplicatedStorage.Packages.Project, {
	verbose = true,
	ci = false
}, { ReplicatedStorage.Packages.Project }):awaitStatus()

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