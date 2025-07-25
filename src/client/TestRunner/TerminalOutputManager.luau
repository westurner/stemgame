--!strict
-- src/client/TestRunner/TerminalOutputManager.luau

local TerminalOutputManager = {}

local terminalComponentRef = nil

function TerminalOutputManager.setTerminalComponent(component)
    terminalComponentRef = component
end

function TerminalOutputManager.print(message)
    if terminalComponentRef and terminalComponentRef.appendOutput then
        terminalComponentRef:appendOutput(tostring(message))
    else
        print("TerminalOutputManager: TerminalComponent not set. Message: " .. tostring(message))
    end
end

return TerminalOutputManager
