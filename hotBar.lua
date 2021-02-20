require "inventory"

local pad = 2

HotBar = class (Inventory) {}

function HotBar:init()
	Inventory.init(self, 9)
end

function HotBar:draw(x, y)
	local size = Inventory.iconSize

	love.graphics.setColor(0, 0, 0, 0.3)
	love.graphics.rectangle("fill", x, y, self.numSlots * (size + pad) + pad, size + pad * 2, 2, 2)
	for n = 1, self.numSlots do
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", x + 2 + (n - 1) * (size + pad), y + pad, size, size, 2, 2)
	end
end