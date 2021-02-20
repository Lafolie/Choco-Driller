require "world.block"

Chunk = class 
{
	chunkSize = 16
}

function Chunk:init(atlas)
	-- block grid
	for y = 0, self.chunkSize - 1 do
		local row = {}
		self[y] = row
		for x = 0, self.chunkSize - 1 do
			--[[
				1: blockList id (zero means empty)
				2: block quad id
			]]
			row[x] = {0, 1}
		end
	end

	-- neighbours
	self.north = false
	self.south = false
	self.east = false
	self.west = false

	self.batch = love.graphics.newSpriteBatch(atlas.img, self.chunkSize ^ 2, "dynamic")
	self.gridSize = atlas.gridSize
end

function Chunk:randomise(blocks)
	for y = 0, self.chunkSize - 1 do
		local row = self[y]
		for x = 0, self.chunkSize - 1 do
			local id = love.math.random(2) - 1
			row[x] = {id, 1}
			print(x, y, id)
		end
	end
end

function Chunk:autoTile()

end

function Chunk:generateBatch(blockList)
	self.batch:clear()
	for y = 0, self.chunkSize -1 do
		local row = self[y]
		local v = y * self.gridSize

		for x = 0, self.chunkSize - 1 do
			local u = x * self.gridSize
			local id, quad = unpack(row[x])
			if id > 0 then
				self.batch:add(blockList[id][quad], u, v)
			end
		end
	end
end
