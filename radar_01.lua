-- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
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
	simulator:setScreen(1, "2x2")
	simulator:setProperty("Total Fuel", 100)
	simulator:setProperty("Temperature Unit", false)
	simulator:setProperty("RPS Unit", false)

	-- Runs every tick just before onTick; allows you to simulate the inputs changing
	---@param simulator Simulator Use simulator:<function>() to set inputs etc.
	---@param ticks     number Number of ticks since simulator started
	function onLBSimulatorTick(simulator, ticks)
		-- touchscreen defaults
        rot = rot or 0
        rot = math.fmod(rot + 0.005, 1)
        target = false
        target_t = 0
		local screenConnection = simulator:getTouchScreen(1)
        if ticks % 600 <= 10 then
            target = true
            target_t = math.max(ticks % 600 - 1,0)
        end
		simulator:setInputBool(1, target)
		simulator:setInputNumber(31, rot)
        simulator:setInputNumber(27, 5000)
		simulator:setInputNumber(2, 0.1)
		simulator:setInputNumber(1, 500)
		simulator:setInputNumber(4, target_t)

		-- NEW! button/slider options from the UI
		--simulator:setInputBool(31, simulator:getIsClicked(1))     -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
		--simulator:setInputNumber(31, simulator:getSlider(1))      -- set input 31 to the value of slider 1

		--simulator:setInputBool(32, simulator:getIsToggled(2))     -- make button 2 a toggle, for input.getBool(32)
		--simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
	end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

EXPONENT = property.getNumber("distance scaling") or 1
CLOCKWISE_ROT = property.getBool("clockwise rotation") or true
FADE = property.getNumber("fade speed") or 0.005
PI2 = math.pi*2
-- tables
UUID = 0
TARGETS = {}
TARGETS_PRE = {}
ANGLES = {}
-- Tick function that will be executed every logic tick
function onTick()
    Radar_Range = input.getNumber(27)
    Radar_Rangle_Scaled = Radar_Range^EXPONENT
	local rotation_input = input.getNumber(31)
	Radar_Rotation = math.fmod(math.abs(1.5-rotation_input)*PI2, PI2)

	for i=1, 8 do
		local target = input.getBool(i)
        local target_distance = input.getNumber((i*4)-3)
        local target_angle = math.fmod((input.getNumber((i*4)-2)+1.5)*PI2, PI2)
        local target_time = input.getNumber((i*4))
		if target and target_time == 0 then
            -- new target found
            TARGETS_PRE[i] = {
                UUID,
                target_distance,
                target_angle
            }
            UUID = UUID + 1
        elseif target and target_time <= 10 then
            -- average values over time
            TARGETS_PRE[i][2] = (TARGETS_PRE[i][2] + target_distance) / 2
            TARGETS_PRE[i][3] = (TARGETS_PRE[i][3] + target_angle) / 2
        elseif TARGETS_PRE[i] then
            -- add final values to output array
            local id = TARGETS_PRE[i][1]
            local distance = TARGETS_PRE[i][2]
            local angle = TARGETS_PRE[i][3]
            -- calculate target x & y
            local distance_percent = (distance^EXPONENT)/Radar_Rangle_Scaled
            local tx = distance_percent * math.sin(angle)
            local ty = distance_percent * math.cos(angle)
            local angle_short = math.floor(angle*100)/100
            local angle2 = 2
            ANGLES[angle_short] = {id, tx, ty}
            TARGETS_PRE[i] = nil
        end
	end

    local rotation_short = math.floor(Radar_Rotation*10)/10
    -- display after sweep has passed
    if ANGLES[rotation_short] then
        local id = ANGLES[rotation_short][1]
        local tx = ANGLES[rotation_short][2]
        local ty = ANGLES[rotation_short][3]
        TARGETS[id] = {tx, ty, 1}
        ANGLES[rotation_short] = nil
    end
end
-- Draw function that will be executed when this script renders to a screen
function onDraw()
	w = screen.getWidth()
	h = screen.getHeight()
	radius = (w/2)-1
	x1 = w/2 + radius * math.sin(Radar_Rotation) -- Get X & Y Postitions of rotated line
	y1 = h/2 + radius * math.cos(Radar_Rotation)
	screen.setColor(0,10,0)
	screen.drawLine(w/2, 0, w/2, h)
	screen.drawLine(0, h/2, w, h/2)
	screen.setColor(0,200,0)
	screen.drawCircle(w/2, h/2, radius)
	screen.setColor(0,10,0)
	screen.drawCircle(w/2, h/2, radius*((math.floor(Radar_Range*0.1/100)*100)^EXPONENT)/Radar_Rangle_Scaled)
	screen.drawCircle(w/2, h/2, radius*((math.floor(Radar_Range*0.5/100)*100)^EXPONENT)/Radar_Rangle_Scaled)
	screen.setColor(0,200,0)
	screen.drawLine(w/2, h/2, x1, y1)	-- Draw rotating Radar Line
	-- draw radar blips with fadeout
    for id, array in pairs(TARGETS) do
        local mult = array[3]
        screen.setColor(255, 255, 255, math.floor(255*mult))
        TARGETS[id][3] = mult - FADE
        local tx = array[1]
        local ty = array[2]
        screen.drawRectF(w/2 + radius * tx, w/2 + radius * ty, 1, 1)
        if mult <= FADE then
            TARGETS[id] = nil
        end
    end
end