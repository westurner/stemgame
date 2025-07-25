-- init.server.luau

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- 1. CREATE THE REMOTE EVENTS
local environmentStateChanged = Instance.new("RemoteEvent")
environmentStateChanged.Name = "EnvironmentStateChanged"
environmentStateChanged.Parent = ReplicatedStorage

local playerAction = Instance.new("RemoteEvent")
playerAction.Name = "PlayerAction"
playerAction.Parent = ReplicatedStorage

-- 2. DEFINE THE AUTHORITATIVE STATE
local SharedEnvironmentState = {
    isSharedMode = true, -- Default to shared mode, can be toggled
    airHockey = {
        puckPosition = Vector3.new(-100, 12.5, -100),
        puckVelocity = Vector3.new(0, 0, 0),
        paddle1Pos = Vector3.new(-100, 12, -130), -- Initial positions
        paddle2Pos = Vector3.new(-100, 12, -70),
        score1 = 0,
        score2 = 0,
        -- Track who controls which paddle
        paddle1Controller = nil, -- Player object
        paddle2Controller = nil,
    },
    doublePendulum = {
        angle1 = math.pi / 2,
        angle2 = math.pi / 2,
        vel1 = 0,
        vel2 = 0,
        trail = {},
    },
    areaVolumeCube = {
        highlightedBlocks = {},
    },
    billboardAnswers = {
        problem = nil,
        selectedAnswer = nil,
        lastAnswerCorrect = nil,
    },
    blochSphere = {
        -- No dynamic state for now, just a placeholder
    },
    surfaceSphere = {
        currentPoint = Vector3.new(0, 10, 0), -- Initial point on sphere surface
        trail = {},
    },
    -- ... other component states
}

-- Helper function to generate a new math problem
local function generateAdditionProblem()
    local num1 = math.random(1, 10)
    local num2 = math.random(1, 10)
    local correctAnswer = num1 + num2

    local answers = {}
    local correctIndex = math.random(1, 3)
    local allAnswers = {}

    -- Generate correct answer
    table.insert(allAnswers, {value = correctAnswer, correct = true})

    -- Generate two incorrect answers
    while #allAnswers < 3 do
        local incorrectAnswer = math.random(1, 20)
        if incorrectAnswer ~= correctAnswer and not table.find(allAnswers, incorrectAnswer) then
            table.insert(allAnswers, {value = incorrectAnswer, correct = false})
        end
    end

    -- Shuffle answers and assign IDs
    local answerIDs = {'A', 'B', 'C'}
    for i = 1, #allAnswers do
        local randIdx = math.random(i, #allAnswers)
        allAnswers[i], allAnswers[randIdx] = allAnswers[randIdx], allAnswers[i]
    end

    for i, ans in ipairs(allAnswers) do
        answers[answerIDs[i]] = ans
    end

    return {
        question = string.format("%d + %d = ?", num1, num2),
        answers = answers,
    }
end

-- Initialize the first problem
SharedEnvironmentState.billboardAnswers.problem = generateAdditionProblem()

-- 3. HANDLE PLAYER ACTIONS
playerAction.OnServerEvent:Connect(function(player, actionData)
    if actionData.component == "airHockey" then
        local hockeyState = SharedEnvironmentState.airHockey

        if actionData.action == "controlPaddle" then
            -- Assign control to the player if the paddle is free
            if actionData.paddle == 1 and not hockeyState.paddle1Controller then
                hockeyState.paddle1Controller = player
            elseif actionData.paddle == 2 and not hockeyState.paddle2Controller then
                hockeyState.paddle2Controller = player
            end
        elseif actionData.action == "releasePaddle" then
            -- Release control
            if actionData.paddle == 1 and hockeyState.paddle1Controller == player then
                hockeyState.paddle1Controller = nil
            elseif actionData.paddle == 2 and hockeyState.paddle2Controller == player then
                hockeyState.paddle2Controller = nil
            end
        elseif actionData.action == "movePaddle" then
            -- Update paddle position if the player has control
            if actionData.paddle == 1 and hockeyState.paddle1Controller == player then
                hockeyState.paddle1Pos = actionData.position
            elseif actionData.paddle == 2 and hockeyState.paddle2Controller == player then
                hockeyState.paddle2Pos = actionData.position
            end
        end
    elseif actionData.component == "modeToggle" then
        SharedEnvironmentState.isSharedMode = actionData.isSharedMode
    elseif actionData.component == "areaVolumeCube" then
        local cubeState = SharedEnvironmentState.areaVolumeCube
        if actionData.action == "toggleLight" then
            local blockKey = string.format("%d,%d,%d", actionData.block.X, actionData.block.Y, actionData.block.Z)
            if cubeState.highlightedBlocks[blockKey] then
                cubeState.highlightedBlocks[blockKey] = nil -- Turn off highlight
            else
                cubeState.highlightedBlocks[blockKey] = true -- Turn on highlight
            end
        end
    elseif actionData.component == "billboardAnswers" then
        local baState = SharedEnvironmentState.billboardAnswers
        if actionData.action == "selectAnswer" then
            local selectedID = actionData.answerID
            local currentProblem = baState.problem
            if currentProblem and currentProblem.answers[selectedID] then
                local isCorrect = currentProblem.answers[selectedID].correct
                baState.selectedAnswer = selectedID
                baState.lastAnswerCorrect = isCorrect
                print(string.format("Player %s selected %s. Correct: %s", player.Name, selectedID, tostring(isCorrect)))

                -- If correct, generate a new problem after a delay
                if isCorrect then
                    task.delay(3, function()
                        baState.problem = generateAdditionProblem()
                        baState.selectedAnswer = nil
                        baState.lastAnswerCorrect = nil
                    end)
                end
            end
        end
    end
end)

-- 4. THE MAIN SERVER LOOP
RunService.Heartbeat:Connect(function(deltaTime)
    if not SharedEnvironmentState.isSharedMode then return end

    -- Run simulations here...
    -- For example, simplified Air Hockey puck physics:
    local hockeyState = SharedEnvironmentState.airHockey
    hockeyState.puckPosition = hockeyState.puckPosition + hockeyState.puckVelocity * deltaTime
    -- (Add wall bouncing, goal checking, etc. here)

    -- Double Pendulum physics
    local pendulumState = SharedEnvironmentState.doublePendulum
    local g = 9.81
    local a1 = pendulumState.angle1
    local a2 = pendulumState.angle2
    local v1 = pendulumState.vel1
    local v2 = pendulumState.vel2
    local m1 = 1 -- Default mass
    local m2 = 1 -- Default mass
    local l1 = 10 -- Default length
    local l2 = 10 -- Default length

    local num1 = -g * (2 * m1 + m2) * math.sin(a1)
    local num2 = -m2 * g * math.sin(a1 - 2 * a2)
    local num3 = -2 * math.sin(a1 - a2) * m2
    local num4 = v2 * v2 * l2 + v1 * v1 * l1 * math.cos(a1 - a2)
    local den = l1 * (2 * m1 + m2 - m2 * math.cos(2 * a1 - 2 * a2))
    local acc1 = (num1 + num2 + num3 * num4) / den

    num1 = 2 * math.sin(a1 - a2)
    num2 = v1 * v1 * l1 * (m1 + m2)
    num3 = g * (m1 + m2) * math.cos(a1)
    num4 = v2 * v2 * l2 * m2 * math.cos(a1 - a2)
    den = l2 * (2 * m1 + m2 - m2 * math.cos(2 * a1 - 2 * a2))
    local acc2 = (num1 * (num2 + num3 + num4)) / den

    -- Check for NaN or Inf and reset if necessary
    if acc1 ~= acc1 or acc1 == math.huge or acc1 == -math.huge or
       acc2 ~= acc2 or acc2 == math.huge or acc2 == -math.huge then
        print("DEBUG: Server DoublePendulum: NaN or Inf detected, resetting.")
        pendulumState.angle1 = math.pi / 2
        pendulumState.angle2 = math.pi / 2
        pendulumState.vel1 = 0
        pendulumState.vel2 = 0
        pendulumState.trail = {}
    else
        pendulumState.vel1 = v1 + acc1 * deltaTime
        pendulumState.vel2 = v2 + acc2 * deltaTime
        pendulumState.angle1 = a1 + pendulumState.vel1 * deltaTime
        pendulumState.angle2 = a2 + pendulumState.vel2 * deltaTime

        -- Update trail (simplified for server, just positions)
        local origin = Vector3.new(-100, 32, 42) -- Hardcoded origin for server simulation
        local p1 = origin + Vector3.new(l1 * math.sin(pendulumState.angle1), -l1 * math.cos(pendulumState.angle1), 0)
        local p2 = p1 + Vector3.new(l2 * math.sin(pendulumState.angle2), -l2 * math.cos(pendulumState.angle2), 0)

        local now = os.clock()
        table.insert(pendulumState.trail, {pos = p2, time = now})
        -- Keep trail length reasonable
        while #pendulumState.trail > 60 and now - pendulumState.trail[1].time > 3.5 do
            table.remove(pendulumState.trail, 1)
        end
    end

    -- Surface Sphere physics
    local surfaceSphereState = SharedEnvironmentState.surfaceSphere
    local SPHERE_RADIUS = 10 -- Must match client
    local TRAIL_FADE_TIME = 1.2 -- Must match client

    local function randomPointOnSphere(radius)
        local theta = math.random() * 2 * math.pi
        local phi = math.acos(2 * math.random() - 1)
        local x = radius * math.sin(phi) * math.cos(theta)
        local y = radius * math.sin(phi) * math.sin(theta)
        local z = radius * math.cos(phi)
        return Vector3.new(x, y, z)
    end

    -- Move currentPoint towards a new random point
    if not surfaceSphereState._targetPoint or (surfaceSphereState.currentPoint - surfaceSphereState._targetPoint).Magnitude < 0.1 then
        surfaceSphereState._targetPoint = randomPointOnSphere(SPHERE_RADIUS)
    end
    surfaceSphereState.currentPoint = surfaceSphereState.currentPoint:Lerp(surfaceSphereState._targetPoint, 0.05)

    -- Update trail
    local now = os.clock()
    table.insert(surfaceSphereState.trail, {pos = surfaceSphereState.currentPoint, time = now})
    while #surfaceSphereState.trail > 60 and now - surfaceSphereState.trail[1].time > TRAIL_FADE_TIME do
        table.remove(surfaceSphereState.trail, 1)
    end

    -- Broadcast the updated state to all clients
    environmentStateChanged:FireAllClients(SharedEnvironmentState)
end)

-- Handle players leaving and dropping their paddles
Players.PlayerRemoving:Connect(function(player)
    local hockeyState = SharedEnvironmentState.airHockey
    if hockeyState.paddle1Controller == player then
        hockeyState.paddle1Controller = nil
    end
    if hockeyState.paddle2Controller == player then
        hockeyState.paddle2Controller = nil
    end
end)

print("DEBUG: server: init.server.luau loaded with shared state management.")
