require "atlas"

Block = class {}

function Block:init(atlas, x, y, name)
	self.name = name

	local size = atlas.gridSize
	-- local w, h = atlas.img:getDimensions()
	-- local cols = math.floor(w / size)
	local rows = math.floor(atlas.img:getHeight() / size)
	local startTile = rows * y + x
	for n = startTile, startTile + 16 do
		table.insert(self, atlas[n])
	end
end