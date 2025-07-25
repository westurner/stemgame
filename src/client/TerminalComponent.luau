--!strict
-- src/client/TerminalComponent.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local TerminalComponent = React.Component:extend("TerminalComponent")

function TerminalComponent:init()
    self.state = {
        outputLines = {},
        input = "",
        isVisible = true,
    }
    self.outputRef = React.createRef()
    self.inputRef = React.createRef()

    self.commands = {"ls", "ps", "make test", "reset", "echo", "true", "false", "less", "help", "info", "man", "printf", "export", "declare", "touch", "cat", "mkdir", "tree"}

    self["$"] = 0 -- Last exit code
    self["$#"] = 0 -- Number of arguments
    self.env = {} -- Environment variables
    self.fs = require(script.Parent.Terminal.InMemoryFilesystem).new() -- Initialize filesystem

    -- Bind methods
    self.handleInputChanged = function(rbx)
        self:setState({ input = rbx.Text })
    end
    self.handleInputActivated = function()
        self:executeCommand(self.state.input)
        self:setState({ input = "" })
    end
    self.toggleVisibility = function()
        self:setState({ isVisible = not self.state.isVisible })
    end
    self.appendOutput = function(line)
        self:setState(function(prevState)
            local newLines = table.clone(prevState.outputLines)
            table.insert(newLines, line)
            -- Keep a reasonable number of lines, e.g., 100
            if #newLines > 100 then
                table.remove(newLines, 1)
            end
            return { outputLines = newLines }
        end)
    end
end

function TerminalComponent:expandVariables(text)
    return string.gsub(text, "%$(%[%a_][%w_]*%]|%?|%#)", function(varName)
        if varName == "?" then
            return tostring(self["$"])
        elseif varName == "#" then
            return tostring(self["$#"])
        else
            return tostring(self.env[varName] or "")
        end
    end)
end

function TerminalComponent:didUpdate(prevProps, prevState)
    -- Scroll to bottom when new output is added
    if #self.state.outputLines > #prevState.outputLines and self.outputRef.current then
        local scrollingFrame = self.outputRef.current
        scrollingFrame.CanvasPosition = Vector2.new(0, scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteSize.Y)
    end
end

function TerminalComponent:executeCommand(command)
    self:appendOutput("> " .. command)
    local cmd:string, arg = command:match("^(%S+)%s*(.*)$")
    local success = true
    local argCount = 0

    -- Handle environment variable assignments (VAR=VALUE, export VAR=VALUE, declare VAR=VALUE)
    local varAssign = command:match("^([%a_][%w_]*)=(.+)$")
    local exportAssign = command:match("^export%s+([%a_][%w_]*)=(.+)$")
    local declareAssign = command:match("^declare%s+([%a_][%w_]*)=(.+)$")
    local declareGlobalAssign = command:match("^declare%s+%-g%s+([%a_][%w_]*)=(.+)$")

    if exportAssign then
        self.env[exportAssign[1]] = exportAssign[2]
        argCount = 2
    elseif declareGlobalAssign then
        self.env[declareGlobalAssign[1]] = declareGlobalAssign[2]
        argCount = 3
    elseif declareAssign then
        self.env[declareAssign[1]] = declareAssign[2]
        argCount = 2
    elseif varAssign then
        self.env[varAssign[1]] = varAssign[2]
        argCount = 2
    else
        local ok, err = pcall(function()
            if cmd == "ls" then
                self:handleLsCommand(arg)
                argCount = #arg:split(" ")
            elseif cmd == "ps" then
                self:handlePsCommand(arg)
                argCount = #arg:split(" ")
            elseif cmd == "make" and arg == "test" then
                self:handleMakeTestCommand()
                argCount = 2
            elseif cmd == "reset" then
                self:handleResetCommand()
                argCount = 1
            elseif cmd == "echo" then
                self:handleEchoCommand(arg)
                argCount = #arg:split(" ")
            elseif cmd == "printf" then
                self:handlePrintfCommand(arg)
                argCount = #arg:split(" ")
            elseif cmd == "true" then
                self:handleTrueCommand()
                argCount = 1
            elseif cmd == "false" then
                self:handleFalseCommand()
                success = false
                argCount = 1
            elseif cmd == "less" then
                self:handleLessCommand(arg)
                argCount = #arg:split(" ")
            elseif cmd == "help" or cmd == "info" or cmd == "man" then
                self:handleManCommand()
                argCount = 1
            elseif cmd == "touch" then
                self:handleTouchCommand(arg)
                argCount = #arg:split(" ")
            elseif cmd == "cat" then
                self:handleCatCommand(arg)
                argCount = #arg:split(" ")
            elseif cmd == "mkdir" then
                self:handleMkdirCommand(arg)
                argCount = #arg:split(" ")
            elseif cmd == "tree" then
                self:handleTreeCommand(arg)
                argCount = #arg:split(" ")
            else
                self:appendOutput("Command not recognized: " .. command)
                success = false
            end
        end)
        if not ok then
            self:appendOutput("Error: " .. tostring(err))
            success = false
        end
    end

    self["$"] = success and 0 or 1
    self["$#"] = argCount
end

function TerminalComponent:handleLsCommand(arg)
    local result, err = self.fs:ls(self:expandVariables(arg))
    if result then
        for _, item in ipairs(result) do
            self:appendOutput(item)
        end
        self["$"] = 0
    else
        self:appendOutput("ls: " .. err)
        self["$"] = 1
    end
end

function TerminalComponent:handlePsCommand(arg)
    -- Mocking a simple 'ps' command
    self:appendOutput("Mock ps output:")
    self:appendOutput("  PID TTY      TIME CMD")
    self:appendOutput("    1 ?        00:00:00 init")
    self:appendOutput("  123 ?        00:00:01 RobloxPlayer")
    self:appendOutput("  456 ?        00:00:00 Script")
    self["$"] = 0
end

function TerminalComponent:handleMakeTestCommand()
    local TestFramework = require(script.Parent.TestRunner.TestFramework)
    local success, err = pcall(TestFramework.runAllTests)
    if success then
        self["$"] = 0
    else
        self["$"] = 1
        self:appendOutput("Error running tests: " .. tostring(err))
    end
end

function TerminalComponent:handleResetCommand()
    self:setState({ outputLines = {} })
    self:appendOutput("Terminal cleared.")
    self["$"] = 0
end

function TerminalComponent:handleEchoCommand(arg)
    self:appendOutput(self:expandVariables(arg))
    self["$"] = 0
end

function TerminalComponent:handlePrintfCommand(arg)
    -- Very basic printf implementation, just expands variables and prints
    self:appendOutput(self:expandVariables(arg))
    self["$"] = 0
end

function TerminalComponent:handleTrueCommand()
    -- Does nothing, always succeeds
    self["$"] = 0
end

function TerminalComponent:handleFalseCommand()
    -- Does nothing, always fails (in a real shell, would set exit code)
    self["$"] = 1
end

function TerminalComponent:handleLessCommand(arg)
    local content = ""
    if arg == "manpage" or arg == "help" then
        content = "#stemgame\n\nThis is the manpage for #stemgame.\n\nAvailable commands:\n  ls - list directory contents\n  ps - report a snapshot of the current processes\n  make test - run all tests\n  reset - clear the terminal\n  echo [args] - display a line of text (supports $VAR, $?, $#)\n  printf [format] - print formatted text (supports $VAR, $?, $#)\n  true - do nothing, successfully\n  false - do nothing, unsuccessfully\n  less [file] - view file contents (mocked)\n  help/info/man - display this manpage\n  var=value - set environment variable\n  export var=value - set environment variable\n  declare [-g] var=value - set environment variable\n  touch [file] - create or update file timestamp\n  cat [file] - display file content\n  mkdir [dir] - create directory\n  tree [dir] - list contents of directories in a tree-like format\n"
    else
        local fileContent, err = self.fs:cat(self:expandVariables(arg))
        if fileContent then
            content = fileContent
        else
            self:appendOutput("less: " .. err)
            self["$"] = 1
            return
        end
    end
    for line in string.gmatch(content, "([^]+)") do
        self:appendOutput(line)
    end
    self["$"] = 0
end

function TerminalComponent:handleManCommand()
    self:handleLessCommand("manpage")
    self["$"] = 0
end

function TerminalComponent:handleTouchCommand(arg)
    local success, err = self.fs:touch(self:expandVariables(arg))
    if not success then
        self:appendOutput("touch: " .. err)
        self["$"] = 1
    else
        self["$"] = 0
    end
end

function TerminalComponent:handleCatCommand(arg)
    local content, err = self.fs:cat(self:expandVariables(arg))
    if content then
        self:appendOutput(content)
        self["$"] = 0
    else
        self:appendOutput("cat: " .. err)
        self["$"] = 1
    end
end

function TerminalComponent:handleMkdirCommand(arg)
    local success, err = self.fs:mkdir(self:expandVariables(arg))
    if not success then
        self:appendOutput("mkdir: " .. err)
        self["$"] = 1
    else
        self["$"] = 0
    end
end

function TerminalComponent:handleTreeCommand(arg)
    local results, success = self.fs:tree(self:expandVariables(arg))
    for _, line in ipairs(results) do
        self:appendOutput(line)
    end
    if not success then
        self["$"] = 1
    else
        self["$"] = 0
    end
end

function TerminalComponent:handleTabCompletion()
    local currentInput = self.state.input
    local matchingCommands = {}
    for _, cmd in ipairs(self.commands) do
        if string.sub(cmd, 1, #currentInput) == currentInput then
            table.insert(matchingCommands, cmd)
        end
    end

    if #matchingCommands == 1 then
        self:setState({ input = matchingCommands[1] })
    elseif #matchingCommands > 1 then
        self:appendOutput("\n" .. table.concat(matchingCommands, "\t"))
    end
end

function TerminalComponent:render()
    if not self.state.isVisible then
        return React.createElement("TextButton", {
            Size = UDim2.new(0, 100, 0, 30),
            Position = UDim2.new(1, -110, 0, 10),
            Text = "Show Terminal",
            [React.Event.Activated] = self.toggleVisibility,
            BackgroundTransparency = 0.5,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        })
    end

    return React.createElement("ScreenGui", {
        Name = "TerminalGui",
        ResetOnSpawn = false,
    }, {
        Frame = React.createElement("Frame", {
            Size = UDim2.new(0.8, 0, 0.8, 0),
            Position = UDim2.new(0.1, 0, 0.1, 0),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
        }, {
            -- Close Button
            CloseButton = React.createElement("TextButton", {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -30, 0, 0),
                Text = "X",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundColor3 = Color3.fromRGB(200, 0, 0),
                [React.Event.Activated] = self.toggleVisibility,
            }),

            -- Output Area
            OutputScrollingFrame = React.createElement("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, -40), -- Leave space for input
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                CanvasSize = UDim2.new(0, 0, 0, 0), -- Will be set dynamically
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                VerticalScrollBarInset = Enum.ScrollBarInset.Always,
                ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
                ScrollBarThickness = 6,
                ref = self.outputRef,
            }, {
                UIListLayout = React.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    Padding = UDim.new(0, 2),
                },
                -- Output Lines
                table.unpack((function(lines)
                    local result = {}
                    for index, line in ipairs(lines) do
                        result[index] = React.createElement("TextLabel", {
                            key = index,
                            Size = UDim2.new(1, 0, 0, 16),
                            Text = tostring(line), -- TODO
                            TextColor3 = Color3.fromRGB(200, 200, 200),
                            BackgroundTransparency = 1,
                            Font = Enum.Font.Code,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextWrapped = true,
                        })
                    end
                    return result
                end)(self.state.outputLines))),
            -- Input Area
            InputTextBox = React.createElement("TextBox", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 1, -30),
                Text = self.state.input,
                PlaceholderText = "Enter command...",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                BackgroundTransparency = 0.5,
                Font = Enum.Font.Code,
                TextSize = 14,
                ClearTextOnFocus = false,
                [React.Event.Changed] = self.handleInputChanged,
                [React.Event.FocusLost] = function(rbx, enterPressed)
                    if enterPressed then
                        self:handleInputActivated()
                    end
                end,
                [React.Event.InputBegan] = function(rbx, inputObject)
                    if inputObject.UserInputType == Enum.UserInputType.Keyboard and inputObject.KeyCode == Enum.KeyCode.Tab then
                        self:handleTabCompletion()
                    end
                end,
                ref = self.inputRef,
            }),
        })
    })
})
end

return TerminalComponent