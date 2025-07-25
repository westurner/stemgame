
-- AnswerPadComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local AnswerPadComponent = React.Component:extend("AnswerPadComponent")

function AnswerPadComponent:init()
    self.props = self.props or {}
    self.state = {}
    self.state.isActive = false

function AnswerPadComponent:activate()
    self:setState({ isActive = true })
    task.delay(1, function()
        self:setState({ isActive = false })
    end)
end

function AnswerPadComponent:render()
    local color = self.state.isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)

    return React.createElement("Part", {
        --key = self.props._key, -- TODO
        Name = self.props.name or "AnswerPad",
        Size = self.props.size or Vector3.new(5, 1, 5),
        Position = self.props.position or Vector3.new(0, 0, 0),
        Anchored = true,
        Color = color,
        ref = self.props._ref,
        [React.Event.Touched] = function(hit)
            if hit.Parent:FindFirstChild("Humanoid") then
                self:activate()
            end
        end,
    })
end

return AnswerPadComponent