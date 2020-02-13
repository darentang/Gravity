-- /bin/controls.lua: updates the change in keyboard and mouse control and generates the physics to maneuver the spacecraft

-- mouse control used during the game
function gameMouseControl(x,y,button)
	-- offX and offY defines the position of the mouse within the gamera canvas
	offX = currentX - (400-mX)
	offY = currentY + (mY-300) 
	-- conditions when the left mouse button is clicked
	if button == 'l' then
		mouse.l = true
		mouse.downl = {offX,offY} -- position at which the mouse is clicked
		drag.active = true
		drag.diffX = (-x + origin[1]) -- dragging within the game environment
		drag.diffY = (-y + origin[2])
		clicktime = os.time()
        if clicktime <= lastclick + clickInterval then -- double click
            mouse.ld = true
            for i,v in pairs(body) do
				p1,p2 = origin[1] + v.p[1]*SCALE,origin[2] - v.p[2]*SCALE
				if (mrX-p1)^2 + (mrY-p2)^2 <= 100  and button == 'l' then
					v.toggle = not v.toggle
					if v.toggle == false then
						cameraActive = nil -- swithc camera chase subject
					else 
						cameraActive = v
					end
					for p,q in pairs(body) do
						if q ~= v then
							q.toggle = false
						end
					end 
					
				end
			end
        else
            lastclick = clicktime
        end
        -- check if the Mnode can be dragged 
        if active~= nil and node[active.name] ~= nil and node[active.name].active == true then
			local bx,by = origin[1]+(active.parent.p[1]+node[active.name].r[1])*SCALE,origin[2]-(active.parent.p[2]+node[active.name].r[2])*SCALE
			if (offX-bx)^2+(offY-by)^2 <= 160 then
				drag.node = true
			end
		end
		-- selecting targets
		if active ~= nil then
			for i,v in pairs(body) do
				if v.type == "dynamic" and v.parent == active.parent and v~= active then
					local distance,tru,d1 =  mouseProximity(mouse.downl[1],mouse.downl[2],v)
					if math.abs(distance) < 50E4/s   and mouse.ld then -- check if mouse is near the drawn orbits
						if active.target == nil  then
							active.target = v
						else
							v.colour = v.colourtemp
							active.target = nil
						end
					end
				end
			end
		end
		-- card navigation in tutorials 
		if levelSelect(level)~= nil and levelSelect(level).cards ~= nil then
			local l = levelSelect(level)
			if l.current == 1 then -- first card
				love.graphics.draw(buttdisabled,490,90)
				if buttonHoverClick({587,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover) then
					l.current = l.current + 1
				end
			elseif l.current == #l.cards then -- last card
				love.graphics.draw(buttdisabled,587,90)
				if buttonHoverClick({490,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover) then
					l.current = l.current - 1
				end
			else -- cards in between
				if buttonHoverClick({587,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover) then
					l.current = l.current + 1
				elseif buttonHoverClick({490,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover) then
					l.current = l.current - 1
				end
			end
		end
	end

	if button == 'r' then
		mouse.r = true -- right click boolean
	end
	-- zooming in and out. changing the position of the origin so that the point under the mouse is stationary
	if button == "wu" then
		local change = (math.exp(0.1)-1)
		local offsetX = -((offX - origin[1])*change)
		local offsetY = -((offY - origin[2])*change)
		if s < 500 then
			if not toggle.camera then origin = {origin[1]+offsetX,origin[2]+offsetY} end
			s = s * math.exp(0.1)
		end
	elseif button == "wd" then
		local change = (math.exp(-0.1)-1)
		local offsetX = -((offX - origin[1])*change)
		local offsetY = -((offY - origin[2])*change)	
		if not toggle.camera then origin = {origin[1]+offsetX,origin[2]+offsetY} end
		s = s * math.exp(-0.1)
	end
end

function gameMenuControl(x,y,button)
	-- called when the menu is active

	if button ==  "l" then
		mouse.l = true
		mouse.downl = {mX,mY}
	end
end

function love.mousepressed(x, y, button)
	key_map = {
		[1] = "l",
		[2] = "r",
	}
	--calls the two functions when either is active
	if level~= nil and level > 0 then
		gameMouseControl(x,y,key_map[button])
	else
		gameMenuControl(x,y,key_map[button])
	end
end

function love.mousereleased(x, y, button)
	-- disable click variables once the mouse is released
	if level ~= nil and level > 0 then
		if button == 1 then mouse.l = false mouse.ld = false drag.active = false mouse.downl = {0,0} drag.node = false end
		if button == 2 then mouse.r = false end
	else
		mouse.l = false
	end
end

function love.wheelmoved(x,y)
	if y > 0 then
		dir = "wu"
	elseif y < 0 then
		dir = "wd"
	end

	--calls the two functions when either is active
	if level~= nil and level > 0 then
		gameMouseControl(0,0,dir)
	else
		gameMenuControl(0,0,dir)
	end

end

function love.keypressed(key)
	-- toggle variables
	if level ~= nil and level > 0 then
		if key == 's' then
			toggle.stat = not toggle.stat
		end
		if key == 't' and active ~= nil then
			active.sas = not active.sas
		end
		if key == 'r' and active~= nil then
			active.rcs = not active.rcs
		end
		if key == 'c' then
			toggle.camera = not toggle.camera
		end
		if key == 'g' then
			toggle.groundplot = not toggle.groundplot
		end
		if key == '.' then
			if warp <= 5 then
				warp = warp + 1
			end
		elseif key ==',' then
			if warp >= 1 then
				warp = warp - 1
			end
		end
		if key == 'escape' then
			toggle.menu = not toggle.menu
		end
	end
end

function scroll()
	-- scroll control for the canvas
	currentX,currentY = cam:getPosition()
	offX = currentX - (400-mX)
	offY = currentY + (mY-300)
	if drag.active == true  then
		origin = {drag.diffX+mX,drag.diffY+mY} -- displace the origin when the canvas is dragged
		-- cam:setPosition(drag.diffX-mX,drag.diffY-mY)
	end

end

function updatePhysics(dt)
	for i,v in pairs(body) do
		v.orientation = v.orientation + dt*v.orientationV -- updates orientation of the body which has an angular velocity 
	end
end

function keyboard(dt)
	-- keyboard control for the spacecraft.
	if active ~= nil and active.type == "dynamic" then
		if toggle.stat then -- cheat mode
			if love.keyboard.isDown("down") then
				active.v[1] =active.v[1] - 10*math.cos(active.v.arg) -- acceleartes along the velocity vector 
				active.v[2] =active.v[2] - 10*math.sin(active.v.arg)
				computeOrbit(active.parent, active)
			elseif love.keyboard.isDown("up") then
				active.v[1] =active.v[1] + 10*math.cos(active.v.arg)
				active.v[2] =active.v[2] + 10*math.sin(active.v.arg)
				computeOrbit(active.parent, active)
			end 
		end
		active.I = (1/12)*active.mass*active.length^2 -- calculates the moment of inertia of the spacecraft, assuming it is a rod spining perpendicular to its central axis
		local rcsTorque = 0
		local RCSmasschange = 0
		active.rcsTorque = 0
		if active.rcs and active.rcsmass > 0 then
			rcsTorque = active.rcsengine.thrust*(active.radius*2) -- calculates the maximum torque that the rcs thrusters provide under current status
			RCSmasschange = (active.rcsengine.thrust/(9.81*active.rcsengine.Isp)) -- calculates the change in mass due to the burnign of the hypergolic fuel
		end
		if warp == 0 then
			if love.keyboard.isDown("lshift") and active.throttle < 100 then -- increases thrust when lshift is down
				active.throttle = active.throttle + 1
			elseif love.keyboard.isDown("lctrl") and active.throttle > 0 then -- decreases thrust when lctrl is down
				active.throttle = active.throttle - 1
			elseif love.keyboard.isDown("x") then -- cuts throttle when x is pressed
				active.throttle = 0
			end
			rcs:setVolume(0.3*volume) -- sets default volume fo the rcs thrusters
			if love.keyboard.isDown("a") then -- induces anticlockwise torque to the spacecraft
				active.torque = -active.gyro - rcsTorque -- calculates the sum of moment			
				active.rcsmass = active.rcsmass-dt*RCSmasschange -- calculates the decrease in mass
				active.rcsTorque = - rcsTorque -- calculates the torque induced by the rcs
				if active.rcs then rcs:play() end -- play the rcs sound if it is active
			elseif love.keyboard.isDown("d") then -- and vise versa
				active.torque = active.gyro + rcsTorque
				active.rcsmass = active.rcsmass-dt*RCSmasschange
				active.rcsTorque = rcsTorque
				if active.rcs then rcs:play() end
			elseif active.sas then -- if the sas system is engaged
				local T = 0
				if math.abs(active.orientationV)/d2rad(10) < 1 then -- defines the amount of torque that should be applied given current angular velocity
					T = math.abs(active.orientationV)/d2rad(10) 
				else
					T = 1
				end
				rcs:setVolume(T*0.3*volume)
				if active.rcs then rcs:play() end -- plays sound
				if active.orientationV > 0 then -- induce anticlockwise torque if current angular velocity is clockwise
					active.torque = (-active.gyro -rcsTorque)*T
					active.rcsmass = active.rcsmass-dt*RCSmasschange*T
					active.rcsTorque = -rcsTorque*T
				elseif active.orientationV < 0 then -- vise versa
					active.torque = (active.gyro +rcsTorque)*T
					active.rcsmass = active.rcsmass-dt*RCSmasschange*T
					active.rcsTorque = rcsTorque*T
				end
			else
				rcs:stop() -- stops the rcs noise if nothing is pressed
				active.torque = 0 -- stop torque
			end
			engine:setVolume(active.throttle/100*volume) -- set the volume of the engine sound
			active.orientationV = (active.torque/active.I)*dt + active.orientationV -- calculates the angular velocity (angular acceleration = toruque/moment of inertia)
			local thurst = 0 
			if active.fuelmass > 0 then -- burns if current fuel is positive
				if not engine:isPlaying() then engine:play() end
				thrust = (active.throttle/100)*active.engine.thrust
				local masschange = (active.engine.thrust/(9.81*active.engine.Isp))*(active.throttle/100)
				active.fuelmass = active.fuelmass-dt*masschange -- calculate the mass of the fuel after burn
			else -- dont burn
				engine:stop()
				thrust = 0
			end
			active.mass = active.drymass + active.fuelmass + active.rcsmass -- sum of mass
			active.v[1] = active.v[1] + (thrust/active.mass)*dt*math.cos(active.orientation) --calculates the change in velocity after burn
			active.v[2] = active.v[2] + (thrust/active.mass)*dt*math.sin(active.orientation)
			
			if node[active.name] ~= nil then
				node[active.name].dv1[1] = node[active.name].dv1[1] - (thrust/active.mass)*dt*math.cos(active.orientation) -- calculates the change in delta time in node
				node[active.name].dv1[2] = node[active.name].dv1[2] - (thrust/active.mass)*dt*math.sin(active.orientation)
			end
			
			-- not sure
			-- active.orientation = active.orientation+ 0.5*(active.torque/active.I)*dt^2 + active.orientationV*dt

			-- staging 
			if love.keyboard.isDown("space") and active.stage ~= nil and table.getn(active.stage) > 1 then
				-- creates new object once it is staged
				body[active.stage[2].name] = deepcopy(active.stage[2]) 
				body[active.stage[2].name].parent = active.parent
				body[active.stage[2].name].orientation = active.orientation
				body[active.stage[2].name].p = active.p
				body[active.stage[2].name].v = active.v
				body[active.stage[2].name].type = "dynamic"
				body[active.stage[2].name].colour = active.colour
				body[active.stage[2].name].colourtemp = active.colour
				injection[active.stage[1].name.." junk"] = injection[active.name]
				node[active.stage[1].name.." junk"] = node[active.name]
				active.name = active.stage[1].name.." junk"
				active.colour = {180,180,180}
				active.colourtemp = {180,180,180}
				active.stage ={}
				active = body[stage[2].name]

			end
			computeOrbit(active.parent,active) -- turns cartesian r,v vectors into keplerian parameters
		else
			active.orientationV = 0 -- sets the angular velocity to 0 when warping 
			active.torque=0
		end
	end
end

function input(dt)
	keyboard(dt) -- inputs
	scroll() 
end