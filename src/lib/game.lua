-- /bin/game.lua loads,updates and draws the "game"

game = {}

function game:load(level)
	-- loads the game
	if currentTrack1 ~= nil and menutrack[currentTrack1]:isPlaying() then -- shuts off current music
		menutrack[currentTrack1]:stop()
	end
	currentX,currentY = cam:getPosition() -- defines the variables current X and current Y
	G = 6.6725985E-11 --wrong value of G, but uses this anyway for desk check
	-- G = 6.6740831E-11 -- the right one here :/
	AU = (149.6E6 * 1000) -- unit for length between the sun and the earth. 
	Mm = 1E6 -- defines a mega meter. not used
	iSCALE = 1E6/AU -- initial scale of the game (constant)
	SCALE = iSCALE --  changing scale
	
	-- define variables for game
	warp = 0 -- time warp speed
	drag = {} 
	injection = {}
	drag.active = false
	mouse.downl = {0,0}
	toggle = {}
	node = {}
	toggle.stat = false
	toggle.node = false
	toggle.menu = false
	toggle.camera = false
	toggle.groundplot = false
	cameraActive = nil
	time = 0
	active = nil
	s = 1
	currentTrack = 1
	lastclick = 0
	clickInterval = 0.2 
	--loading images
	loadimg()
	-- loads the objects for this level
	body = loadbody(level)
	-- initialising the game
	for i,v in pairs(body) do
		if v.type == "dynamic" then
			computeOrbit(v.parent,v) -- keplerian orbit calculation
			v.soi = v.a*((v.mass/v.parent.mass)^(2/5)) -- deifnes the sphere of influnce of an object
		end
	end

	active = body.ship -- defines ship as the current active object
	cameraActive = active.parent -- follows the parent of the object
	origin = {1000-(active.parent.p[1]*SCALE),1000+(active.parent.p[2]*SCALE)} -- defines current origin (centered at the parent of the ship)
	cam:setPosition(1000,1000) -- sets currentX currentY

	if levelObjectives(level,active) ~= nil then
		complete = nil -- complete of objectives
	end
	track[currentTrack]:setVolume(volume) -- plays background music
	track[currentTrack]:play()
end

function game:update(dt)
	if track[currentTrack]:isStopped() then -- switches to next track if current is finished playing
		if currentTrack < #track then
			currentTrack = currentTrack + 1
		elseif currentTrack == #track then
			currentTrack = 1
		end
	end
	track[currentTrack]:setVolume(volume)
	track[currentTrack]:play() -- plays the track
 	mrX,mrY = currentX + (mX-400),currentY + (mY-300) -- defines current mouse position
	dtt = dt -- global variable for delta time
	dt = dt*(10^warp) -- warps the delta time 
	updatePhysics(dt) -- rotates with velocity
	input(dt) -- keyboard/mouse inputs
	time = time + dt -- keeps track of system time
	for i,v in pairs(body) do
		if v.type == "dynamic" then
			control(v.parent,v,dt) -- computes the position of objects after 1 dt
		end
	end
end

function game:draw(level)
	love.graphics.draw(backdrop,0,0,0,(800/1200),(800/1200)) -- draws the "backdrop"
	local slave = active
	if s>1 then
		cam:setWorld(0,0,math.floor(2000*s),math.floor(2000*s)) -- explands world as it zooms out
	end
	SCALE = iSCALE*s
	if toggle.camera == true and cameraActive ~= nil then -- chase cam
		drag.active = false
		origin = {1000-(cameraActive.p[1]*SCALE),1000+(cameraActive.p[2]*SCALE)}
	end
	
	-- draws the objects displayed in the canvas
	cam:draw(function(l,t,w,h)	
		display()
		interface()
	end)
	nav()

	-- draws debug
	if active ~= nil and toggle.stat then
		love.graphics.print(
			"a: "..slave.a.."\n"..
			"h: "..slave.h[3].."\n"..
			"e: "..magnitude(slave.e).."\n"..
			"w: "..180*slave.w/math.pi.."\n"..
			"i: "..180*slave.i/math.pi.."\n"..
			"tru: "..180*slave.tru/math.pi.."\n"..
			"E: "..180*slave.E/math.pi.."\n"..
			"M: "..180*slave.M/math.pi.."\n"..
			"Velx: " .. slave.v[1] .. "\n"..
			"Vely: " .. slave.v[2] .. "\n" .. 
			"Vel: " .. magnitude({slave.v[1],slave.v[2],slave.v[3]}) .. "\n" ..
			"Rx: " .. slave.r[1] .. "\n"..
			"Ry: " .. slave.r[2] .. "\n" .. 
			"R: " .. magnitude(slave.r) .. "\n" ..
			"Time: " .. time .. "\n" ..
			"Loops" .. index .. "\n" ..
			"Scale: " .. s .. "\n" ..
			"mX " ..screen2scale({mX,mY})[1] .. "\n" ..
			"mY " .. screen2scale({mX,mY})[2] .. "\n" ..
			"origin" ..origin[1].." ".. origin[2] .. "\n" ..
			"active " .. active.name .. "\n" ..
			"active parent " .. active.parent.name .. "\n" ..
			"warp" .. 10^warp .. "\n" ..
			"fps" .. 1/dtt .. "\n" 
			,10,10	
		)
	end

	-- quit window
	if toggle.menu then
		drawwindow()
	end
end
