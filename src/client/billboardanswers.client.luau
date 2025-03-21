-- --!strict
--[[# MathGame2025.MathGamePart0.AdditionProblemScript

--]]

if 0 then
    return
end

-- ## Define data schema
local function _schema()
	-- ## JSON-LD schema
	local _context = {
		question = "schema:String",
		answers = {_container = "@list"},
		correct = "schema:Boolean"
		--[[
		answers = {
			_container = "@index",
			_index = "schema:name"},
		--]]
	}
	return _context
end

local function test_schema()
	local problem0 = {
		_id = "#001",
		_type = "addition",
		question = {
			string = "4 + 2 = ?", -- TODO: string
		},
		--[[ answers = {
			A= "0",
			B= "2",
			C= "6"
		}, --]]
		--[[ answers = {
			A= {_value="0"},
			B= {_value="2"},
			C= {_value="6", correct = true},
		}, --]]
		answers = {
			{_id='A', _value= "0"},
			{_id='B', _value= "2"},
			{_id='C', _value= "6", correct = true},
		}
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


-- ## Define Classes
local Problem = {}

function Problem:new(question, answers)
	local self = setmetatable({}, {__index=Problem})
	self._name = "Problem"
	self.question = question
	self.answers = answers
	return self
end


local AdditionProblem = {}
--setmetatable(AdditionProblem, {__index=Problem})

function AdditionProblem:new(question, answers)
	local self = Problem:new(question, answers)
	setmetatable(self, {__index=AdditionProblem})
	self._name = "AdditionProblem"
	return self
end

function AdditionProblem.generate()
	local num1 = math.random(1, 10)
	local num2 = math.random(1, 10)

	local question = string.format("%d + %d = ?", num1, num2)
	local correctAnswerText = string.format("%d + %d = %d", num1, num2, num1+num2)
	local answers = {
		{_id='A', _value= "0"}, -- todo: add noise
		{_id='B', _value= "2"}, -- todo: add noise
		{_id='C', _value= tostring(num1+num2), correct = correctAnswerText},
	}
	return AdditionProblem.new(question, answers, correctAnswerText)
end



-- ## Add render methods which reference global references (for performance)
function AdditionProblem:render(msg)
	print(string.format('INFO: AdditionProblem:render(msg="%s")', tostring(msg)))
	print(string.format('INFO: problem.question= %s', self.question))
	local textLabel = script.Parent.GreyWall0.SurfaceGui.TextLabel
	textLabel.Text = tostring(self.question)
	textLabel.Visible = true

	assert (#self.answers > 0)

	if self._rendered then
		return
	end
	self._rendered = true

	for _, answerPad in ipairs(script.Parent.AnswerPads0:GetChildren()) do
		answerPad.SurfaceGuiTop.TextLabel.Text = ""
		answerPad.SurfaceGuiFront.TextLabel.Text = ""
		answerPad.SurfaceGuiTop.TextLabel.Visible = false
		answerPad.SurfaceGuiFront.TextLabel.Visible = false
		answerPad.Transparency = 0.8
		answerPad.SurfaceGuiFront.TextLabel.Transparency = 0.8
		answerPad.SurfaceGuiFront.TextLabel.BackgroundTransparency = 0.8
		answerPad.SurfaceGuiTop.TextLabel.BackgroundTransparency = 0.8
		task.wait(0.1)
	end

	
	-- localx = zip(self.answers, script.Parent.AnswerPads0:GetChildren())
	
	local answers = {}
	local answerPads = script.Parent.AnswerPads0:GetChildren()
	for i, answer in ipairs(self.answers) do
		answers[answer._id] = {answerPad=answerPads[i], answer=answer}
	end

	for _, _answer in pairs(answers) do
		_answer.answerPad.SurfaceGuiTop.TextLabel.Text = _answer.answer._value
		_answer.answerPad.SurfaceGuiFront.TextLabel.Text = _answer.answer._id
		_answer.answerPad:SetAttribute("isCorrectAnswer", _answer.answer.correct)
		_answer.answerPad.SurfaceGuiTop.TextLabel.Visible = true
		_answer.answerPad.SurfaceGuiFront.TextLabel.Visible = true
		_answer.answerPad.Transparency = 0
		_answer.answerPad.SurfaceGuiFront.TextLabel.Transparency = 0
		task.wait(0.1)
	end

end



-- ## Test classes and their methods
function test_AdditionProblem_1()
	local p = AdditionProblem.generate()
	assert(p.question ~= "")
	assert(#p.answers > 0)
end


-- ## Call test functions
local function main_test()
	print("INFO: main_test() start")
	test_schema()
	test_AdditionProblem_1()
	print("INFO: main_test() end")
end


local function main()
	print("INFO: main() begin")

	-- ## Instantiate globals
	local state = {}
	state.problem = AdditionProblem.generate()

	-- ## Bind to events

	--script.Parent.StartPad0.Touched:Connect(state.problem.render(p,"startPad0.Touched"))

	state.isTouchingStartPad0 = false
	script.Parent.StartPad0.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") then
			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if player and not state.isTouchingStartPad0 then
				state.isTouchingStartPad0 = true
				state.problem:render(player)  -- AdditionProblem.render(state.problem, player)
				task.wait(0.5)
				state.isTouchingStartPad0 = false
			end
		end
	end)



	state.prevBackgroundColor3 = script.Parent.AnswerPads0.AnswerPadA.SurfaceGuiFront.TextLabel.BackgroundColor3
	state.isTouchingAnswerPad = false
	state.lastAnswerPad = nil
	for _, answerPad in ipairs(script.Parent.AnswerPads0:GetChildren()) do
		answerPad.Touched:Connect(function(hit)
			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if not player then
				print(string.format("ERROR: GetPlayerFromCharacter(hit.Parent=%s) returned nil ", hit.Parent.Name))
				return
			end
			if player and not state.isTouchingAnswerPad then
				state.isTouchingAnswerPad = true
				state.lastAnswerPad = answerPad
				print(string.format("INFO: state.lastAnswerPad.Name=%s user.Name=%s", state.lastAnswerPad and state.lastAnswerPad.Name or nil, hit.Parent.Name))
				--local userName = hit.Parent.Name , hit.Parent.renderName
				--local avatarPartName = hit.Name

				-- Set the color on the front of the answerpads
				--answerPad.SurfaceGuiFront.TextLabel.BackgroundColor3 = Color3.fromHex("#cc4242") -- red todo
				answerPad.SurfaceGuiFront.TextLabel.BackgroundColor3 = Color3.fromHex("#ff6e42")   -- orange
				task.wait(1)
				state.isTouchingAnswerPad = false
				answerPad.SurfaceGuiFront.TextLabel.BackgroundColor3 = state.prevBackgroundColor3

			end
		end)
	end


	-- Jumping
	state.isJumping = false
	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")

			if humanoid then
				humanoid.Changed:Connect(function()
					if humanoid.Jump and not state.isJumping then
						state.isJumping = true
						print('INFO: Changed.Jump=' .. player.Name)

					end
				end)

				state.humanoidJumpPower_initial = humanoid.JumpPower
				humanoid.FreeFalling:Connect(function()
					if state.isJumping then
	
						if state.isTouchingStartPad0 then
							state.problem = AdditionProblem.generate()
							state.problem:render("FreeFalling & state.isTouchingStartPad0 .. AdditionProblem.generate")
						end

						if state.isTouchingAnswerPad then
							--TODO: HERE
							print("INFO: state.isTouchingAnswerPad && state.lastAnswerPad=" .. state.lastAnswerPad.Name)

							if (state.lastAnswerPad:GetAttribute("isCorrectAnswer")) then
								-- TODO: Award points
								print("CORRECT Answer")
								state.lastAnswerPad.Color = Color3.fromHex('#00aa00')
								state.lastAnswerPad.SurfaceGuiFront.TextLabel.BackgroundColor3 = Color3.fromHex("#00aa00")
								workspace.BillboardAnswers.GreyWall0.SurfaceGui.TextLabel.Text = state.lastAnswerPad:GetAttribute("isCorrectAnswer");
								workspace.BillboardAnswers.GreyWall0.Color = Color3.fromHex("#00aa00")	
							else
								print("INCORRECT Answer")
								state.lastAnswerPad.Color = Color3.fromHex('#aa0000')
								state.lastAnswerPad.SurfaceGuiFront.TextLabel.BackgroundColor3 = Color3.fromHex("#aa0000")
							end
						end

						-- TODO: double jump
						humanoid.JumpPower = humanoid.JumpPower * 3
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						print('INFO: FreeFalling.notJumping=' .. player.Name)
						print("INFO: humanoid.JumpPower=" .. humanoid.JumpPower)
						wait(1)
						humanoid.JumpPower = state.humanoidJumpPower_initial
						state.isJumping = false
					end
				end)
			end
		end)
	end)


	print("INFO: main() end")
end

if game:GetService("RunService").IsStudio then
	main_test()
else
	print("INFO: Skipping main_test() because .IsStudio is false")
end


main()

