require "actor"

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
end