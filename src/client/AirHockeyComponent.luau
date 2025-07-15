local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local AirHockeyComponent = React.Component:extend("AirHockeyComponent")

function AirHockeyComponent:init()
    self.props = self.props or {}
    -- Set all default props here
    self.props.Position = self.props.Position or Vector3.new(0, 0, 0)
    self.props.tableLength = self.props.tableLength or 60
    self.props.tableWidth = self.props.tableWidth or 120
    self.props.tableHeight = self.props.tableHeight or 2
    self.props.wallHeight = self.props.wallHeight or 4
    self.props.wallThickness = self.props.wallThickness or 1
    self.props.puckRadius = self.props.puckRadius or 2
    self.props.puckHeight = self.props.puckHeight or 1
    self.props.puckColor = self.props.puckColor or Color3.fromRGB(0, 255, 255)
    self.props.wallColor = self.props.wallColor or Color3.fromRGB(255, 0, 0)
    self.props.tableColor = self.props.tableColor or Color3.fromRGB(200, 200, 200)
    self.props.paddleRadius = self.props.paddleRadius or 3
    self.props.paddleHeight = self.props.paddleHeight or 1.5
    self.props.paddleColor1 = self.props.paddleColor1 or Color3.fromRGB(0, 162, 255)
    self.props.paddleColor2 = self.props.paddleColor2 or Color3.fromRGB(0, 162, 255)
    self.props.puckTransparency = self.props.puckTransparency or 0.4
    self.props.wallTransparency = self.props.wallTransparency or 0.5
    self.props.tableTransparency = self.props.tableTransparency or 0.4
    self.props.paddleTransparency = self.props.paddleTransparency or 0.3
    self.props.paddleOffset = self.props.tableLength / 2 - 10
    self.props.autoReturnDelay = self.props.autoReturnDelay or 3
    self.props.showGoals = self.props.showGoals ~= false
    self.props.goalWidth = self.props.tableWidth / 3
    self.props.goalDepth = self.props.wallThickness * 2.2
    self.props.goalHeight = self.props.wallHeight * 1.1
    self.props.goalColor1 = self.props.goalColor1 or Color3.fromRGB(0, 255, 204)
    self.props.goalColor2 = self.props.goalColor2 or Color3.fromRGB(247, 102, 40)
    self.props.goalTransparency = self.props.showGoals and 0.5 or 1
    self.state = {
        userControlPaddle1 = false,
        userControlPaddle2 = false,
        score1 = 0,
        score2 = 0,
        paddle1Pos = nil,
        paddle2Pos = nil,
    }
    self.refs = self.refs or {}
    self.refs.puckRef = self.refs.puckRef or React.createRef()
    self.refs.paddle1Ref = self.refs.paddle1Ref or React.createRef()
    self.refs.paddle2Ref = self.refs.paddle2Ref or React.createRef()
    self.scoreboardGui = nil
end

function AirHockeyComponent:centerOfTable()
    return self.props.Position + Vector3.new(
        0, --self.props.tableLength/2,
        self.props.tableHeight + self.props.puckHeight/2,
        0 --self.props.tableWidth/2)
    )
end

function AirHockeyComponent:resetPuck()
    local puck = self.refs.puckRef.current
    if puck then
        print("DEBUG: AirHockeyComponent:resetPuck()")
        -- Center of table, on top of the ice
        puck.Position = self:centerOfTable()
        puck.Velocity = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
        -- puck.CanCollide = false
        -- task.delay(0.5, function()
        --     if puck then
        --         puck.CanCollide = true
        --         puck.Velocity = Vector3.new(0,0,0)
        --     end
        -- end)
    end
end

function AirHockeyComponent:trackPaddles()
    local function movePaddleToward(paddle, targetZ, speed)
        if not paddle then return end
        local pos = paddle.Position
        -- Clamp paddle Z to stay within the table, not in the goal
        local tableLength = self.props.tableLength
        local tableWidth = self.props.tableWidth
        local wallThickness = self.props.wallThickness
        local paddleRadius = self.props.paddleRadius
        local position = self.props.Position
        local minZ = position.Z - tableWidth / 2 + paddleRadius + wallThickness
        local maxZ = position.Z + tableWidth / 2 - paddleRadius - wallThickness
        local newZ = pos.Z + math.clamp(targetZ - pos.Z, -speed, speed)
        newZ = math.clamp(newZ, minZ, maxZ)
        paddle.Position = Vector3.new(pos.X, pos.Y, newZ)
    end
    local puck = self.refs.puckRef.current
    local paddle1 = self.refs.paddle1Ref.current
    local paddle2 = self.refs.paddle2Ref.current
    if puck then
        if paddle1 and not self.state.userControlPaddle1 then
            movePaddleToward(paddle1, puck.Position.Z, 0.5)
        end
        if paddle2 and not self.state.userControlPaddle2 then
            movePaddleToward(paddle2, puck.Position.Z, 0.5)
        end
    end
end

function AirHockeyComponent:handleBoundsAndBounce()
    -- Table and object parameters
    local props = self.props
    local position = props.Position
    local tableLength = props.tableLength
    local tableWidth = props.tableWidth
    local wallThickness = props.wallThickness
    local tableHeight = props.tableHeight
    local puckRadius = props.puckRadius
    local puckHeight = props.puckHeight
    local paddleRadius = props.paddleRadius
    local paddleHeight = props.paddleHeight
    local paddleOffset = tableLength / 2 - 10

    -- Bounce area (inside walls)
    local minX = position.X - tableLength / 2 + wallThickness
    local maxX = position.X + tableLength / 2 - wallThickness
    local minZ = position.Z - tableWidth / 2 + wallThickness
    local maxZ = position.Z + tableWidth / 2 - wallThickness
    -- Out-of-bounds area (for reset)
    local minXOut = position.X - tableLength / 2 - 1 * puckRadius
    local maxXOut = position.X + tableLength / 2 + 1 * puckRadius
    local minZOut = position.Z - tableWidth / 2 - 1 * puckRadius
    local maxZOut = position.Z + tableWidth / 2 + 1 * puckRadius
    -- Paddle clamp area
    local minXPad = position.X - tableLength / 2 + paddleRadius + wallThickness
    local maxXPad = position.X + tableLength / 2 - paddleRadius - wallThickness
    local minZPad = position.Z - tableWidth / 2 + paddleRadius + wallThickness
    local maxZPad = position.Z + tableWidth / 2 - paddleRadius - wallThickness

    -- Y bounds for puck and paddles
    local minY = position.Y + tableHeight
    local maxY = position.Y + tableHeight + 20 -- allow a little leeway above the table

    -- Helper: check if part is out of bounds and reset after delay
    local function checkAndReset(part, startPos, minX, maxX, minZ, maxZ, minY, maxY)
        if not part then return end
        local pos = part.Position
        local isOut =
            pos.X < minX or pos.X > maxX or
            pos.Z < minZ or pos.Z > maxZ or
            (minY and maxY and (pos.Y < minY or pos.Y > maxY))
        if isOut then
            if not part:GetAttribute("OutOfBounds") then
                part:SetAttribute("OutOfBounds", true)
                task.delay(1.2, function()
                    if part and part:GetAttribute("OutOfBounds") then
                        print("DEBUG: AirHockeyComponent: Part out of bounds")
                        part.Position = startPos
                        part.Velocity = Vector3.new(0, 0, 0)
                        part:SetAttribute("OutOfBounds", false)
                    end
                end)
            end
        else
            part:SetAttribute("OutOfBounds", false)
        end
    end

    -- Helper: bounce puck off walls
    local function bouncePuck(puck)
        if not puck then return end
        local pos, vel = puck.Position, puck.Velocity
        local bounced = false
        if pos.X < minX and vel.X < 0 then
            vel = Vector3.new(-vel.X, vel.Y, vel.Z)
            bounced = true
        elseif pos.X > maxX and vel.X > 0 then
            vel = Vector3.new(-vel.X, vel.Y, vel.Z)
            bounced = true
        end
        if pos.Z < minZ and vel.Z < 0 then
            vel = Vector3.new(vel.X, vel.Y, -vel.Z)
            bounced = true
        elseif pos.Z > maxZ and vel.Z > 0 then
            vel = Vector3.new(vel.X, vel.Y, -vel.Z)
            bounced = true
        end
        if bounced then puck.Velocity = vel * 0.98 end
    end

    -- Get refs
    local puck = self.refs.puckRef.current
    local paddle1 = self.refs.paddle1Ref.current
    local paddle2 = self.refs.paddle2Ref.current

    -- Puck: bounce and reset
    if puck then
        bouncePuck(puck)
        local puckStart = self:centerOfTable()
        checkAndReset(puck, puckStart, minXOut, maxXOut, minZOut, maxZOut, minY, maxY)
    end

    -- Helper: clamp paddle to play area and reset if far out
    local function clampAndResetPaddle(paddle, startPos)
        if not paddle then return end
        local pos = paddle.Position
        local newX = math.clamp(pos.X, minXPad, maxXPad)
        local newZ = math.clamp(pos.Z, minZPad, maxZPad)
        if newX ~= pos.X or newZ ~= pos.Z then
            paddle.Position = Vector3.new(newX, pos.Y, newZ)
            paddle.Velocity = Vector3.new(0, 0, 0)
        else
            -- If paddle is not being moved by user or AI, zero velocity to prevent drift
            if math.abs(paddle.Velocity.X) < 0.01 and math.abs(paddle.Velocity.Z) < 0.01 then
                paddle.Velocity = Vector3.new(0, 0, 0)
            end
        end
        checkAndReset(paddle, startPos, minXPad, maxXPad, minZPad, maxZPad, minY, maxY)
    end

    -- Paddle 1
    local paddle1Start = position + Vector3.new(0, tableHeight / 2 + paddleHeight / 2 + 0.1, -paddleOffset)
    clampAndResetPaddle(paddle1, paddle1Start)
    -- Paddle 2
    local paddle2Start = position + Vector3.new(0, tableHeight / 2 + paddleHeight / 2 + 0.1, paddleOffset)
    clampAndResetPaddle(paddle2, paddle2Start)
end

function AirHockeyComponent:didMount()
    self:createScoreboard()
    self.heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
        self:trackPaddles()
        self:checkGoals()
        self:handleBoundsAndBounce()
    end)
end

function AirHockeyComponent:willUnmount()
    if self.heartbeatConn then
        self.heartbeatConn:Disconnect()
    end
    if self.scoreboardGui then
        self.scoreboardGui:Destroy()
    end
end

function AirHockeyComponent:checkGoals()
    local puck = self.refs.puckRef.current
    if not puck then return end
    local x = puck.Position.X
    local z = puck.Position.Z
    local position = self.props.Position
    local puckRadius = self.props.puckRadius
    local goalZ = (self.props.tableWidth / 2) + (self.props.goalDepth or (self.props.wallThickness * 2.2)) / 2
    local goalWidth = self.props.goalWidth or (self.props.tableWidth / 3)
    -- Check if puck is fully within the X bounds of the goal when crossing Z boundary
    if (z - puckRadius) < (position.Z - goalZ) and math.abs(x - position.X) <= (goalWidth / 2 - puckRadius) then
        self:setState({ score2 = self.state.score2 + 1 })
        self:resetPuck()
    elseif (z + puckRadius) > (position.Z + goalZ) and math.abs(x - position.X) <= (goalWidth / 2 - puckRadius) then
        self:setState({ score1 = self.state.score1 + 1 })
        self:resetPuck()
    end
end

function AirHockeyComponent:createScoreboard()
    local Players = game:GetService("Players")
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "AirHockeyScoreboard"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    self.scoreboardGui = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(1, -210, 1, -90)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Name = "ScoreLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Text = self:getScoreText()
    label.Parent = frame
    self.scoreLabel = label
end

function AirHockeyComponent:getScoreText()
    return string.format("Score\nP1: %d  |  P2: %d", self.state.score1, self.state.score2)
end

function AirHockeyComponent:didUpdate()
    if self.scoreLabel then
        self.scoreLabel.Text = self:getScoreText()
    end
end

function AirHockeyComponent:onUserControlButton(paddleNum)
    if paddleNum == 1 then
        self:setState({ userControlPaddle1 = true })
    elseif paddleNum == 2 then
        self:setState({ userControlPaddle2 = true })
    end
end

function AirHockeyComponent:onDropPaddle(paddleNum)
    if paddleNum == 1 then
        self:setState({ userControlPaddle1 = false })
        task.delay(self.autoReturnDelay, function()
            if not self.state.userControlPaddle1 then
                self:setState({ userControlPaddle1 = false })
            end
        end)
    elseif paddleNum == 2 then
        self:setState({ userControlPaddle2 = false })
        task.delay(self.autoReturnDelay, function()
            if not self.state.userControlPaddle2 then
                self:setState({ userControlPaddle2 = false })
            end
        end)
    end
end

function AirHockeyComponent:render()
    local position = self.props.Position
    local tableLength = self.props.tableLength
    local tableWidth = self.props.tableWidth
    local tableHeight = self.props.tableHeight
    local tableY = position.Y + tableHeight / 2
    local wallHeight = self.props.wallHeight
    local wallThickness = self.props.wallThickness
    local puckPosition = self:centerOfTable()
    local puckRadius = self.props.puckRadius
    local puckHeight = self.props.puckHeight
    local puckColor = self.props.puckColor
    local wallColor = self.props.wallColor
    local tableColor = self.props.tableColor
    local paddleRadius = self.props.paddleRadius
    local paddleHeight = self.props.paddleHeight
    local paddleColor1 = self.props.paddleColor1
    local paddleColor2 = self.props.paddleColor2
    local puckTransparency = self.props.puckTransparency
    local wallTransparency = self.props.wallTransparency
    local tableTransparency = self.props.tableTransparency
    local paddleTransparency = self.props.paddleTransparency
    local paddleOffset = self.props.paddleOffset
    local showGoals = self.props.showGoals
    local goalWidth = self.props.goalWidth
    local goalDepth = self.props.goalDepth
    local goalHeight = self.props.goalHeight
    local goalColor1 = self.props.goalColor1
    local goalColor2 = self.props.goalColor2
    local goalTransparency = self.props.goalTransparency

    -- Goals (optionally visible)
    -- Table
    local tablePart = React.createElement("Part", {
        Name = "AirHockeyTable",
        Size = Vector3.new(tableLength, tableHeight, tableWidth),
        Position = position + Vector3.new(0, tableY, 0),
        Anchored = true,
        Color = tableColor,
        Material = Enum.Material.SmoothPlastic,
        Transparency = tableTransparency,
        CanCollide = true,
        Friction = 0.01,
        --CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5),
    })

    -- Walls (4 low walls around the table)
    local walls = {
        -- Left
        React.createElement("Part", {
            Name = "WallLeft",
            Size = Vector3.new(wallThickness, wallHeight, tableWidth + wallThickness * 2),
            Position = position + Vector3.new(-tableLength / 2 - wallThickness / 2, wallHeight / 2 + tableY, 0),
            Anchored = true,
            Color = wallColor,
            Material = Enum.Material.Neon,
            Transparency = wallTransparency,
            CanCollide = true,
        }),
        -- Right
        React.createElement("Part", {
            Name = "WallRight",
            Size = Vector3.new(wallThickness, wallHeight, tableWidth + wallThickness * 2),
            Position = position + Vector3.new(tableLength / 2 + wallThickness / 2, wallHeight / 2 + tableY, 0),
            Anchored = true,
            Color = wallColor,
            Material = Enum.Material.Neon,
            Transparency = wallTransparency,
            CanCollide = true,
        }),
        -- Top
        React.createElement("Part", {
            Name = "WallTop",
            Size = Vector3.new(tableLength, wallHeight, wallThickness),
            Position = position + Vector3.new(0, wallHeight / 2 + tableY, -tableWidth / 2 - wallThickness / 2),
            Anchored = true,
            Color = wallColor,
            Material = Enum.Material.Neon,
            Transparency = wallTransparency,
            CanCollide = true,
        }),
        -- Bottom
        React.createElement("Part", {
            Name = "WallBottom",
            Size = Vector3.new(tableLength, wallHeight, wallThickness),
            Position = position + Vector3.new(0, wallHeight / 2 + tableY, tableWidth / 2 + wallThickness / 2),
            Anchored = true,
            Color = wallColor,
            Material = Enum.Material.Neon,
            Transparency = wallTransparency,
            CanCollide = true,
        }),
    }

    -- Paddles (2, one for each side)
    local paddles = {
        React.createElement("Part", {
            Name = "Paddle1",
            ref = self.refs.paddle1Ref,
            Shape = Enum.PartType.Cylinder,
            Size = Vector3.new(paddleHeight, paddleRadius * 2, paddleRadius*2),
            Position = position + Vector3.new(0, tableY + paddleHeight / 2 + 0.1, -paddleOffset),
            Anchored = false,
            Color = paddleColor1,
            Material = Enum.Material.Neon,
            Transparency = paddleTransparency,
            CanCollide = true,
            Orientation = Vector3.new(0, 0, 90),
            Friction = 0.01,
            CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5),
        }),
        React.createElement("Part", {
            Name = "Paddle2",
            ref = self.refs.paddle2Ref,
            Shape = Enum.PartType.Cylinder,
            Size = Vector3.new(paddleHeight, paddleRadius * 2, paddleRadius * 2),
            Position = position + Vector3.new(0, tableY + paddleHeight / 2 + 0.1, paddleOffset),
            Anchored = false,
            Color = paddleColor2,
            Material = Enum.Material.Neon,
            Transparency = paddleTransparency,
            CanCollide = true,
            Orientation = Vector3.new(0, 0, 90),
            Friction = 0.01,
            CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5),
        }),
    }

    local goals = {
        React.createElement("Part", {
            Name = "Goal1",
            Size = Vector3.new(goalWidth, goalHeight, goalDepth),
            Position = position + Vector3.new(0, tableY + goalHeight / 2, 2 + -tableWidth / 2 - goalDepth),
            Anchored = true,
            Color = goalColor1,
            Material = Enum.Material.Neon,
            Transparency = goalTransparency,
            CanCollide = false,
        }),
        React.createElement("Part", {
            Name = "Goal2",
            Size = Vector3.new(goalWidth, goalHeight, goalDepth),
            Position = position + Vector3.new(0, tableY + goalHeight / 2, -2 + tableWidth / 2 + goalDepth),
            Anchored = true,
            Color = goalColor2,
            Material = Enum.Material.Neon,
            Transparency = goalTransparency,
            CanCollide = false,
        }),
    }

    -- Puck (allow player to ride it by setting CanCollide = true and SurfaceType = Smooth)
    local puck = React.createElement("Part", {
        Name = "Puck",
        ref = self.refs.puckRef,
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(puckHeight, puckRadius * 2, puckRadius * 2),
        Position = puckPosition, --position + Vector3.new(tableLength/2, tableY + puckHeight / 2 + 0.1, tableWidth/2),
        Anchored = false,
        Color = puckColor,
        Material = Enum.Material.Neon,
        Transparency = puckTransparency,
        CanCollide = true,
        Orientation = Vector3.new(0, 0, 90),
        TopSurface = Enum.SurfaceType.Smooth,
        BottomSurface = Enum.SurfaceType.Smooth,
        Friction = 0.01,
        --CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5),
    })

    -- User control buttons for each paddle
    local userButton1 = React.createElement("TextButton", {
        Name = "UserControlButton1",
        Text = self.state.userControlPaddle1 and "Drop Paddle 1" or "Control Paddle 1",
        Size = UDim2.new(0, 200, 0, 50),
        Position = UDim2.new(0.2, -100, 0.9, 0),
        [React.Event.Activated] = function()
            if self.state.userControlPaddle1 then
                self:onDropPaddle(1)
            else
                self:onUserControlButton(1)
            end
        end,
    })
    local userButton2 = React.createElement("TextButton", {
        Name = "UserControlButton2",
        Text = self.state.userControlPaddle2 and "Drop Paddle 2" or "Control Paddle 2",
        Size = UDim2.new(0, 200, 0, 50),
        Position = UDim2.new(0.8, -100, 0.9, 0),
        [React.Event.Activated] = function()
            if self.state.userControlPaddle2 then
                self:onDropPaddle(2)
            else
                self:onUserControlButton(2)
            end
        end,
    })

    -- Combine all elements into a single array for Model children
    local modelChildren = { tablePart, puck, userButton1, userButton2 }
    for _, wall in ipairs(walls) do table.insert(modelChildren, wall) end
    for _, paddle in ipairs(paddles) do table.insert(modelChildren, paddle) end
    for _, goal in ipairs(goals) do table.insert(modelChildren, goal) end

    return React.createElement("Model", {
        Name = "AirHockeyModel",
    }, modelChildren)
end

return AirHockeyComponent
