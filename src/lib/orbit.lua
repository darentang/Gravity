-- /bin/orbit.lua: this module contains all the nessesary mathematical algorithms that converts between cartesian vectors to keplerian parameters
function computeOrbit(parent,slave)
	-- turns cartesian parameters into kepler parameters
	prep(parent,slave) -- calculates: r(relative position), h(specific relative angular momentum), e(orbital eccentricity), n(direction of ascending node)
	argPeri(parent,slave) --calculates argument of periapsis (how tilted the orbit is)
	trueAnomaly(parent,slave) -- calculates true anomaly (angled measured from the periapsis to the r vector)
	inclination(parent,slave) -- calculates the inclination (either 0 or pi in a 2d plane)

	eccentricAnomaly(parent, slave) --calculates the eccentric anomaly (angled measured from the auxillary circle)

	meanAnomaly(parent,slave) -- calculates the mean anomaly (M = E -EsinE)
	semiMajor(parent,slave) -- calculates the semimajor axis
	slave.r = tru2r(slave,slave.tru) -- recalculates r (for checking purpose)
	slave.v = veloGuess(parent,slave) -- recalculates v (for checking )

end


function skipOrbit(parent,slave)
	-- calculates the escape orbit
	if slave.parent.parent ~= nil then
		local e = magnitude(slave.e)
		local a = slave.a
		local theta = 0
		local soi = parent.a*((parent.mass/parent.parent.mass)^(2/5)) -- radius of sphere of influence
		if a*(1-e^2)/(1-e) >= soi or e >= 1 then
			if e < 1 then
				theta = math.acos(( ((a*(1-e^2))/soi) - 1 )/e)  -- solution to solving the equation of a conic in polar coordinates to a circle of radius soi
			else
				theta = math.acos(( ((a*(e^2-1))/soi) - 1 )/e) 
			end
			local delt = math.abs(deltatime(slave,theta,slave.tru)) -- calculates the time til skip
			local r1 = {}
			local r2 = {}
			r1 = tru2r(slave,theta) -- position at skip
			r2 = tru2r(slave,-theta)
			local v1 = {}
			local v2 = {}
			v1 = veloGuess2(slave.parent,slave,theta) -- velocity at skip
			v2 = veloGuess2(slave.parent,slave,2*math.pi-theta)
			local q = {}
			q = updatePos(delt,slave.parent.parent,slave.parent,true) -- find the position fo the craft at escaoe

			-- creates the "skip" object at time of escape
			slave.skip = {}
			slave.skip.mass = slave.mass
			slave.skip.name = slave.name.."skip"
			slave.skip.tru1 = theta
			slave.skip.type = "skip"
			slave.skip.delt = delt
			slave.skip.parent = slave.parent.parent
			if slave.name == "nodeinject" then
				slave.skip.colour = {201,157,176}
				slave.skip.colourtemp = {201,157,176}
			else
				slave.skip.colour = {49,196,59}
				slave.skip.colourtemp = {49,196,59}
			end
			slave.skip.v = {v1[1]+q.v[1],v1[2]+q.v[2],0}	
			slave.skip.p = {q.p[1]+r1[1],q.p[2]+r1[2],0}
			slave.skip.soi = soi
			slave.skip.alpha = 0	
			computeOrbit(slave.skip.parent,slave.skip) -- finally resolve for keplerian coordinates
		else
			slave.skip = nil
		end
	end
end

function inject(o,target,delt)
	-- this function calculates the orbit when the spacecraft enters a body's sphere of influence
	-- not that while we know where the spacecraft is closest to the target, we do not know WHEN and HWERE it enteres the SOI
	-- this method is perhaps not the most efficient, but stepping through time from the time of closet approach to when it starts to enter the band is a good start
	-- this function steps through time 50 times in order to find the posittion and time of which the spaceship first enters the sphere of influence
	-- by finding this delta time, we are able to find its velocity
	-- thus, its orbit can be determined (roughly)
	if o ~= nil and target ~= nil then
		local q1,q2 = {},{}
		local e = magnitude(target.e)
		local a = target.a
		local r = target.a*((target.mass/target.parent.mass)^(2/5))
		for i = 0,50 do
			t = delt*(i/50)
			q1 = updatePos(t,o.parent,o,true)
			q2 = updatePos(t,target.parent,target,true)
			if magnitude(distance(q1.p,q2.p)) < r then
				break
			end
		end
		-- creates the new "injection" object
		injection[o.name] = q1
		injection[o.name].type = "inject"
		injection[o.name].name = o.name .."inject"
		injection[o.name].colour = {200,200,200}
		injection[o.name].colourtemp = {200,200,200}
		injection[o.name].v = {q1.v[1]-q2.v[1],q1.v[2]-q2.v[2],0}
		injection[o.name].parent = q2
		injection[o.name].tru1 = q1.tru
		-- finally resolve keplerian parameters
		computeOrbit(injection[o.name].parent,injection[o.name])
		-- look for escape (there will always be one)
		skipOrbit(injection[o.name].parent,injection[o.name])
		local ptime = deltatime(injection[o.name],0,injection[o.name].tru)
		-- draw the injection orbit
		if o.type == "node" then
			drawinject(injection[o.name],ptime,{222,199,158})
		else
			drawinject(injection[o.name],ptime,{255,132,0})
		end
	else
		-- or, it has no injection at all
		injection[o.name] = nil
	end
end


function drawinject(o,delt,colour)
	-- drawing the injection orbit is tricky, because as the spacecraft is moving relative to the target, the target is also moving relative to the parent
	-- so, this function steps through the time when the spacecraft enters the sphere of influence until it exits
	-- the two position coordinates are ended and then plotted as a line
	-- note that the "updatePos" function cannot be called too often, as this function requires iteration of the newton's method (see below)
	-- therefore, this function is only called 20 times
	if o.skip ~= nil then
		love.graphics.setColor(colour)
		delt = math.abs(delt)
		local pts = {}
		for x = 0,20 do 
			local t = o.skip.delt*(x/20)
			local q1 = updatePos(t,o.parent,o,true).r
			local q2 = updatePos(t,o.parent.parent,o.parent,true).p
			pts[x] = real2scale({q2[1]-q1[1],q2[2]-q1[2]})
			if x > 0 then
				love.graphics.line(pts[x-1][1],pts[x-1][2],pts[x][1],pts[x][2])
			end
		end
		love.graphics.setColor(255,255,255)
		local q1 = updatePos(delt,o.parent,o,true).r
		local q2 = updatePos(delt,o.parent.parent,o.parent,true).p
		local p = real2scale({q2[1]-q1[1],q2[2]-q1[2]})
		love.graphics.print("pe",p[1],p[2])
	end
end

function eccentricity(p,s,r)
	-- resovles the eccentricity of the orbit: a 3D vector
	local mu = G*(p.mass + s.mass)
	local v = magnitude(s.v)
	local r = magnitude(s.r)
	local e = {}
	e[1] = (1/mu) *( (v^2 - (mu/r))*s.r[1] - (innerProduct(s.r,s.v)*s.v[1]) )
	e[2] = (1/mu) *( (v^2 - (mu/r))*s.r[2] - (innerProduct(s.r,s.v)*s.v[2]) )
	e[3] = (1/mu) *( (v^2 - (mu/r))*s.r[3] - (innerProduct(s.r,s.v)*s.v[3]) )
	return e
end

function prep(parent,slave)
	-- stage 1 of process (resoolve h,e,n)
	local mu = G*(parent.mass + slave.mass)
	slave.r = distance(parent.p,slave.p)
	slave.h = crossProduct(slave.r,slave.v)
	slave.e = eccentricity(parent,slave,slave.r)
	slave.n = {-slave.h[2],slave.h[1],0}
	local c = innerProduct(slave.e,slave.r)/(magnitude(slave.e)*magnitude(slave.r))
		-- if slave.h[3] > 0 then
		-- 	if slave.tru == nil then
		-- 		slave.tru = math.acos(c)
		-- 	else
		-- 		if slave.tru < 0 or slave.tru > math.pi then
		-- 			slave.tru = 2*math.pi- math.acos(c)
		-- 		else
		-- 			slave.tru = math.acos(c)
		-- 		end
		-- 	end
		-- elseif slave.tru ~= nil then
		-- 	if slave.tru < 0 or slave.tru > math.pi then
		-- 		slave.tru = 2*math.pi- math.acos(c)
		-- 	else
		-- 		slave.tru = math.acos(c)
		-- 	end
		-- else 
		-- 	slave.tru = 2*math.pi- math.acos(c)
		-- end
end

function argPeri(parent,slave)
	-- resolves argument of periapsis. 2pi - theta if orbit is anticlockwise
	if slave.h[3] >= 0 then
		slave.w = math.atan2(slave.e[2],slave.e[1])
	else
		slave.w = 2*math.pi - math.atan2(slave.e[2],slave.e[1])
	end
end

function trueAnomaly(parent,slave)
	-- resolve for true anomaly
	if slave.h[3] > 0 then
		slave.tru = math.atan2(slave.r[2],slave.r[1]) - slave.w
	else
		slave.tru = 2*math.pi-(math.atan2(slave.r[2],slave.r[1]) + slave.w)
	end
end

function inclination(parent,slave)
	-- resolve inclination
	slave.i = math.acos(slave.h[3]/magnitude(slave.h))
end

function eccentricAnomaly(parent,slave)
	-- resolve eccentric anomaly
	local e = magnitude(slave.e)
	if e <= 1 then
		slave.E = 2*math.atan2(math.tan(slave.tru/2),math.sqrt((1+e)/(1-e)))
	else
		slave.E = math.arccosh((e+math.cos(slave.tru))/(1 + e*math.cos(slave.tru)))
		if math.sin(slave.tru) < 0 then
			slave.E = -slave.E
		end
	end
end

function argPeri(parent,slave)
	-- resolve for argument of periapsis
	if slave.h[3] >= 0 then
		slave.w = math.atan2(slave.e[2],slave.e[1])
	else
		slave.w = 2*math.pi - math.atan2(slave.e[2],slave.e[1])
	end
end

function meanAnomaly(parent,slave) 
	-- resolve for mean anomaly
	if magnitude(slave.e) <= 1 then 
		slave.M = slave.E - magnitude(slave.e)*math.sin(slave.E) 
	else
		slave.M = magnitude(slave.e)*math.sinh(slave.E) - slave.E
	end
end

function semiMajor(parent,slave)
	-- semi major axis is determined here
	-- note that while the semimajor axis of a hyperbola should be negative, it is positive in this simulation (because i messed up)
	local mu = G*(parent.mass + slave.mass)
	local e = magnitude(slave.e)
	-- slave.a = 1/( (2/magnitude(slave.r)) - (magnitude(slave.v)^2)/mu )
	if e < 1 then
		slave.a  = (slave.h[3]^2)/(mu*(1-e^2))
	elseif e >= 1 then
		slave.a  = (slave.h[3]^2)/(mu*(e^2-1))
	end
end

function control (parent,slave,dt)
	-- this function updates the position of the spacecraft through time
	-- this spacecraft also account for any injection, escape and collision
	local parent = slave.parent 
	-- orbit is skipped when it reaches the edge of the soi
	if slave.skip ~= nil then
		if magnitude(slave.r) > slave.skip.soi then
			node[slave.name]= nil
			slave.parent = slave.skip.parent
			slave.v = slave.skip.v
			slave.p = slave.skip.p
			computeOrbit(slave.parent,slave)
			slave = updatePos(dt,parent,slave)
			print("skipped",slave.p[1],slave.p[2],slave.skip.p[1],slave.skip.p[2])
			slave.skip = nil
		end
	end
	-- orbit is injected if it enters the soi
	for i,v in pairs(body) do
		if v.class == "planet" and v~= slave and v.mass > slave.mass then
			if v.type == "dynamic" and magnitude(distance(slave.p,v.p)) <= v.soi and v.parent == slave.parent then
				local p = slave
				slave.parent = v
				if injection[slave.name] ~= nil then
					slave.v = injection[slave.name].v
					slave.p = injection[slave.name].p
				else
					slave.v = {slave.v[1]-v.v[1],slave.v[2]-v.v[2],0}
				end
				computeOrbit(slave.parent,slave)
				slave = updatePos(dt,slave.parent,slave)
				slave.target = nil
				slave.encounter = false
				injection[slave.name]=nil
			end
			if v == slave.parent and magnitude(slave.r) <= v.radius and slave == active then
				-- you are daed if you reach this point
				level = 0
				complete = nil
				menu:load(-1)
			end
		end
	end
	slave = updatePos(dt,parent,slave)
end


function updatePos(dt,parent,slave,copy)
	-- this function returns the cartesian coordinates (r,v) according to the keplerian parameters it is given (a,e,h,M,w)
	-- this function also determines the position of the spacecraft "dt" seconds ahead of time
	local q = {}
	if copy == true then
		q = deepcopy(slave)
	else
		q = slave
	end
	q.M  = updateMean(dt,parent,q)
	q.E = reverseKepler(parent,q)
	q.tru = updateTru(parent,q)
	q.p = pos(parent,q,dt)
	q.r = distance(q.p,parent.p)
	q.v = veloGuess(parent,q)
	return q
end

function updateMean(dt,parent,slave)
	-- determines the mean anomaly dt seconds ahead of time
	local mu = G*(parent.mass+slave.mass)
	local n = math.sqrt(math.abs(mu/(slave.a^3)))
	return (slave.M + n*dt)
end


function reverseKepler(parent,slave)
	-- this function returns the eccentric anomaly given a mean anomaly
	-- as the equation M = E - esinE does not have a close solution, an estimation is needed
	-- this function estimates the eccentric anomaly (E) using newton's method
	local E = slave.M
	index = 0
	if magnitude(slave.e) <= 1 then
		while math.abs(E - magnitude(slave.e)*math.sin(E) - slave.M) > 1E-8	 do -- elliptical
			E = slave.M + magnitude(slave.e)*math.sin(E)
			index = index + 1
		end
	else
		while math.abs(slave.M - magnitude(slave.e)*math.sinh(E) + E) > 1E-6 do
			E = E + (slave.M-magnitude(slave.e)*math.sinh(E)+E)/(magnitude(slave.e)*math.cosh(E)-1) --hyperbollic
			index = index + 1
		end
	end
	return E
end

function updateTru(parent,slave)
	-- this function resolves the true anomaly
	local e = magnitude(slave.e)
	local tru = 0 
	if e < 1 then
		tru = 2*math.atan2(math.sqrt(1+e)*math.sin(slave.E/2),math.sqrt(1-e)*math.cos(slave.E/2))
	else
		tru = 2*math.atan(math.sqrt((e+1)/(e-1))*math.tanh(slave.E/2))
	end
	return tru
end

function pos(parent,slave,dt)
	-- position is then found using the conic polar equation
	local e = magnitude(slave.e)
	estimatev = {}
	newp = {}
	local d = 0
	if e < 1 then
		d = (slave.a*(1-e^2))/(1+e*math.cos(slave.tru))
	else
		d = (slave.a*(e^2-1))/(1+e*math.cos(slave.tru))
	end
	newp[1] = parent.p[1] + d*math.cos(slave.tru+slave.w)
	if slave.h[3] > 0 then
		newp[2] = parent.p[2] + d*math.sin(slave.tru+slave.w)
	else
		newp[2] = parent.p[2] - d*math.sin(slave.tru+slave.w)
	end
	return({newp[1],newp[2],0})
end

function veloGuess(parent,slave)
	-- velocity is then "guessed" (not actually guessed) through the equation sqrt(mu/p)*(-sin(theta)) and sqrt(mu/p)*(e+cos(theta))
	-- it returns the velocity vector along with its argument (arg)
	local mu = (slave.mass+parent.mass)*G
	local a = slave.a
	local r = magnitude(slave.r)
	local e = magnitude(slave.e)
	local p = math.abs(a*(1-e^2))

	local P = math.sqrt(mu/p)*(-math.sin(slave.tru))
	local Q = math.sqrt(mu/p)*(e+math.cos(slave.tru))
	local v = magnitude({P,Q,0})
	local q = {}

	if slave.h[3] >0 then
		q.arg = math.atan2(Q,P) + slave.w
	else
		q.arg = -math.atan2(Q,P) - slave.w
	end
	q[1] = v*math.cos(q.arg)
	q[2] = v*math.sin(q.arg)
	q[3] = 0
	return q
end

function veloGuess2(parent,slave,tru)
	-- same thing as above, except a tru anomaly is given
	local mu = (slave.mass+parent.mass)*G
	local a = slave.a
	local r = magnitude(slave.r)
	local e = magnitude(slave.e)
	local p = math.abs(a*(1-e^2))

	local P = math.sqrt(mu/p)*(-math.sin(tru))
	local Q = math.sqrt(mu/p)*(e+math.cos(tru))
	local v = magnitude({P,Q,0})
	local q = {}

	if slave.h[3] >0 then
		q.arg = math.atan2(Q,P) + slave.w
	else
		q.arg = -math.atan2(Q,P) - slave.w
	end
	q[1] = v*math.cos(q.arg)
	q[2] = v*math.sin(q.arg)
	q[3] = 0
	return q
end

function deltatime(o,tru,tru0)
	-- calculates the time taken to travel from one true anomaly to another
	local e = magnitude(o.e)
	local mu = (o.mass + o.parent.mass)*G
	local E,E0,M,M0 = 0,0,0,0
	local n =math.sqrt(math.abs(mu/o.a^3))
	if o.h[3]< 0 then
		tru = 2*math.pi - tru
		tru0 = 2*math.pi - tru0
	end
	if e < 1 then
		E = 2*math.atan2(math.tan(tru/2),math.sqrt((1+e)/(1-e)))
		E0 = 2*math.atan2(math.tan(tru0/2),math.sqrt((1+e)/(1-e)))
		M = E - e*math.sin(E)
		M0 = E0 - e*math.sin(E0)
	else 
		E = math.arccosh((e+math.cos(tru))/(1 + e*math.cos(tru)))
		E0 = math.arccosh((e+math.cos(tru0))/(1 + e*math.cos(tru0)))
		if math.sin(tru) < 0 then E = -E end
		if math.sin(tru0) < 0 then E0 = -E0 end
		M = e*math.sinh(E) - E
		M0 = e*math.sinh(E0) - E0
	end
	return (M-M0)/n
end

function drawpath(parent,slave)
	-- this functino simply draws the path of the orbit 
	local d,d1,d2,y1 = 0,0,0,0
	local tru = 0
	love.graphics.setColor(slave.colour)
	local e = magnitude(slave.e)
	pts = {}

	-- a set of limits are sometimes needed to draw truncated orbits. These are defined below
	if e < 1 then
		if slave.skip ~= nil then
			low,high =  math.floor(rad2d(slave.tru)*10)/10,math.floor(rad2d(slave.skip.tru1)*10)/10
			interval = 0.1
		elseif slave.encounter == true then
			low,high =  math.floor(rad2d(slave.tru)*10)/10,math.floor(rad2d(injection[slave.name].tru1)*10)/10
			interval = 0.1
		else
			low,high = 0,360
			interval = 0.5
		end
	else
		limit  = (180/math.pi)*2*math.atan(math.sqrt( (e+1)/(e-1) ))

		if slave.skip ~= nil then
			if slave.type == "inject" then
				low,high = -math.floor(rad2d(slave.skip.tru1)*10)/10,math.floor(rad2d(slave.skip.tru1)*10)/10
			else
				low,high = math.floor(rad2d(slave.tru)*10)/10,math.floor(rad2d(slave.skip.tru1)*10)/10
			end
			local p = real2scale(slave.skip.p)
			-- love.graphics.circle("fill",p[1],p[2],5)
		elseif slave.encounter == true then
			low,high =  math.floor(rad2d(slave.tru)*10)/10,math.floor(rad2d(injection[slave.name].tru1)*10)/10
		else
			low,high = math.floor(rad2d(slave.tru)*10)/10,math.floor(limit*10)/10-1
		end
		interval = 0.1
	end

	-- high and low swaps if condition is not valid
	if low > high then
		local t = low
		low = high
		high = low
	end

	-- draws the orbit by cycling through 0 to 360 degrees with a set interval
	-- the distance is determined in that angle and then drawn as a line
	for x = low,high,interval do
		local theta = d2rad(x)
		d1 =real2scale(r2p(tru2r(slave,theta),slave,parent))
		d2 =real2scale(r2p(tru2r(slave,theta+d2rad(interval)),slave,parent))
		love.graphics.line(d1[1],d1[2],d2[1],d2[2])
	end
	love.graphics.setColor(255,255,255)
	d2 = real2scale(r2p(tru2r(slave,0),slave,parent))

	-- draws the apoapsis and periapsis 
	if (offX-d2[1])^2 + (offY-d2[2])^2 <= 25 then
		love.graphics.print("pe",d2[1],d2[2])
		local d = conicDistance(slave,0)
		local delt = deltatime(slave,0,slave.tru)
		love.graphics.print(slave.parent.name.." periapsis\n"..round((d/1000),2).." km\n"..tomin(delt),d2[1]+20,d2[2]+20)
	else
		love.graphics.print("pe",d2[1],d2[2])
	end

	if e < 1  and high > 180 then
		d2 = real2scale(r2p(tru2r(slave,math.pi),slave,parent))
		if (offX-d2[1])^2 + (offY-d2[2])^2 <= 100 then
			love.graphics.print("ap",d2[1],d2[2])
			local d = conicDistance(slave,math.pi)
			local delt = deltatime(slave,math.pi,slave.tru)
			love.graphics.print(slave.parent.name.." apoapsis\n"..round((d/1000),2).." km\n"..tomin(delt),d2[1]+20,d2[2]+20)
		else
			love.graphics.print("ap",d2[1],d2[2])
		end
	end
end

function drawship(parent,slave)
	-- simply draws the ship in its current position 
	love.graphics.setColor(255,255,255,70)
	if slave.class == "ship"  then
		love.graphics.circle("fill",origin[1] + slave.p[1]*SCALE,origin[2] - slave.p[2]*SCALE,5)
	end
	if slave.class == 'planet' then
		if slave.radius*SCALE < 5 then
			love.graphics.circle("fill",real2scale(slave.p)[1],real2scale(slave.p)[2],5)
		end
	end
	love.graphics.setColor(255,255,255)
end

function encounter(o,p)
	-- calculates the encounter orbit 
	-- this function cycles from 0 to 360 degrees with 0.2 degrees interval
	-- this function only calculates the closest encounter of the ORBITS not the SHIPS
	-- however, this is considered "good enough", as the closest encounter that matters happens near the overlapping 
	-- cycling 1800 cycles of newtons method would not be feasible, as this will greatly decrease the performance of the game (i tried that)
	-- also, one must also determine the position of the ship when it enters the SOI
	-- this function does not do this. instead, it calculates the time when it enters the SOI "band": a band with thickness 2*SOI around the orbit
	-- the time which it encounters "delt1", is then passed to the injection function to estimate the time at arrival at SOI
	local initial = mouseProximity(real2scale(o.p)[1],real2scale(o.p)[2],p)
	local min = math.abs(initial)
	local mintru1 = "a" -- arbitary value to check if the value is ever called
	local mintru2 = 0
	local enctru1 = "a"
	local enctru2 = 0
	local mintru = 0
	local dis = {}
	local soi = p.a*((p.mass/p.parent.mass)^(2/5))
	-- starting cycle
	for x = 0,1800 do
		local d1 = conicDistance(o,x*(math.pi/180)/5)
		local r = tru2r2(o,d1,x*(math.pi/180)/5)
		local q = r2p(r,o,o.parent)
		local displacement,tru,r = mouseProximity(real2scale(q)[1],real2scale(q)[2],p)
		dis[x] = displacement
		if x > 0 then
			if dis[x-1]*dis[x] < 0 then -- when the distance changes sign (indicates a 0 lies between the intervals)
				if mintru1 == "a" then 
					mintru1 = x*(math.pi/180)/5
				else
					mintru2 = x*(math.pi/180)/5
				end
			end
			if (math.abs(dis[x-1])-soi)*(math.abs(dis[x])-soi) < 0  then -- when it encounters the SOI "band"
				if enctru1 == "a" then
					enctru1 = x*(math.pi/180)/5
				else
					enctru2 = x*(math.pi/180)/5
				end
			end
		end
		if math.abs(dis[x]) < min then
			min = math.abs(dis[x])
			mintru = x*(math.pi/180)/5
		end
	end
	local delt = deltatime(o,mintru,o.tru)
	local d1 = updatePos(delt,p.parent,p,true)
	local d2 = updatePos(delt,o.parent,o,true)
	if mintru1 ~= "a" then
		-- finds which point of encounter is the closest 
		local deltt = deltatime(o,mintru1,o.tru)
		local k1 = updatePos(deltt,p.parent,p,true)
		local k2 = updatePos(deltt,o.parent,o,true) 
		local deltt1 = deltatime(o,mintru2,o.tru)
		local k3 = updatePos(deltt1,p.parent,p,true)
		local k4 = updatePos(deltt1,o.parent,o,true)
		if magnitude(distance(k1.r,k2.r)) < magnitude(distance(k3.r,k4.r)) then
			mintru = mintru2
			delt = deltt
			d1 = k1
			d2 = k2
		else
			mintru = mintru1
			delt = deltt1
			d1 = k3
			d2 = k4
		end
	end

	if magnitude(distance(d1.r,d2.r)) <= soi  and o.h[3]*p.h[3] > 0 then
		-- if it is found that it enters the SOI "band", an injection is calculated
		local delt1 = deltatime(o,enctru1,o.tru)
		local c3 = updatePos(delt1,p.parent,p,true)
		local c4 = updatePos(delt1,o.parent,o,true)
		inject(c4,c3,delt- delt1)
		o.encounter = true
	else
		o.encounter = false
		injection[o.name] = nil
	end

	return delt,d1,d2
end