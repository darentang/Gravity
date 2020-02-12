-- /bin/leveldescription: stores the level information i.e. thumnail, description, cards
local cards = {}
-- the local card table stores the text in which is sequentially displayed in each tutorial level
cards[1] = {
	"Press the A key and D key to change the spacecraft's heading.",
	"Press the left shift key and left control key to control the spacecraft's throttle",
	"Press SPACEBAR to stage.",
	"Press R to enable Reaction Control thrusters",
	"Press T to enavle stability control",
	"Notice that as you turn, the compass points at the direction in which you are going.",
	"The rate in which you turn is determined by the amount of torque that is acted upon the spacecraft",
	"Inherently, your spacecraft maneuvers through the use of a gyroscopic reaction wheel",
	"However, the torque that this provides is minimal",
	"For larger torque, RCS thrusters are used to maneuver the spacecraft",
	"They work by expelling hypergollic fuel or cold gas to induce torque"
}

cards[2] = {
	"The fuel tank's capacity is shown in the diagram located in the left bottom corner",
	"Hover on top of a tank to inspect its current status.",
	"As more fuel is expended, the acceleration of the spacecraft increases, since a = F/m",
	"Hover on top of the engine to inspect its properties",
	"The specific impulse of an engine indicates its efficiency.",
	"The rate at which fuel is expelled from the engine is given by: Thrust/(9.81*Isp)",
	"Therefore, the higher the specific impulse, the more efficient the engine is.",
}

cards[3] = {
	"When a fuel tank is empty, it becomes dead weight.",
	"Therefore, it is desirable to ditch the tank when all fuel is expended",
	"The stages of your spacecraft can be observed in the lower right corner.",
	"Now, press SPACEBAR to discard the empty tanks",
	"Notice that a grey orbit appears. You have now produced spacejunk",
	"Accelerate away from the discarded stage by acceleratign"
}

cards[4] = {
	"This game simulates Keplerian two-body solutions",
	"This means that it only calculates the affect of one massive body towards a much lighter body",
	"Keplerian orbits are conic sections. Which means they are either circles, ellipses, parabolas or hyperbolas",
	"You are now in a circular orbit",
	"In a circular orbit, your velocity is always normal to the radius. Your speed is constant",
	"A circular orbit as an eccentricity(measure of how 'squashed' the conic section is) of 0",
	"Now fire in the prograde direction. Notice the orbit changing in shape",
	"The orbit changes into an ellipse. The focus is located at the point mass of the earth",
	"An elliptical orbit as an eccentricity of 0<e<1",
 	"Fire in the prograde direction a bit more until the ellipse breaks",
 	"The shape of the body is now a hyperbola. It will not return to its original spot",
	"A hyperbolic orbit as an eccentricity of > 1"
}

cards[5] = {
	"Double-click on a point on the orbit, a white ring will appear.",
	"Drag the symbols to accelerate in the respective direction.",
	"In a 2d plane, we have only 4 directions: Prograde, retrograde, radial and antiradial.",
	"Prograde is the directoin that you are travelling towards",
	"Retrograde is the direction opposite to your velocity vector",
	"Radial is the direction 90 degrees anticlockwise to your prograde direction",
	"Antiradial is the direction 90 degrees clockwise to your prograde direction",
	"Notice that when you drag the nodes, your deltaV increases",
	"This is the magnitude of the velocity that is required to be changed at that point",
	"Your burn time is calculated by your current engine configuration and the rate at which mass is expelled",
	"The time till node is the time from your current position until the node"
}

cards[6] = {
	"Zoom out and double click on the orbit of the moon",
	"Two pointers will appear. They indicate the closest approach of your spacecraft and the moon",
	"Now, create a maneuver node and adjust it so that the pointers are close",
	"When the distance between the two nodes are less than the target's sphere of influence, and encounter is made",
	"An enconuter means that your spacecraft will temporarily be affected by the object's gravity",
	"When you exit the sphere of influence, the gravity of the body no longer affects you",
	"However, your path has changed, since the gravitational force of the body has affected your spacecraft's velocity and position"
}

cards[7] = {
	"Double-click to target the moon",
	"Using the maneuver node, perform a burn so that your spacecraft encounters with the target",
	"The white path indicates your spacecraft's movement relative to the moon",
	"The orange path indicates your spacecraft's movement relative to the earth",
	"The green path indicates your spacecraft's orbit when it eventually leaves the sphere of influnce of the moon"
}


cards[8] = {
	"You are now in a circular lunar orbit",
	"Perform a burn so that your orbit is hyperbolic",
	"Notice the green path and the bubble at the end of your orbit",
	"This indicates the location at which you spacecraft would escape mooon's sphere of influnce"
}


cards[9] = {
	"When it is desired to change the radius of a circular orbit, a transfer orbit is needed.",
	"Boosting directly upward would result in a very inefficient use of deltaV",
	"Now, let's use a Hohmann Transfer to change the radisu of this orbit to 42000km",
	"First, point the spacecraft towards the prograde vector",
	"Fire the engine until the apoapsis reaches 42000km",
	"Cut the engine and warp to apoapsis",
	"Again, point the spacecraft towards the prograde vector until circularised",
	"The radius of the orbit has now increased",
	"If desired to return to original orbit, doing the reverse will also work"
}

-- title cards, description and thumbnails

local level = {}
level[1] = {
	title = "Basic Control",
	description = "Learn to control the spacecraft's attitude and thrust.",
	cards = cards[1],
}

level[2] = {
	title = "Fuel and Engine",
	description = "Inspect the status of the spacecraft's fuel and engine.",
	cards = cards[2]
}

level[3] = {
	title = "Staging",
	description = "Discard expended fuel tanks to decrease weight",
	cards = cards[3]
}

level[4] = {
	title = "Orbit 101",
	description = "Learn the basics of orbital mechanics",
	cards = cards[4]
}

level[5] = {
	title = "Maneuver Node",
	description = "Use the maneuver node tool to plan your maneuvers",
	cards = cards[5]
}

level[6] = {
	title = "Targeting",
	description = "Select a target to estimate closest approach",
	cards = cards[6]
}

level[7] = {
	title = "Injection",
	description = "Inject into the body's sphere of influence",
	cards = cards[7]
}

level[8] = {
	title = "Escape",
	description = "Escaping from a sphere of influence",
	cards = cards[8]
}

level[9] = {
	title = "Hohmann Transfer",
	description = "Changing radius of a circular orbit.",
	cards = cards[8]
}


level[101] = {
	title = "Crisis Averted",
	description = "Jeb and his crew is in a suborbital tragetory plunging towards the Earth's atmosphere. Help him pull out of this dive by circularising the orbit with a semi-major axis of 8000km"
}

level[102] = {
	title = "Soviet Spy Satellite",
	description = "A soviet spy satellite is in a 7500km parking orbit. Help maneuver this satellite to a geosynchronous orbit. Adjust the orbit so that the satellite is above the Caribbean Sea (75°W to 120°W) Hint: Press 'g' for groundtrace.",
}

level[103] = {
	title = "Orbital Redezvous",
	description = "The International Space Station is 90° ahead and 200km above your alttitude. Catch-up with the station and get within 500km"
}

level[104] = {
	title = "Australian Space Program",
	description = "Prime Minister Malcolm Turnbull decides to privatise MediCare, and spend its funding on a space program instead. Maneuver HMAS Tinny into a lunar injection orbit and then form a circular orbit of 2500km around the Moon."
}

level[105] = {
	title = "Kerbal Business",
	description = "The Kerbin system has 2 moons: Mun and Minmus. You will be placed in a stable orbit around minmus. Your mission is to enter a circular orbit of 300km around the Mun."
}



for i,v in pairs(level) do
	v.thumbnail = love.graphics.newImage("/img/menu/thumbnail/"..i..".png")
	local dim = 256/v.thumbnail:getWidth()
	v.top_left =  love.graphics.newQuad(0,0,256,157,256,v.thumbnail:getHeight()*dim)
	v.current = 1
end

function levelinspect()
	return level
end

function levelSelect(x)
	return level[x]
end