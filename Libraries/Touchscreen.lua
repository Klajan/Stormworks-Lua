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
        return x >= rectX and x < rectX + rectWidth and y >= rectY and y < rectY + rectHeight;
    end,
    ---@endsection
}
---@endsection _TOUCHSCREENTOOLS_

---@class TouchscreenSlider
---@section TouchscreenSlider 2 _TOUCHSCREENSLIDER_
TouchscreenSlider = {
    --x = 0,
    --y = 0,
    --width = 0,
    --height = 0,
    --horizontal = false,
    --inverted = 1,
    ---comment
    ---@param class TouchscreenSlider
    ---@param x number
    ---@param y number
    ---@param width number
    ---@param height number
    ---@param sliderDirection? number Direction of the slider -2 to 2. 1 = Top->Bottom ; 2 = Left->Right ; - reverses direction
    ---@return TouchscreenSlider
    new = function(class, x, y, width, height, sliderDirection)
        sliderDirection = (sliderDirection and sliderDirection ~= 0) and sliderDirection or 1
        return {
            x = x or 0,
            y = y or 0,
            width = width or 1,
            height = height or 1,
            horizontal = math.abs(sliderDirection) == 2 and true or false,
            inverted = sliderDirection < 0 and 1 or 0,
            checkInteraction = class.checkInteraction
        }
    end,

    ---Checks if the Slider has been interacted with
    ---@param touchX number
    ---@param touchY number
    ---@return boolean
    ---@return integer
    checkInteraction = function(self, touchX, touchY)
        local hasInteracted = false
        local percent = 0
        if TouchscreenTools.isPointInRectangle(touchX, touchY, self.x, self.y, self.width, self.height) then
            hasInteracted = true
            if self.horizontal then
                percent = math.abs(self.inverted - ((touchX - self.x) / self.width))
            else
                percent = math.abs(self.inverted - ((touchY - self.y) / self.height))
            end
        end
        return hasInteracted, percent
    end
}

---@endsection _TOUCHSCREENSLIDER_
