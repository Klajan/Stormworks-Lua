-- Author: Klajan
-- GitHub: https://github.com/Klajan
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section SegmentDisplays 1 _SegmentDisplays_
SegmentDisplays = {
	---@section _7Segment 2 _7SEGMENT_
	_7Segment = {
		---Draw a seven segment display
		---@param x number
		---@param y number
		---@param input integer
		---@param scale? integer defaults to 2, scale=1 is barely readable
		---@section draw7Segment
		draw7Segment = function(x, y, input, scale)
			scale = scale or 2              -- scale of 1 barely works for most numbers
			local masks = { 1, 2, 4, 8, 16, 32, 64 } -- { 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40 }
			local segments = { { 2, 1, scale, 1 }, { 2 + scale, 2, 1, scale }, { 2 + scale, 3 + scale, 1, scale },
				{ 2, 3 + 2 * scale, scale, 1 }, { 1, 3 + scale, 1, scale }, { 1, 2, 1, scale }, { 2, 2 + scale,
				1 * scale, 1 } } --base layout: {2,1,1,1},{3,2,1,1},{3,4,1,1},{2,5,1,1},{1,4,1,1},{1,2,1,1},{2,3,1,1}
			for index, value in ipairs(masks) do
				if (input & value) ~= 0 then
					local seg = segments[index]
					screen.drawRectF(x + seg[1] - 1, y + seg[2] - 1, seg[3], seg[4])
				end
			end
		end,

		---comment
		---@param number integer
		---@return integer
		---@segment numberTo7Segment
		numberTo7Segment = function(number)
			local decoder = { 6, 91, 79, 102, 109, 127, 7, 127, 111 } -- { 0x6, 0x5B, 0x4F, 0x66, 0x6D, 0x7F, 0x7, 0x7F, 0x6F }
			decoder[0] = 63                                  -- 0x3F
			return decoder[number] or 0
		end,
		---@endsection
	},
	---@endsection _7SEGMENT_
}
---@endsection _SegmentDisplays_
