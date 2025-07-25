--!strict
local BallComponent = require(script.Parent.Parent.BallComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("BallComponent", function()
    it("should exist", function()
        expect(BallComponent).to.be.ok()
    end)

    it("should instantiate with default props", function()
        local instance = BallComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props.Size).to.equal(Vector3.new(7,7,7))
        expect(instance.props.Color).to.equal(Color3.new(0.7, 0, 0))
        expect(instance.props.Material).to.equal(Enum.Material.Neon)
        expect(instance.props.Position).to.equal(Vector3.new(0,20,0))
        expect(instance.props.Shape).to.equal(Enum.PartType.Ball)
    end)
end)