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

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(CHANNELS.TOUCHSCREEN_COMBINER.BINARY.INPUT.TOUCHSCREEN_1_CLICKED, screenConnection.isTouched)
        simulator:setInputNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.INPUT.TOUCHSCREEN_1_WIDTH, screenConnection.width)
        simulator:setInputNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.INPUT.TOUCHSCREEN_1_HEIGHT, screenConnection.height)
        simulator:setInputNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.INPUT.TOUCHSCREEN_1_CLICK_X, screenConnection.touchX)
        simulator:setInputNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.INPUT.TOUCHSCREEN_1_CLICK_Y, screenConnection.touchY)

        simulator:setInputBool(CHANNELS.TOUCHSCREEN_COMBINER.BINARY.INPUT.TOUCHSCREEN_2_CLICKED, simulator:getIsClicked(1))
        simulator:setInputNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.INPUT.TOUCHSCREEN_2_WIDTH, screenConnection.width / 3)
        simulator:setInputNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.INPUT.TOUCHSCREEN_2_HEIGHT, screenConnection.height / 3)
        simulator:setInputNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.INPUT.TOUCHSCREEN_2_CLICK_X, screenConnection.touchX / 3)
        simulator:setInputNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.INPUT.TOUCHSCREEN_2_CLICK_Y, screenConnection.touchY / 3)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("LifeBoatAPI")
function newScreen(width, height)
    local touchscreen = {
        screen = LifeBoatAPI.lb_copy(LifeBoatAPI.LBTouchScreen),
        width = width,
        height = height
    }
    return touchscreen
end

TOUCHSCREENS = {
    newScreen(0,0),
    newScreen(0,0),
    newScreen(0,0)
}

LAST_TOUCHSCREEN_ID = 1

function onTick()
    local active_screen = TOUCHSCREENS[LAST_TOUCHSCREEN_ID]

    for i = 1, #TOUCHSCREENS, 1 do
        local screen = TOUCHSCREENS[i]
        local compositeOffset = 4*(i - 1)
        screen.screen:lbtouchscreen_onTick(compositeOffset)
        screen.width = input.getNumber(compositeOffset + 1)
        screen.height = input.getNumber(compositeOffset + 2)
        if screen.screen.isPressed and not screen.screen.wasPressed then
            active_screen = screen
            LAST_TOUCHSCREEN_ID = i
        end
    end

    output.setBool(CHANNELS.TOUCHSCREEN_COMBINER.BINARY.OUTPUT.TOUCHSCREEN_CLICKED, active_screen.screen.isPressed)
    output.setNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.OUTPUT.TOUCHSCREEN_WIDTH, active_screen.width)
    output.setNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.OUTPUT.TOUCHSCREEN_HEIGHT, active_screen.height)
    output.setNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.OUTPUT.TOUCHSCREEN_CLICK_X, active_screen.screen.touchX)
    output.setNumber(CHANNELS.TOUCHSCREEN_COMBINER.NUMBER.OUTPUT.TOUCHSCREEN_CLICK_Y, active_screen.screen.touchY)
end




