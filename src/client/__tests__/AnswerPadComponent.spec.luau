--!strict
local AnswerPadComponent = require(script.Parent.Parent.AnswerPadComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("AnswerPadComponent", function()
    it("should exist", function()
        expect(AnswerPadComponent).to.be.ok()
    end)

    it("should instantiate with default props and state", function()
        local instance = AnswerPadComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props.name).to.equal("AnswerPad")
        expect(instance.props.size).to.equal(Vector3.new(5, 1, 5))
        expect(instance.props.position).to.equal(Vector3.new(0, 0, 0))
        expect(instance.state.isActive).to.equal(false)
    end)
end)