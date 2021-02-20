class = require "lib.class"
vector = require "lib.brinevector.brinevector"

-------------------------------------------------------------------------------
-- Main Callbacks
-------------------------------------------------------------------------------

function love.load()

end

function love.update()

end

require "atlas"
require "world.blocks.testBlock"
require "world.chunk"
tiles = Atlas("testTiles.png")

blockList = {TestBlock(tiles)}

local chunks = {}
for n=1, 4 do
	local ch = Chunk(tiles)
	ch:randomise()
	ch:generateBatch(blockList)
	chunks[n] = ch
end


function love.draw()
	love.graphics.draw(chunks[1].batch, 16, 16)
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

