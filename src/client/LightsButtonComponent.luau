
-- LightsButtonComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local TextButtonComponent = require(script.Parent.TextButtonComponent)


local LightsButtonComponent = React.Component:extend("LightsButtonComponent")

function LightsButtonComponent:init()
	self.props = self.props or {}
	self.props.cubeRef = self.props.cubeRef or nil

	if not self.props.dimensions then
		error("LightsButtonComponent: dimensions prop is required")
	end

	self.prev = {} -- store previous attributes for each block by eventid

	self:setState({
		dimensions=self.props.dimensions,
		current_block=Vector3.new(1,1,1)})
end

function LightsButtonComponent:decorateBlock(block, eventid)
	self.attrs = {'BrickColor', 'Material', 'Transparency'}

	self.prev[block] = self.prev[block] or {}
	self.prev[block][eventid] = self.prev[block][eventid] or {}

	for _, attr in ipairs(self.attrs) do
		self.prev[block][eventid][attr] = block[attr]
	end

	-- set new attributes
	block.BrickColor = BrickColor.new("Bright red")
	block.Material = Enum.Material.Neon
	--block.Transparency = 0.8
end

function LightsButtonComponent:undecorateBlock(block, eventid)
	if self.attrs then
		-- restore previous attributes
		for _, attr in ipairs(self.attrs) do
			block[attr] = self.prev[block][eventid][attr]
			--block[attr] = block:GetAttribute(string.format("__prev__%s", attr))
			--block:SetAttribute(string.format("__prev__%s", attr), nil)	
		end
	else
		--print("ERROR: BlockButtonComponent: undecorateBlock: previousState not found for block=" .. tostring(block))
		block.BrickColor = BrickColor.new("Medium stone grey")
		block.Material = Enum.Material.Rock
		block.Transparency = 0.5
	end
end

function LightsButtonComponent:render()
	return React.createElement(TextButtonComponent, {
		Text="Lights",
		Position=UDim2.new(0.8, 0, 0.8, 0),
		Size=UDim2.new(0, 200, 0, 50),

		[React.Event.Activated]=function(eventobj, inputobj, arg3)
			print(string.format("DEBUG: BlockButtonComponent.Activated eventobj=%s inputobj=%s arg3=%s",
				tostring(eventobj), tostring(inputobj), tostring(arg3)))

			--local areaVolumeCube = workspace.AreaVolumeCube1 -- TODO: 
			local areaVolumeCube = self.props.cubeRef or workspace:FindFirstChild("AreaVolumeCube1", true)

			for i=1, (2*self.state.dimensions.X * self.state.dimensions.Y * self.state.dimensions.Z) do
				local current_block = self.state.current_block
				local block_key = string.format("Block%02d,%02d,%02d",
					current_block.x,
					current_block.y,
					current_block.z)
				local block = areaVolumeCube.Cube1[block_key]
				if block then
					local eventid = os.clock()
					self:decorateBlock(block, eventid)
					task.wait(0.3)
					self:undecorateBlock(block, eventid)

					self:setState({
						current_block=_next_block_xyz(current_block, self.state.dimensions)
					})
				else
					print(string.format("ERROR: Block not found: %s", block_key))
				end
				--task.wait(0.3)
			end
		end
	})
end

function _next_block_xyz(block_position: Vector3, dimensions: Vector3)
	local next_block = block_position + Vector3.new(1, 0, 0)
	if next_block.X > dimensions.X then
		next_block = Vector3.new(1, next_block.Y + 1, next_block.Z)
		if next_block.Y > dimensions.Y then
			next_block = Vector3.new(1, 1, next_block.Z + 1)
			if next_block.Z > dimensions.Z then
				next_block = Vector3.new(1, 1, 1) -- reset to first block
			end
		end
	end
	return next_block
end

function _next_block_zxy(block_position: Vector3, dimensions: Vector3)
	local next_block = block_position + Vector3.new(0, 0, 1)
	if next_block.Z > dimensions.Z then
		next_block = Vector3.new(next_block.X + 1, next_block.Y, 1)
		if next_block.X > dimensions.X then
			next_block = Vector3.new(1, next_block.Y + 1, 1)
			if next_block.Y > dimensions.Y then
				next_block = Vector3.new(1, 1, 1) -- reset to first block
			end
		end
	end
	return next_block
end

function _next_block_zyx(block_position: Vector3, dimensions: Vector3)
	local next_block = block_position + Vector3.new(0, 0, 1)
	if next_block.Z > dimensions.Z then
		next_block = Vector3.new(next_block.X, next_block.Y + 1, 1)
		if next_block.Y > dimensions.Y then
			next_block = Vector3.new(next_block.X + 1, 1, 1)
			if next_block.X > dimensions.X then
				next_block = Vector3.new(1, 1, 1) -- reset to first block
			end
		end
	end
	return next_block
end



return LightsButtonComponent
