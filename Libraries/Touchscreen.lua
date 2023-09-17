-- Author: Klajan
-- GitHub: https://github.com/Klajan
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section TouchscreenTools 1 _TOUCHSCREENTOOLS_
TouchscreenTools = {
    ---Checks if Point is within a rectangle
    ---@param x any
    ---@param y any
    ---@param rectX any
    ---@param rectY any
    ---@param rectWidth any
    ---@param rectHeight any
    ---@return boolean
    ---@section isPointInRectangle
    isPointInRectangle = function(x, y, rectX, rectY, rectWidth, rectHeight)
        return x > rectX and x < rectX+rectWidth and y > rectY and y < rectY+rectHeight;
    end;
    ---@endsection
}
---@endsection _TOUCHSCREENTOOLS_