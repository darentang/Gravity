-- /lib/objects.lua: this module stores the parameters for standard objects, and stores the parameters of objects to be loaded in each level

local function std()
	-- the std function contains standard object pacakges, such as standard earth, moon, kerbin, mun and minmus
	-- these standard models are created according to real world parameters
	standard = {}
	standard.earth = {}
	standard.earth = deepcopy(objects.planet.earth)
	standard.earth.type = "static"
	standard.earth.p = {0,0,0}
	standard.earth.v = {0,0,0}

	standard.kerbin = {}
	standard.kerbin = deepcopy(objects.planet.kerbin)
	standard.kerbin.type = "static"
	standard.kerbin.p = {0,0,0}
	standard.kerbin.v = {0,0,0}

	standard.moon = deepcopy(objects.planet.moon)
	standard.moon.type = "dynamic"
	standard.moon.parent = standard.earth
	standard.moon.colour = {0,255,255}
	standard.moon.colourtemp = {0,255,255}
	standard.moon.a = 384400E3
	standard.moon.e = {0.0554,0,0}
	standard.moon.h = {0,0,math.sqrt(standard.moon.a*(G*(standard.moon.mass+standard.earth.mass)*(1-magnitude(standard.moon.e)^2)))}
	standard.moon.w = (318.5)*(math.pi/180)
	standard.moon.M = 135.27*(math.pi/180)
	updatePos(0,standard.moon.parent,standard.moon)

	standard.mun = deepcopy(objects.planet.mun)
	standard.mun.type = "dynamic"
	standard.mun.parent = standard.earth
	standard.mun.colour = {0,255,255}
	standard.mun.colourtemp = {0,255,255}
	standard.mun.a = 12000000
	standard.mun.e = {0.01,0,0}
	standard.mun.h = {0,0,math.sqrt(standard.mun.a*(G*(standard.mun.mass+standard.kerbin.mass)*(1-magnitude(standard.mun.e)^2)))}
	standard.mun.w = 0
	standard.mun.M = 1.7
	updatePos(0,standard.mun.parent,standard.mun)

	standard.minmus = deepcopy(objects.planet.minmus)
	standard.minmus.type = "dynamic"
	standard.minmus.parent = standard.earth
	standard.minmus.colour = {0,255,255}
	standard.minmus.colourtemp = {0,255,255}
	standard.minmus.a = 47000000
	standard.minmus.e = {0.01,0,0}
	standard.minmus.h = {0,0,math.sqrt(standard.mun.a*(G*(standard.minmus.mass+standard.kerbin.mass)*(1-magnitude(standard.minmus.e)^2)))}
	standard.minmus.w = (38)*(math.pi/180)
	standard.minmus.M = 0.9
	updatePos(0,standard.minmus.parent,standard.minmus)



end

local function circularOrbit(o,p,a,M)
	-- loads keplerian parameters for a (near) circular orbit. An orbit of eccentricity exactly 0 will cause the program to spaz out
	local q = o
	q.type = "dynamic"
	q.parent = p
	q.colour = {0,191,255}
	q.colourtemp = {0,191,255}
	q.a = a
	q.e = {0.001,0,0}
	q.h = {0,0,math.sqrt(q.a*(G*(q.mass+p.mass)*(1-magnitude(q.e)^2)))}
	q.w = 0
	q.M = M
	updatePos(0,p,o)
	return q
end

local function obj()
	-- the obj function contains standard parts packages. These parts can be assembled to form a ship
	objects = {}

	objects.parts = {}

	objects.engine = {}

	objects.engine.LVT30 = {
		name = "LV-T30 'Reliant' Liquid Fuel Engine",
		thrust = 215E3,
		Isp = 300
	}
	objects.engine.aj10 = {
		name = "AJ10",
		thrust = 43.7E3,
		Isp = 319
	}

	objects.engine.j2 = {
		-- thrust = 1033.1E3,
		name = "J2",
		thrust = 10331E3,
		Isp = 421
	}

	objects.engine.rcs = {
		name = "rcs",
		thrust = 3.87E3,
		Isp = 50
	}

	objects.engine.rcsBIG = {
		name = "bigrcs",
		thrust = 38.7E3,
		Isp = 50
	}

	objects.tank = {}
	objects.tank.empty ={
		mass = 0
	}
	objects.tank.sm = {
		mass =  2790,
		ratio = 0.7
	}

	objects.tank.rcs = {
		mass = 480
	}


	objects.tank.rcsMEDIUM = {
		mass = 1000
	}

	objects.tank.rcsBIG = {
		mass = 4800
	}

	objects.tank.SIVB = {
		mass = 104000,
		ratio = 0.7
	}

	objects.tank.FLT800 = {
		mass = 4000,
		ratio = 0.45
	}

	objects.tank.FLT8002 = {
		mass = 8000,
		ratio = 0.45
	}
	-- planet parameters
	objects.planet = {}
	objects.planet.kerbin = {
		name = "Kerbin",
		mass = 5.2915793E22,
		radius = 600000,
		pic = kerbin,
		orientation = 0,
		orientationV = 2*math.pi/21549.425
	}

	objects.planet.earth = {
		name = "Earth",
		mass = 5.972E24,
		radius = 6371E3,
		pic = earth,
		orientation = 0,
		orientationV = -7.2921150E-5
	}

	objects.planet.moon = {
		name = "Moon",
		mass = 7.34767E22,
		radius =  1737E3,
		pic = moon,
		orientation = 0,
		orientationV = 24.627/1737E3
	}

	objects.planet.mun = {
		name = "Mun",
		mass = 	9.7600236E20,
		radius = 200000,
		pic = mun,
		orientation = 0,
		orientationV = 2*math.pi/138984.38
	}

	objects.planet.minmus = {
		name = "Minmus",
		mass = 	2.6457897E19,
		radius = 60000,
		pic = minmus,
		orientation = 0,
		orientationV = 2*math.pi/40400
	}

	-- ships are assembled using tanks and engines describe above
	objects.ship = {}
	objects.ship.ASM = {
		name = "ASM",
		engine = objects.engine.aj10,
		tank = objects.tank.sm,
		rcs = false,
		rcstank = objects.tank.rcs,
		rcsengine = objects.engine.rcs,
		rcsmass = objects.tank.rcs.mass,
		fuelmass = objects.tank.sm.mass,
		drymass = 14690,
		gyro = 10E2,
		radius = 3.9/2,
		length = 7.9519
	}

	objects.ship.SIVB = {
		name = "S-IVB",
		engine = objects.engine.j2,
		tank = objects.tank.SIVB,
		rcs = false,
		rcstank = objects.tank.rcsBIG,
		rcsengine = objects.engine.rcsBIG,
		rcsmass = objects.tank.rcsBIG.mass,
		fuelmass =objects.tank.SIVB.mass, 
		drymass = 11000,
		gyro = 10E4,
		radius = 6.60/2,
		length = 17.81
	}
	
	objects.ship.Default = {
		name = "Default Ship",
		engine = objects.engine.LVT30,
		tank = objects.tank.FLT8002,
		rcs = false,
		rcstank = objects.tank.rcsMEDIUM,
		rcsengine = objects.engine.rcs,
		rcsmass = objects.tank.rcsMEDIUM.mass,
		fuelmass = objects.tank.FLT8002.mass, 
		drymass = 2E3,
		gyro = 2E4,
		radius = 5/2,
		length = 7
	}

	for i,v in pairs(objects.planet) do
		v.class = "planet"
		v.alpha = 0
	end

	for i,v in pairs(objects.ship) do
		v.mass = v.drymass + v.fuelmass + v.rcsmass
		v.class = "ship"
		v.alpha = 0
		v.target = nil
		v.type = "dynamic"
		v.encounter =false
		v.orientation = 0
		v.orientationV = 0
		v.torque = 0
		v.throttle = 0
		v.sas = false
		v.I = 0.5*v.mass*v.radius^2
	end
	-- compound ships can also be formed
	stage =  {deepcopy(objects.ship.SIVB),deepcopy(objects.ship.ASM)}
	objects.ship.LunarTransfer = {
		name = "LunarTransfer",
		engine = stage[1].engine,
		tank = stage[1].tank,
		rcs = false,
		rcstank = stage[1].rcstank,
		rcsengine = stage[1].rcsengine,
		rcsmass = stage[1].rcsmass,
		fuelmass = stage[1].fuelmass,
		drymass = stage[1].drymass + stage[2].fuelmass + stage[2].rcsmass,
		gyro = stage[1].gyro,
		radius = stage[1].radius,
		length = stage[1].length + stage[2].length
	}
	objects.ship.LunarTransfer.stage = stage

	for i,v in pairs(objects.ship) do
		v.mass = v.drymass + v.fuelmass + v.rcsmass
		v.class = "ship"
		v.alpha = 0
		v.target = nil
		v.type = "dynamic"
		v.encounter =false
		v.orientation = 0
		v.orientationV = 0
		v.torque = 0
		v.throttle = 0
		v.sas = false
		v.I = 0.5*v.mass*v.radius^2
	end
end

function loadbody(x)
	-- this function returns the "body" package of each level
	obj()
	std()
	local level = {}

	-- the first 99 levels are designated for tutorial use
	for x = 1,5 do 
		level[x] = {}
		level[x].earth = standard.earth
		level[x].ship = circularOrbit(deepcopy(objects.ship.Default),level[x].earth,8000E3,0)
	end
	level[3].ship = circularOrbit(deepcopy(objects.ship.LunarTransfer),level[3].earth,8000E3,0)
	level[3].ship.fuelmass = 0

	for x = 6,7 do
		level[x] = {}
		level[x].earth = standard.earth
		level[x].moon = standard.moon
		level[x].ship = circularOrbit(deepcopy(objects.ship.LunarTransfer),level[x].earth,8000E3,0)
	end
	level[8] = {}
	level[8].earth = standard.earth
	level[8].moon = standard.moon
	level[8].ship = circularOrbit(deepcopy(objects.ship.Default),level[8].moon,8000E3,0)

	-- the next 99 levels are dsignated for mission use
	level[101] = {}
	level[101].earth = standard.earth
	level[101].moon = standard.moon
	level[101].ship = deepcopy(objects.ship.Default)
	level[101].ship.type = "dynamic"
	level[101].ship.parent = level[101].earth
	level[101].ship.colour = {0,255,255}
	level[101].ship.colourtemp = {0,255,255}
	level[101].ship.a = 5000E3
	level[101].ship.e = {0.5,0,0}
	level[101].ship.h = geth(level[101].ship)
	level[101].ship.w = 0
	level[101].ship.M = d2rad(173)
	updatePos(0,level[101].ship.parent,level[101].ship)
	

	level[102] = {}
	level[102].earth = standard.earth
	level[102].moon = standard.moon
	level[102].ship = circularOrbit(deepcopy(objects.ship.Default),level[102].earth,7500E3,0)
	level[102].ship.name = "Super Secret Satellite"

	level[103] = {}
	level[103].earth = standard.earth
	level[103].moon = standard.moon
	level[103].ship = circularOrbit(deepcopy(objects.ship.Default),level[103].earth,7500E3,d2rad(178))
	level[103].ship.name = "STS-101"
	level[103].ship2 = circularOrbit(deepcopy(objects.ship.Default),level[103].earth,8000E3,d2rad(178+90))
	level[103].ship2.name = "ISS"
	level[103].ship2.colour = {194,2,168}
	level[103].ship2.colourtemp = {194,2,168}

	level[104] = {}
	level[104].earth = standard.earth
	level[104].moon = standard.moon
	level[104].ship = circularOrbit(deepcopy(objects.ship.LunarTransfer),level[104].earth,7500E3,0)
	level[104].ship.name = "HMAS Tinny"
	level[104].ship.stage[1].name = "Tanky McTankface"
	level[104].ship.stage[2].name = "Tin Can"

	level[105] = {}
	level[105].kerbin = standard.kerbin
	level[105].mun = standard.mun
	level[105].minmus = standard.minmus
	level[105].minmus.colour = {192,2,168}
	level[105].minmus.colourtemp = {192,2,168}
	level[105].ship = circularOrbit(deepcopy(objects.ship.Default),level[105].minmus,80E3,0)
	level[105].ship.name = "Kerbal X"

	-- beyond this we have the "sandbox" mode. which is just a default ship in a default universe
	level[200] = {}
	level[200].earth = standard.earth
	level[200].moon = standard.moon
	level[200].ship = circularOrbit(deepcopy(objects.ship.Default),level[200].earth,8000E3,0)


	return level[x] -- returns the level package
end
