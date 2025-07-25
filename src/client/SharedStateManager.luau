-- src/client/shared/SharedStateManager.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SharedStateManager = {}
SharedStateManager.__index = SharedStateManager

local _sharedState = {} -- The current shared state received from the server
local _subscribers = {} -- { componentName = { callback1, callback2, ... } }

function SharedStateManager.new()
    local self = setmetatable({}, SharedStateManager)
    self:init()
    return self
end

function SharedStateManager:init()
    -- Listen for server updates to the entire shared state
    ReplicatedStorage.EnvironmentStateChanged.OnClientEvent:Connect(function(newState)
        _sharedState = newState
        -- Notify subscribers for relevant parts of the state
        for componentName, callbacks in pairs(_subscribers) do
            if _sharedState[componentName] then
                for _, callback in ipairs(callbacks) do
                    -- Pass a copy or immutable version if state objects are complex
                    callback(_sharedState[componentName])
                end
            end
        end
    end)
end

function SharedStateManager:subscribe(componentName, callback)
    _subscribers[componentName] = _subscribers[componentName] or {}
    table.insert(_subscribers[componentName], callback)
    -- Immediately provide current state if available upon subscription
    if _sharedState[componentName] then
        callback(_sharedState[componentName])
    end
    return function() -- Return an unsubscribe function
        local index = table.find(_subscribers[componentName], callback)
        if index then
            table.remove(_subscribers[componentName], index)
        end
    end
end

function SharedStateManager:getSharedState(componentName)
    return _sharedState[componentName]
end

return SharedStateManager.new() -- Return a singleton instance
