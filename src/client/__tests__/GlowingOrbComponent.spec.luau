--!strict
local GlowingOrbComponent = require(script.Parent.Parent.GlowingOrbComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("GlowingOrbComponent", function()
    local originalGetService

    beforeEach(function()
        originalGetService = game.GetService

        game.GetService = function(serviceName)
            if serviceName == "ReplicatedStorage" then
                return {
                    Packages = {
                        React = React,
                    }
                }
            elseif serviceName == "TweenService" then
                return {
                    Create = function() return { Completed = { Connect = function() end }, Play = function() end, Cancel = function() end } end
                }
            end
            return originalGetService(serviceName)
        end
    end)

    afterEach(function()
        game.GetService = originalGetService
    end)

    it("should exist", function()
        expect(GlowingOrbComponent).to.be.ok()
    end)

    it("should instantiate with default props", function()
        local instance = GlowingOrbComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props.glowColor).to.equal(Color3.fromRGB(120, 0, 0))
        expect(instance.props.Size).to.equal(Vector3.new(10, 10, 10))
        expect(instance.props.Transparency).to.equal(0)
        expect(instance.props.Anchored).to.equal(true)
        expect(instance.props.CanCollide).to.equal(false)
        expect(instance.props.Material).to.equal(Enum.Material.Neon)
        expect(instance.state.isGlowing).to.equal(false)
        expect(instance.state.glowTween).to.be.nil()
    end)
end)