-- Set desired pitch based on altitude

-- ADVANCED PID CONTROLLER BY GAVIN DISTASO (Potoo) --

-- code inspired by https://www.reddit.com/r/Stormworks/comments/kei6pg/lua_code_for_a_basic_pid/ --

-- HOW TO USE: --
-- * set 'kp', 'ki', 'kd', and 'bias' below
-- * if you're having an integral windup issue set 'antiWindup' to true
-- * set min and max values for your output (this is necessary for anti-windup to work)

-- * composite boolean input 1 to disable when true *
-- * composite number input 1 is setpoint *
-- * composite number input 2 is variable *
-- * composite number output 1 is PID out *

-- I recommend using 'NJ PID TUNER' if you don't know how to get P, I, and D values
-- 'NJ PID TUNER' can be found here: https://steamcommunity.com/sharedfiles/filedetails/?id=2354403971

-- EDIT THIS --
local kp = 0.55
local ki = 0.00525
local kd = 0.0
local bias = 1
local antiWindup = true

local minOutput = -1.5
local maxOutput = 7

local reset_on_disable = true

-- internal use only --
local errorPrior = 0
local integralPrior = 0
local antiWindupClamp = false

function onTick()

	local disable = input.getBool(1)
	if disable then
		output.setNumber(1, 0)
		if reset_on_disable then
			errorPrior = 0
			integralPrior = 0
			antiWindupClamp = false
		end
	else
		setpoint = input.getNumber(1)
		variable = input.getNumber(2)
		--
		error = setpoint - variable
		derivative = error - errorPrior

		--
		if(not antiWindup or not antiWindupClamp) then
			integral = integralPrior + error
		elseif(antiWindupClamp) then
			integral = integralPrior
		end

		--
		out = kp * error + ki * integral + kd * derivative + bias
		clampedOut = math.max(math.min(out, maxOutput), minOutput)

		--
		output.setNumber(1, clampedOut)

		--
		-- * if you want to understand what anti-windup is and how this anti-windup works go here:
		-- * https://www.mathworks.com/videos/understanding-pid-control-part-2-expanding-beyond-a-simple-integral-1528310418260.html
		antiWindupClamp = (out ~= clampedOut) and (sign(error) == sign(out))

		--

		errorPrior = error
		integralPrior = integral
	end
end

function sign(x)
	if(x > 0) then return 1
	elseif(x == 0) then return 0
	else return -1 end
end