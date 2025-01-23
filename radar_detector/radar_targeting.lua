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
INPUT_NUM = CHANNELS.RADAR_TARGETING.NUMBER.INPUT
INPUT_BOOL = CHANNELS.RADAR_TARGETING.BINARY.INPUT
OUTPUT_NUM = CHANNELS.RADAR_TARGETING.NUMBER.OUTPUT
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
        simulator:setInputBool(8, simulator:getIsToggled(1))
        simulator:setInputNumber(INPUT_NUM.SELECTED_TARGET_DISTANCE, simulator:getSlider(1) * 10000)
        simulator:setInputNumber(INPUT_NUM.SELECTED_TARGET_AZIMUTH, simulator:getSlider(2) - 0.5)
        simulator:setInputNumber(INPUT_NUM.SELECTED_TARGET_ELEVATION, simulator:getSlider(3) * 0.5 - 0.25)

        simulator:setInputBool(2, true)
        simulator:setInputNumber(4, 23000)
        simulator:setInputNumber(5, 0.02)
        simulator:setInputNumber(6, 0.08)

        simulator:setInputBool(3, true)
        simulator:setInputNumber(7, 13000)
        simulator:setInputNumber(8, 0.05)
        simulator:setInputNumber(9, 0.02)

        simulator:setInputBool(4, true)
        simulator:setInputNumber(10, 33000)
        simulator:setInputNumber(11, 0.12)
        simulator:setInputNumber(12, 0.01)

        simulator:setInputBool(5, true)
        simulator:setInputNumber(13, 8000)
        simulator:setInputNumber(14, 0.3)
        simulator:setInputNumber(15, 0.03)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("ClassAdditions.RadarTarget")
require("MathAdditions")
SELECTED_TARGET = RadarTarget:new(nil, false, 0,0,0,-1)

function onTick()
    SELECTED_TARGET = RadarTarget:new(
        nil,
        true,
        input.getNumber(INPUT_NUM.SELECTED_TARGET_DISTANCE),
        input.getNumber(INPUT_NUM.SELECTED_TARGET_AZIMUTH),
        input.getNumber(INPUT_NUM.SELECTED_TARGET_ELEVATION)
    )
    -- add newly detected targets
    ---@type table<number, RadarTarget>
    local detected_targets = {}
    for i = 1, 8, 1 do
        local target_detected = input.getBool(i)
        if target_detected then
            local target_num_index = i + (i - 1) * 2
            local new_target = RadarTarget:new(
                i,
                target_detected,
                input.getNumber(target_num_index),
                input.getNumber(target_num_index + 1),
                input.getNumber(target_num_index + 2),
                i / 1000
            )
            table.insert(detected_targets, new_target)
        end
    end
    if #detected_targets <= 0 then
        return
    end
    local selected_tgt_vec = LifeBoatAPI.LBVec:newFromAzimuthElevation(SELECTED_TARGET.azimuth*LifeBoatAPI.LBMaths.lbmaths_2pi, SELECTED_TARGET.elevation*LifeBoatAPI.LBMaths.lbmaths_2pi, SELECTED_TARGET.distance)
    local closest_tgt = detected_targets[1]
    local closest_tgt_vec = LifeBoatAPI.LBVec:newFromAzimuthElevation(closest_tgt.azimuth*LifeBoatAPI.LBMaths.lbmaths_2pi, closest_tgt.elevation*LifeBoatAPI.LBMaths.lbmaths_2pi, closest_tgt.distance)
    local closest_tgt_distance = LBVecExtension.sqrDistance(selected_tgt_vec, closest_tgt_vec)
    for i = 2, #detected_targets, 1 do
        local tgt = detected_targets[i]
        local tgt_vec = LifeBoatAPI.LBVec:newFromAzimuthElevation(tgt.azimuth*LifeBoatAPI.LBMaths.lbmaths_2pi, tgt.elevation*LifeBoatAPI.LBMaths.lbmaths_2pi, tgt.distance)
        local distance = LBVecExtension.sqrDistance(selected_tgt_vec, tgt_vec)
        if distance < closest_tgt_distance then
            closest_tgt_distance = distance
            closest_tgt = tgt
        end
    end
    output.setNumber(OUTPUT_NUM.SELECTED_TARGET_AZIMUTH, closest_tgt.azimuth)
    output.setNumber(OUTPUT_NUM.SELECTED_TARGET_ELEVATION, closest_tgt.elevation)
    output.setNumber(OUTPUT_NUM.SELECTED_TARGET_DISTANCE, closest_tgt.distance)
end

--TODO: When firing missiles at a selected target the radar switches for a second to the fired missile when it gets in front of it, check whether low azimuth-elevation targets are prioritized when at low distance!
