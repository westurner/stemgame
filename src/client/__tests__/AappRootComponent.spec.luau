--!strict
local AappRootComponent = require(script.Parent.Parent.AappRootComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("AappRootComponent", function()
    it("should exist", function()
        expect(AappRootComponent).to.be.ok()
    end)

    it("should instantiate with default props and state", function()
        local instance = AappRootComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props).to.be.empty()
        expect(instance.state).to.be.empty()
    end)
end)