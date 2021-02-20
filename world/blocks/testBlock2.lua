require "world.block"

TestBlock2 = class {}

function TestBlock2:init(atlas)
	Block.init(self, atlas, 4, 1, "Test Block", true)
end