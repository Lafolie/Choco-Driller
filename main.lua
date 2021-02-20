class = require "lib.class"
vector = require "lib.brinevector.brinevector"

-------------------------------------------------------------------------------
-- Main Callbacks
-------------------------------------------------------------------------------
require "world.world"
local world = World(4, 4)

function love.load()

end

local id

function love.update()
	local mx, my = love.mouse.getPosition()
	id = world:getBlock_Worldspace(mx, my)
end


function love.draw()
	world:draw()
	love.graphics.print(id, 1, 1)
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

