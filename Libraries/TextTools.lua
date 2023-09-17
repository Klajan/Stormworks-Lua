-- Author: Klajan
-- GitHub: https://github.com/Klajan
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---Draw Text more compact (non monospace)
---@param x number The X Coordinate to the top left of the text
---@param y number The Y Coordinate to the top left of the text
---@param text string The text to draw
---@param alignRight? boolean Aligns text right. X,Y are now top right of the text
---@section drawTextCompact_Deprecated
function drawTextCompact_Deprecated(x, y, text, alignRight)
	local offsets = CompactText_Offsets
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

CompactText_Offsets = {
	["I"] = { -1, -2 },
	["T"] = { 0, -1 },
	["."] = { -1, -2 }
}

---@endsection

---@class TextTools
---@section TextTools 1 _TEXTTOOLS_
TextTools = {

	---@section _ 2 _PRIVATE_
	_ = {
		---Unpacks offsets for compact text.
		---Format is "abc"; a = ASCII character, b = left offset, c = right offset.
		---@param str string -- hex string to unpack to table.
		---@return table -- Returns the unpacked hex offset table
		---@section unpackOffsets
		unpackOffsets = function(str)
			local output = {}
			while true do
				if str:len() < 3 then
					return output
				end
				local char, left, right = string.unpack("BBB", str:sub(1, 3))
				output[string.char(char)] = { left, right }
				str = str:sub(4)
			end
		end,
		---@endsection
		---@section CompactTextOffsetTable
		PackedOffsets = "I\1\2T\0\1.\1\2 \3\0";
		CompactTextOffsetTable = nil,
		---@endsection
	},
	---@endsection _PRIVATE_

	---@section drawTextCompact

	---Draw Text more compact (non monospace)
	---@param x number The X Coordinate to the top left of the text
	---@param y number The Y Coordinate to the top left of the text
	---@param text string The text to draw
	---@param alignRight? boolean Aligns text right. X,Y are now top right of the text
	drawTextCompact = function(x, y, text, alignRight)
		local _ = TextTools._
		_.CompactTextOffsetTable = _.CompactTextOffsetTable or _.unpackOffsets(_.PackedOffsets)
		local offsets =  _.CompactTextOffsetTable or {}
		local width = 5
		local next = 0
		if alignRight then
			text = text:reverse()
			width = -width
			x = x + width + 1
		end
		text = text:upper()
		for char in text:gmatch(".") do
			next = 0
			if not alignRight then
				if offsets[char] then
					x = x - offsets[char][1]
					next = -offsets[char][2]
				end
			else
				if offsets[char] then
					x = x + offsets[char][2]
					next = offsets[char][1]
				end
			end
			screen.drawText(x, y, char)
			x = x + width + next
		end
	end,

	---Formats a number according to formatString and returns the string with trailing . removed
	---@param number number Number to process
	---@param formatString string Format string (see string.format)
	---@param maxLength number Maximum string length
	---@return string
	---@section numberToString
	numberToString = function(number, formatString, maxLength)
		local text = string.format(formatString, number)
		if not maxLength or (text:len() < maxLength) then
			return text
		end
		text = text:sub(1, maxLength)
		local dotPosition = text:find("%p")
		if dotPosition and (dotPosition == maxLength) then
			text = text:sub(1, maxLength - 1)
		end
		return text
	end;
	---@endsection
}
---@endsection _TEXTTOOLS_
