-- /bin/interface.lua: GUI for the user
function display()
	for i,v in pairs(body) do
		if v.type == "dynamic" then 
			drawship(v.parent,v) -- draws the ship (a circle)
			skipOrbit(v.parent,v) -- predict if the orbit skips out of the sphere of influence
			if v.skip ~= nil then 
				drawpath(v.skip.parent,v.skip) -- draw the skip path if it does
				-- love.graphics.circle("line",origin[1] + body.moon.p[1]*SCALE,origin[2] - body.moon.p[2]*SCALE,body.moon.soi*SCALE)
			end
			drawpath(v.parent,v) -- draws the ship's orbit
		end
	end
	for i,v in pairs(body) do
		if v.class == "planet" then
			-- draws the picture of the planet 
			if v.name == "Earth" then
				love.graphics.draw(v.pic,origin[1] + v.p[1]*SCALE,origin[2] - v.p[2]*SCALE,v.orientation,2*(v.radius*SCALE)/2048,2*(v.radius*SCALE)/2048,v.pic:getWidth()/2,v.pic:getHeight()/2)
			else
				love.graphics.draw(v.pic,origin[1] + v.p[1]*SCALE,origin[2] - v.p[2]*SCALE,v.orientation,2*(v.radius*SCALE)/v.pic:getWidth(),2*(v.radius*SCALE)/v.pic:getHeight(),v.pic:getWidth()/2,v.pic:getHeight()/2)
			end
		end
	end
	-- reset colour
	love.graphics.setColor(255,255,255)
end

function interface()
	-- main interface
	for i,v in pairs(body) do
		hover(i,v) -- mouse hover ontop of the ship
		escape(i,v) -- escape of a planet's sphere of influence
	end
	if active ~= nil and active.class == "ship" then
		Mnode() -- maneuver node system
		if active.target ~= nil then
			forecast(active,active.target) -- forecasts close encounters with target
		end
	end

end

function findplot(o)
	local period = 2*math.pi*math.sqrt(o.a^3/(G*(o.mass+o.parent.mass))) -- period of the orbit (if elliptical)
	local d = updatePos(period,o.parent,o) -- find the position of the ship after one period
	local theta = (math.atan2(o.r[2],o.r[1]) - math.pi)+ o.parent.orientation - d2rad(50) -- calculates the angle between the ship and the earth
	local theta1 = (math.atan2(d.r[2],d.r[1]) - math.pi)+ o.parent.orientation - d2rad(50) + period*o.parent.orientationV -- same but after one period
	
	theta = normalise(theta) -- turns it into 0 < theta <= 2pi
	theta1 = normalise(theta1)
	return theta,theta1
end

function groundplot()
	love.graphics.setColor(255,255,255,70)
	love.graphics.draw(earthprojection,442,151,0,0.1665,0.1665) -- draws groundplot map
	love.graphics.setColor(255,255,255)
	theta,theta1 = findplot(active)
	if theta > theta1 then
		love.graphics.line(442.999+(theta/(2*math.pi))*341.3,237.165,442.999+341.3,237.165) 
		love.graphics.line(442.999,237.165,442.999+(theta1/(2*math.pi))*341.3,237.165)
	else
		love.graphics.line(442.999+(theta/(2*math.pi))*341.3,237.165,442.999+(theta1/(2*math.pi))*341.3,237.165)
	end
	love.graphics.setColor(255,0,0)
	love.graphics.circle("fill",442.999+(theta/(2*math.pi))*341.3,237.165,5) -- bubbles
	love.graphics.setColor(0,255,0)
	love.graphics.circle("fill",442.999+(theta1/(2*math.pi))*341.3,237.165,5)
	love.graphics.setColor(255,255,255)
	if (442.999+(theta/(2*math.pi))*341.3-mX)^2 + (mY-237.165)^2 < 25 then
		love.graphics.print("Current Position\nLat: "..round(rad2d(theta)-180,2),mX,mY+10) -- print lattitude if hovered
	end
	if (442.999+(theta1/(2*math.pi))*341.3-mX)^2 + (mY-237.165)^2 < 25 then
		love.graphics.print("Position After \n1 Period",mX,mY+10) -- same thing but after 1 period
	end
end

function drawwarp()
	-- draws the warp time and system time
	love.graphics.draw(corner,14,11)
	for x = 1,warp+1 do 
		love.graphics.draw(warparrow,30+(x-1)*16,49.3)
	end
	love.graphics.setColor(58,170,53)
	love.graphics.print("Warp: "..10^warp,30,33) 
	love.graphics.setColor(255,255,255)
	love.graphics.print("Time:"..tomin(time),30,14)
end

function drawcard()
	-- draws the tutorial cards
	if  levelSelect(level)~= nil and levelSelect(level).cards ~= nil then
		local l = levelSelect(level)
		love.graphics.draw(card,476,16)
		if l.current == 1 then
			love.graphics.draw(buttdisabled,490,90)
			buttonHoverClick({587,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover) 
		elseif l.current == #l.cards then
			love.graphics.draw(buttdisabled,587,90)
			buttonHoverClick({490,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover)
			if buttonHoverClick({684,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover) then
				menu:load(2)
				level = 0 
			end
			love.graphics.setColor(0,0,0)
			love.graphics.print("Back",696,95)
			love.graphics.setColor(255,255,255)
		else
			buttonHoverClick({587,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover)
			buttonHoverClick({490,90},buttactive:getWidth(),buttactive:getHeight(),buttactive,butthover,butthover)
		end
		love.graphics.setColor(0,0,0)
		love.graphics.print("Next",602,95)
		love.graphics.print("Prev",505,95)
		love.graphics.setColor(255,255,255)
		love.graphics.printf(l.cards[l.current],489,28,270)

	end
end

function drawwindow()
	-- draws the quit window
	love.graphics.setFont(typewriter)
	love.graphics.draw(window,400,300,0,1,1,window:getWidth()/2,window:getHeight()/2)
	if buttonHoverText({321,300},70,43,{255,255,255},{255,162,0},{255,255,255},"YES") then
		level = 0 -- resets
		complete = nil
		menu:load()
	end 
	if buttonHoverText({425,300},50,43,{255,255,255},{255,162,0},{255,255,255},"NO") then
		toggle.menu = false 
	end 
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(defaultFont)
end


function nav()
	-- this function draws the instrument panel of the ship
	if active ~= nil then
		love.graphics.draw(throttle,209.6,366.6,0,0.5,0.5) -- draws throttle
		love.graphics.draw(compass,397.66,464.16,-active.orientation,0.5,0.5,compass:getWidth()/2,compass:getHeight()/2) -- draws compass
		love.graphics.draw(cneedle,385.389,404.329) -- draws needle 
		love.graphics.draw(tneedle,238.5,(544.333-(171.014*(active.throttle/100)))) -- draws throttle needle

		-- drawing directional nodes
		local p = rotatePt({397.66,464.16},89.55,-active.v.arg+active.orientation+math.pi/2)
		love.graphics.draw(prograde,p[1],p[2],0,0.7,0.7,prograde:getWidth()/2,prograde:getHeight()/2)
		local p = rotatePt({397.66,464.16},89.55,-active.v.arg+active.orientation+2*math.pi/2)
		love.graphics.draw(antiradial,p[1],p[2],0,0.7,0.7,antiradial:getWidth()/2,antiradial:getHeight()/2)
		local p = rotatePt({397.66,464.16},89.55,-active.v.arg+active.orientation+3*math.pi/2)
		love.graphics.draw(retrograde,p[1],p[2],0,0.7,0.7,retrograde:getWidth()/2,retrograde:getHeight()/2)
		local p = rotatePt({397.66,464.16},89.55,-active.v.arg+active.orientation+4*math.pi/2)
		love.graphics.draw(radial,p[1],p[2],0,0.7,0.7,radial:getWidth()/2,radial:getHeight()/2)

		--draws node direction if avaliable
		if node[active.name]~= nil and node[active.name].active then
			local p = rotatePt({397.66,464.16},89.55,-node[active.name].dv1.arg+active.orientation+math.pi/2)
			local delt = tomin(deltatime(active,node[active.name].atru,active.tru))
			local modV = round(magnitude({node[active.name].dv1[1],node[active.name].dv1[2],0}),2)
			love.graphics.draw(nodep,p[1],p[2],0,0.7,0.7,nodep:getWidth()/2,nodep:getHeight()/2)
			love.graphics.print("Time Till Node: "..delt.."\nDelta V: "..modV.."\nEST burn time: "..tomin(burntime(active,modV)),517,492)
		end
		
		-- draws sas and rcs light
		if active.sas then
			love.graphics.draw(sason,518,360.873)
		else
			love.graphics.draw(sasoff,518,360.873)
		end
		if active.rcs then
			love.graphics.draw(rcson,518,420.561)
		else
			love.graphics.draw(rcsoff,518,420.561)
		end

		-- draws fuel gauges
		love.graphics.setColor(0,159,227)
		love.graphics.rectangle("fill",86.417,418.42+58.6*(1-active.fuelmass/active.tank.mass),81.713,58.6*(active.fuelmass/active.tank.mass))
		love.graphics.setColor(249,148,51)
		love.graphics.rectangle("fill",86.417,482.128+35.778*(1-active.fuelmass/active.tank.mass),81.713,35.778*(active.fuelmass/active.tank.mass))
		love.graphics.setColor(149,193,31)
		love.graphics.rectangle("fill",108,381+27.137*(1-active.rcsmass/active.rcstank.mass),37,27.137*(active.rcsmass/active.rcstank.mass))
		love.graphics.setColor(255,255,255)
		love.graphics.draw(ship,28,372.585,0,0.5,0.5)
		love.graphics.print(round(active.fuelmass/active.tank.mass*100,2).."%",91.66,437.69)
		love.graphics.print(round(active.fuelmass/active.tank.mass*100,2).."%",91.66,492.786)
		love.graphics.print(round(active.rcsmass/active.rcstank.mass*100,2).."%",118.291,387.235)


		-- hover information with fuel gauges
		if hoverShip({86.417,418.42},82,59) then
			love.graphics.print("Capacity :"..round(active.tank.mass*active.tank.ratio,2).." kg\nCurrent Mass: "..round(active.fuelmass*active.tank.ratio,2).." kg",mX+10,mY+10)
		end

		if hoverShip({86.417,482.128},82,36) then
			love.graphics.print("Capacity :"..round(active.tank.mass*(1-active.tank.ratio),2).." kg\nCurrent Mass: "..round(active.fuelmass*(1-active.tank.ratio),2).." kg",mX+10,mY+10)
		end

		if hoverShip({108,381},37,27) then
			love.graphics.print("Capacity :"..round(active.rcstank.mass,2).." kg\nCurrent Mass: "..round(active.rcsmass,2).." kg",mX+10,mY+10)
		end

		if hoverShip({103,520},48,35) then
			love.graphics.print("Name: "..active.engine.name.."\nSpecific Impulse:"..active.engine.Isp.." s\nThrust: "..round(active.engine.thrust/1000,2).." kN\n Current Thrust: "..round((active.engine.thrust*active.throttle)/1000,2).." kN",mX+10,mY+10)
		end

		-- draws staging 
		if active.stage ~= nil then
			love.graphics.draw(stageactive,677.296,532.791)
			love.graphics.print(active.stage[1].name,711,537.4)
			love.graphics.draw(stageoff,677.296,498.591)
			love.graphics.print(active.stage[2].name,711,503.197)
		else
			love.graphics.draw(stageactive,677.296,532.791)
			love.graphics.print(active.name,711,537.4)
		end

		-- draws objective cards
		if levelObjectives(level,active) ~= nil then
			local goal = levelObjectives(level,active)
			
			for x = 1,#goal do
				if goal[x].complete then
					if x == #goal and complete == nil then
						complete = true
					end
					love.graphics.draw(goalon,578.416,15.917+(x-1)*31)
				else
					love.graphics.draw(goaloff,578.416,15.917+(x-1)*31)
				end
				love.graphics.print(goal[x].text,587,21.623+(x-1)*31)
			end
			-- check if they are all completed
			if complete == true then
				love.graphics.draw(goalon,578.416,15.917+(#goal)*31)
				love.graphics.print("Complete!",587,21.623+(#goal)*31)
			end
		end
		-- draw the groundplot
		if toggle.groundplot and active.parent == body.earth and magnitude(active.e)<1 then
			groundplot()
		end
		--rcs thrusters rendering 
		if active.rcs then
			local maxTorque = active.rcsengine.thrust*(active.radius*2)
			local amount = math.abs(active.rcsTorque/maxTorque)
			if active.rcsTorque > 0 then
				love.graphics.draw(rcsthrust,176,460,0,1,amount,rcsthrust:getWidth()/2,rcsthrust:getHeight())
				love.graphics.draw(rcsthrust,78,480,math.pi,1,amount,rcsthrust:getWidth()/2,rcsthrust:getHeight())	
			else 
				love.graphics.draw(rcsthrust,78,460,0,1,amount,rcsthrust:getWidth()/2,rcsthrust:getHeight())
				love.graphics.draw(rcsthrust,176,480,math.pi,1,amount,rcsthrust:getWidth()/2,rcsthrust:getHeight())
			end
		end
	end
	drawwarp()
	drawcard()
end	

function hoverShip(corner,width,height)
	-- check if the mouse is on top of a specific rectangle
	if math.abs(mX-(corner[1]+width/2)) < width/2 and math.abs(mY-(corner[2]+height/2)) < height/2 then
		return true
	else
		return false
	end
end

function forecast(o,target)
	-- This function forecasts into one orbital period in looking for the closest approach 
	target.colour = {0,222,15}
	local delt,d1,d2 = encounter(o,target) -- returns closest encounter state
	if o.type == "node" then
		love.graphics.setColor(0,255,0)
	end
	-- draws pointers
	love.graphics.draw(close,real2scale(d1.p)[1],real2scale(d1.p)[2],0,0.2,0.2,close:getWidth()/2,close:getHeight())
	if (offX-real2scale(d1.p)[1])^2 + (offY-real2scale(d1.p)[2])^2 < 25 then
		love.graphics.print(round(magnitude(distance(d1.p,d2.p))/1000,2).."km\n"..d1.name,offX+10,offY+10)
	end
	love.graphics.draw(close,real2scale(d2.p)[1],real2scale(d2.p)[2],math.pi,0.2,0.2,close:getWidth()/2,close:getHeight())
	if (offX-real2scale(d2.p)[1])^2 + (offY-real2scale(d2.p)[2])^2 < 25 then
		love.graphics.print(round(magnitude(distance(d1.p,d2.p))/1000,2).."km\n"..d2.name,offX+10,offY+10)
	end
	love.graphics.setColor(255,255,255)
	local soi = target.a*((target.mass/target.parent.mass)^(2/5)) -- radius of sphere of influence
	-- love.graphics.circle("fill",real2scale(d1.p)[1],real2scale(d1.p)[2],3)
	-- love.graphics.circle("fill",real2scale(d2.p)[1],real2scale(d2.p)[2],3)
	if injection[o.name] ~= nil then
		--draws the predicted injection path
		drawpath(injection[o.name].parent,injection[o.name])
		local p1 = real2scale(injection[o.name].p)
		local p2 = real2scale(injection[o.name].skip.p)
		local delt0 = deltatime(o,o.tru,injection[o.name].tru1)
		local delt = tomin(delt0)
		local delt1 = tomin(delt0 + deltatime(injection[o.name].skip,-injection[o.name].skip.tru,injection[o.name].skip.tru))
		love.graphics.setColor(214,214,214,90)
		if (offX-p1[1])^2 + (offY-p1[2])^2  <= 25 then
			love.graphics.setColor(214,214,214)
			love.graphics.print(target.name.." insertion\n"..delt ,p1[1]+20,p1[2]+20)
		end
		love.graphics.circle("fill",p1[1],p1[2],5)
		love.graphics.setColor(214,214,214,90)
		if injection[o.name].skip ~= nil then
			local p2 = real2scale(injection[o.name].skip.p) -- draws the predicted skip path
			if (offX-p2[1])^2 + (offY-p2[2])^2  <= 25 then
				love.graphics.setColor(214,214,214)
				love.graphics.print(target.name.." escape\n"..delt1 ,p2[1]+20,p2[2]+20) 
			end
			love.graphics.circle("fill",p2[1],p2[2],5)
			love.graphics.setColor(255,255,255)
			drawpath(injection[o.name].skip.parent,injection[o.name].skip)
		end
		love.graphics.setColor(255,255,255)
	end
end

function hover(i,v)
	-- ship display colour
	local p1,p2
	p1,p2 = origin[1] + v.p[1]*SCALE,origin[2] - v.p[2]*SCALE
	if v.type == "dynamic" then
		if (mrX-p1)^2 + (mrY-p2)^2 <= 100 then
			if v.alpha < 100 then 
				v.alpha = v.alpha + 5 
			end
			love.graphics.setColor(0,219,121,v.alpha)
			love.graphics.circle( "fill", origin[1] + v.p[1]*SCALE,origin[2] - v.p[2]*SCALE,10)
			love.graphics.setColor(255,255,255)
			love.graphics.print(v.name.."\n Semi Major:".. round(v.a/1000,2).."km", origin[1] + v.p[1]*SCALE+10,origin[2] - v.p[2]*SCALE-10) -- prints orbital information
		else
			v.alpha = 0
		end
		if v.toggle then
			love.graphics.setColor(247,101,72,100)
			love.graphics.circle( "fill", origin[1] + v.p[1]*SCALE,origin[2] - v.p[2]*SCALE,10)
			love.graphics.setColor(255,255,255)
		end
	end
end

function escape(i,v)
	--draws the escape path
	if v.skip ~= nil then
		local theta = v.skip.tru1
		local r = tru2r(v,theta)
		local p1 = {origin[1] + (v.parent.p[1]+r[1])*SCALE,origin[2] - (v.parent.p[2]+r[2])*SCALE} -- finds the two point of escape and insertion
		local p2 = {origin[1] + v.skip.p[1]*SCALE,origin[2] - v.skip.p[2]*SCALE}
		local delt = tomin(deltatime(v,v.skip.tru1,v.tru))
		love.graphics.setColor(214,214,214,90)
		-- draws the two bubbles
		if (offX-p1[1])^2 + (offY-p1[2])^2  <= 25 then
			love.graphics.setColor(214,214,214)
			love.graphics.print(v.parent.name.." escape\n"..delt ,p1[1]+20,p1[2]+20)
		end
		love.graphics.circle("fill",p1[1],p1[2],5)
		love.graphics.setColor(214,214,214,90)
		if (offX-p2[1])^2 + (offY-p2[2])^2  <= 25 then
			love.graphics.setColor(214,214,214)
			love.graphics.print(v.parent.parent.name.." insertion\n"..delt,p2[1]+20,p2[2]+20)
		end
		love.graphics.circle("fill",p2[1],p2[2],5)
		love.graphics.setColor(255,255,255)
	end
end


function mouseProximity(x,y,o)
	-- this function returns the magnitude distance between a point and the given orbit
	local e = magnitude(o.e)
	local d1,d2 = 0,0
	local r = {(x-origin[1])/SCALE,-(y-origin[2])/SCALE,0}
	local d2 = distance(active.parent.p,r)
	if o.h[3] < 0 then
		d2[2] = -d2[2] 
	end
	local tru = math.atan2(d2[2],d2[1])
	d1 = conicDistance(o,tru-o.w)
	return magnitude(d2)-d1,tru,d1
end
function computeNode(o)
	-- this function calculates and creates the node
	local distance,tru,d1 = mouseProximity(offX,offY,o)
	distance = math.abs(distance)
	if distance < 30E4/s then
		love.graphics.setColor(255,255,255,70)
		local delt = deltatime(o,tru - o.w,o.tru) --calculated time til the manevour event
		local vel = veloGuess2(o.parent,o,tru-o.w)
		local x1 = origin[1] + (active.parent.p[1] + d1*math.cos(tru))*SCALE
		local y1 = origin[2] - (active.parent.p[2] + d1*math.sin(tru))*SCALE
		if o.h[3] < 0 then
			y1 = origin[2] - (active.parent.p[2] - d1*math.sin(tru))*SCALE
		end
		love.graphics.circle("fill",x1,y1,7)
		love.graphics.setColor(255,255,255)
		if mouse.l then
			drag.active = false
			love.graphics.print(tomin(delt).."\n".."Vel: "..round(magnitude(vel),2).." ms-1",10+x1,10+y1)
		end
		if mouse.ld then
			-- creates a new manevour node object
			node[o.name] = {}
			node[o.name].parent = o.parent
			node[o.name].a = o.a
			node[o.name].h = o.h
			node[o.name].e = o.e
			node[o.name].w = o.w
			node[o.name].mass = o.mass
			node[o.name].name = "node"
			node[o.name].type = "node"
			node[o.name].colour = {255,196,0}
			node[o.name].colourtemp = {255,255,255}
			node[o.name].tru = tru - o.w 
			node[o.name].atru = node[o.name].tru
			node[o.name].r = tru2r(node[o.name])
			node[o.name].p = r2p(node[o.name].r,node[o.name],node[o.name].parent)
			node[o.name].v0 = veloGuess2(active.parent,o,node[o.name].tru)
			node[o.name].v = node[o.name].v0
			node[o.name].dv = {0,0,arg = 0}
			node[o.name].dv1 = {0,0,arg = 0}
			node[o.name].active = true
		end
	end
end

function drawnode()
	-- this function draws the node and allows interaction with the node
	local bx,by = real2scale(node[active.name].p)[1],real2scale(node[active.name].p)[2]
	love.graphics.setColor(255,255,255,90)
	love.graphics.draw(ring,bx,by,0,1.25,1.25,ring:getWidth()/2,ring:getHeight()/2)
	local r1 = 10
	local r2 = {}
	local ns = {}
	local bright = {}
	local scale = {}
	local amount = 0
	for x = 0,3 do
		ns[x] = 0.5
		bright[x] = {255,255,255}
		scale[x] = 1.25
		r2[x] = 40
	end
	for x = 0,3 do
		-- cycles through 0,pi/2,pi,and 3pi/2
		local theta = 0
		love.graphics.setColor(255,255,255,90)
		theta = node[active.name].v.arg + (math.pi/2)*x
		local q,p = bx+r2[x]*math.cos(theta),by-r2[x]*math.sin(theta)
		if math.abs(mouse.downl[1] - q) < 10 and math.abs(mouse.downl[2] - p) < 10 and drag.node == false  then
			-- calculates for the change in velocity desired by the user
			drag.active = false
			ns[x] = 0.8
			bright[x] = {234,255,240}
			love.graphics.setColor(255,255,255)
			-- local l = distance({q,p,0},{offX,offY,0})
			local l = distance({mouse.downl[1],mouse.downl[2],0},{offX,offY,0})
			local arg = math.atan2(l[2],l[1]) + theta
			if math.abs(magnitude(l)) <= 100 then
				amount = magnitude(l)*math.cos(arg)
			end
			node[active.name].dv[1] = node[active.name].dv[1] + amount*math.cos((math.pi/2)*x)
			node[active.name].dv[2] = node[active.name].dv[2] + amount*math.sin((math.pi/2)*x)
			if magnitude({ node[active.name].v[1] + node[active.name].dv[1],node[active.name].v[2] + node[active.name].dv[2],0}) < 100 then
					amount = 0
			end
			-- node[active.name].v[1] = node[active.name].v[1]+  amount*math.cos(node[active.name].v.arg + x*(math.pi/2))
			-- node[active.name].v[2] = node[active.name].v[2]+  amount*math.sin(node[active.name].v.arg + x*(math.pi/2))
			scale[x] = 1.25 + (amount/40)
			r2[x] = 40 * (scale[x]/1.25)
			deltaV(node[active.name])
		elseif math.abs(offX - q) < 10 and math.abs(offY - p) < 10 then
			ns[x] = 0.8
			bright[x] = {234,255,240}
			love.graphics.setColor(255,255,255)
		end
		love.graphics.draw(branch,bx+r1*math.cos(theta),by-r1*math.sin(theta),(3*math.pi/2)-theta,1.25,scale[x],branch:getWidth()/2,0)
		if x == 0 then
			-- draws the 4 nodes
			love.graphics.setColor(bright[0])
			love.graphics.draw(prograde,bx+r2[0]*math.cos(theta),by-r2[0]*math.sin(theta),0,ns[0],ns[0],retrograde:getWidth()/2,retrograde:getHeight()/2)
			love.graphics.setColor(255,255,255)
		elseif x == 1 then
			love.graphics.setColor(bright[1])
			love.graphics.draw(radial,bx+r2[1]*math.cos(theta),by-r2[1]*math.sin(theta),0,ns[1],ns[1],radial:getWidth()/2,radial:getHeight()/2)
			love.graphics.setColor(255,255,255)
		elseif x == 2 then
			love.graphics.setColor(bright[2])
			love.graphics.draw(retrograde,bx+r2[2]*math.cos(theta),by-r2[2]*math.sin(theta),0,ns[2],ns[2],prograde:getWidth()/2,prograde:getHeight()/2)
			love.graphics.setColor(255,255,255)
		else
			love.graphics.setColor(bright[3])
			love.graphics.draw(antiradial,bx+r2[3]*math.cos(theta),by-r2[3]*math.sin(theta),0,ns[3],ns[3],antiradial:getWidth()/2,antiradial:getHeight()/2)
			love.graphics.setColor(255,255,255)
		end
		love.graphics.setColor(255,255,255)
	end
	if (offX-bx)^2+(offY-by)^2 <= 150 then
		-- deactivates the node
		if mouse.r then
			node[active.name].active = false
		end
		love.graphics.draw(ring,bx,by,0,1.25,1.25,ring:getWidth()/2,ring:getHeight()/2)
	end

	if drag.node  then
		-- dragging the node around and calculates the new orbit
		drag.active = false
		local r = {(currentX+mX-400-origin[1])/SCALE,-(currentY+mY-300-origin[2])/SCALE,0}
		local d2 = distance(active.parent.p,r)
		if active.h[3] < 0 then
			d2[2] = -d2[2] 
		end
		local tru = math.atan2(d2[2],d2[1])
		node[active.name].atru = tru - active.w
		node[active.name].v0 = veloGuess2(active.parent,active,node[active.name].atru)
		deltaV(node[active.name])
		node[active.name].r = tru2r(active,node[active.name].atru)
		node[active.name].p = r2p(node[active.name].r,node[active.name],node[active.name].parent)
	end
	computeOrbit(active.parent,node[active.name]) -- process the new velocity into keplerian coordinates
	skipOrbit(active.parent,node[active.name]) -- calculates skip orbits
	if active.target ~= nil then
		forecast(node[active.name],active.target) -- calculates encounters
	end
	if node[active.name].skip ~= nil then
		drawpath(node[active.name].skip.parent,node[active.name].skip) -- draws the skip and escaoe oath
		escape(0,node[active.name])
	end
end


function deltaV(o)
	-- this translates the local coordinates of velocity change into global coordinates
	local modV = magnitude({o.dv[1],o.dv[2],0})
	local arg = math.atan2(o.dv[2],o.dv[1]) + o.v0.arg
	local vx = o.v0[1] + modV*math.cos(arg)
	local vy = o.v0[2] + modV*math.sin(arg)
	o.dv1[1] = modV*math.cos(arg)
	o.dv1[2] = modV*math.sin(arg)
	o.dv1.arg = math.atan2(o.dv1[2],o.dv1[1])
	local theta = math.atan2(vy,vx)
	o.v = {vx,vy,0, arg = theta}
end
function Mnode()
	-- the entire manvoure node package
	computeNode(active,node)
	active.colourtemp = active.colour
	if node[active.name]~= nil and node[active.name].active ~= nil then
		if node[active.name].active then
			-- node[active.name].r = tru2r(active,node[active.name].atru)
			node[active.name].p = {node[active.name].r[1]+active.parent.p[1],node[active.name].r[2]+active.parent.p[2],0}
			-- love.graphics.circle("fill",origin[1] + (active.parent.p[1] +node[active.name].r[1] )*SCALE,origin[2] - (active.parent.p[2] + node[active.name].r[2])*SCALE,5)
			drawnode()
			drawpath(active.parent,node[active.name])
		else
			-- active.colour = active.colourtemp 
		end
	end
end



