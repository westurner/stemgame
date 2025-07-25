--!strict
local CameraComponent = require(script.Parent.Parent.CameraComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("CameraComponent", function()
    it("should exist", function()
        expect(CameraComponent).to.be.ok()
    end)

    it("should instantiate with provided props", function()
        local mockSubject = Instance.new("Part")
        local mockFocus = CFrame.new(1,2,3)
        local instance = CameraComponent.new({
            CameraSubject = mockSubject,
            CameraType = Enum.CameraType.Scriptable,
            Focus = mockFocus
        })
        expect(instance).to.be.ok()
        expect(instance.props.CameraSubject).to.equal(mockSubject)
        expect(instance.props.CameraType).to.equal(Enum.CameraType.Scriptable)
        expect(instance.props.Focus).to.equal(mockFocus)
    end)
end)