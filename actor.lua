require "inventory"
local floor = math.floor

Actor = class {}

function Actor:init(x, y, name)
	self.name = name or "New Actor"
	self.location = vector.isVector(x) and x.copy() or vector(x, y)
	self.size = vector(12, 12)
	self.halfSize = vector(6, 6)

	self.air = 0
	self.velocity = vector()
	self.gravity = 1
	self.friction = 1
	self.airFriction = 0.5

	self.accel = 0.25
	self.lastAccel = 0
	self.walkSpeed = 1.25
	self.quickTurn = 2
	self.jumpForce = -6
	self.maxJumps = 1
	self.jumps = 0

	self.inventory = Inventory()
end

function Actor:addMovement(x, y)
	local turnAmt = sign(x) ~= sign(self.velocity.x) and self.quickTurn or 1
	local accel = self.accel * x * (turnAmt * self.air > 0 and 0.5 or 1)
	self.lastAccel = accel
	local vx = self.velocity.x + accel
	-- local vy = self.velocity.y + self.accel * y
	self.velocity.x = math.max(-self.walkSpeed, math.min(vx, self.walkSpeed))
	-- self.velocity.y = math.max(-self.walkSpeed, math.max(vy, self.walkSpeed))
end

function Actor:startJump()
	if self.air == 0 and self.jumps < self.maxJumps then
		self.jumps = self.jumps + 1
		self.velocity.y = self.jumpForce
	end
end

function Actor:stopJump()
	if self.air > 0 and self.velocity.y < 0 then
		self.velocity.y = self.velocity.y * 0.25
	end
end

function Actor:phys(world)
	local tileSize = world.tileSizePx
	local x, y = self.location.x, self.location.y
	local hw, hh = self.halfSize.x - 0.0000001, self.halfSize.y - 0.0000001
	local vx, vy = self.velocity.x, self.velocity.y

	local hit = false

	vy = math.min(8, vy + world.gravity * self.gravity)
	y = y + vy
	self.air = self.air + 1
	local top = floor((y - hh) / tileSize)
	local bottom = floor((y + hh) / tileSize)
	local left = floor((x - hw + 0.5) / tileSize)
	local right = floor((x + hw - 0.5) / tileSize)
	for n = left, right do
		if world:getBlock_Tilespace(n, top).isSolid then
			--hit ceiling
			hit = true
			y = top * tileSize + tileSize + hh
			vy = vy * 0.25
		end

		if world:getBlock_Tilespace(n, bottom).isSolid then
			--hit floor
			hit = true
			y = bottom * tileSize - hh
			vy = 0
			self.air = 0
			self.jumps = 0
		end
	end

	if self.lastAccel == 0 then
		vx = lerp(vx, 0, 0.4 * (self.air > 0 and self.airFriction or self.friction))
	end
	if math.abs(vx) <= 0.01 then
		vx = 0
	end

	x = x + vx
	top = floor((y - hh + 0.5) / tileSize)
	bottom = floor((y + hh - 0.5) / tileSize)
	left = floor((x - hw) / tileSize)
	right = floor((x + hw) / tileSize)
	for n = top, bottom do
		if world:getBlock_Tilespace(left, n).isSolid then
			--hit left
			hit = true
			x = left * tileSize + tileSize + hw
		end

		if world:getBlock_Tilespace(right, n).isSolid then
			--hit right
			hit = true
			x = right * tileSize - hw
		end
	end

	self.location.x = x
	self.location.y = y
	self.velocity.x = vx
	self.velocity.y = vy

	return hit
end

function Actor:draw()
	love.graphics.rectangle("line", math.floor(self.location.x - self.halfSize.x), math.floor(self.location.y - self.halfSize.y), self.size.x, self.size.y)
end