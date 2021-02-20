local floor = math.floor

Actor = class {}

function Actor:init(x, y)
	self.location = vector.isVector(x) and x.copy() or vector(x, y)
	self.size = vector(16, 16)
	self.halfSize = vector(8, 8)

	self.velocity = vector()
	self.gravity = 0
	self.friction = 1
end

function Actor:phys(world)
	local tileSize = world.tileSizePx
	local x, y = self.location.x, self.location.y
	local hw, hh = self.halfSize.x - 0.0000001, self.halfSize.y - 0.0000001
	local vx, vy = self.velocity.x, self.velocity.y

	local hit = false

	vy = vy + world.gravity * self.gravity
	y = y + vy
	local top = floor((y - hh) / tileSize)
	local bottom = floor((y + hh) / tileSize)
	local left = floor((x - hw + 0.5) / tileSize)
	local right = floor((x + hw - 0.5) / tileSize)
	for n = left, right do
		if world:getBlock_Tilespace(n, top).isSolid then
			--hit ceiling
			hit = true
			y = top * tileSize + tileSize + hh
		end

		if world:getBlock_Tilespace(n, bottom).isSolid then
			--hit floor
			hit = true
			y = bottom * tileSize - hh
		end
	end

	vx = vx * self.friction
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