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
	simulator:setScreen(1, "1x1")
	simulator:setProperty("Speed Unit", 0)

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
		simulator:setInputNumber(4, screenConnection.touchY)

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
require("Libraries.ScreenUtilities")
require("Libraries.SegmentDisplays")

-- 0:km/h ; 1:knots ; 2:mi/h ; 3:m/s
local unitprop = property.getNumber("Speed Unit")
local SU = ScreenUtilities
local _7S = SegmentDisplays._7Segment

function onTick()
	speed = input.getNumber(1)
	unit = "m/s"
	if unitprop == 0 then
		speed = speed * 3.6
		unit = "kph"
	elseif unitprop == 1 then
		speed = speed * 1.943844
		unit = "knt"
	elseif unitprop == 2 then
		speed = speed * 2.236936
		unit = "mph"
	end
end

local background_rgb, textfield_rgb, border_rgb, text_rgb = SU.applyGammaCorrection(30, 40, 60),
	SU.applyGammaCorrection(40, 50, 70), SU.applyGammaCorrection(34, 34, 36),
	SU.applyGammaCorrection(51, 255, 0)

function onDraw()
	--screen.drawCircle(16,16,5)
	SU.setColorFromTable(border_rgb)
	screen.drawRectF(0, 0, 32, 32)
	SU.setColorFromTable(background_rgb)
	screen.drawRectF(4, 2, 24, 1)
	screen.drawRectF(3, 3, 26, 13)
	screen.drawRectF(4, 16, 24, 1)
	screen.drawRectF(8, 19, 16, 1)
	screen.drawRectF(7, 20, 18, 5)
	screen.drawRectF(8, 25, 16, 1)
	SU.setColorFromTable(textfield_rgb)
	screen.drawRectF(9, 20, 14, 5)
	_7S.draw7Segment(5, 4, 255, 4)
	_7S.draw7Segment(13, 4, 255, 4)
	_7S.draw7Segment(21, 4, 255, 4)
	SU.setColorFromTable(text_rgb)
	screen.drawText(9, 20, unit)
	local a, b, c = splitNumber(speed)
	_7S.draw7Segment(5, 4, _7S.numberTo7Segment(a), 4)
	_7S.draw7Segment(13, 4, _7S.numberTo7Segment(b), 4)
	_7S.draw7Segment(21, 4, _7S.numberTo7Segment(c), 4)
end

function splitNumber(number)
	number = math.floor(number + 0.5)
	local a, b, c = math.floor(number / 100), math.floor(number / 10) % 10 or nil, number % 10
	return (a ~= 0) and a or nil, (b ~= 0) and b or nil, c
end
