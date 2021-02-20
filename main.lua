class = require "lib.class"
vector = require "lib.brinevector.brinevector"

log = require "lib.logger"
log:init "global"

-------------------------------------------------------------------------------
-- Main Callbacks
-------------------------------------------------------------------------------
require "world.world"
local world = World(4, 4)

function love.load()

end

local color
require "actor"
local act = Actor(0, 0)

function love.update()
	local mx, my = love.mouse.getPosition()

	local x, y = 0, 0
	if love.keyboard.isDown("left") then x = x - 1 end
	if love.keyboard.isDown("right") then x = x + 1 end
	if love.keyboard.isDown("up") then y = y - 1 end
	if love.keyboard.isDown("down") then y = y + 1 end

	act.velocity.x = x
	act.velocity.y = y

	if act:phys(world) then
		color = {1, 0, 0, 1}
	else
		color = {1, 1, 1, 1}
	end

	world:update()
end


function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	world:draw()

	love.graphics.setColor(color)
	act:draw()

	love.graphics.print(string.format("%dfps", love.timer.getFPS()), 1, 1)
end

function love.quit()

end

-------------------------------------------------------------------------------
-- Keyboard
-------------------------------------------------------------------------------

function love.keypressed(key, scan, isRepeat)
	if key == "escape" then
		love.event.push "quit"
	end
end

function love.keyreleased(key, scan)

end

-------------------------------------------------------------------------------
-- Mouse
-------------------------------------------------------------------------------

function love.mousemoved(x, y, dx, dy)

end

function love.mousepressed(x, y, btn)

end

function love.mousereleased(x, y, btn)

end

