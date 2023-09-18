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
		a = a or 0
		a = math.fmod(a + 0.01, 0.5)
		simulator:setInputBool(1, screenConnection.isTouched)
		simulator:setInputNumber(1, screenConnection.width)
		simulator:setInputNumber(2, screenConnection.height)
		simulator:setInputNumber(3, screenConnection.touchX)
		simulator:setInputNumber(4, screenConnection.touchY)
		simulator:setInputNumber(5, 0)
		simulator:setInputNumber(6, 0)
		simulator:setInputNumber(7, a)
		simulator:setInputNumber(8, 0)

		-- NEW! button/slider options from the UI
		simulator:setInputBool(31, simulator:getIsClicked(1)) -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
		simulator:setInputNumber(31, simulator:getSlider(1)) -- set input 31 to the value of slider 1

		simulator:setInputBool(32, simulator:getIsToggled(2)) -- make button 2 a toggle, for input.getBool(32)
		simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
	end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("Libraries.DrawingTools")
require("Libraries.Touchscreen")
require("Libraries.ScreenUtilities")
--require("LifeBoatAPI")
-- Tick function that will be executed every logic tick
local PI2 = math.pi * 2
local screenWidth = 32
local screenHeight = 32
local ZoomSlider = TouchscreenSlider:new(0, 0, 0, 0)
init = false
zoomPercent = 0
zoomLevel = 0.5

function onTick()
	if not init and input.getNumber(1) ~= 0 then
		screenWidth = input.getNumber(1)
		screenHeight = input.getNumber(2)
		ZoomSlider = TouchscreenSlider:new(screenWidth - 5, 3, 5, screenHeight - 6, 1)
		init = true
	end
	local isTouch = input.getBool(1)
	touchX = input.getNumber(3)
	touchY = input.getNumber(4)
	x = input.getNumber(5)
	y = input.getNumber(6)
	if isTouch then
		--ZoomSlider:checkInteraction()
		local interact, percent = ZoomSlider:checkInteraction(touchX, touchY)
		if interact then
			zoomPercent = math.floor(percent * 100) / 100
			zoomLevel = lerp(0.5, 50, zoomPercent ^ 2)
		end
	end
	output.setNumber(1, zoomLevel)
	compass_input = input.getNumber(7) or 0
	compass = math.fmod((-compass_input + 1) * PI2, PI2)
end

local GC = ScreenUtilities.applyGammaCorrection

local OceanRGB, ShallowsRGB, LandRGB, GrassRGB, SandRGB, SnowRGB, RockRGB, GravelRGB =
GC(9, 111, 211), GC(37, 164, 231),
GC(241, 208, 95), GC(251, 184, 53),
GC(255, 250, 99), GC(231, 246, 255),
GC(255, 142, 10), GC(146, 146, 146)

-- Draw function that will be executed when this script renders to a screen
function onDraw()
	screen.setMapColorOcean(table.unpack(OceanRGB))
	screen.setMapColorShallows(table.unpack(ShallowsRGB))
	screen.setMapColorLand(table.unpack(LandRGB))
	screen.setMapColorGrass(table.unpack(GrassRGB))
	screen.setMapColorSand(table.unpack(SandRGB))
	screen.setMapColorSnow(table.unpack(SnowRGB))
	screen.setMapColorRock(table.unpack(RockRGB))
	screen.setMapColorGravel(table.unpack(GravelRGB))
	screen.drawMap(x, y, zoomLevel) -- Draw the map

	screen.setColor(0, 0, 0)
	CPX, CPY = map.mapToScreen(x, y, zoomLevel, screenWidth, screenHeight, x, y)
	DrawingTools.drawPointer(CPX, CPY, 9, compass)
	screen.setColor(0, 0, 0, 128)
	DrawingTools.drawPointer(CPX, CPY, 11, compass)

	--drawPointer(CPX,CPY,10,rads_from_north)
	--screen.drawLine(CenterX,CenterX,CenterX+x1,CenterY+y1)
	screen.setColor(255, 255, 255)
	-- Draw zoom line

	screen.setColor(0, 0, 0, 128)
	screen.drawRectF(screenWidth - 2, 3, 2, screenHeight - 6)

	screen.setColor(0, 0, 0, 255)
	local sliderHeight = (screenHeight - 6) * zoomPercent

	screen.drawRectF(screenWidth - 5, 3 + sliderHeight, 5, 1)

	--screen.drawText(1, 1, tostring(math.floor(zoomLevel * 100) / 100))
	--screen.drawText(1, 7, tostring(math.floor(compass_input * 100) / 100))
end

function lerp(startValue, endValue, t)
	return (1 - t) * startValue + t * endValue
end;
