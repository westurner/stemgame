local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local DevPackages = ReplicatedStorage.DevPackages

--local Jest = require("@DevPackages/Jest")
local Jest = require(DevPackages.Jest)

local runCLIOptions = {
	verbose = false,
	ci = false,
}

local projects = {
	Packages.Project,
}

Jest.runCLI(script, runCLIOptions, projects):await()

return nil