--!strict
local AirHockeyComponent = require(script.Parent.Parent.AirHockeyComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("AirHockeyComponent", function()
    it("should exist", function()
        expect(AirHockeyComponent).to.be.ok()
    end)

    it("should instantiate with default props", function()
        local instance = AirHockeyComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props.Name).to.equal("Hockey01")
        expect(instance.props.Position).to.equal(Vector3.new(0, 0, 0))
        expect(instance.props.tableLength).to.equal(60)
        expect(instance.props.tableWidth).to.equal(120)
        expect(instance.props.tableHeight).to.equal(2)
        expect(instance.props.wallHeight).to.equal(4)
        expect(instance.props.wallThickness).to.equal(1)
        expect(instance.props.puckRadius).to.equal(2)
        expect(instance.props.puckHeight).to.equal(1)
        expect(instance.props.puckColor).to.equal(Color3.fromRGB(0, 255, 255))
        expect(instance.props.wallColor).to.equal(Color3.fromRGB(255, 0, 0))
        expect(instance.props.tableColor).to.equal(Color3.fromRGB(200, 200, 200))
        expect(instance.props.paddleRadius).to.equal(3)
        expect(instance.props.paddleHeight).to.equal(1.5)
        expect(instance.props.paddleColor1).to.equal(Color3.fromRGB(0, 162, 255))
        expect(instance.props.paddleColor2).to.equal(Color3.fromRGB(0, 162, 255))
        expect(instance.props.puckTransparency).to.equal(0.4)
        expect(instance.props.wallTransparency).to.equal(0.5)
        expect(instance.props.tableTransparency).to.equal(0.4)
        expect(instance.props.paddleTransparency).to.equal(0.3)
        expect(instance.props.paddleOffset).to.equal(10)
        expect(instance.props.autoReturnDelay).to.equal(3)
        expect(instance.props.showGoals).to.equal(true)
        expect(instance.props.goalWidth).to.equal(instance.props.tableWidth / 3)
        expect(instance.props.goalDepth).to.equal(instance.props.wallThickness * 2.2)
        expect(instance.props.goalHeight).to.equal(instance.props.wallHeight * 1.1)
        expect(instance.props.goalColor1).to.equal(Color3.fromRGB(0, 255, 204))
        expect(instance.props.goalColor2).to.equal(Color3.fromRGB(247, 102, 40))
        expect(instance.props.goalTransparency).to.equal(0.5)
    end)
end)
