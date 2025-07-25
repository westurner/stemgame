--!strict
local MultiJumpComponent = require(script.Parent.Parent.MultiJumpComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("MultiJumpComponent", function()
    it("should exist", function()
        expect(MultiJumpComponent).to.be.ok()
    end)

    it("should instantiate with default props", function()
        local instance = MultiJumpComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props.jumpHeight).to.equal(50)
        expect(instance.props.maxJumps).to.equal(2)
    end)
end)