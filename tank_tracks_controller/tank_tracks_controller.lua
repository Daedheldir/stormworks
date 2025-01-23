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
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))     -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))      -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))     -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("MathAdditions.MathAdditions")

CHANNELS = {
    NUMBER = {
        INPUT = {
            W_S = 1,
            A_D = 2,
        },
        OUTPUT = {
            THROTTLE = 1,
            LEFT_TRACK_CLUTCH = 2,
            RIGHT_TRACK_CLUTCH = 3
        }
    },
    BINARY = {
        INPUT = {
        },
        OUTPUT = {
            REVERSE_GEAR = 1
        }
    }
}

THROTTLE = 0
LEFT_TRACK_CLUTCH = 0
RIGHT_TRACK_CLUTCH = 0
REVERSE_GEAR = false

function onTick()
    local w_s = input.getNumber(CHANNELS.NUMBER.INPUT.W_S)
    local a_d = input.getNumber(CHANNELS.NUMBER.INPUT.A_D)

    if w_s < 0 then
        REVERSE_GEAR = true
        w_s = math.abs(w_s)
    else
        REVERSE_GEAR = false
    end

    LEFT_TRACK_CLUTCH = w_s
    RIGHT_TRACK_CLUTCH = w_s

    LEFT_TRACK_CLUTCH = LEFT_TRACK_CLUTCH + a_d
    RIGHT_TRACK_CLUTCH = RIGHT_TRACK_CLUTCH - a_d

    LEFT_TRACK_CLUTCH = MathExtension.clamp(0, 1, LEFT_TRACK_CLUTCH)
    RIGHT_TRACK_CLUTCH = MathExtension.clamp(0, 1, RIGHT_TRACK_CLUTCH)

    THROTTLE = MathExtension.clamp(0, 1, (LEFT_TRACK_CLUTCH + RIGHT_TRACK_CLUTCH) / 2)

    output.setBool(CHANNELS.BINARY.OUTPUT.REVERSE_GEAR, REVERSE_GEAR)
    output.setNumber(CHANNELS.NUMBER.OUTPUT.THROTTLE, THROTTLE)
    output.setNumber(CHANNELS.NUMBER.OUTPUT.LEFT_TRACK_CLUTCH, LEFT_TRACK_CLUTCH)
    output.setNumber(CHANNELS.NUMBER.OUTPUT.RIGHT_TRACK_CLUTCH, RIGHT_TRACK_CLUTCH)
end
