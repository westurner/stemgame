--!strict
local Scene001 = require(script.Parent.Parent.Scene001)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("Scene001", function()
    local originalGetService
    local originalCreateRoot
    local originalInstanceNew
    local originalWaitForChild
    local originalFireServer
    local originalPrint

    beforeEach(function()
        originalGetService = game.GetService
        originalCreateRoot = ReactRoblox.createRoot
        originalInstanceNew = Instance.new
        originalWaitForChild = Instance.new("Folder").WaitForChild
        originalFireServer = game:GetService("ReplicatedStorage").PlayerAction.FireServer
        originalPrint = print

        -- Mock game:GetService
        game.GetService = function(serviceName)
            if serviceName == "Players" then
                return {
                    LocalPlayer = {
                        WaitForChild = function(childName)
                            if childName == "PlayerGui" then
                                return {
                                    Name = "PlayerGui",
                                    Parent = nil,
                                    Destroy = function() end,
                                    -- Mock WaitForChild for PlayerGui
                                    WaitForChild = function(grandchildName)
                                        if grandchildName == "Character" then
                                            return {
                                                Character = {
                                                    PrimaryPart = {
                                                        Position = Vector3.new(0,0,0)
                                                    },
                                                    Humanoid = {
                                                        JumpHeight = 50
                                                    }
                                                }
                                            }
                                        end
                                    end
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
                        }
                    }
                }
            elseif serviceName == "ReplicatedStorage" then
                return {
                    Packages = {
                        React = React,
                        ReactRoblox = ReactRoblox,
                    },
                    PlayerAction = {
                        FireServer = function() end
                    }
                }
            elseif serviceName == "Workspace" then
                return {
                    CurrentCamera = {
                        Name = "Camera",
                        Destroy = function() end
                    },
                    Gravity = 196.2
                }
            elseif serviceName == "Lighting" then
                return {
                    ClockTime = 18.42,
                    Ambient = Color3.fromRGB(111, 111, 101),
                    OutdoorAmbient = Color3.fromRGB(111, 111, 101),
                }
            end
            return nil
        end

        -- Mock ReactRoblox.createRoot
        ReactRoblox.createRoot = function()
            return {
                render = function() end,
                unmount = function() end,
            }
        end

        -- Mock Instance.new
        Instance.new = function(className)
            if className == "ScreenGui" then
                return {
                    Name = "Scene001_UI",
                    Parent = nil,
                    Destroy = function() end,
                }
            else
                return originalInstanceNew(className)
            end
        end

        -- Suppress print statements during tests
        print = function() end
    end)

    afterEach(function()
        game.GetService = originalGetService
        ReactRoblox.createRoot = originalCreateRoot
        Instance.new = originalInstanceNew
        Instance.new("Folder").WaitForChild = originalWaitForChild
        game:GetService("ReplicatedStorage").PlayerAction.FireServer = originalFireServer
        print = originalPrint
    end)

    it("should exist", function()
        expect(Scene001).to.be.ok()
    end)

    it("should instantiate with default props and state", function()
        local instance = Scene001.new()
        expect(instance).to.be.ok()
        expect(instance.props).to.be.empty()
        expect(instance.state.isSharedMode).to.equal(true)
    end)
end)
