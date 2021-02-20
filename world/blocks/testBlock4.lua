require "world.block"

TestBlock4 = class {}

function TestBlock4:init(atlas)
	Block.init(self, atlas, 4, 5, "Test Block", true)
end