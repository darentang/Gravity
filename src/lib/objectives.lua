-- /bin/objectives.lua: This module contains all standard objectives that returns a boolean value of whether it is achieved or not.

local objectives = {}

function objectives:checkAp(o,ap,tolerance)
	if math.abs(conicDistance(o,math.pi)-ap) < tolerance then
		return true
	else
		return false
	end
end

function objectives:checkE(o,e,tolerance)
	if math.abs(magnitude(o.e) - e) < tolerance then
		return true
	else
		return false
	end
end

function objectives:checkSemiMaj(o,a,tolerance)
	if math.abs(o.a-a) < tolerance then
		return true
	else
		return false
	end
end

function objectives:checkClose(o,p,tolerance)
	 local delt,d1,d2 = encounter(o,p)
	 if magnitude(distance(d1.r,d2.r)) < tolerance then
	 	return true
	 else
	 	return false
	 end
end

function objectives:checkInject(o,p)
	if injection[o.name] ~= nil and injection[o.name].parent.name == p.name then
		return true
	else
		return false
	end
end	

function objectives:checkRendezvous(o,p)
	if magnitude(distance(o.p,p.p)) < 500E3 and math.abs(o.a-p.a) < 100E3 and math.abs(magnitude(o.e)-magnitude(p.e)) < 0.01 then
		return true
	else
		return false
	end
end

function objectives:checkSynchronous(o,tolerance)
	local tolerance = d2rad(tolerance)
	local theta,theta1 = findplot(o)
	if math.abs(theta-theta1)<tolerance then
		return true
	else
		return false
	end
end

function objectives:checkLat(o,low,high)
	local a = d2rad(180 + low)
	local b = d2rad(180 + high)
	local theta,theta1 = findplot(o)
	if (theta-a)*(theta-b) <0 then
		return true
	else
		return false
	end
end

function levelObjectives(level,o)
	-- this function contains all the objectives that should be achived by each mission. 
	local goal = {}
	if level == 101 then
		goal[1] = {}
		goal[1].text = "Circularise at 8000km" 
		if objectives:checkAp(o,8000E3,50E4) and objectives:checkE(o,0,0.01)then
			goal[1].complete = true
		end
		return goal
	elseif level == 102 then
		goal[1] = {}
		goal[1].text = "Reach Geosynchronous Orbit"
		if	objectives:checkSynchronous(o,3) then
			goal[1].complete = true
		end
		goal[2] = {}
		goal[2].text = "Stay between 90°W and 135°W"
		if goal[1].complete and objectives:checkLat(o,-75,-120) then
			goal[2].complete = true
		end
		return goal
	elseif level == 103 then
		goal[1] = {}
		goal[1].text = "Rendezvous with the ISS"
		if	objectives:checkRendezvous(o,body.ship2) then
			goal[1].complete = true
		end
		return goal
	elseif level == 104 then
		goal[1] = {}
		goal[1].text = "Lunar Transfer Orbit"
		if	objectives:checkInject(o,body.moon) then
			goal[1].complete = true
		end
		goal[2] = {}
		goal[2].text = "Lunar orbit at 2500km"
		if	objectives:checkAp(o,2500E3,20E4) and objectives:checkE(o,0,0.01) and o.parent == body.moon then
			goal[2].complete = true
		end		
		return goal	

	elseif level == 105 then
		goal[1] = {}
		goal[1].text = "Munar orbit of 300km"
		if	objectives:checkAp(o,300E3,50E3) and objectives:checkE(o,0,0.01) and o.parent == body.mun then
			goal[1].complete = true
		end
		return goal	
	else
		return nil
	end

	-- the table "goal" is returned to indicate whether the specific objective is achived, and the descriptiong of the objective
end
