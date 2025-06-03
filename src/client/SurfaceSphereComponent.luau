-- SurfaceSphereComponent.luau
-- A Bloch sphere with an animated arrow and a fading trail on the surface

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local BlochSphereComponent = require(script.Parent.BlochSphereComponent)

local TRAIL_LENGTH = 30 -- number of points in the trail
local TRAIL_FADE_TIME = 1.2 -- seconds for a trail point to fade out
local ARROW_LENGTH = 10
local SPHERE_RADIUS = 10

local function randomPointOnSphere(radius)
	local theta = math.random() * 2 * math.pi
	local phi = math.acos(2 * math.random() - 1)
	local x = radius * math.sin(phi) * math.cos(theta)
	local y = radius * math.sin(phi) * math.sin(theta)
	local z = radius * math.cos(phi)
	return Vector3.new(x, y, z)
end

local SurfaceSphereComponent = React.Component:extend("SurfaceSphereComponent")

function SurfaceSphereComponent:init()
    self.props = self.props or {}
    self.props.sphereRadius = self.props.sphereRadius or SPHERE_RADIUS
	self:setState({
		arrowPos = randomPointOnSphere(self.props.sphereRadius),
		trail = {},
	})
	self._running = true
end

function SurfaceSphereComponent:willUnmount()
	self._running = false
end

function SurfaceSphereComponent:didMount()
	-- Animate the arrow and update the trail
	coroutine.wrap(function()
		while self._running do
			local newPos = randomPointOnSphere(self.props.sphereRadius)
			local startPos = self.state.arrowPos
			local steps = 30
			for i = 1, steps do
				if not self._running then return end
				local alpha = i / steps
				local interp = startPos:Lerp(newPos, alpha)
				local now = os.clock()
				local newTrail = table.clone(self.state.trail)
				table.insert(newTrail, {pos = interp, time = now})
				-- Remove old trail points
				while #newTrail > 0 and now - newTrail[1].time > TRAIL_FADE_TIME do
					table.remove(newTrail, 1)
				end
				self:setState({
					arrowPos = interp,
					trail = newTrail,
				})
				task.wait(0.03)
				--task.wait(0.001)
			end
		end
	end)()
end

function SurfaceSphereComponent:render()
	local arrowPos = self.state.arrowPos
	local trail = self.state.trail
    local position = self.props.Position or Vector3.new(0, 10, 0)
    local sphereRadius = self.props.sphereRadius or SPHERE_RADIUS
    local arrowLength = self.props.arrowLength or ARROW_LENGTH

	local children = {
		BlochSphere = React.createElement(BlochSphereComponent, {
			Position = position,
			Size = Vector3.new(sphereRadius*2, sphereRadius*2, sphereRadius*2),
			Material = Enum.Material.Neon,
            drawLabels = false,
            sphereTransparency = 0.2,
			sphereColor = Color3.fromRGB(20, 20, 20),
            ringTransparency = 0,
		}),
		Arrow = React.createElement("Part", {
			Anchored = true,
			CanCollide = false,
			Size = Vector3.new(0.3, 0.3, arrowLength/2),
			CFrame = CFrame.new(position, position+arrowPos) * CFrame.new(0, 0, -arrowLength/4),
			Color = Color3.fromRGB(255, 0, 0),
			Material = Enum.Material.Neon,
			Transparency = 0,
			Name = "Arrow",
		}),
	}

	-- Add ghost arrows and trail points
	for i, point in ipairs(trail) do
		local fade = math.clamp(1 - (os.clock() - point.time) / TRAIL_FADE_TIME, 0, 1)
		-- Ghost arrow
		children["GhostArrow"..i] = React.createElement("Part", {
			Anchored = true,
			CanCollide = false,
			Size = Vector3.new(0.3, 0.3, arrowLength/2),
			CFrame = CFrame.new(position, position+point.pos) * CFrame.new(0, 0, -arrowLength/2),
			Color = Color3.fromRGB(255, 0, 0),
			Material = Enum.Material.Neon,
			Transparency = 1 - fade,
			Name = "GhostArrow"..i,
		})
		-- Trail point (sphere)
		children["TrailPoint"..i] = React.createElement("Part", {
			Anchored = true,
			CanCollide = false,
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(0.6, 0.6, 0.6),
			Position = position + point.pos,
			Color = Color3.fromRGB(0, 200, 255),
			Material = Enum.Material.Neon,
			Transparency = 1 - fade,
			Name = "TrailPoint"..i,
		})
	end

	return React.createElement("Folder", nil, children)
end

return SurfaceSphereComponent
