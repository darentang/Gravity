local gamera = require 'gamera' -- "gamera" module v1.0.1 Julien Patte and LuaObject, Sebastien Rocca-Serra
-- load custom modules --
require("/lib/orbit")
require("/lib/maths")
require("/lib/interface")
require("/lib/controls")
require("/lib/load")
require("/lib/objects")
require("/lib/game")
require("/lib/objectives")
require("/lib/menu")
require("/lib/leveldescription")


-- load sound for the game
volume = 1
track = loadsound()

-- create a new Gamera canvas
cam = gamera.new(0,0,2000,2000)

-- love loading module
function love.load()
	-- load the menu
	menu:load()
end

-- love update module
function love.update(dt)
	-- define the mX and mY variables 
	mX = love.mouse.getX()
	mY = love.mouse.getY()
	
	-- only update game when there is a valid module (level 0 = manual, level 1-99 = tutorials, level 100-199 = missions, level >200 sandbox mode)
	if level ~= nil and level > 0 then
		game:update(dt) -- cycles through the game
	else
		menu:update(dt) -- cyclese through the menu
	end
end

-- love draw module
function love.draw()
	if level ~= nil and level > 0 then
		game:draw(level) -- only draws game when there is a valid level
	else
		menu:draw() -- draws menu instead
	end
	
end




