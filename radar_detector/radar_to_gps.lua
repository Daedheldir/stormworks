-- Author: Daedheldir
-- GitHub: https://github.com/Daedheldir
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA

require("channels")

--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
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
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.TARGET_ID, 1)
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.TARGET_DISTANCE, 1000)
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.TARGET_AZIMUTH, simulator:getSlider(1) - 0.5)
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.TARGET_ELEVATION, simulator:getSlider(2) * 0.5 - 0.25)
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.BASE_GPS_X, 20 * (simulator:getSlider(3) - 0.5))
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.BASE_GPS_Y, 20 * (simulator:getSlider(4) - 0.5))
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.BASE_GPS_Z, 20 * (simulator:getSlider(5) - 0.5))
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.BASE_COMPASS_HEADING, simulator:getSlider(6) - 0.5)
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.RADAR_X_TILT, simulator:getSlider(7) - 0.5)
        simulator:setInputNumber(CHANNELS.RADAR_TO_GPS.NUMBER.INPUT.RADAR_Z_TILT, simulator:getSlider(8) - 0.5)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("RadarTarget")
require("MathAdditions")
require("LifeBoatAPI.Maths.LBVec")
require("LifeBoatAPI.Maths.LBMaths")

INPUT_NUM = CHANNELS.RADAR_TO_GPS.NUMBER.INPUT

function onTick()
    local target_id = input.getNumber(INPUT_NUM.TARGET_ID)
    local target_azimuth = input.getNumber(INPUT_NUM.TARGET_AZIMUTH)
    local target_elevation = input.getNumber(INPUT_NUM.TARGET_ELEVATION)
    local target_distance = input.getNumber(INPUT_NUM.TARGET_DISTANCE)

    local base_gps = LifeBoatAPI.LBVec:new(
        input.getNumber(INPUT_NUM.BASE_GPS_X),
        input.getNumber(INPUT_NUM.BASE_GPS_Y),
        input.getNumber(INPUT_NUM.BASE_GPS_Z)
    )
    local compass_heading = input.getNumber(INPUT_NUM.BASE_COMPASS_HEADING)
    local tilt_x = input.getNumber(INPUT_NUM.RADAR_X_TILT) -- pitch
    local tilt_z = input.getNumber(INPUT_NUM.RADAR_Z_TILT) -- roll

    local target_global_gps = LifeBoatAPI.LBVec.globalGPSFromAzimuthElevationDistance(target_azimuth, target_elevation, target_distance, base_gps, compass_heading, tilt_z, tilt_x)

    output.setNumber(1, target_global_gps.x)
    output.setNumber(2, target_global_gps.y)
    output.setNumber(3, target_global_gps.z)
end
