function loadimg()
	-- loads all the images for the game
	ring = love.graphics.newImage("/img/node/ring.png")
	prograde = love.graphics.newImage("/img/node/prograde.png")
	retrograde = love.graphics.newImage("/img/node/retrograde.png")
	radial = love.graphics.newImage("/img/node/radial.png")
	antiradial = love.graphics.newImage("/img/node/antiradial.png")
	branch = love.graphics.newImage("/img/node/branch.png")
	close = love.graphics.newImage("/img/node/close.png")
	nodep = love.graphics.newImage("/img/node/node.png")
	cneedle = love.graphics.newImage("/img/nav/cneedle.png")
	compass = love.graphics.newImage("/img/nav/compass.png")
	throttle = love.graphics.newImage("/img/nav/throttle.png")
	tneedle = love.graphics.newImage("/img/nav/tneedle.png")
	sason = love.graphics.newImage("/img/nav/sason.png")
	sasoff = love.graphics.newImage("/img/nav/sasoff.png")
	rcson = love.graphics.newImage("/img/nav/rcson.png")
	rcsoff = love.graphics.newImage("/img/nav/rcsoff.png")
	ship = love.graphics.newImage("/img/nav/ship.png")
	earth = love.graphics.newImage("/img/planets/earth.png")
	earthprojection = love.graphics.newImage("/img/planets/earthprojection.png")
	kerbin = love.graphics.newImage("/img/planets/kerbin.png")
	moon = love.graphics.newImage("/img/planets/moon.png")
	minmus = love.graphics.newImage("/img/planets/minmus.png")
	mun = love.graphics.newImage("/img/planets/mun.png")
	stageactive = love.graphics.newImage("/img/nav/stageactive.png")
	stageoff = love.graphics.newImage("/img/nav/stageoff.png")
	backdrop = love.graphics.newImage("/img/planets/background.jpg")
	goaloff = love.graphics.newImage("/img/nav/goaloff.png")
	goalon = love.graphics.newImage("/img/nav/goalon.png")
	window = love.graphics.newImage("/img/nav/window.png")
	corner = love.graphics.newImage("/img/nav/corner.png")
	warparrow = love.graphics.newImage("/img/nav/warp.png")
	buttdisabled = love.graphics.newImage("/img/nav/button/active.png")
	buttactive = love.graphics.newImage("/img/nav/button/disabled.png")
	butthover = love.graphics.newImage("/img/nav/button/hover.png")
	card = love.graphics.newImage("/img/nav/card.png")
	rcsthrust = love.graphics.newImage("/img/nav/rcsthrust.png")
end

function loadsound()
	-- loads sound for the game
	local track = {}
	for x = 1,6 do
		track[x] = love.audio.newSource("/soundtrack/space/"..x..".mp3", "static")
	end
	rcs = love.audio.newSource("/soundtrack/effect/rcs.wav","static")
	engine = love.audio.newSource("/soundtrack/effect/engine1.wav","static")
	rcs:setVolume(0.5)
	return track
end

function loadmenusound()
	-- loads sound for the menu
	local track = {}
	for x = 1,2 do
		track[x] = love.audio.newSource("/soundtrack/menu/"..x..".mp3", "static")
	end
	clicksound = love.audio.newSource("/soundtrack/effect/click.wav","static") 
	return track
end

function loadMenuImg()
	-- loads images for the menu
	home = love.graphics.newImage("/img/menu/mainmenu.png")
	tutorial = love.graphics.newImage("/img/menu/tutorial.png")
	missions = love.graphics.newImage("/img/menu/missions.png")
	deadpic = love.graphics.newImage("/img/menu/dead.png")
	settingsPic = love.graphics.newImage("/img/menu/settings.png")
	menuring = {}
	menuring[1] = love.graphics.newImage("/img/menu/ring1.png")
	menuring[2] = love.graphics.newImage("/img/menu/ring2.png")
	menuring[3]= love.graphics.newImage("/img/menu/ring3.png")
	buttonnative = love.graphics.newImage("/img/menu/buttonnative.png")
	buttonhover = love.graphics.newImage("/img/menu/buttonhover.png")
	buttonpressed = love.graphics.newImage("/img/menu/buttonpressed.png")

end

function loadFonts()
	-- loads fonts
	defaultFont = love.graphics.newFont(12)
	typewriter = love.graphics.newFont("/fonts/typewriter.ttf",36)
	typewriterSmall = love.graphics.newFont("/fonts/typewriter.ttf",25)
	corbelBigBold = love.graphics.newFont("/fonts/corbel/Corbel Bold.ttf",35)
	corbelSmall = love.graphics.newFont("/fonts/corbel/Corbel.ttf",20)

end