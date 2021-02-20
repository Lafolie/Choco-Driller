require "atlas"

Block = class {}

function Block:init(atlas, x, y, name, isSolid)
	self.name = name
	self.isSolid = isSolid
	self.toughness = 1

	--check that this isn't a nullblock (see world.lua)
	if type(atlas) ~= "string" then
		local size = atlas.gridSize
		local w, h = atlas.img:getDimensions()
		local cols = math.floor(w / size)
		local rows = math.floor(h / size)

		-- local startTile = rows * y + x
		-- for n = startTile, startTile + 16 do
		-- 	table.insert(self, atlas[n])
		-- end
		for n = y, y + 3 do
			local i = x + n * cols + 1
			print(i, y)
			table.insert(self, atlas[i])
			table.insert(self, atlas[i + 1])
			table.insert(self, atlas[i + 2])
			table.insert(self, atlas[i + 3])
		end
	else
		self.name = "null"
	end
end