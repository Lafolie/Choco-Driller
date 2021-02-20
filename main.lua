class = require "lib.class"
vector = require "lib.brinevector.brinevector"

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
	act.location.x = mx
	act.location.y = my
	if act:phys(world) then
		color = {1, 0, 0, 1}
	else
		color = {1, 1, 1, 1}
	end
end


function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	world:draw()

	love.graphics.setColor(color)
	act:draw()
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

