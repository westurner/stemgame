-- MultiJumpComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local MultiJumpComponent = React.Component:extend("MultiJumpComponent")

function MultiJumpComponent:init()
    self.props = self.props or {}
    self.state = {
        isJumping = false,
        jumpCount = 0,
    }
end

function MultiJumpComponent:render()
    local jumpHeight = self.props.jumpHeight or 50
    local maxJumps = self.props.maxJumps or 2

    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")

            if humanoid then
                humanoid.Changed:Connect(function()
                    if humanoid.Jump and not self.state.isJumping then
                        self.state.isJumping = true
                        self.state.jumpCount = 1
                        print("INFO: Initial Jump by " .. player.Name)
                    end
                end)

                humanoid.FreeFalling:Connect(function()
                    if self.state.isJumping and self.state.jumpCount < maxJumps then
                        self.state.jumpCount += 1
                        humanoid.JumpPower = jumpHeight * self.state.jumpCount
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        print("INFO: MultiJump " .. self.state.jumpCount .. " by " .. player.Name)
                        task.wait(0.5)
                        humanoid.JumpPower = jumpHeight
                    else
                        self.state.isJumping = false
                        self.state.jumpCount = 0
                    end
                end)
            end
        end)
    end)

    return nil
end

return MultiJumpComponent