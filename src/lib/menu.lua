-- /bin/menu.lua: menu compnents 

menu = {}
-- initialises the menu, loads images and sounds
function menu:load(c)
	if currentTrack ~= nil and track[currentTrack]:isPlaying() then
		track[currentTrack]:stop()
	end
	loadMenuImg()
	loadFonts()
	menutrack = loadmenusound()
	mouse = {}
	mouse.l = false
	currentTrack1 = 1
	l = levelinspect()
	ringrotate = {0,0,0}
	ringrotateV = {0.1745,-0.23,0.17}
	if c == nil then
		click = {}
	else
		click = {}
		click[1] = c
	end
	menutrack[currentTrack1]:setVolume(volume)
	menutrack[currentTrack1]:play()
end

-- updates the menu
function menu:update(dt)
	clicksound:setVolume(volume)
	if not menutrack[currentTrack1]:isPlaying() then
		if currentTrack1 < #menutrack then
			currentTrack1 = currentTrack1+1
		elseif currentTrack1 == #menutrack then
			currentTrack1 = 1
		end
	end
	menutrack[currentTrack1]:setVolume(volume)	
	menutrack[currentTrack1]:play()
	for x = 1,#ringrotate do
		ringrotate[x] = ringrotate[x] + dt*ringrotateV[x]
	end
end

function menu:draw()
	-- the menu is drawn 
	love.graphics.draw(home,0,0)
	for x =1,#menuring do
		love.graphics.draw(menuring[x],574.5,364.5,ringrotate[x],1,1,menuring[x]:getWidth()/2,menuring[x]:getHeight()/2)
	end
	love.graphics.setFont(typewriter)
	love.graphics.setColor(0,0,0)
	local pts = {}
	local text = {"sandbox","tutorial","missions","settings","quit"}
	
	if click[1] == nil then
		for x = 1,5 do
			pts[x] = {109,202 + (x-1)*48}
			if  buttonHoverText(pts[x],144,43,{0,0,0},{255,162,0},{255,255,255},text[x]) then
				click[1] = x -- returns the option that is clicked
			end
			love.graphics.setColor(0,0,0)
		end
	end
	love.graphics.setColor(255,255,255)
	if click[1] == 1 then
		level = 200
		love.graphics.setFont(defaultFont)
		game:load(level)
	elseif click[1] == 2 then
		submenu(0)
	elseif click[1] == 3 then
		submenu(1)
	elseif click[1] == 4 then
		settings()
	elseif click[1] == 5 then
		love.event.quit()
	elseif click[1] == -1 then
		love.graphics.draw(deadpic,0,0)
		if  buttonHoverText({297,460},233,43,{0,0,0},{255,162,0},{255,255,255},"back to menu") then
			click[1] = nil
		end
	end

	
end

function settings()
	-- settings page
	love.graphics.draw(settingsPic,0,0)
	local pt = {168+volume*475,151}
	if mouse.l and  math.abs(mY-151) < 10 then
		local dist = mX-168
		if (dist-475)*dist <= 0 then
			volume = dist/475
		end
	end
	local pt = {168+volume*475,151}
	love.graphics.setColor(180,180,180)
	love.graphics.circle("fill",pt[1],pt[2],7)
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(typewriterSmall)
	love.graphics.print(round(volume*100,0),690,138)
	love.graphics.setFont(typewriter)
	if buttonHoverText({43,507},144,43,{0,0,0},{255,162,0},{255,255,255},"back") then
		click[2] = nil
		click[1] = nil
		click = {}
	end
	love.graphics.setColor(255,255,255)
end

function buttonHoverClick(pt,width,height,n,h,p)
	-- a function that draws a button and detects hovers
	-- it also returns whether it has been clicked
	local c = false
	if math.abs(mX-(pt[1]+ width/2)) < width/2 and math.abs(mY-(pt[2]+height/2)) < height/2 then
		if mouse.l then
			clicksound:play()
			love.graphics.draw(p,pt[1],pt[2])
			c = true
		else
			love.graphics.draw(h,pt[1],pt[2])
		end
	else
		love.graphics.draw(n,pt[1],pt[2])
	end
	return c
end

function buttonHoverText(pt,width,height,n,h,p,text,mode)
	-- same as above but with text
	local m = mouse.l
	local c = false
	if math.abs(mX-(pt[1]+ width/2)) < width/2 and math.abs(mY-(pt[2]+height/2)) < height/2 then
		if m then
			clicksound:play()
			love.graphics.setColor(p)
			love.graphics.print(text,pt[1],pt[2])
			c = true
		else
			love.graphics.setColor(h)
			love.graphics.print(text,pt[1],pt[2])
		end
	else
		love.graphics.setColor(n)
		love.graphics.print(text,pt[1],pt[2])
	end
	return c
end

function submenu(x)
	-- draws both the tutorial and mission page
	if x == 0 then
		love.graphics.draw(tutorial,0,0)
	elseif x == 1 then
		love.graphics.draw(missions,0,0)
	end
	for i,v in pairs(l) do
		local q = (i-x*100)
		if (q^2-100^2) < 0 then
			pts = {57+((q-1)%4)*90,98.5 + (math.ceil(q/4)-1)*82}
			if  buttonHoverClick(pts,buttonnative:getWidth(),buttonnative:getHeight(),buttonnative,buttonhover,buttonpressed) then
				click[2] = i
			end
			if i == click[2] then
				love.graphics.draw(buttonpressed,pts[1],pts[2])
			end
			love.graphics.setColor(0,0,0)
			love.graphics.print(q,pts[1]+24,pts[2] + 10.27)
			love.graphics.setColor(255,255,255)
		end
	end
	if click[2] ~=nil then
		-- draws the description 
		love.graphics.draw(l[click[2]].thumbnail,l[click[2]].top_left,493,55)
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(corbelBigBold)
		love.graphics.printf(l[click[2]].title,493,222,253)
		love.graphics.setFont(corbelSmall)
		love.graphics.printf(l[click[2]].description,493,300,253)
	end
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(typewriter)
	if buttonHoverText({43,507},144,43,{0,0,0},{255,162,0},{255,255,255},"back") then
		-- back to menu
		click[2] = nil
		click[1] = nil
		click = {}
	end
	if click[2] ~= nil and buttonHoverText({507,507},144,43,{0,0,0},{255,162,0},{255,255,255},"GO") then
		-- loads level
		level = click[2]
		love.graphics.setFont(defaultFont)
		game:load(level)
	end  
end

