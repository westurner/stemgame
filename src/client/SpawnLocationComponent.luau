
-- SpawnLocationComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local SpawnLocationComponent = React.Component:extend("SpawnLocationComponent")

function SpawnLocationComponent:init()
    self.props = self.props or {}
    self.props._ref = self.props._ref or React.createRef()
	self.props.Name =  self.props.Name or 'SpawnLocation1'
    self.props.Size=self.props.Size or Vector3.new(7,7,2)
    --self.props.Color=self.props.Color or Color3.new(0.7, 0, 0)
    self.props.Position=self.props.Position or Vector3.new(0,20,0)
	self.props.Rotation=Vector3.new(45, 0, 45)
	self.props.Texture="rbxasset://textures/SpawnLocation.png"
	self.props.Material=Enum.Material.Ground
end

function SpawnLocationComponent:render()
	return React.createElement("SpawnLocation", {
			Name=self.props.Name,
			Position=self.props.Position,
			Rotation=self.props.Rotation,
			Size=self.props.Size,
			Material=self.props.Material,
		}, {
			[1]=React.createElement("Decal", {
				key="Decal1",
				Texture = self.props.Texture,
				Face = Enum.NormalId.Top
			})
		})
end

return SpawnLocationComponent
