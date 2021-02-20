love.graphics.setDefaultFilter("nearest", "nearest")

class = require "lib.class"
vector = require "lib.brinevector.brinevector"

log = require "lib.logger"
log:init "global"

require "player"

function lerp(a, b, x)
	return (1 - x) * a + x * b
end

function sign(x)
	return x < 0 and -1 or (x > 0 and 1 or 0)
end

-- Canvas ---------------------------------------------------------------------
local mainCanvas
local nativeRes = vector(640, 360)
-- local nativeRes = vector(1024, 576)
local targetRes = vector(love.graphics.getDimensions())
local canvasScale = vector(1, 1)
local canvasOffset = vector()
local intScaling = true
local uniformScaling = true
local canvasSetup = {mainCanvas, stencil = true}

local function regenerateCanvas(w, h)
	if mainCanvas then 
		mainCanvas:release()
	end

	mainCanvas = love.graphics.newCanvas(nativeRes.x, nativeRes.y)
	canvasSetup[1] = mainCanvas
end

local function regenerateCanvasScale()
    canvasScale = targetRes / nativeRes
	
    if uniformScaling then
        local scale = math.min(canvasScale.x, canvasScale.y)
        canvasScale.x = scale
        canvasScale.y = scale

        if intScaling then
            canvasScale.x = math.floor(canvasScale.x)
            canvasScale.y = math.floor(canvasScale.y)
        end
    end

    canvasOffset = (targetRes - nativeRes % canvasScale) / 2
    canvasOffset = canvasOffset:getFloor()
    
    log:info "Canvas rescaled:"
    log:info("\tNew Resolution\tx: %d, y: %d", targetRes.x, targetRes.y)
    log:info("\tNew Position\tx: %d, y: %d", canvasOffset.x, canvasOffset.y)
    log:info("\tNew Scale\tx: %f, y: %f", canvasScale.x, canvasScale.y)

    
end

function setScaleMode(useIntScaling, useUniformScaling)
	intScaling = useIntScaling
	uniformScaling = useUniformScaling
    regenerateCanvasScale()
    log:info(tostring(canvasScale))
end

function getScaleMode()
	return intScaling, uniformScaling
end

function getCanvasScale()
	return canvasScale
end

-- State ----------------------------------------------------------------------
local p1 = Player(8, 8)

local function screenToWorld(x, y)
	x = x / canvasScale.x - canvasOffset.x
	y = y / canvasScale.y - canvasOffset.y
	return x, y
end
-------------------------------------------------------------------------------
-- Main Callbacks
-------------------------------------------------------------------------------
require "world.world"
local world = World(3, 3)

function love.load()
	regenerateCanvas()
	regenerateCanvasScale()
end

function love.update()
	local mx, my = love.mouse.getPosition()
	p1:setAim(screenToWorld(mx, my))

	local x = 0
	if love.keyboard.isScancodeDown("a") then x = x - 1 end
	if love.keyboard.isScancodeDown("d") then x = x + 1 end

	-- act.velocity.x = x * 1.75
	p1:addMovement(x)
	-- act.velocity.y = y

	p1:phys(world)
	world:update()
end


function love.draw()
	love.graphics.setCanvas(canvasSetup)
	-- love.graphics.setBlendMode("alpha", "alphamultiply")
    love.graphics.clear(0.2, 0.2, 0.2)
	love.graphics.setColor(1, 1, 1, 1)
	world:draw()
	p1:draw()
	love.graphics.setCanvas()


	love.graphics.push()
    love.graphics.translate(canvasOffset.x, canvasOffset.y)
	love.graphics.scale(canvasScale.x, canvasScale.y)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(mainCanvas)
	love.graphics.setBlendMode("alpha", "alphamultiply")
	love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", canvasOffset.x - 1, canvasOffset.y - 1, nativeRes.x * canvasScale.x + 2, nativeRes.y * canvasScale.y + 2)



	love.graphics.print(string.format("%dfps", love.timer.getFPS()), 1, 1)
end

function love.quit()
	log.flushAll()
end

-------------------------------------------------------------------------------
-- Keyboard
-------------------------------------------------------------------------------

function love.keypressed(key, scan, isRepeat)
	if key == "escape" then
		love.event.push "quit"
	end

	if key == "space" then
		p1:startJump()
	end
end

function love.keyreleased(key, scan)
	if key == "space" then
		p1:stopJump()
	end
end

-------------------------------------------------------------------------------
-- Mouse
-------------------------------------------------------------------------------

function love.mousemoved(x, y, dx, dy)

end

function love.mousepressed(x, y, btn)
	x, y = screenToWorld(x, y)
	world:damage(x, y, 10)
	-- world:mousePressed(x, y, btn)
end

function love.mousereleased(x, y, btn)

end

