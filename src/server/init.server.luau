-- init.server.luau

-- Function to log server events
local function logServerEvents(message)
    print("DEBUG: server: " .. message)
end

function init()
    print("DEBUG: server: Starting...")

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    --local LogService = game:GetService("LogService")

    local RemoteEvent = Instance.new("RemoteEvent", game.ReplicatedStorage)
    RemoteEvent.Name = "ServerEvent"

    -- Connect to server events
    RemoteEvent.OnServerEvent:Connect(function(player, ...)
        logServerEvents("OnServerEvent triggered by player.Name=" .. player.Name)
    end)

    Players.PlayerAdded:Connect(function(player)
        logServerEvents("PlayerAdded: " .. player.Name)
    end)

    Players.PlayerRemoving:Connect(function(player)
        logServerEvents("PlayerRemoving: " .. player.Name)
    end)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            logServerEvents("CharacterAdded for player: " .. player.Name)
        end)

        player.CharacterRemoving:Connect(function(character)
            logServerEvents("CharacterRemoving for player: " .. player.Name)
        end)

        player.Chatted:Connect(function(message)
            logServerEvents("Chatted by player: " .. player.Name .. " - Message: " .. message)
        end)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        logServerEvents("InputBegan: " .. input.UserInputType.Name)
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        logServerEvents("InputEnded: " .. input.UserInputType.Name)
    end)

    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        logServerEvents("InputChanged: " .. input.UserInputType.Name)
    end)

    print("DEBUG: server: Done.")
end

function test_init()
    init()
end

-- test_init()

init()

