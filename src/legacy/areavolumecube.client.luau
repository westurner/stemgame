print("DEBUG: areavolumecube.client.luau")


function AreaVolumeCube_render_ball()
	print("INFO: Drawing Ball1 ...")
	local part = Instance.new("Part")
	part.Name = "Ball1"
	part.Anchored = true
	part.Shape = Enum.PartType.Ball
	part.Color = Color3.new(0.7, 0, 0)
	part.Size = Vector3.new(4, 4, 1)
	part.Position = Vector3.new(0,1,0)
	part.Parent = script.Parent
end



function AreaVolumeCube_render_blocks()

	local props = {}
	props.dims = Vector3.new(3, 4, 10)
	props.origin = Vector3.new(20, 30, 50)
	props.blockSpacing = Vector3.new(1.1, 1.1, 1.1)
	props.blockSize = Vector3.new(8, 8, 8)
	props.labelColor = Color3.new(0.8,0.8,0.8)

	print("INFO: Drawing a (" .. tostring(props.dims) .. ") cube of cubes, an AreaVolumeCube ...")

	local areaVolumeCubeFolder = Instance.new("Folder")
	areaVolumeCubeFolder.Name = "AreaVolumeCube"
    areaVolumeCubeFolder.Parent = workspace


	local state = {}
	state.blocks = {}

	local n = 0
	for x = 1, props.dims.X do 
		for y = 1, props.dims.Y do
			for z = 1, props.dims.Z do
				n = n + 1
				-- Create parts named Block_01,02,03
				local part = Instance.new("Part")
				part.Name = string.format("Block_%02d,%02d,%02d", x, y, z)
				part.Anchored = true
				part.Shape = Enum.PartType.Block
				part.Size = props.blockSize
				part.Position = Vector3.new(
					props.origin.X + x * props.blockSize.X * props.blockSpacing.X,
					props.origin.Y + ((y-1) * props.blockSize.Y) * props.blockSpacing.Y,
					props.origin.Z + z * props.blockSize.Z * props.blockSpacing.Z)

				part.Transparency = 0.05
				part.Color = Color3.new(
					x % 2,
					x % 2,
					x % 2)
				part.Color = Color3.new(
					0.9, 0.9, 0.9
				)
				part.Parent = areaVolumeCubeFolder

				local blockindex = string.format("%02d,%02d,%02d", x,y,z)
				local blockdata = {}
				blockdata.loc = Vector3.new(x,y,z)
				blockdata.part = part
				blockdata.color1 = Color3.new((x)/props.dims.x, (y)/props.dims.y, (z)/props.dims.z)
				--print(string.format("DEBUG: _blocks[%s]=%s", blockindex, tostring(_blocks[blockindex])))
				state.blocks[blockindex] = blockdata
				
				for _, Face in Enum.NormalId:GetEnumItems() do
					-- print("DEBUG: Face.Name=" .. Face.Name)

					local surfacegui = Instance.new("SurfaceGui")
					surfacegui.Parent = part
					surfacegui.Face = Face
					surfacegui.Name = string.format("SurfaceGui_%s", Face.Name)

					local label = Instance.new("TextLabel")
					label.Text = string.format("%d,%d,%d\n%d", x, y, z, n)
					label.Size = UDim2.new(1,0,1,0)
					label.BackgroundTransparency = 1
					--label.TextColor3 = Color3.new((x-1)%2, (x-1)%2, (x-1)%2)
					label.TextColor3 = props.labelColor
					label.TextStrokeTransparency = 0
					label.TextScaled = true
					label.RichText = true
					label.FontFace.Weight = Enum.FontWeight.Bold
					label.BorderMode = Enum.BorderMode.Inset
					label.BorderSizePixel = 100
					label.BorderColor3 = props.labelColor
					if Face == Enum.NormalId.Bottom or Face == Enum.NormalId.Top then
						label.Rotation = 180  -- # TODO: ENH: track which side of the cube the player is on
					end
					label.Parent = surfacegui
				end
			end
		end
	end

	for i, block in ipairs(state.blocks) do
		for j, otherBlock in ipairs(state.blocks) do
			if i ~= j then
				local constraint = Instance.new("RigidConstraint")
				constraint.Attachment0 = Instance.new("Attachment", block.part)
				constraint.Attachment1 = Instance.new("Attachment", otherBlock.part)
				constraint.Parent = block
			end
		end
	end

	local function setupExplosionOnJump()
		local function onTouched(hit)
			print(string.format("INFO: onTouched(%s)", tostring(hit)))
			if hit:IsA("Part") and hit.Position.Y <= 4 then
				local explosion = Instance.new("Explosion")
				explosion.Position = hit.Position
				explosion.Parent = workspace
				explosion.BlastRadius = 10
				explosion.ExplosionType = Enum.ExplosionType.NoCraters
				explosion.Parent = workspace
			end
		end

		for _, block in ipairs(workspace:GetChildren()) do
			if block:IsA("Part") then
				block.Touched:Connect(onTouched)
			end
		end
	end

	-- setupExplosionOnJump()

	print("DEBUG: #_blocks=" .. #state.blocks)  -- # TODO: why is this always zero
	return state.blocks, props.dims
end


function AreaVolumeCube_render()
	local blocks, dims = AreaVolumeCube_render_blocks()
	print("INFO: #blocks=" .. #blocks .. " dims=" .. tostring(dims))

	AreaVolumeCube_animate_strobe(blocks, dims) -- #TODO: state.blocks, state.blocks_dims
	return blocks, dims
end

function AreaVolumeCube_animate_strobe(blocks, dims) 
	--local lighting = game:GetService("Lighting")
	local TweenService = game:GetService("TweenService")
	--local targetColor = Color3.new(1, 0, 0) -- target color (red)

	local fadeDuration = 2
	local tweenInfo_fadeIn = TweenInfo.new(
		fadeDuration, 
		Enum.EasingStyle.Linear, 
		Enum.EasingDirection.InOut, 
		-1, 
		true, 
		0
	)
	for x = 1, dims.x do
		for y = 1, dims.y do
			for z = 1, dims.z do
				local targetColor = Color3.new((x-1)/dims.x, (y-1)/dims.y, (z-1)/dims.z)
				--local blockname = string.format("Block_%02d,%02d,%02d", x, y, z)
				local blockindex = string.format("%02d,%02d,%02d", x, y, z)
				--local blockindex = {x,y,z}
				local part = blocks[blockindex].part
				if part ~= nil then
					local tween1 = TweenService:Create(part, tweenInfo_fadeIn, { Color = targetColor })
					tween1:Play()
				else
					print("ERROR: part was nil. blocks[blockindex=" .. tostring(blockindex))
				end
			end
		end
	end
end

function AreaVolumeCube_setAllUnachored()
	local folder = workspace:FindFirstChild("AreaVolumeCubeModel").AreaVolumeCube
	if folder then
		for _, object in ipairs(folder:GetChildren()) do
			--print(object.Name)
			object.Anchored = false


		end
	else
		warn("Folder not found")
	end
end


function initLighting()
	local lighting = game:GetService("Lighting")
	lighting.ClockTime = 20
	--lighting.Ambient = Color3.new(0.4, 0, 0) -- sets the ambient color to red
	--lighting.OutdoorAmbient = Color3.new(0.4, 0, 0)
end
	
function initLighting_strobe() 
	local lighting = game:GetService("Lighting")
	local TweenService = game:GetService("TweenService")
	local targetColor = Color3.new(1, 0, 0) -- target color (red)

	local fadeDuration = 2
	local tweenInfo_fadeIn = TweenInfo.new(
		fadeDuration, 
		Enum.EasingStyle.Linear, 
		Enum.EasingDirection.InOut, 
		-1, 
		true, 
		0
	)
	local tween1 = TweenService:Create(lighting, tweenInfo_fadeIn, { Ambient = targetColor })
	tween1:Play()
end


function init()
	print("INFO: Area Volume Cube !")

	AreaVolumeCube_render_ball()

	initLighting()	
	--initLighting_strobe()

	local blocks, dims = AreaVolumeCube_render()
	-- TODO: initAreaVolumeCube_animations1()
	AreaVolumeCube_animate_strobe(blocks, dims) 
	--wait(10)
	--destroyAreaVolumeCube()

	print("INFO: Done!")
end

local _ = workspace:WaitForChild("SpawnLocation")
init()
--wait(10)
--destroyAreaVolumeCube()


