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

function Chunk:getBlockId(x, y)
	local id
	if not (x < 0 or x >= self.chunkSize or
	        y < 0 or y >= self.chunkSize)
	then
		id = self[y][x][1]
	else
		id = self:getNeighbouringBlockId(x, y) or 0
	end

	return id
end

function Chunk:getNeighbouringBlockId(x, y)
	if y < 0 and self.north then
		return self.north:getBlockId(x, self.chunkSize + y)
	elseif y >= self.chunkSize and self.south then
		return self.south:getBlockId(x, y - self.chunkSize)
	elseif x < 0 and self.west then
		return self.west:getBlockId(self.chunkSize + x, y)
	elseif x >= self.chunkSize and self.east then
		return self.east:getBlockId(self.chunkSize - x, y)
	end
end

function Chunk:randomise(blocks)
	for y = 0, self.chunkSize - 1 do
		local row = self[y]
		for x = 0, self.chunkSize - 1 do
			local id = love.math.random() > 0.7 and 1 or 0
			row[x] = {id, 1}
		end
	end
end


function Chunk:autoTile()
	for y = 0, self.chunkSize -1 do
		local row = self[y]

		for x = 0, self.chunkSize - 1 do
			--quadId beigns at 1 because of Lua
			local quadId = 1
			local tile = row[x][1]

			local other = self:getBlockId(x, y - 1)
			quadId = quadId + (tile == other and 1 or 0)
			other = self:getBlockId(x - 1, y)
			quadId = quadId + (tile == other and 2 or 0)
			other = self:getBlockId(x + 1, y)
			quadId = quadId + (tile == other and 4 or 0)
			other = self:getBlockId(x, y + 1)
			quadId = quadId + (tile == other and 8 or 0)

			row[x][2] = quadId
		end
	end
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