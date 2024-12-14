--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA

ticks = 0

--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
torpedo_yaw = 0
torpedo_previous_yaw = 0
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
        simulator:setInputNumber(1, -0.25 + math.fmod((torpedo_yaw/360) + rand:lbrandom_next() + (ticks / 360) / 20, 1))
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
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

require("LifeBoatAPI")
require("MathAdditions")

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

previous_target = {
    number = -1,
    yaw = 0,
    pitch = 0,
    yaw_relative_velocity = 0,
    yaw_actual_velocity = 0
}
predicted_future_target_yaw = 0
ANGULAR_YAW_VELOCITY = 0
avg_yaw_velocity = LifeBoatAPI.LBRollingAverage:new(60)
avg_angular_velocity = LifeBoatAPI.LBRollingAverage:new(30)
previous_target_yaw_average = LifeBoatAPI.LBRollingAverage:new(30)


--Over Time Average
-- By Multiversal USB on Steam/Unimposed on Youtube
function onTick()
    ticks = ticks + 1

    AZIMUTH_HOLD_GAIN = property.getNumber("APN Gain")
    TARGET_VELOCITY_MULTIPLIER = property.getNumber("Target Velocity Multiplier")
    AZIMUTH_HOLD_MIN = property.getNumber("APN Min Azimuth")
    AZIMUTH_HOLD_MAX = property.getNumber("APN Max Azimuth")
    TARGET_DETECTION_AZIMUTH_LIMIT = property.getNumber("Detection Azimuth Limit")
    TARGET_POSITION_PREDICTION_GAIN = property.getNumber("Target Position Prediction Gain")
    ANGULAR_YAW_VELOCITY = math.deg(input.getNumber(11))
    avg_angular_velocity:lbrollingaverage_addValue(ANGULAR_YAW_VELOCITY)

    local found_targets = {}
    for i = 1, 4, 1 do
        --if target not found
        if not input.getBool(i) then
            goto continue
        end
        --add all found targets to an array
        local target_number = i + i - 1
        local t_yaw = input.getNumber(target_number) * 360
        if t_yaw < TARGET_DETECTION_AZIMUTH_LIMIT and t_yaw > -TARGET_DETECTION_AZIMUTH_LIMIT then
            table.insert(found_targets, {
                number = target_number,
                yaw = t_yaw,
                pitch = input.getNumber(target_number + 1)
            })
        end

        ::continue::
    end
    if #found_targets <= 0 then
        return
    end
    -- loop through found targets and select the one that is closest to the previously selected target
    local yaw_differences_arr = {}
    for key, target in pairs(found_targets) do
        table.insert(yaw_differences_arr, { predicted_future_target_yaw - target.yaw, target })
    end

    table.sort(yaw_differences_arr, function(left, right)
        return math.abs(left[1]) < math.abs(right[1])
    end)
    local current_target = yaw_differences_arr[1][2]
    previous_target_yaw_average:lbrollingaverage_addValue(current_target.yaw)

    current_target.yaw_relative_velocity = (current_target.yaw - previous_target_yaw_average.average) / LifeBoatAPI.LBMaths.lbmaths_ticksToSeconds -- conversion to degrees per second
    current_target.yaw_actual_velocity = current_target.yaw_relative_velocity + avg_angular_velocity.average
    predicted_future_target_yaw = current_target.yaw + (current_target.yaw_relative_velocity / LifeBoatAPI.LBMaths.lbmaths_secondsToTicks)

    avg_yaw_velocity:lbrollingaverage_addValue(current_target.yaw_actual_velocity)

    lerp_yaw = math.clamp(0, 1, (math.abs(avg_yaw_velocity.average/5) * TARGET_VELOCITY_MULTIPLIER) * AZIMUTH_HOLD_GAIN)

    local azimuth_offset = 0
    local azimuth_lerp = LifeBoatAPI.LBMaths.lbmaths_lerp(AZIMUTH_HOLD_MIN, AZIMUTH_HOLD_MAX, lerp_yaw)
    if avg_yaw_velocity.average * TARGET_VELOCITY_MULTIPLIER > 1 then
        -- if target is moving right then put it on the left of the torpedo
        azimuth_offset = azimuth_lerp
    elseif avg_yaw_velocity.average * TARGET_VELOCITY_MULTIPLIER < -1 then
        -- if target is moving left then put it on the right of the torpedo
        azimuth_offset = -azimuth_lerp
    end
    --desired azimuth change in degrees per second
    local desired_azimuth_change = azimuth_offset + (predicted_future_target_yaw * TARGET_POSITION_PREDICTION_GAIN)

    --torpedo_yaw = torpedo_yaw + ANGULAR_YAW_VELOCITY / LifeBoatAPI.LBMaths.lbmaths_secondsToTicks
    --torpedo_yaw_deg = math.deg(torpedo_yaw*LifeBoatAPI.LBMaths.lbmaths_2pi)
    --target_deg = math.deg(current_target.yaw*LifeBoatAPI.LBMaths.lbmaths_2pi)
    --torpedo_yaw = math.clamp(-170, 170, torpedo_yaw)
    --ANGULAR_YAW_VELOCITY = torpedo_previous_yaw - torpedo_yaw
    --torpedo_previous_yaw = torpedo_yaw

    output.setNumber(1, desired_azimuth_change / 180)
    output.setNumber(2, current_target.pitch)
    output.setNumber(3, current_target.number)
    output.setNumber(4, azimuth_offset)
    output.setNumber(5, avg_yaw_velocity.average)
    output.setNumber(6, current_target.yaw)
    output.setNumber(7, current_target.yaw_actual_velocity)
    output.setNumber(8, current_target.yaw_relative_velocity)

    previous_target = current_target
end
