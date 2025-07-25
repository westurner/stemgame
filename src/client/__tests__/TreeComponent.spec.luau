--!strict
local TreeComponent = require(script.Parent.Parent.TreeComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("TreeComponent", function()
    it("should exist", function()
        expect(TreeComponent).to.be.ok()
    end)

    it("should instantiate with default props", function()
        local instance = TreeComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props.Position).to.equal(Vector3.new(0, 0, 0))
        expect(instance.props.depth).to.equal(5)
        expect(instance.props.direction).to.equal(Vector3.new(0, 1, 0))
    end)
end)
