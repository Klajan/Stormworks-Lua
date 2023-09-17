
local Gear_Up_Cooldown = 0.3 * 60
local Gear_Down_Cooldown = 0.3 * 60
local Min_Clutch = 0.6
local Clutch_Delta = 0.1

local RPS_Upper_Threshold = property.getNumber("Upper RPS Threshold")
local RPS_Lower_Threshold= property.getNumber("Lower RPS Threshold")
local Max_Gears = 2^property.getNumber("Number of Gearboxes")
local AutomaticGearChange = property.getBool("Gearbox Setting")

-- internal use
local Gear = 0
local Clutch = 0
local GearChange_allowed = true
local GearChange_cooldown = 0
local GearChange_delta = 0
local GearChange_queued = false
-- Tick function that will be executed every logic tick
function onTick()
	-- get RPS
	local rps = input.getNumber(1)
	local throttle = input.getNumber(2)
	local neutral = input.getBool(1)
	local manual_gear_down = input.getBool(2)
	local manual_gear_up = input.getBool(3)

	if neutral then
		GearNeutral()
	elseif GearChange_queued then
		HandleGearChange()
	elseif ShouldShiftUp(rps) or manual_gear_up then
		GearUp()
		GearChange_allowed = false
	elseif ShouldShiftDown(rps) or manual_gear_down then
		GearDown()
		GearChange_allowed = false
	elseif GearChange_cooldown <= 0 then
		GearChange_allowed = true
	else
		GearChange_cooldown = GearChange_cooldown - 1
	end

	-- send current gear on Output 1
	output.setNumber(1, Gear)
	-- send clutch engagement on Output 2
	output.setNumber(2, Clutch)
end
-- in case of more complex behavior function can be extended
function ShouldShiftUp(rps)
	return AutomaticGearChange and (rps > RPS_Upper_Threshold) and GearChange_allowed
end
-- in case of more complex behavior
function ShouldShiftDown(rps)
	return AutomaticGearChange and (rps < RPS_Lower_Threshold) and GearChange_allowed
end

function GearUp()
	if Gear < Max_Gears then
		GearChange_delta = 1
		GearChange_cooldown = Gear_Up_Cooldown
		GearChange_queued = true
	end
end

function GearDown()
	if Gear > 1 then
		GearChange_delta = -1
		GearChange_cooldown = Gear_Down_Cooldown
		GearChange_queued = true
	end
end

function GearNeutral()
	Gear = 0
	Clutch = SmoothClutch(Clutch, 0, Clutch_Delta)
end

function SmoothClutch(start, target, delta)
	if target < start then
		local out = math.max(start - delta, target)
		return out, (out <= target) or (out <= 0)
	elseif target > start then
		local out = math.min(start + delta, target)
		return out, (out >= target) or (out >= 1)
	end
	return start, true
end

function HandleGearChange()
	if GearChange_delta ~= 0 then
		local val, reached = SmoothClutch(Clutch, Min_Clutch, Clutch_Delta)
		Clutch = val
		if reached then
			Gear = Gear + GearChange_delta
			GearChange_delta = GearChange_delta - GearChange_delta
		end
	else
		local val, reached = SmoothClutch(Clutch, 1, Clutch_Delta)
		Clutch = val
		if reached then
			GearChange_queued = false
		end
	end
end