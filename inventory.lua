Inventory = class {}

function Inventory:init(numSlots)
	self.numSlots = numSlots or 8
end

function Inventory:add(item)
	if #self < numSlots then
		table.insert(self, item)
		return item
	end
end

function Inventory:remove(item)
	if type(item) == "number" then
		if self[item] then
			return table.remove(self, item)
		end
	else
		for k, v in ipairs(self) do
			if v == item then
				return table.remove(self, k)
			end
		end
	end
end