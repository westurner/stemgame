--!strict
local AreaVolumeCube = require(script.Parent.Parent.AreaVolumeCube)
local AreaVolumeCubeComponent = AreaVolumeCube.AreaVolumeCubeComponent
local AreaVolumeCubeSceneComponent = AreaVolumeCube.AreaVolumeCubeSceneComponent
local React = require(game:GetService("ReplicatedStorage").Packages.React)

describe("AreaVolumeCubeComponent", function()
    it("should exist", function()
        expect(AreaVolumeCubeComponent).to.be.ok()
    end)

    it("should instantiate with default props", function()
        local instance = AreaVolumeCubeComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props.dimensions).to.equal(Vector3.new(3, 4, 10))
        expect(instance.props.origin).to.equal(Vector3.new(20, 20, 50))
        expect(instance.props.blockSpacing).to.equal(Vector3.new(1.5, 1.5, 1.5))
        expect(instance.props.blockSize).to.equal(Vector3.new(8, 8, 8))
        expect(instance.props.blockColor).to.equal(Color3.new(0.62, 0.62, 0.62))
        expect(instance.props.blockTransparency).to.equal(0.10)
        expect(instance.props.blockMaterial).to.equal(Enum.Material.SmoothPlastic)
        expect(instance.props.labelColor).to.equal(Color3.fromRGB(34, 34, 34))
    end)
end)

describe("AreaVolumeCubeSceneComponent", function()
    it("should exist", function()
        expect(AreaVolumeCubeSceneComponent).to.be.ok()
    end)

    it("should instantiate with default props and state", function()
        local instance = AreaVolumeCubeSceneComponent.new()
        expect(instance).to.be.ok()
        expect(instance.props).to.be.empty()
        expect(instance.state.dimensions).to.equal(Vector3.new(3, 4, 10))
        expect(instance.state.current_block).to.equal(Vector3.new(1, 1, 1))
        expect(instance.state.highlightedBlocks).to.be.empty()
    end)
end)