local imgCache = setmetatable({}, {__mode = "v"})

Atlas = class {}

function Atlas:init(path, gridSize)
	-- self.path = path
	self.gridSize = gridSize or 16
	self.img = self:loadImage(path)
	self:generateQuads()
end

function Atlas:loadImage(path)
	local img = imgCache[path]

	if not img then
		img = love.graphics.newImage(path)
		imgCache[path] = img
	end

	return img
end

function Atlas:generateQuads()
	local w, h = self.img:getDimensions()
	local size = self.gridSize
	for y = 0, math.floor(h / size) - 1 do
		local v = y * size
		for x = 0, math.floor(w / size) - 1 do
			local quad = love.graphics.newQuad(x * size, v, size, size, w, h)
			table.insert(self, quad)
		end
	end
end