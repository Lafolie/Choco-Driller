require "world.block"

local insert = table.insert

Chunk = class 
{
	chunkSize = 16
}

function Chunk:init(atlas, x, y)
	local gridSize = atlas.gridSize

	self.gridLocation = vector(x, y)
	self.location = vector(x * gridSize * self.chunkSize, y * gridSize * self.chunkSize)

	-- block grid
	for y = 0, self.chunkSize - 1 do
		local row = {}
		self[y] = row
		for x = 0, self.chunkSize - 1 do
			--[[
				1: blockList id (zero means empty)
				2: block quad id
				3: polygon for lighter
			]]
			local px = self.location.x + x * gridSize
			local py = self.location.y + y * gridSize
			local poly =
			{
				px,			 	py,
				px + gridSize,	py,
				px + gridSize,	py + gridSize,
				px,				py + gridSize

			}
			row[x] = {0, 1, poly}
		end
	end

	-- neighbours
	self.north = false
	self.south = false
	self.east = false
	self.west = false

	self.batch = love.graphics.newSpriteBatch(atlas.img, self.chunkSize ^ 2, "dynamic")
	self.gridSize = gridSize
	self.lightTiles = {}
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
			row[x][1] = id
		end
	end
end


function Chunk:autoTile()
	local lightTiles = {}
	for y = 0, self.chunkSize -1 do
		local row = self[y]

		for x = 0, self.chunkSize - 1 do
			local block = row[x]

			--quadId beigns at 1 because of Lua
			local quadId = 1
			local tile = block[1]
			local isOuterTile

			local other = self:getBlockId(x, y - 1)
			quadId = quadId + (tile == other and 1 or 0)
			isOuterTile = (tile ~= 0 and other == 0) or isOuterTile

			other = self:getBlockId(x - 1, y)
			quadId = quadId + (tile == other and 2 or 0)
			isOuterTile = (tile ~= 0 and other == 0) or isOuterTile


			other = self:getBlockId(x + 1, y)
			quadId = quadId + (tile == other and 4 or 0)
			isOuterTile = (tile ~= 0 and other == 0) or isOuterTile


			other = self:getBlockId(x, y + 1)
			quadId = quadId + (tile == other and 8 or 0)
			isOuterTile = (tile ~= 0 and other == 0) or isOuterTile


			block[2] = quadId

			if isOuterTile then
				lightTiles[block[3]] = block[3]
			end
		end
	end

	return lightTiles
end

function Chunk:updateLightTiles(lighting, newLightTiles)
	log:echo("Updating lighting for chunk %03d,%03d", self.gridLocation.x, self.gridLocation.y)
	local lightTiles = {}

	--remove old unused tiles
	for _, oldTile in ipairs(self.lightTiles) do
		if not newLightTiles[oldTile] then
			lighting:removePolygon(oldTile)
		end
	end

	--update lighting
	local n = 1
	for _, v in pairs(newLightTiles) do
		insert(lightTiles, v)
		lighting:addPolygon(v)
		n = n + 1
	end

	log:echo "Done"
	self.lightTiles = lightTiles
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