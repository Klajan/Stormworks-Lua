
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
	---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
	simulator = simulator
	simulator:setScreen(1, "2x2")
	simulator:setProperty("Total Fuel", 100)
	simulator:setProperty("Temperature Unit", false)
	simulator:setProperty("RPS Unit", false)

	-- Runs every tick just before onTick; allows you to simulate the inputs changing
	---@param simulator Simulator Use simulator:<function>() to set inputs etc.
	---@param ticks     number Number of ticks since simulator started
	function onLBSimulatorTick(simulator, ticks)
		-- touchscreen defaults
		local screenConnection = simulator:getTouchScreen(1)
		simulator:setInputBool(1, screenConnection.isTouched)
		simulator:setInputNumber(1, screenConnection.width)
		simulator:setInputNumber(2, screenConnection.height)
		simulator:setInputNumber(3, screenConnection.touchX)
		simulator:setInputNumber(5, screenConnection.touchY)
		simulator:setInputNumber(4, 0.5)
		simulator:setInputNumber(6, 144.9178)
		simulator:setInputNumber(7, 9.0)
		simulator:setInputNumber(11, 0)

		-- NEW! button/slider options from the UI
		simulator:setInputBool(31, simulator:getIsClicked(1))     -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
		simulator:setInputNumber(31, simulator:getSlider(1))      -- set input 31 to the value of slider 1

		simulator:setInputBool(32, simulator:getIsToggled(2))     -- make button 2 a toggle, for input.getBool(32)
		simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
	end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("Libraries.DrawingTools")
--require("LifeBoatAPI")
-- Tick function that will be executed every logic tick
PI2 = math.pi*2

function onTick()
	x = input.getNumber(1)
	y = input.getNumber(2)
	zoom_input = input.getNumber(3)
	-- make sane zoom default
	if zoom_input == 0 then
		zoom = 0.5
	else 
		zoom = math.min(50, math.max(0.1, zoom_input))
	end
	--compass_input = input.getNumber(4)
	compass_input = compass_input or 0
	compass_input = math.fmod(compass_input + 0.01, 1)
	pi2 = math.pi*2
	rads_from_north = math.fmod((compass_input+1.5)*pi2, pi2)
end

-- Draw function that will be executed when this script renders to a screen
function onDraw()
	w = screen.getWidth()				  -- Get the screen's width and height
	h = screen.getHeight()
	screen.drawMap(x, y, zoom)			-- Draw the map
	screen.setMapColorOcean(0,91,255, 255)
	screen.setMapColorShallows(0,191,255, 255)
	screen.setMapColorLand(0, 128, 0, 255)
	
	-- Draw a line from center to current heading
	CenterX = w/2
	CenterY = h/2
	radius = 5
	
	--screen.setColor(255, 255, 255)						-- Set draw color to black
	--screen.drawCircle(CenterX, CenterY, radius)		-- Draw a radius circle in the center of the screen
	
	screen.setColor(0, 0, 0)
	CPX, CPY = map.mapToScreen(x, y, zoom, w, h, x, y)
	DrawingTools.drawPointer(CPX,CPY,9,rads_from_north)
	screen.setColor(0,0,0,128)
	DrawingTools.drawPointer(CPX,CPY,11,rads_from_north)
	
	--screen.drawTriangleF(CenterX+x0,CenterY+y0,CenterX+x1,CenterY+y1,CenterX+x2+x0,CenterY+y2+y0)
	--screen.drawTriangleF(CenterX+x0,CenterY+y0,CenterX+x1,CenterY+y1,CenterX+x3+x0,CenterY+y3+y0)
	
	--drawPointer(CPX,CPY,10,rads_from_north)
	--screen.drawLine(CenterX,CenterX,CenterX+x1,CenterY+y1)
	screen.setColor(255, 255, 255)
	screen.drawRectF(CenterX,CenterY,1,1)
	--screen.drawRectF(CenterX+x1,CenterY+y1,1,1)
	--screen.drawRectF(CenterX+x2,CenterY+y2,1,1)
	--screen.drawRectF(CenterX+x3,CenterY+y3,1,1)
	--screen.drawLine(CenterX, CenterY, CenterX + x, CenterY + y)
	--screen.setColor(0, 0, 0)
	--screen.drawRectF(CenterX, CenterY, 1, 1)
	--screen.drawRectF(CenterX + x, CenterY + y, 1, 1)
	--screen.drawLine(CenterX + x, CenterY + y, CenterX + x, CenterY + y)
	-- Draw zoom line
	OffsetY = math.floor(h*0.1)
	line_height = h-(OffsetY*2)
	
	screen.setColor(0, 0, 0, 128)
	screen.drawLine(w-1, OffsetY, w-1, h - OffsetY)
	
	screen.setColor(0, 0, 0, 255)
	zoom_percent = zoom / 50 * 100
	line_percent = (line_height / 100) * zoom_percent
	
	screen.drawLine(w, OffsetY + line_percent, w-2, OffsetY + line_percent)
end

function drawPointer(x,y,s,r,...)
	a=...
	a=(a or 30)*math.pi/360
	x=x+s/2*math.sin(r)
	y=y-s/2*math.cos(r)
	
	screen.drawTriangleF(x,y,x-s*math.sin(r+a),y+s*math.cos(r+a),x-s*math.sin(r-a),y+s*math.cos(r-a))
end