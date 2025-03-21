print("DEBUG: init.client: starting...")

print("INFO: init.client: Hello world, stemgame!")

_G.__DEV__ = false -- game:GetService("RunService"):IsStudio()
print(string.format("DEBUG: init.client: _G.__DEV__=%s", tostring(_G.__DEV__)))

game:GetService("Lighting").ClockTime = 20.4

print("DEBUG: init.client: done.")