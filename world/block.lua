require "atlas"

Block = class {}

function Block:init(atlas, x, y, name, isSolid)
	self.name = name
	self.isSolid = isSolid
	self.toughness = 1

	--check that this isn't a nullblock (see world.lua)
	if type(atlas) ~= "string" then
		local size = atlas.gridSize
		-- local w, h = atlas.img:getDimensions()
		-- local cols = math.floor(w / size)
		local rows = math.floor(atlas.img:getHeight() / size)
		local startTile = rows * y + x
		for n = startTile, startTile + 16 do
			table.insert(self, atlas[n])
		end
	else
		self.name = "null"
	end
end