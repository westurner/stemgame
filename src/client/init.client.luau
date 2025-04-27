print("DEBUG: init.client: starting...")

print("INFO: init.client: Hello world, stemgame!")

--_G.__DEV__ = false
--_G.__DEV__ = game:GetService("RunService"):IsStudio()
--print(string.format("DEBUG: init.client: _G.__DEV__=%s", tostring(_G.__DEV__)))

function init_lighting()
    --game:GetService("Lighting").ClockTime = 20.4
    --game:GetService("Lighting").ClockTime = 6.17
    local Lighting = game:GetService("Lighting")
    Lighting.ClockTime = 5.15
    Lighting.Ambient = Color3.fromRGB(111, 111, 101)
    Lighting.OutdoorAmbient = Color3.fromRGB(111, 111, 101)
    local _ClockTime = Lighting.ClockTime
    print(string.format("DEBUG: client: ClockTime=%s", tostring(_ClockTime)))
end


-- function initLighting_strobe() 
-- 	local lighting = game:GetService("Lighting")
-- 	local TweenService = game:GetService("TweenService")
-- 	local targetColor = Color3.new(1, 0, 0) -- target color (red)

-- 	local fadeDuration = 2
-- 	local tweenInfo_fadeIn = TweenInfo.new(
-- 		fadeDuration, 
-- 		Enum.EasingStyle.Linear, 
-- 		Enum.EasingDirection.InOut, 
-- 		-1, 
-- 		true, 
-- 		0
-- 	)
-- 	local tween1 = TweenService:Create(lighting, tweenInfo_fadeIn, { Ambient = targetColor })
-- 	tween1:Play()
-- end


init_lighting()

print("DEBUG: init.client: done.")