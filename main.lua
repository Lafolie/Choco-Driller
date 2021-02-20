class = require "lib.class"
vector = require "lib.brinevector.brinevector"

-------------------------------------------------------------------------------
-- Main Callbacks
-------------------------------------------------------------------------------

function love.load()

end

function love.update()

end

require "world.world"
local world = World(4, 4)

function love.draw()
	world:draw()
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

