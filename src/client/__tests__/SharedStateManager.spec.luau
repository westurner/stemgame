--!strict
local SharedStateManager = require(script.Parent.Parent.SharedStateManager)

describe("SharedStateManager", function()
    it("should be a singleton", function()
        local instance1 = require(script.Parent.Parent.SharedStateManager)
        local instance2 = require(script.Parent.Parent.SharedStateManager)
        expect(instance1).to.equal(instance2)
    end)

    it("should subscribe and unsubscribe callbacks", function()
        local componentName = "testComponent"
        local callback1Called = false
        local callback2Called = false

        local function callback1(state)
            callback1Called = true
        end

        local function callback2(state)
            callback2Called = true
        end

        local unsubscribe1 = SharedStateManager:subscribe(componentName, callback1)
        local unsubscribe2 = SharedStateManager:subscribe(componentName, callback2)

        -- Simulate a state change (this would normally come from the server)
        -- Since we can't directly trigger OnClientEvent, we'll mock the internal state update
        -- This part is tricky without mocking the entire ReplicatedStorage service.
        -- For now, we'll assume the internal _subscribers table is accessible for testing purposes.
        -- In a real scenario, you might mock ReplicatedStorage.EnvironmentStateChanged.OnClientEvent
        -- and then fire it to test the subscription.

        -- Mocking internal state update for testing purposes (not ideal for production code)
        local _subscribers = SharedStateManager._subscribers -- Assuming access for testing
        local _sharedState = SharedStateManager._sharedState -- Assuming access for testing

        _sharedState[componentName] = { data = "test" }
        if _subscribers[componentName] then
            for _, cb in ipairs(_subscribers[componentName]) do
                cb(_sharedState[componentName])
            end
        end

        expect(callback1Called).to.equal(true)
        expect(callback2Called).to.equal(true)

        callback1Called = false
        callback2Called = false

        unsubscribe1()

        _sharedState[componentName] = { data = "test2" }
        if _subscribers[componentName] then
            for _, cb in ipairs(_subscribers[componentName]) do
                cb(_sharedState[componentName])
            end
        end

        expect(callback1Called).to.equal(false)
        expect(callback2Called).to.equal(true)

        unsubscribe2()

        callback1Called = false
        callback2Called = false

        _sharedState[componentName] = { data = "test3" }
        if _subscribers[componentName] then
            for _, cb in ipairs(_subscribers[componentName]) do
                cb(_sharedState[componentName])
            end
        end

        expect(callback1Called).to.equal(false)
        expect(callback2Called).to.equal(false)
    end)

    it("should return current state upon subscription", function()
        local componentName = "initialStateTest"
        local receivedState = nil

        -- Simulate initial state being set before subscription
        local _sharedState = SharedStateManager._sharedState -- Assuming access for testing
        _sharedState[componentName] = { initialData = "present" }

        SharedStateManager:subscribe(componentName, function(state)
            receivedState = state
        end)

        expect(receivedState).to.equal({ initialData = "present" })
    end)

    it("should retrieve shared state", function()
        local componentName = "getStateTest"
        local testState = { value = 123 }

        local _sharedState = SharedStateManager._sharedState -- Assuming access for testing
        _sharedState[componentName] = testState

        local retrievedState = SharedStateManager:getSharedState(componentName)
        expect(retrievedState).to.equal(testState)
    end)
end)