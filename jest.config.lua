return {
	--setupFilesAfterEnv = { script.Parent.jestSetup },
	--testMatch = { "**/*.(spec|test)", "**/__tests__/index" },
	testMatch = { "**/__tests__/*.(spec|test)", "**/*.spec.(lua|luau)" },
	testPathIgnorePatterns = {
		"Packages",
		"DevPackages",

		"lite",
		"_output"
	},
}