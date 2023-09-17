-- Author: Klajan
-- GitHub: https://github.com/Klajan
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---Class for
---@class ScreenUtilities
---@section ScreenUtilities 1 _ScreenUtilities_
ScreenUtilities = {
	---Apply Gamma Correction to RGB Values
	---@param r number
	---@param g number
	---@param b number
	---@param a? number
	---@return table
	---@section applyGammaCorrection
	applyGammaCorrection = function(r, g, b, a)
		a = a or 255
		r = r ^ 2.2 / 255 ^ 2.2 * r
		g = g ^ 2.2 / 255 ^ 2.2 * g
		b = b ^ 2.2 / 255 ^ 2.2 * b
		return { r, g, b, a }
	end,
	---@endsection

	---Parse hex string to rgba colors
	---@param hex string Hex string to parse. no leading 0x
	---@return table
	---@section hexToRGBA
	hexToRGBA = function(hex)
		local n, r, g, b, a = tonumber(hex, 16)
		if hex:len() > 6 then
			a = n & 255 -- 0xFF
			n = n >> 8
		end
		r = n & 255
		g = (n >> 8) & 255
		b = (n >> 16) & 255
		return { r, g, b, a }
	end,
	---@endsection

	---Set screen color from supplied table
	---@param rgba table RGB(A) values in table
	---@section setColorFromTable
	setColorFromTable = function(rgba)
		screen.setColor(table.unpack(rgba))
	end,
	---@endsection
}
---@endsection _ScreenUtilities_
