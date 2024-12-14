--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
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
    --simulator:setScreen(1, "3x3")
    --simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        -- touchscreen defaults
        simulator:setInputBool(1, simulator:getIsToggled(1))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputBool(2, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(CHANNELS.NAVIGATION.NUMBER.COMPASS, 0.499999 * (2 * simulator:getSlider(1) - 1))
        simulator:setInputNumber(CHANNELS.NAVIGATION.NUMBER.GPS_X, 2 * simulator:getSlider(2) - 1)
        simulator:setInputNumber(CHANNELS.NAVIGATION.NUMBER.GPS_Y, 2 * simulator:getSlider(3) - 1)
        simulator:setInputNumber(CHANNELS.NAVIGATION.NUMBER.TARGET_X, 2 * simulator:getSlider(4) - 1)
        simulator:setInputNumber(CHANNELS.NAVIGATION.NUMBER.TARGET_Y, 2 * simulator:getSlider(5) - 1)
        simulator:setInputNumber(CHANNELS.NAVIGATION.NUMBER.SPEED, 10 * simulator:getSlider(6))
        -- NEW! button/slider options from the UI
        --simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        --simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        --simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        --simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("LifeBoatAPI")
require("NavBusChannels")
ticks = 0

local inputChannels = {}
inputChannels.compass =             CHANNELS.NAVIGATION.NUMBER.COMPASS
inputChannels.gpsX =                CHANNELS.NAVIGATION.NUMBER.GPS_X
inputChannels.gpsY =                CHANNELS.NAVIGATION.NUMBER.GPS_Y
inputChannels.targetX =             CHANNELS.NAVIGATION.NUMBER.TARGET_X
inputChannels.targetY =             CHANNELS.NAVIGATION.NUMBER.TARGET_Y
inputChannels.speed =               CHANNELS.NAVIGATION.NUMBER.SPEED

local outputChannels = {}
outputChannels.vectorToTargetX =    CHANNELS.NAVIGATION.NUMBER.VECTOR_TO_TARGET_X
outputChannels.vectorToTargetY =    CHANNELS.NAVIGATION.NUMBER.VECTOR_TO_TARGET_Y
outputChannels.kilometersToTarget = CHANNELS.NAVIGATION.NUMBER.DISTANCE_TO_TARGET
outputChannels.timeToTarget =       CHANNELS.NAVIGATION.NUMBER.TIME_TO_TARGET
outputChannels.azimuth =            CHANNELS.NAVIGATION.NUMBER.AZIMUTH
outputChannels.targetAngle =        CHANNELS.NAVIGATION.NUMBER.TARGET_ANGLE


function onTick()
    ticks = ticks + 1
    local own_coords_toggle = input.getBool(CHANNELS.NAVIGATION.BINARY.OWN_COORDS_TOGGLE)
    local speed = input.getNumber(inputChannels.speed) or 0
    local compass = input.getNumber(inputChannels.compass) or 0
    local compassRads = compass*LifeBoatAPI.LBMaths.lbmaths_2pi
    local compassDeg = math.deg(compass*LifeBoatAPI.LBMaths.lbmaths_2pi)
    --local compassVec = LifeBoatAPI.LBVec:new(math.sin(compassRads), math.cos(compassRads))

    local gpsPosition = LifeBoatAPI.LBVec:new(
        input.getNumber(inputChannels.gpsX) or 0,
        input.getNumber(inputChannels.gpsY) or 0
    )

    local targetPosition = LifeBoatAPI.LBVec:new(
        input.getNumber(inputChannels.targetX) or 0,
        input.getNumber(inputChannels.targetY) or 0
    )

    local vectorToTarget = LifeBoatAPI.LBVec:new(
        targetPosition.x - gpsPosition.x,
        targetPosition.y - gpsPosition.y
    )

    local distance = vectorToTarget:lbvec_length()
    local targetAngle = math.deg(vectorToTarget:lbvec_angle2D()) + compassDeg
    if targetAngle < -180 then
        targetAngle = targetAngle + 360
    elseif targetAngle > 180 then
        targetAngle = targetAngle - 360
    end
    if own_coords_toggle then
        vectorToTarget = gpsPosition
    end

    for i = 1, 32, 1 do
        output.setBool(i,input.getBool(i))
        output.setNumber(i,input.getNumber(i))
    end
    output.setNumber(26, math.deg(vectorToTarget:lbvec_angle2D()))
    output.setNumber(outputChannels.vectorToTargetX, vectorToTarget.x)
    output.setNumber(outputChannels.vectorToTargetY, vectorToTarget.y)
    output.setNumber(outputChannels.kilometersToTarget, distance/1000)
    output.setNumber(outputChannels.timeToTarget, distance / speed)
    output.setNumber(outputChannels.azimuth, compassDeg)
    output.setNumber(outputChannels.targetAngle, targetAngle)
end
