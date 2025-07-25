--!strict
local CameraOnPartComponent = require(script.Parent.Parent.CameraOnPartComponent)
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("CameraOnPartComponent", function()
    it("should exist", function()
        expect(CameraOnPartComponent).to.be.ok()
    end)

    it("should instantiate with provided props", function()
        local mockSubject = Instance.new("Part")
        local mockFocus = CFrame.new(1,2,3)
        local instance = CameraOnPartComponent.new({
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