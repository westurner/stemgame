--!strict
local BillboardAnswersComponent = require(script.Parent.Parent.BillboardAnswersComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("BillboardAnswersComponent", function()
    it("should exist", function()
        expect(BillboardAnswersComponent).to.be.ok()
    end)

    it("should instantiate with default props and state", function()
        local instance = BillboardAnswersComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props).to.be.empty()
        expect(instance.state.problem).to.be.nil()
        expect(instance.state.selectedAnswer).to.be.nil()
        expect(instance.state.lastAnswerCorrect).to.be.nil()
    end)
end)
