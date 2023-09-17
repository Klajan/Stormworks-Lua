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
	simulator:setScreen(1, "2x1")
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
		simulator:setInputNumber(4, screenConnection.touchY)
		simulator:setInputNumber(5, 7.5)
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
require("Libraries.ScreenUtilities")
require("Libraries.TextTools")
require("Libraries.DrawingTools")
local SU, TT = ScreenUtilities, TextTools
--local DT = DrawingTools

local DoRpm = property.getBool("RPS Unit")
local DoFarenheit = property.getBool("Temperature Unit")
local TotalFuel = property.getNumber("Total Fuel")
-- Tick function that will be executed every logic tick
function onTick()
	Rps = input.getNumber(5)
	Temp = input.getNumber(6)
	Fuel = input.getNumber(7)
	FuelPerSecond = input.getNumber(8)
	Gear = input.getNumber(11) -- from transmition input
	
	FuelPerc = math.floor((Fuel / TotalFuel * 100) + 0.5)
	FuelInd = (FuelPerc < 10)
	TempInd = (Temp > 100)
	if DoFarenheit then
		Temp = (Temp * 9 / 5) + 32
	end
	if DoRpm then
		Rps = Rps * 60
	end
end

local background_rgb, textfield_rgb, border_rgb, text_rgb, indicator_rgb = SU.applyGammaCorrection(30, 40, 60),
	SU.applyGammaCorrection(40, 50, 70), SU.applyGammaCorrection(55, 65, 90), SU.applyGammaCorrection(51, 255, 0), SU.applyGammaCorrection(255, 51, 0)
local drawRF = screen.drawRectF
-- Draw function that will be executed when this script renders to a screen
function onDraw()
	-- width = 64
	-- height = 32

	-- draw static elements
	SU.setColorFromTable(border_rgb)
	drawRF(0, 0, 64, 32)

	SU.setColorFromTable(background_rgb)
	drawRF(1, 1, 62, 7)
	drawRF(1, 9, 43, 22)
	drawRF(45, 9, 18, 22)

	SU.setColorFromTable(textfield_rgb)
	drawRF(2, 2, 60, 5)
	drawRF(2, 10, 41, 5)
	drawRF(2, 17, 41, 5)
	drawRF(2, 24, 41, 5)
	drawRF(46, 10, 16, 5)
	drawRF(46, 17, 16, 5)
	drawRF(46, 24, 16, 5)

	SU.setColorFromTable(text_rgb)
	TT.drawTextCompact(3, 2, "ENGINE")
	TT.drawTextCompact(34, 2, "STATUS")
	TT.drawTextCompact(2, 17, "TEMP")
	TT.drawTextCompact(2, 24, "FUEL")
	if DoRpm then
		TT.drawTextCompact(2, 10, "RPM")
	else
		TT.drawTextCompact(2, 10, "RPS")
	end
	if DoFarenheit then
		--DT.drawImageFromHex(39,17,1,5,"83464")
		drawRF(39, 17, 1, 1)
		drawRF(41, 18, 2, 1)
		drawRF(41, 20, 1, 1)
		drawRF(40, 19, 1, 3)
	else
		--DT.drawImageFromHex(39,17,1,5,"83443")
		drawRF(39, 17, 1, 1)
		drawRF(41, 18, 2, 1)
		drawRF(41, 21, 2, 1)
		drawRF(40, 19, 1, 2)
	end

	-- draw real time data
	TT.drawTextCompact(43, 10, TT.numberToString(Rps, "%.2f", 4), true)
	TT.drawTextCompact(38, 17, TT.numberToString(Temp, "%.1f", 3), true)
	-- fuel % text
	local text = TT.numberToString(FuelPerc, "%.1f", 3) .. "%"
	if FuelPerc >= 100 then
		text = "MAX"
	end
	TT.drawTextCompact(43, 24, text, true)
	-- gear text
	if Gear == 0 then
		text = "N"
		screen.drawText(53, 10, "-")
	else
		if Gear > 0 then
			text = "D"
		elseif Gear < 0 then
			text = "R"
		end
		TT.drawTextCompact(53, 10, TT.numberToString(math.abs(Gear), "%d", 2))
	end
	screen.drawText(46, 10, text)

	TT.drawTextCompact(46, 24, TT.numberToString(FuelPerSecond, "%.2f", 4))

	--draw indicators

	SU.setColorFromTable(indicator_rgb)

	if FuelInd then
		--DT.drawImageFromHex(48,17,2,5,"F098F4F4F4")
		drawRF(48,17,4,1)
		drawRF(48,18,1,1)
		drawRF(51,18,2,1)
		drawRF(48,19,4,3)
		drawRF(53,19,1,3)
	end
	if TempInd then
		--DT.drawImageFromHex(56,17,1,5,"464EE")
		drawRF(57,17,1,3)
		drawRF(58,18,1,1)
		drawRF(56,20,3,2)
	end

	
end
