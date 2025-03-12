print("INFO: Area Volume Cube !")


function drawBall()
	print("INFO: Drawing Ball1 ...")
	local part = Instance.new("Part")
	part.Name = "Ball1"
	part.Anchored = true
	part.Shape = Enum.PartType.Ball
	part.Color = Color3.new(1, 0.5, 1)
	part.Size = Vector3.new(4, 4, 1)
	part.Position = Vector3.new(0,1,0)
	part.Parent = script.Parent
end



function drawAreaVolumeCube()
	print("INFO: Drawing 3x4x5 balls ...")

	local max = Vector3.new(3, 4, 10)
	local spacing = Vector3.new(1.1, 1.1, 1.1)
	local blocksize = Vector3.new(8, 8, 8)
	local origin = Vector3.new(
		20, 0, 20
	)


	local avc = Instance.new("Folder")
	avc.Name = "AreaVolumeCube"

	avc.Parent = script.Parent


	local blocks = {}

	for x = 1, max.X do 
		for y = 1,  max.Y do
			for z = 1, max.Z do
				local part = Instance.new("Part")
				part.Name = string.format("Block_%d,%d,%d", x, y, z)
				part.Anchored = true
				part.Shape = Enum.PartType.Block
				part.Size = blocksize
				part.Position = Vector3.new(
					origin.X + x * blocksize.X * spacing.X,
					origin.Y + y * blocksize.Y * spacing.Y,
					origin.Z + z * blocksize.Z * spacing.Z)

				part.Transparency = 0.05
				part.Color = Color3.new(
					x % 2,
					x % 2,
					x % 2)

				part.Parent = avc
				blocks[{x,y,z}] = part
				
				-- iterate through all enums in Enum.NormalId?
				
				for _, Face in Enum.NormalId:GetEnumItems() do
					-- print(Face.Name)

					local surfacegui = Instance.new("SurfaceGui")
					surfacegui.Parent = part
					surfacegui.Face = Face

					local label = Instance.new("TextLabel")
					label.Text = string.format("%d,%d,%d", x, y, z)
					label.Size = UDim2.new(1,0,1,0)
					label.BackgroundTransparency = 1
					label.TextColor3 = Color3.new((x-1)%2, (x-1)%2, (x-1)%2)
					label.TextStrokeTransparency = 0
					label.TextScaled = true
					label.RichText = true
					label.FontFace.Weight = Enum.FontWeight.Bold
					label.BorderMode = Enum.BorderMode.Inset
					label.BorderSizePixel = 100
					label.Parent = surfacegui
				end

			end
		end
	end
	return blocks
end
blocks = drawAreaVolumeCube()
print("INFO: Done!")


function destroyAreaVolumeCube()
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

--wait(10)
--destroyAreaVolumeCube()