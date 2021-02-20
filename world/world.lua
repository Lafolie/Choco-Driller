--[[
	Co-ordinate spaces:

		* Chunkspace: relative to world[y][x]
		* Tilespace:  relative to chunk[y][x]
		* Worldspace: relative to global pixel xy
]]

require "atlas"
require "world.block"
require "world.chunk"
require "world.blocks.testBlock"

local floor = math.floor
local tileSizePx = 16
local chunkSizePx

World = class {}

function World:init(width, height)
	self.tileset = Atlas("testTiles.png", tileSizePx)
	chunkSizePx = Chunk.chunkSize * self.tileset.gridSize

	self.blockList = 
	{
		TestBlock(self.tileset)
	}

	self.width = width
	self.height = height

	--pass1: gen chunks
	for y = 0, height - 1 do
		local row = {}
		self[y] = row
		for x = 0, width - 1 do
			local ch = Chunk(self.tileset)
			ch:randomise()

			row[x] = ch
		end
	end

	--pass2: set neighbours
	for y = 0, height - 1 do
		local row = self[y]
		for x = 0, width - 1 do
			local ch = row[x]
			ch.north = self:getChunk_Chunkspace(x, y - 1)
			ch.south = self:getChunk_Chunkspace(x, y + 1)
			ch.west = self:getChunk_Chunkspace(x - 1, y)
			ch.east = self:getChunk_Chunkspace(x + 1, y)
		end
	end

	--pass3: generate
	for y = 0, height - 1 do
		local row = self[y]
		for x = 0, width - 1 do
			local ch = row[x]
			ch:autoTile()
			ch:generateBatch(self.blockList)
		end
	end
end

function World:getBlock_Worldspace(x, y)
	local id = 0
	--chunkspace xy
	local cx = floor(x / chunkSizePx)
	local cy = floor(y / chunkSizePx)
	local chunk = self:getChunk_Chunkspace(cx, cy)
	
	if chunk then
		--tilespace xy
		local tx = floor((x % chunkSizePx) / tileSizePx)
		local ty = floor((y % chunkSizePx) / tileSizePx)
		id = chunk:getBlockId(tx, ty)
	end

	return id
end

function World:getChunk(mode, x, y)

end

function World:getChunk_Chunkspace(x, y)
	if not(x < 0 or x >= self.width or
	       y < 0 or y >= self.height)
	then
		return self[y][x]
	end
end

function World:getChunk_Tilespace(x, y)
end

function World:getChunk_Worldspace(x, y)

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