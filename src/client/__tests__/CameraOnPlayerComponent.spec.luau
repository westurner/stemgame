--!strict
local CameraOnPlayerComponent = require(script.Parent.Parent.CameraOnPlayerComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("CameraOnPlayerComponent", function()
    it("should exist", function()
        expect(CameraOnPlayerComponent).to.be.ok()
    end)

    it("should instantiate with provided props", function()
        local mockSubject = Instance.new("Part")
        local mockFocus = CFrame.new(1,2,3)
        local instance = CameraOnPlayerComponent.new({
            CameraSubject = mockSubject,
            CameraType = Enum.CameraType.Scriptable,
            Focus = mockFocus,
            FieldOfView = 70,
            VRTiltAndRollEnabled = true
        })
        expect(instance).to.be.ok()
        expect(instance.props.CameraSubject).to.equal(mockSubject)
        expect(instance.props.CameraType).to.equal(Enum.CameraType.Scriptable)
        expect(instance.props.Focus).to.equal(mockFocus)
        expect(instance.props.FieldOfView).to.equal(70)
        expect(instance.props.VRTiltAndRollEnabled).to.equal(true)
    end)
end)