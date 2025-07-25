--!strict
local DolmenComponent = require(script.Parent.Parent.DolmenComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("DolmenComponent", function()
    it("should exist", function()
        expect(DolmenComponent).to.be.ok()
    end)

    it("should instantiate with default props", function()
        local instance = DolmenComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props._ref).to.be.ok()
    end)
end)