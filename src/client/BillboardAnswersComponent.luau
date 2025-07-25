-- BillboardAnswersComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local SharedStateManager = require(game.StarterPlayer.StarterPlayerScripts.Client.SharedStateManager)

local BillboardAnswersComponent = React.Component:extend("BillboardAnswersComponent")

function BillboardAnswersComponent:init()
    self.props = self.props or {}
    self.state = {}
    self.state.problem = nil
    self.state.selectedAnswer = nil
    self.state.lastAnswerCorrect = nil
end

local function _schema()
    local _context = {
        question = "schema:String",
        answers = {_container = "@list"},
        correct = "schema:Boolean",
    }
    return _context
end


function BillboardAnswersComponent:willUnmount()
    if self.unsubscribe then
        self.unsubscribe()
    end
end


local function test_schema()
    local problem0 = {
        _id = "#001",
        _type = "addition",
        question = {
            string = "4 + 2 = ?",
        },
        answers = {
            {_id = 'A', _value = "0"},
            {_id = 'B', _value = "2"},
            {_id = 'C', _value = "6", correct = true},
        },
    }

    assert(problem0._id == "#001")
    assert(problem0._type == "addition")
    assert(problem0.question.string == "4 + 2 = ?")
    assert(problem0.answers)
    assert(#problem0.answers == 3)
    assert(problem0.answers[1]._id == 'A')
    assert(problem0.answers[2]._value == '2')
    assert(problem0.answers[3]._id == 'C')
    assert(problem0.answers[3].correct == true)
end

function BillboardAnswersComponent:render()
    local AdditionProblem = {}

    function AdditionProblem:new(question, answers)
        local self = setmetatable({}, { __index = AdditionProblem })
        self._name = "AdditionProblem"
        self.question = question
        self.answers = answers
        return self
    end

    function AdditionProblem.generate()
        local num1 = math.random(1, 10)
        local num2 = math.random(1, 10)

        local question = string.format("%d + %d = ?", num1, num2)
        local correctAnswerText = string.format("%d + %d = %d", num1, num2, num1 + num2)
        local answers = {
            { _id = 'A', _value = "0" },
            { _id = 'B', _value = "2" },
            { _id = 'C', _value = tostring(num1 + num2), correct = correctAnswerText },
        }
        return AdditionProblem:new(question, answers)
    end

    local problem = AdditionProblem.generate()

    local answerPads = {}
    local answerPadSize = self.props.answerPadSize or Vector3.new(5, 1, 5)

    for id, answerData in pairs(problem.answers) do
        local answerColor = Color3.fromRGB(255, 255, 255) -- Default white
        if selectedAnswer == id then
            if lastAnswerCorrect == true then
                answerColor = Color3.fromRGB(0, 255, 0) -- Green for correct
            elseif lastAnswerCorrect == false then
                answerColor = Color3.fromRGB(255, 0, 0) -- Red for incorrect
            end
        end

        table.insert(answerPads, React.createElement(require(script.Parent.AnswerPadComponent), {
            key = "AnswerPad" .. answer._id,
            size = answerPadSize,
            position = Vector3.new(i * 6 - 12, 0, 0), -- Spread out the answer pads horizontally
            answer = answerData.value,
            color = answerColor,
            [React.Event.Touched] = function(hit)
                if self.props.isSharedMode and hit.Parent:FindFirstChild("Humanoid") then
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    ReplicatedStorage.PlayerAction:FireServer({
                        component = "billboardAnswers",
                        action = "selectAnswer",
                        answerID = id,
                    })
                end
            end,
        }))
    end

    return React.createElement("Model", {
        key = "BillboardAnswersModel",
    }, {
        React.createElement("Part", {
            key = "QuestionBoard",
            Size = Vector3.new(10, 5, 1),
            Position = Vector3.new(0, 10, 0),
            Anchored = true,
            Color = Color3.fromRGB(255, 255, 255),
        }, {
            React.createElement("SurfaceGui", {
                key = "QuestionGui",
                AlwaysOnTop = true,
            }, {
                React.createElement("TextLabel", {
                    key = "QuestionLabel",
                    Text = problem.question,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextScaled = true,
                    BackgroundTransparency = 1,
                }),
            }),
        }),
        unpack(answerPads),
    })
end

return BillboardAnswersComponent
