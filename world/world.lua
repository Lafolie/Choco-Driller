--[[
	Co-ordinate spaces:

		* Chunkspace: relative to world[y][x]
		* Tilespace:  relative to global tile xy
		* Worldspace: relative to global pixel xy
]]

require "atlas"
require "world.block"
require "world.chunk"
require "world.blocks.testBlock"
local Lighter = require "lib.lighter"

local floor, ceil = math.floor, math.ceil
local insert = table.insert
local tileSizePx = 16
local chunkSize, chunkSizePx
local blockList
local lighting = Lighter({litPolygons = false})

local nullBlock = Block "Null Block"


World = class 
{
	gravity = 0.25,
	tileSizePx = tileSizePx
}

local damagedBlockAtlas = Atlas("blockBreak.png", 16)
local damagedBlocks = {}
local damagedBlockBatch = love.graphics.newSpriteBatch(damagedBlockAtlas.img, 1024, "stream")

function World:init(width, height)
	self.tileset = Atlas("testTiles.png", tileSizePx)
	self.dirtyChunks = {}

	chunkSize = Chunk.chunkSize
	chunkSizePx = Chunk.chunkSize * self.tileset.gridSize

	self.width = width
	self.height = height

	blockList = 
	{
		TestBlock(self.tileset)
	}

	--pass1: gen chunks
	for y = 0, height - 1 do
		local row = {}
		self[y] = row
		for x = 0, width - 1 do
			local ch = Chunk(self.tileset, x, y)
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
			local lightTiles = ch:autoTile()
			ch:updateLightTiles(lighting, lightTiles)
			ch:generateBatch(blockList)
		end
	end
end

function World:getBlock_Worldspace(x, y)
	--chunkspace xy
	local cx = floor(x / chunkSizePx)
	local cy = floor(y / chunkSizePx)
	local chunk = self:getChunk_Chunkspace(cx, cy)
	
	if chunk then
		--tilespace xy
		local tx = floor((x % chunkSizePx) / tileSizePx)
		local ty = floor((y % chunkSizePx) / tileSizePx)
		id = chunk:getBlockId(tx, ty)

		return blockList[id] or nullBlock
	end

	return nullBlock
end

function World:getBlock_Tilespace(x, y)
	--chunkspace xy
	local cx = floor(x / chunkSize)
	local cy = floor(y / chunkSize)
	local chunk = self:getChunk_Chunkspace(cx, cy)
	
	if chunk then
		--tilespace xy
		local tx = x % chunkSize
		local ty = y % chunkSize
		id = chunk:getBlockId(tx, ty)

		return blockList[id] or nullBlock
	end

	return nullBlock
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


local light = lighting:addLight(0, 0, 256, 1, 1, 1, 1)
local lights = {}

-------------------------------------------------------------------------------
-- Update
-------------------------------------------------------------------------------

function World:update()
	--update dirty chunks
	for n = #self.dirtyChunks, 1, -1 do
		local chunk = table.remove(self.dirtyChunks, n)
		local lightTiles = chunk:autoTile()
		chunk:updateLightTiles(lighting, lightTiles)
		chunk:generateBatch(blockList)
	end

	--update damaged blocks
	damagedBlockBatch:clear()
	local dmgBlocks = {}
	for k, block in pairs(damagedBlocks) do
		block[3] = block[3] + 0.25
		if block[3] < 100 then
			local quad = 6 - ceil(block[3] / 20)
			print(quad)
			damagedBlockBatch:add(damagedBlockAtlas[quad], block[1], block[2])
			dmgBlocks[k] = block
		end
	end
	damagedBlocks = dmgBlocks

	--junk
	local mx, my = love.mouse.getPosition()
	local s = getCanvasScale()
	-- lighting:updateLight(light, mx / s.x, my / s.y)
end


function World:mousePressed(x, y, btn)
	x = floor(x / tileSizePx) * tileSizePx
	y = floor(y / tileSizePx) * tileSizePx
	print(x, y)
	if btn == 1 then
		insert(lights, lighting:addLight(x + 8, y + 8, 256, 0.8, 0.75, 0.2, 0.8))
	else
		for k, v in ipairs(lights) do
			if v.x == x and v.y == y then
				lighting:removeLight(v)
				return
			end
		end
	end
end

function World:damage(x, y, dmg)
	local tx = floor(x / tileSizePx)
	local ty = floor(y / tileSizePx)

	local block = self:getBlock_Tilespace(tx, ty)

	if block == nullBlock then
		return
	end

	local id = string.format("%d:%d", tx, ty)
	local dmgBlock = damagedBlocks[id]
	if not dmgBlock then
		dmgBlock = {tx * tileSizePx, ty * tileSizePx, 100}
		damagedBlocks[id] = dmgBlock
	end

	dmgBlock[3] = dmgBlock[3] - dmg * block.toughness
	print(id, dmgBlock[3])
	if dmgBlock[3] <= 0 then
		print "destroying"
		damagedBlocks[id] = nil
		self:setBlock_Tilespace(tx, ty, 0)
		self.isDirty = true
	end
end

function World:addDirtyChunk(chunk)
	for k, ch in ipairs(self.dirtyChunks) do
		if ch == chunk then
			return
		end
	end

	insert(self.dirtyChunks, chunk)
end

function World:setBlock_Tilespace(x, y, id)
	--chunkspace xy
	local cx = floor(x / chunkSize)
	local cy = floor(y / chunkSize)
	local chunk = self:getChunk_Chunkspace(cx, cy)
	
	if chunk then
		--tilespace xy
		local tx = x % chunkSize
		local ty = y % chunkSize
		chunk:setBlockId(tx, ty, id)

		--dirtify any chunks that are touching the modified tile
		self:addDirtyChunk(chunk)

		if tx == 0 and cx > 0 then
			self:addDirtyChunk(chunk.east)
		elseif tx == chunkSize - 1 and cx < self.width - 1 then
			self:addDirtyChunk(chunk.west)
		end

		if ty == 0 and cy > 0 then
			self:addDirtyChunk(chunk.north)
		elseif ty == chunkSize - 1 and cy < self.height - 1 then
			self:addDirtyChunk(chunk.south)
		end

		return true
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
			local u = x * size
			love.graphics.draw(row[x].batch, u, v)

			-- love.graphics.line(u, v, u + chunkSize * tileSizePx, v)
			-- love.graphics.line(u, v, u, v + chunkSize * tileSizePx)

			-- for k, v in ipairs(row[x].lightTiles) do
			-- 	love.graphics.polygon("fill", unpack(v))
			-- end
		end
	end

	love.graphics.draw(damagedBlockBatch, 0, 0)
	lighting:drawLights()
end