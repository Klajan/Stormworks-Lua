-- Converts a unsinged integer to 32 bit binary
-- Integer is clamped instead of overflowing

local prev_number = -1
local binary = {}

function onTick()
    local number_in = math.floor(clamp(input.getNumber(1), 0, 4294967295))

    if number_in ~= prev_number then
        local number = number_in
        for i = 1, 32, 1 do
            local bit = ((number % 2) > 0)
            number = math.floor(number / 2)
            binary[i] = bit
        end
    end
    for i = 1, 32, 1 do
        output.setBool(i, binary[i])
    end
end

function clamp(x, min, max)
    return math.min(math.max(x, min), max)
end