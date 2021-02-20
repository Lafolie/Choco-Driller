require "actor"

local armImg = love.graphics.newImage("armTest.png")

Player = class (Actor) {}

function Player:init(x, y)
	Actor.init(self, x, y, "player")

	self.gravity = 1
	self.friction = 1
	self.airFriction = 1

	self.accel = 0.5
	self.walkSpeed = 1.75
	self.quickTurn = 2
	self.jumpForce = -5.5
	self.maxJumps = 1

	self.aim = vector(0, 0)
	self.armRot = 0
end

function Player:setAim(x, y)
	self.aim.x = x
	self.aim.y = y

	self.armRot = (self.aim - self.location).normalized.angle
end

function Player:draw()
	Actor.draw(self)
	love.graphics.draw(armImg, math.floor(self.location.x), math.floor(self.location.y), self.armRot, 1, 1, 8, 8)
	
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.circle("fill", self.aim.x, self.aim.y, 2)
end