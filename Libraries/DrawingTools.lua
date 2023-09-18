-- Author: Klajan
-- GitHub: https://github.com/Klajan
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section DarkModeColorScheme
local background_rgb = { 0.270645, 0.679522, 2.487113 } --Gamma Corrected #1e283c
local textfield_rgb = { 0.679522, 1.387764, 4.073102 }  --Gamma Corrected #283246
local border_rgb = { 1.882661, 3.213175, 9.103065 }     --Gamma Corrected #37415a
local text_rgb = { 1.478551, 255, 0 }                   --Gamma Corrected #33ff00
DarkModeColorScheme = { background_rgb, textfield_rgb, border_rgb, text_rgb }
---@endsection

---@endsection

---@section DrawingTools 1 _DrawingTools_
DrawingTools = {
	drawPointer = function(x, y, size, rotation, width) -- position x,y, size, direction, angle/width of the arrow (optional)
		width = (width or 30) * math.pi / 360
		x = x + size / 2 * math.sin(rotation)
		y = y - size / 2 * math.cos(rotation)
		screen.drawTriangleF(x, y, x - size * math.sin(rotation + width), y + size * math.cos(rotation + width),
			x - size * math.sin(rotation - width), y + size * math.cos(rotation - width))
	end,
	---Draws any Image (4n x 1n) from a hex string. Each byte represents if the pixel should be drawn (1) or not (0)
	---@param x number
	---@param y number
	---@param rows number
	---@param columns number
	---@param hex string
	---@section drawImageFromHex
	drawImageFromHex = function(x, y, columns, rows, hex)
		local mask = 2 ^ (4 * columns) - 1         -- precalculate mask to prevent unecessary pow calculations
		for i = 0, rows - 1, 1 do
			local bytes = tonumber(hex:sub(1, columns), 16) -- get all bytes in a row
			local j = 0
			while bytes and bytes ~= 0 do
				local w = 0
				while ((bytes << w) & (0x8 << (4 * (columns - 1)))) ~= 0 do -- bitshift left until 0 bit is found on leftmost position
					w = w + 1
				end
				if w > 0 then
					screen.drawRectF(x + j, y + i, w, 1)
				else
					w = 1
				end
				bytes = (bytes << w) & mask -- drop processed bytes to the left
				j = j + w
			end
			hex = hex:sub(columns + 1)
		end
	end,
	---@endsection
}
---@endsection _DrawingTools_
