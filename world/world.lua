require "atlas"
require "world.block"
require "world.chunk"
require "world.blocks.testBlock"

World = class {}

function World:init(width, height)
	self.tileset = Atlas("testTiles.png", 16)
	self.blockList = 
	{
		TestBlock(self.tileset)
	}

	self.width = width
	self.height = height
	for y = 0, height - 1 do
		local row = {}
		self[y] = row
		for x = 0, width - 1 do
			local ch = Chunk(self.tileset)
			ch:randomise()
			ch:autoTile()
			ch:generateBatch(self.blockList)
			row[x] = ch
		end
	end
end

function World:draw()
	--todo: only render chunks on-screen
	local img = self.tileset.img
	local size = Chunk.chunkSize * self.tileset.gridSize
	for y = 0, self.height - 1 do
		local row = self[y]
		local v = y * size
		for x = 0, self.width - 1 do
			love.graphics.draw(row[x].batch, x * size, v)
		end
	end
end