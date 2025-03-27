print("DEBUG: init.client: starting...")

print("INFO: init.client: Hello world, stemgame!")

--_G.__DEV__ = false
--_G.__DEV__ = game:GetService("RunService"):IsStudio()
--print(string.format("DEBUG: init.client: _G.__DEV__=%s", tostring(_G.__DEV__)))

--game:GetService("Lighting").ClockTime = 20.4
game:GetService("Lighting").ClockTime = 6.17
local _ClockTime = game:GetService("Lighting").ClockTime
print(string.format("DEBUG: client: ClockTime=%s", tostring(_ClockTime)))

print("DEBUG: init.client: done.")