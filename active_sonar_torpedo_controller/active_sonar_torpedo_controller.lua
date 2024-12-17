--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA

ticks = 1

--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
torpedo_yaw = 0
torpedo_previous_yaw = 0

test_yaws = {-0.01,0.01}
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        rand = LifeBoatAPI.LBRandom:new()
        --t1_yaw = math.fmod(0 + ticks/1000, 0.2) -0.2
        t1_yaw = 0.1
        --simulator:setInputNumber(1, t1_yaw - torpedo_yaw)
        simulator:setInputNumber(1, test_yaws[1+math.fmod(ticks, #test_yaws)])
        --simulator:setInputNumber(1, 0.1)--math.fmod(torpedo_yaw + 0.3 * math.cos(ticks / 10), 0.5))
        simulator:setInputNumber(2, 0.01)
        simulator:setInputNumber(3, torpedo_yaw + 0.3 * math.sin(ticks / 10))
        simulator:setInputNumber(4, -0.01)
        simulator:setInputNumber(5, 0)
        simulator:setInputNumber(6, 0)
        simulator:setInputNumber(7, 0.25)
        simulator:setInputNumber(8, 0.2)

        simulator:setInputBool(1, true)
        simulator:setInputBool(2, false)
        simulator:setInputBool(3, false)
        simulator:setInputBool(4, false)

        simulator:setProperty("APN Gain", 1)
        simulator:setProperty("Target Velocity Multiplier", 1)
        simulator:setProperty("APN Min Azimuth", 1)
        simulator:setProperty("APN Max Azimuth", 45)
        simulator:setProperty("Detection Azimuth Limit", 360)
        simulator:setProperty("Target Position Prediction Gain", 1)
        simulator:setProperty("Data Averaging Period", 1)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

require("LifeBoatAPI")
require("MathAdditions")

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!


function getTargetsInYawRange(max_yaw, target_count)
    local found_targets = {}
    for i = 1, target_count, 1 do
        --if target not found
        if not input.getBool(i) then
            goto continue
        end
        --add all found targets to an array
        local target_number = i + i - 1
        local t_yaw = input.getNumber(target_number) * 360
        if t_yaw < max_yaw and t_yaw > -max_yaw then
            table.insert(found_targets, {
                number = target_number,
                yaw = t_yaw,
                pitch = input.getNumber(target_number + 1)
            })
        end

        ::continue::
    end
    return found_targets
end

function sortTargetsByYawDifferences(targets)
    -- loop through found targets and select the one that is closest to the previously selected target
    local yaw_differences_arr = {}
    for key, target in pairs(targets) do
        table.insert(yaw_differences_arr, { predicted_future_target_yaw - target.yaw, target })
    end

    table.sort(yaw_differences_arr, function(left, right)
        return math.abs(left[1]) < math.abs(right[1])
    end)
    return yaw_differences_arr
end

function calculateTargetRelativeAngularVelocityPerSecond(current_target_yaw, previous_target_yaw)
    return (current_target_yaw - previous_target_yaw) / LifeBoatAPI.LBMaths.lbmaths_ticksToSeconds -- conversion to degrees per second
end

function calculateTargetAbsoluteAngularVelocityPerSecond(relative_angular_velocity, vessel_angular_velocity)
    return relative_angular_velocity + vessel_angular_velocity -- in degrees per second
end

local DATA_AVERAGING_PERIOD = property.getNumber("Data Averaging Period")

previous_target = {
    number = -1,
    yaw = 0,
    pitch = 0,
    yaw_relative_rate = 0,
    yaw_actual_rate = 0
}
predicted_future_target_yaw = 0

yaw_relative_average = LifeBoatAPI.LBRollingAverage:new(DATA_AVERAGING_PERIOD)
yaw_actual_average = LifeBoatAPI.LBRollingAverage:new(DATA_AVERAGING_PERIOD)
angular_velocity_average = LifeBoatAPI.LBRollingAverage:new(DATA_AVERAGING_PERIOD)
current_target_yaw_average = LifeBoatAPI.LBRollingAverage:new(DATA_AVERAGING_PERIOD)
desired_azimuth_change_average = LifeBoatAPI.LBRollingAverage:new(DATA_AVERAGING_PERIOD)
--yi+1 = N(lambdai+1 - lambdai) + yi

function onTick()
    ticks = ticks + 1
    local APN_GAIN = property.getNumber("PN Gain")
    local TARGET_DETECTION_AZIMUTH_LIMIT = property.getNumber("Detection Azimuth Limit")
    angular_velocity_average:lbrollingaverage_addValue(input.getNumber(31)*360)-- torpedo turn rate in degrees / second

    local found_targets = getTargetsInYawRange(TARGET_DETECTION_AZIMUTH_LIMIT, 14)

    if #found_targets <= 0 then
        previous_target = {
            number = -1,
            yaw = 1,
            pitch = 0,
            yaw_relative_rate = 0,
            yaw_actual_rate = 0,
        }
        return
    end

    local yaw_differences_arr = sortTargetsByYawDifferences(found_targets)
    local current_target = yaw_differences_arr[1][2]

    current_target_yaw_average:lbrollingaverage_addValue(current_target.yaw)
    current_target.yaw = current_target_yaw_average.average
    yaw_relative_average:lbrollingaverage_addValue(calculateTargetRelativeAngularVelocityPerSecond(current_target.yaw, previous_target.yaw))
    current_target.yaw_relative_rate = yaw_relative_average.average
    
    yaw_actual_average:lbrollingaverage_addValue(calculateTargetAbsoluteAngularVelocityPerSecond(current_target.yaw_relative_rate, angular_velocity_average.average))
    current_target.yaw_actual_rate = yaw_actual_average.average
    predicted_future_target_yaw = current_target.yaw + current_target.yaw_relative_rate

    --desired azimuth change in degrees per second
    desired_azimuth_change_average:lbrollingaverage_addValue(APN_GAIN * current_target.yaw_actual_rate)
    output.setNumber(1, math.clamp(-1,1,desired_azimuth_change_average.average / LifeBoatAPI.LBMaths.lbmaths_secondsToTicks))
    output.setNumber(2, current_target.pitch)
    output.setNumber(3, current_target.yaw)
    output.setNumber(4, current_target.number)
    output.setNumber(5, angular_velocity_average.average)
    output.setNumber(6, current_target.yaw_actual_rate)
    output.setNumber(7, current_target.yaw_relative_rate)
    previous_target = current_target
end


-- ISSUE: HAS TROUBLE WITH MANOUVERING ENEMIES