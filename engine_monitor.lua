local DoRpm = property.getBool("RPS Unit")
local DoFarenheit = property.getBool("Temperature Unit")
local TotalFuel = property.getNumber("Total Fuel")
-- Tick function that will be executed every logic tick
function onTick()
	Rps = input.getNumber(1)
	Temp = input.getNumber(2)
	Fuel = input.getNumber(3)
	Gear = input.getNumber(11) -- from transmition input
	if DoFarenheit then
		Temp = (Temp * 9 / 5) + 32
	end
	if DoRpm then
		Rps = Rps * 60
	end
	FuelPerc = math.floor((Fuel / TotalFuel * 100) + 0.5)
end

-- Draw function that will be executed when this script renders to a screen
function onDraw()
	local c_background = { 0, 0, 10 }
	local c_border = { 0, 0, 0 }
	local c_textfield = { 0, 0, 5 }
	local c_text = { 0, 64, 0 }
	local width = 64
	local height = 32

	-- draw static elements
	setColorFromTable(c_border)
	screen.drawRectF(0, 0, 64, 32)

	setColorFromTable(c_background)
	screen.drawRectF(1, 1, 62, 7)
	screen.drawRectF(1, 9, 43, 22)
	screen.drawRectF(45, 9, 18, 22)

	setColorFromTable(c_textfield)
	screen.drawRectF(2, 2, 60, 5)
	screen.drawRectF(2, 10, 41, 5)
	screen.drawRectF(2, 17, 41, 5)
	screen.drawRectF(2, 24, 41, 5)
	screen.drawRectF(46, 10, 16, 5)
	screen.drawRectF(46, 17, 16, 5)
	screen.drawRectF(46, 24, 16, 5)

	setColorFromTable(c_text)
	drawTextCompact_Deprecated(3, 2, "ENGINE")
	drawTextCompact_Deprecated(34, 2, "STATUS")
	drawTextCompact_Deprecated(2, 17, "TEMP")
	drawTextCompact_Deprecated(2, 24, "FUEL")
	if DoRpm then
		drawTextCompact_Deprecated(2, 10, "RPM")
	else
		drawTextCompact_Deprecated(2, 10, "RPS")
	end
	if DoFarenheit then
		screen.drawRectF(39, 17, 1, 1)
		screen.drawRectF(41, 18, 2, 1)
		screen.drawRectF(41, 20, 1, 1)
		screen.drawRectF(40, 19, 1, 3)
	else
		screen.drawRectF(39, 17, 1, 1)
		screen.drawRectF(41, 18, 2, 1)
		screen.drawRectF(41, 21, 2, 1)
		screen.drawRectF(40, 19, 1, 2)
	end

	-- draw real time data
	drawTextCompact_Deprecated(43, 10, numberToString(Rps, "%.2f", 4), true)
	drawTextCompact_Deprecated(37, 17, numberToString(Temp, "%.1f", 3), true)
	-- fuel % text
	local text = numberToString(FuelPerc, "%.1f", 3) .. "%"
	if FuelPerc >= 100 then
		text = "MAX"
	end
	drawTextCompact_Deprecated(43, 24, text, true)
	-- gear text
	text = "N"
	if Gear > 0 then
		text = "D"
	elseif Gear < 0 then
		text = "R"
	end
	screen.drawText(46, 10, text)
	screen.drawRectF(51, 12, 1, 1)
	drawTextCompact_Deprecated(53, 10, numberToString(Gear, "%d", 2))
end

function setColorFromTable(array)
	screen.setColor(table.unpack(array))
end

function numberToString(num, formatString, maxLength)
	local text = string.format(formatString, num)
	if text:len() < maxLength then
		return text
	end
	local dot = text:find("%p")
	if dot and (dot == maxLength) then
		return text:sub(1, maxLength - 1)
	end
	return text:sub(1, maxLength)
end

function drawTextCompact_Deprecated(x, y, text, alignRight)
	local offsets = {
		I = { -1, -2 },
		T = { 0, -1 },
		["."] = { -1, -2 }
	}
	local next = 5
	local next_offset = 0
	if alignRight then
		text = text:reverse()
		next = -next
		x = x + next + 1
	end
	text = text:upper()
	for char in text:gmatch(".") do
		next_offset = 0
		if not alignRight then
			if offsets[char] then
				x = x + offsets[char][1]
				next_offset = offsets[char][2]
			end
		else
			if offsets[char] then
				x = x - offsets[char][2]
				next_offset = -offsets[char][1]
			end
		end
		screen.drawText(x, y, char)
		x = x + next + next_offset
	end
end
---@section SC
function applyGammaCorrection(r, g, b, a)
	if a == nil then a = 255 end
	r = r ^ 2.2 / 255 ^ 2.2 * r
	g = g ^ 2.2 / 255 ^ 2.2 * g
	b = b ^ 2.2 / 255 ^ 2.2 * b
	screen.setColor(r, g, b, a)
end
---@endsection