local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SharedStateManager = require(game.StarterPlayer.StarterPlayerScripts.Client.SharedStateManager)

local AirHockeyComponent = React.Component:extend("AirHockeyComponent")

function AirHockeyComponent:init()
    self.props = self.props or {}
    -- Set all default props here
    self.props.Name = self.props.Name or "Hockey01"
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
    self.props.paddleOffset = self.props.paddleOffset or 10
    self.props.autoReturnDelay = self.props.autoReturnDelay or 3
    self.props.showGoals = self.props.showGoals ~= false
    self.props.goalWidth = self.props.goalWidth or (self.props.tableWidth / 3)
    self.props.goalDepth = self.props.goalDepth or (self.props.wallThickness * 2.2)
    self.props.goalHeight = self.props.goalHeight or (self.props.wallHeight * 1.1)
    self.props.goalColor1 = self.props.goalColor1 or Color3.fromRGB(0, 255, 204)
    self.props.goalColor2 = self.props.goalColor2 or Color3.fromRGB(247, 102, 40)
    self.props.goalTransparency = self.props.goalTransparency or (self.props.showGoals and 0.5 or 1)

    self.state = {}
    self.state.userControlPaddle1 = false
    self.state.userControlPaddle2 = false
    self.state.score1 = 0
    self.state.score2 = 0
    self.state.puckPosition = self.props.Position
    self.state.paddle1Pos = self.props.Position
    self.state.paddle2Pos = self.props.Position
    self.state.puckRenderPos = self.props.Position
    self.state.paddle1RenderPos = self.props.Position
    self.state.paddle2RenderPos = self.props.Position
    self.state.showButtons = false -- New state for UI button visibility

    self.refs = self.refs or {}
    self.refs.puckRef = self.refs.puckRef or React.createRef()
    self.refs.paddle1Ref = self.refs.paddle1Ref or React.createRef()
    self.refs.paddle2Ref = self.refs.paddle2Ref or React.createRef()
    self.scoreboardGui = nil

    -- UI elements for PlayerGui
    self.playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "AirHockeyUI_" .. self.props.Name or "AirHockeyUI"
    self.uiRoot = ReactRoblox.createRoot(self.screenGui)
    self.screenGui.Parent = self.playerGui
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
    local maxZPad = position.Z + tableWidth / 2 - paddleRadius + wallThickness

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
    self:renderUI() -- Initial render of UI

    -- Proximity check for UI buttons
    self.proximityCheckConn = RunService.Heartbeat:Connect(function()
        local localPlayer = Players.LocalPlayer
        if localPlayer and localPlayer.Character and localPlayer.Character.PrimaryPart then
            local playerPos = localPlayer.Character.PrimaryPart.Position
            local tableCenter = self.props.Position
            local distance = (playerPos - tableCenter).Magnitude
            local newShowButtons = distance <= 102 -- Within 102 units

            if newShowButtons ~= self.state.showButtons then
                self:setState({ showButtons = newShowButtons })
                self:renderUI() -- Re-render UI when visibility changes
            end
        end
    end)

    if self.props.isSharedMode then
        -- Listen for server state
        self.stateChangedConn = SharedStateManager:subscribe("airHockey", function(hockeyState)
            self:setState({
                puckPosition = hockeyState.puckPosition,
                paddle1Pos = hockeyState.paddle1Pos,
                paddle2Pos = hockeyState.paddle2Pos,
                score1 = hockeyState.score1,
                score2 = hockeyState.score2,
            })
        end)

        -- Start a client-side render loop for interpolation
        self.renderLoopConn = RunService.RenderStepped:Connect(function(deltaTime)
            -- Smoothly move the rendered puck towards the target position
            self:setState({
                puckRenderPos = self.state.puckRenderPos:Lerp(self.state.puckPosition, 0.2),
                paddle1RenderPos = self.state.paddle1RenderPos:Lerp(self.state.paddle1Pos, 0.2),
                paddle2RenderPos = self.state.paddle2RenderPos:Lerp(self.state.paddle2Pos, 0.2),
            })
        end)

    else
        -- Local mode: run the original physics simulation
        self.heartbeatConn = RunService.Heartbeat:Connect(function()
            self:trackPaddles()
            self:checkGoals()
            self:handleBoundsAndBounce()
        end)
    end
end

function AirHockeyComponent:willUnmount()
    if self.heartbeatConn then
        self.heartbeatConn:Disconnect()
    end
    if self.stateChangedConn then
        self.stateChangedConn:Disconnect()
    end
    if self.renderLoopConn then
        self.renderLoopConn:Disconnect()
    end
    if self.proximityCheckConn then
        self.proximityCheckConn:Disconnect()
    end
    if self.scoreboardGui then
        self.scoreboardGui:Destroy()
    end
    if self.uiRoot then
        self.uiRoot:unmount()
        self.screenGui:Destroy()
    end
end

local TextButtonComponent = script.Parent.TextButtonComponent

function AirHockeyComponent:renderUI()
    local ui = React.createElement(React.Fragment, {}, {
        userButton1 = React.createElement("TextButton", {
            Text = self.state.userControlPaddle1 and "Drop Paddle 1" or "Control Paddle 1",
            Size = UDim2.new(0, 200, 0, 50),
            Position = UDim2.new(0.2, -100, 0.9, 0),
            Visible = self.state.showButtons, -- Control visibility
            [React.Event.Activated] = function()
                if self.state.userControlPaddle1 then
                    self:onDropPaddle(1)
                else
                    self:onUserControlButton(1)
                end
            end,
        }),
        userButton2 = React.createElement("TextButton", {
            Text = self.state.userControlPaddle2 and "Drop Paddle 2" or "Control Paddle 2",
            Size = UDim2.new(0, 200, 0, 50),
            Position = UDim2.new(0.8, -100, 0.9, 0),
            Visible = self.state.showButtons, -- Control visibility
            [React.Event.Activated] = function()
                if self.state.userControlPaddle2 then
                    self:onDropPaddle(2)
                else
                    self:onUserControlButton(2)
                end
            end,
        }),
    })
    self.uiRoot:render(ui)
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
    self:renderUI() -- Re-render UI on state changes (e.g., paddle control state)
end

function AirHockeyComponent:onUserControlButton(paddleNum)
    if self.props.isSharedMode then
        -- Tell the server we are controlling the paddle
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        ReplicatedStorage.PlayerAction:FireServer({
            component = "airHockey",
            action = "controlPaddle",
            paddle = paddleNum,
        })
    else
        -- Handle it locally as before
        if paddleNum == 1 then
            self:setState({ userControlPaddle1 = true })
        elseif paddleNum == 2 then
            self:setState({ userControlPaddle2 = true })
        end
    end
end

function AirHockeyComponent:onDropPaddle(paddleNum)
    if self.props.isSharedMode then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        ReplicatedStorage.PlayerAction:FireServer({
            component = "airHockey",
            action = "releasePaddle",
            paddle = paddleNum,
        })
    else
        if paddleNum == 1 then
            self:setState({ userControlPaddle1 = false })
        elseif paddleNum == 2 then
            self:setState({ userControlPaddle2 = false })
        end
    end
end

function AirHockeyComponent:render()
    local position = self.props.Position
    local goalColor1 = self.props.goalColor1
    local goalColor2 = self.props.goalColor2
    local goalDepth = self.props.goalDepth
    local goalHeight = self.props.goalHeight
    local goalTransparency = self.props.goalTransparency
    local goalWidth = self.props.goalWidth
    local paddleColor1 = self.props.paddleColor1
    local paddleColor2 = self.props.paddleColor2
    local paddleHeight = self.props.paddleHeight
    local paddleOffset = self.props.paddleOffset
    local paddleRadius = self.props.paddleRadius
    local paddleTransparency = self.props.paddleTransparency
    local puckColor = self.props.puckColor
    local puckHeight = self.props.puckHeight or 1
    local puckRadius = self.props.puckRadius
    local puckTransparency = self.props.puckTransparency
    local showGoals = self.props.showGoals
    local tableColor = self.props.tableColor
    local tableHeight = self.props.tableHeight or 1
    local tableWidth = self.props.tableWidth
    local tableLength = self.props.tableLength
    local tableTransparency = self.props.tableTransparency
    local tableY = self.props.tableY or position.Y + tableHeight / 2
    local wallColor = self.props.wallColor
    local wallHeight = self.props.wallHeight
    local wallThickness = self.props.wallThickness
    local wallTransparency = self.props.wallTransparency

    if not self.props.tableHeight then
        return {}
    end

    local puckPosition = self.props.isSharedMode and self.state.puckRenderPos or self:centerOfTable()
    local paddle1Position = self.props.isSharedMode and self.state.paddle1RenderPos or position + Vector3.new(0, tableY + paddleHeight / 2 + 0.1, -paddleOffset)
    local paddle2Position = self.props.isSharedMode and self.state.paddle2RenderPos or position + Vector3.new(0, tableY + paddleHeight / 2 + 0.1, paddleOffset)

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
            Position = paddle1Position,
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
            Position = paddle2Position,
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
        Position = puckPosition,
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

    return React.createElement("Folder", {
        key = self.props.Name,
    }, {
        Table = tablePart,
        Puck = puck,
        Paddle1 = paddles[1],
        Paddle2 = paddles[2],
        WallLeft = walls[1],
        WallRight = walls[2],
        WallTop = walls[3],
        WallBottom = walls[4],
        Goal1 = goals[1],
        Goal2 = goals[2],
    })
end

return AirHockeyComponent
