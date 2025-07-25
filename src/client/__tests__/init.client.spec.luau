--!strict
local initClient = require(script.Parent.Parent["init.client"])
local React = require(game:GetService("ReplicatedStorage").Packages.React)
local ReactRoblox = require(game:GetService("ReplicatedStorage").Packages.ReactRoblox)

describe("init.client", function()
    local originalGetService
    local originalInstanceNew
    local originalRequire
    local originalPrint

    local mockReplicatedStorage
    local mockWorkspace
    local mockPlayers
    local mockRunService

    local mockAppRootModel
    local mockReactRoot
    local mockAappRootComponent
    local mockSharedStateManager

    beforeEach(function()
        originalGetService = game.GetService
        originalInstanceNew = Instance.new
        originalRequire = require
        originalPrint = print

        -- Mock game:GetService
        mockReplicatedStorage = {
            Packages = {
                React = React,
                ReactRoblox = ReactRoblox,
            },
            DevPackages = {
                ReactDevtools = {
                    setup = function() end
                }
            },
            EnvironmentStateChanged = {
                OnClientEvent = {
                    Connect = function() end
                }
            }
        }
        mockWorkspace = {
            Name = "Workspace",
            CurrentCamera = {
                Name = "Camera",
                Destroy = function() end
            },
            Gravity = 196.2,
            FindFirstChild = function(name)
                if name == "AppRoot1" then
                    return mockAppRootModel
                end
                return nil
            end
        }
        mockPlayers = {
            LocalPlayer = {
                WaitForChild = function(childName)
                    if childName == "PlayerGui" then
                        return {
                            Name = "PlayerGui",
                            Parent = nil,
                            Destroy = function() end,
                            WaitForChild = function() end
                        }
                    end
                end,
                Character = {
                    PrimaryPart = {
                        Position = Vector3.new(0,0,0)
                    },
                    Humanoid = {
                        JumpHeight = 50
                    }
                },
                CharacterAdded = {
                    Wait = function() return { WaitForChild = function() end } end
                }
            }
        }
        mockRunService = {
            IsStudio = function() return false end
        }

        game.GetService = function(serviceName)
            if serviceName == "ReplicatedStorage" then
                return mockReplicatedStorage
            elseif serviceName == "Workspace" then
                return mockWorkspace
            elseif serviceName == "Players" then
                return mockPlayers
            elseif serviceName == "RunService" then
                return mockRunService
            elseif serviceName == "Lighting" then
                return {
                    ClockTime = 18.42,
                    Ambient = Color3.fromRGB(111, 111, 101),
                    OutdoorAmbient = Color3.fromRGB(111, 111, 101),
                }
            elseif serviceName == "TweenService" then
                return {
                    Create = function() return { Completed = { Connect = function() end }, Play = function() end, Cancel = function() end } end
                }
            end
            return originalGetService(serviceName)
        end

        -- Mock Instance.new
        mockAppRootModel = {
            Name = "",
            Parent = nil,
            Destroy = function() end
        }
        Instance.new = function(className)
            if className == "Folder" then
                return mockAppRootModel
            elseif className == "ScreenGui" then
                return {
                    Name = "Scene001_UI",
                    Parent = nil,
                    Destroy = function() end,
                }
            else
                return originalInstanceNew(className)
            end
        end

        -- Mock ReactRoblox.createRoot
        mockReactRoot = {
            render = function() end,
            unmount = function() end,
        }
        ReactRoblox.createRoot = function(model)
            return mockReactRoot
        end

        -- Mock require
        mockAappRootComponent = {}
        mockSharedStateManager = {
            subscribe = function() return function() end end
        }
        _G.require = function(path)
            if path == script.Parent.Parent.Client.AappRootComponent then
                return mockAappRootComponent
            elseif path == game.StarterPlayer.StarterPlayerScripts.Client.SharedStateManager then
                return mockSharedStateManager
            end
            return originalRequire(path)
        end

        -- Suppress print statements during tests
        print = function() end
    end)

    afterEach(function()
        game.GetService = originalGetService
        Instance.new = originalInstanceNew
        _G.require = originalRequire
        print = originalPrint
    end)

    it("should initialize the app root model and render AappRootComponent", function()
        -- Spy on key functions
        local createRootSpy = spy.on(ReactRoblox, "createRoot")
        local renderSpy = spy.on(mockReactRoot, "render")
        local createElementSpy = spy.on(React, "createElement")

        -- Execute the init.client.luau script
        initClient()

        -- Assertions
        expect(mockAppRootModel.Name).to.equal("AppRoot1")
        expect(mockAppRootModel.Parent).to.equal(mockWorkspace)

        expect(createRootSpy).to.have.been.called_with(mockAppRootModel)
        expect(renderSpy).to.have.been.called_once()
        expect(createElementSpy).to.have.been.called_with(mockAappRootComponent, {
            key = 'AappRoot1',
            appRoot = mockAppRootModel,
            refs = {
                appRoot = mockAppRootModel,
            },
        })
    end)

    it("should return the appRoot", function()
        local exports = initClient()
        expect(exports.appRoot).to.equal(mockReactRoot)
    end)
end)
