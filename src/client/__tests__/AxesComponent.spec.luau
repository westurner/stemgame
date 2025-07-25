--!strict
local AxesComponent = require(script.Parent.Parent.AxesComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("AxesComponent", function()
    it("should exist", function()
        expect(AxesComponent).to.be.ok()
    end)

    it("should instantiate with default props", function()
        local instance = AxesComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props.Name).to.equal("Axes1")
        expect(instance.props.origin).to.be.nil()
    end)
end)