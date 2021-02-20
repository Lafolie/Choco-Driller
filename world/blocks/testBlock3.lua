require "world.block"

TestBlock3 = class {}

function TestBlock3:init(atlas)
	Block.init(self, atlas, 0, 5, "Test Block", true)
end