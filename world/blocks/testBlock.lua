require "world.block"

TestBlock = class {}

function TestBlock:init(atlas)
	Block.init(self, atlas, 0, 1, "Test Block", true)
end