-- /bin/maths.lua frequently used mathematical operations
function crossProduct(u,v) -- cross product between two vectors
	local h = {}
	h[1] = u[2]*v[3] - u[3]*v[2]
	h[2] = u[3]*v[1] - u[1]*v[3]
	h[3] = u[1]*v[2] - u[2]*v[1]
	return h
end

function tomin(sec) -- returns string T+- hh:mm:ss
	local text = ""
	if sec > 0 then 
		text = "T+ "
	else
		text = "T- "
	end
	sec = math.abs(sec)
	local h = math.floor(sec/(60*60))
	if h ~= 0 then
		text = text .. h .. ":"
	end
	local m = math.floor(sec%(60*60)/60)
	if m < 10 then
		text = text .. "0" .. m
	else
		text = text .. m
	end
	local s = math.floor(sec%(60*60)%60)
	text = text .. ":"
	if s < 10 then
		text = text .. "0" .. s
	else
		text = text .. s
	end
	return text
end
function math.arccosh(x) -- hyperbolic inverse cosine
	return math.log(x + math.sqrt(x^2-1))
end

function innerProduct(u,v) -- inner product between two vectors
	return u[1]*v[1]+u[2]*v[2]+u[3]*v[3] 
end
function magnitude(v) -- pythagoras theorem 
	return math.sqrt(v[1]^2 + v[2]^2 + v[3]^2)
end

function distance(a,b) -- distance between two 3d points
	dx = b[1] - a[1]
	dy = b[2] - a[2]
	dz = b[3] - a[3]
	return {dx,dy,dz}
end

function round(num, idp) -- rounding 
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function conicDistance(o,tru) -- distance of a conic from its focus given its tru anomaly 
	local e = magnitude(o.e)
	local c = 0
	if e < 1 then
		c = 1 - e^2
	else
		c = e^2 - 1 
	end

	return (o.a*c)/(1+e*math.cos(tru))
end

function r2p(o,slave,parent) -- relative to positional vectors
	local x,y = o[1],o[2]
	return {x+parent.p[1],y+parent.p[2],0}
end

function real2scale(o) -- real to game scale
	local x,y = o[1],o[2]
	return {x*SCALE+origin[1],origin[2]-y*SCALE}
end

function real2screen(o) -- real to screen 
	return scale2screen(real2scale(o))
end

function screen2scale(o) -- screen to real
	local x,y = o[1],o[2]
	return {currentX - (400-x),currentY - (300-y)}
end

function scale2real(o) -- scale to real
	local x,y = o[1],o[2]
	return {(x-origin[1])/SCALE,-(y-origin[2])/SCALE}
end

function screen2real(o) -- screen to real
	return scale2real(screen2scale(o))
end

function scale2screen(o) -- scale to screen
	local x,y = o[1],o[2]
	return {x - currentX + 400,y - currentY +300}
end

function deepcopy(orig) -- copies all contents of a table into a seperate table 
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else 
        copy = orig
    end
    return copy
end

function tru2r2(o,d1,tru) -- finding radial vector given a true anomaly and distance
	local e = magnitude(o.e)
	local r = 0
	if o.h[3] > 0 then
		r = {d1*math.cos(tru+o.w),d1*math.sin(tru+o.w),0}  
	else
		r = {d1*math.cos(tru+o.w),-d1*math.sin(tru+o.w),0}  
	end
	return r
end

function d2rad(x) -- degrees to radians
	return x*(math.pi/180)
end

function rad2d(x) -- radians to degrees
	return x*(180/math.pi)
end

function tru2r(o,tru) -- finding radial vector given a true anomaly
	if tru == nil then
		tru = o.tru
	end
	local e = magnitude(o.e)
	local r = 0
	local d1 = 0
	if e < 1 then
		d1 = (o.a*(1-e^2))/(1+e*math.cos(tru))
	else
		d1 = (o.a*(e^2-1))/(1+e*math.cos(tru))
	end
	if o.h[3] > 0 then
		r = {d1*math.cos(tru+o.w),d1*math.sin(tru+o.w),0}  
	else
		r = {d1*math.cos(tru+o.w),-d1*math.sin(tru+o.w),0}  
	end

	return r
end


function rotatePt(p,r,theta) -- rotate about a point given a degree
	return {p[1] + r*math.cos(theta),p[2] - r*math.sin(theta)}
end

function burntime(o,delV) -- inverse Tisolkovsky's rocket equation
	local changemass = (o.engine.thrust)/(9.81*o.engine.Isp)
	return (o.mass/changemass)*(1-math.exp((-changemass/o.engine.thrust)*delV))
end

function normalise(x) -- turns radians in any magnitude to within 0 < theta <= 2pi
	if x > 2*math.pi then
		theta = theta - 2*math.pi*math.floor(math.abs(x)/(2*math.pi))
	elseif x < 0 then
		
		x = 2*math.pi*math.ceil(math.abs(x)/(2*math.pi)) + x

	end
	return x
end

function geth(o) -- get the specific relative angular momentum given semimajor axis, mass and eccentricity
	return {0,0,math.sqrt(o.a*(G*(o.mass+o.parent.mass)*(1-magnitude(o.e)^2)))}
end