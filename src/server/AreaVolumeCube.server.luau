
print("DEBUG: AreaVolumeCube.server: starting...")

--local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

--local SpawnLocation = game.SpawnLocation
--local SpawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
local SpawnLocation = Instance.new("SpawnLocation")
SpawnLocation.Position = Vector3.new(0, 1000, 0)
SpawnLocation.Rotation=Vector3.new(0, 0, 0)
SpawnLocation.Size=Vector3.new(20,1,20)
SpawnLocation.Material=Enum.Material.Ground
SpawnLocation.CanCollide=false
SpawnLocation.CanTouch=false
SpawnLocation.Transparency=1

local props = {}
props.dims = Vector3.new(3,4,10)
props.spacing = Vector3.new(1.1, 1.1, 1.1)
props.blockSize = Vector3.new(8, 8, 8)

local areaVolumeCube = Instance.new("Part")
areaVolumeCube.Transparency = 0.5
areaVolumeCube.Shape = Enum.PartType.Block
areaVolumeCube.Position = Vector3.new(20, 30, 50)
--props.origin = areaVolumeCube.Position
areaVolumeCube.Size=Vector3.new(
    (props.dims.X-1) * props.spacing.X + (props.blockSize.X * props.spacing.X),
    (props.dims.Y-1) * props.spacing.Y + (props.blockSize.Y * props.spacing.Y),
    (props.dims.Z-1) * props.spacing.Z + (props.blockSize.Z * props.spacing.Z)) -- TODO: spacing
areaVolumeCube.CanCollide = false
areaVolumeCube.Anchored = true
areaVolumeCube.Parent = workspace

-- local character_spawn_rotation = CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))

local function AreaVolumeCube_connect_onPlayerSpawned(player)
	game.Players.PlayerAdded:Connect(function(player)
	    print("DEBUG: AreaVolumeCube.server:PlayerAdded: " .. player.Name)
	    player.CharacterAdded:Connect(function(character)
	        print("DEBUG: AreaVolumeCube.server:CharacterAdded: " .. character.Name)
	        if character then
	            local humanoid = character:WaitForChild("Humanoid")
	            if humanoid then
	                local rootPart = humanoid.RootPart
	                --local SpawnLocation = workspace:FindFirstChild("SpawnLocation", true)
                    --rootPart.CFrame = SpawnLocation.CFrame
                    --[[rootPart.Position = SpawnLocation.Position + Vector3.new(
                        0,
                        SpawnLocation.Size.Y+100,
                        0)
                    ]]--
	                --rootPart.CFrame = SpawnLocation.CFrame * character_spawn_rotation
                    rootPart.CFrame = CFrame.lookAt(rootPart.Position, areaVolumeCube.Position)
                    SpawnLocation.Parent = workspace

                    task.wait(1)
                    rootPart.CFrame = CFrame.lookAt(rootPart.Position, areaVolumeCube.Position)
	            end
	        end
		end)
	end)
end

AreaVolumeCube_connect_onPlayerSpawned()



print("DEBUG: AreaVolumeCube.server: done.")