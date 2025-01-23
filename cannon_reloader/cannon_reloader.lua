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
        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputBool(2, simulator:getIsToggled(2))
        simulator:setInputBool(3, simulator:getIsToggled(3))
        simulator:setInputBool(4, simulator:getIsToggled(4))

    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("channels")
require("LifeBoatAPI.Tickable.LBStateMachine")
require("LifeBoatAPI.Maths.LBMaths")

TRIGGER = false
CANNON_LOADED = false
MAGAZINE_BEFORE_BREECH_LOADED  = false
TURRET_MAGAZINE_FULLY_LOADED = false

BREECH_OPEN_TIME = 0
BREECH_OPEN_CLOSE_DELAY = 0
MAGAZINE_LOAD_DELAY = 0

STATE_NAMES = {
    LOAD_CANNON = "Load Cannon",
    BREECH_OPEN = "Breech Open",
    BREECH_CLOSED = "Breech Closed",
    FEED_CANNON = "Feed Cannon",
    LOAD_MAGAZINE = "Load Magazine",
    READY_TO_FIRE = "Ready To Fire"
}

---Reloads the cannon using only the ammo stored in the turret
---@param ticks number
---@param statemachine LBStateMachine
---@return string | nil
function StateLoadCannon(ticks, statemachine)
    if CANNON_LOADED then
        return STATE_NAMES.READY_TO_FIRE
    end
    if not TURRET_MAGAZINE_FULLY_LOADED then
        output.setBool(CHANNELS.BINARY.OUTPUT.BREECH, true)
        if not MAGAZINE_BEFORE_BREECH_LOADED then
            output.setBool(CHANNELS.BINARY.OUTPUT.CANNON_FEED, true)
        end
        output.setBool(CHANNELS.BINARY.OUTPUT.MAGAZINE_FEED, true)
        return STATE_NAMES.LOAD_MAGAZINE
    end
    -- if cannon is not loaded then open breech and enable cannon feed
    output.setBool(CHANNELS.BINARY.OUTPUT.BREECH, true)
    return STATE_NAMES.BREECH_OPEN
end


---@param ticks number
---@param statemachine LBStateMachine
---@return string | nil
function StateBreechOpenDelay(ticks, statemachine)
    output.setBool(CHANNELS.BINARY.OUTPUT.BREECH, true)
    if ticks >= BREECH_OPEN_CLOSE_DELAY then
        return STATE_NAMES.FEED_CANNON
    end
end

---@param ticks number
---@param statemachine LBStateMachine
---@return string | nil
function StateBreechCloseDelay(ticks, statemachine)
    output.setBool(CHANNELS.BINARY.OUTPUT.BREECH, false)
    if ticks >= BREECH_OPEN_CLOSE_DELAY then
        return STATE_NAMES.READY_TO_FIRE
    end
end

---@param ticks number
---@param statemachine LBStateMachine
---@return string | nil
function StateFeedCannon(ticks, statemachine)
    output.setBool(CHANNELS.BINARY.OUTPUT.BREECH, true)
    output.setBool(CHANNELS.BINARY.OUTPUT.CANNON_FEED, true)
    if ticks >= BREECH_OPEN_TIME then
        return STATE_NAMES.BREECH_CLOSED
    end
end

---Reloads the whole turret using using the magazine
---@param ticks number
---@param statemachine LBStateMachine
---@return string | nil
function StateLoadMagazine(ticks, statemachine)
    output.setBool(CHANNELS.BINARY.OUTPUT.BREECH, true)
    if not MAGAZINE_BEFORE_BREECH_LOADED then
        output.setBool(CHANNELS.BINARY.OUTPUT.CANNON_FEED, true)
    end
    output.setBool(CHANNELS.BINARY.OUTPUT.MAGAZINE_FEED, true)
    if TURRET_MAGAZINE_FULLY_LOADED and ticks >= MAGAZINE_LOAD_DELAY then
        return STATE_NAMES.LOAD_CANNON
    end
end

---Fires the cannon
---@param ticks number
---@param statemachine LBStateMachine
---@return string | nil
function StateReadyToFire(ticks, statemachine)
    if not CANNON_LOADED then
        return STATE_NAMES.LOAD_CANNON
    end 
    if TRIGGER then
        output.setBool(CHANNELS.BINARY.OUTPUT.FIRE, true)
        return STATE_NAMES.LOAD_CANNON
    end
end
STATE_ACTIONS = {
    LOAD_CANNON = StateLoadCannon,
    BREECH_OPEN = StateBreechOpenDelay,
    BREECH_CLOSED = StateBreechCloseDelay,
    FEED_CANNON = StateFeedCannon,
    LOAD_MAGAZINE = StateLoadMagazine,
    READY_TO_FIRE = StateReadyToFire
}
STATE_MACHINE = LifeBoatAPI.LBStateMachine:new(function (ticks, statemachine)
    return STATE_NAMES.LOAD_CANNON
end)
STATE_MACHINE.states[STATE_NAMES.LOAD_CANNON] = STATE_ACTIONS.LOAD_CANNON
STATE_MACHINE.states[STATE_NAMES.BREECH_OPEN] = STATE_ACTIONS.BREECH_OPEN
STATE_MACHINE.states[STATE_NAMES.BREECH_CLOSED] = STATE_ACTIONS.BREECH_CLOSED
STATE_MACHINE.states[STATE_NAMES.FEED_CANNON] = STATE_ACTIONS.FEED_CANNON
STATE_MACHINE.states[STATE_NAMES.LOAD_MAGAZINE] = STATE_ACTIONS.LOAD_MAGAZINE
STATE_MACHINE.states[STATE_NAMES.READY_TO_FIRE] = STATE_ACTIONS.READY_TO_FIRE

function onTick()
    for i = 1, 32, 1 do
        output.setBool(i, false)
    end
    BREECH_OPEN_TIME = property.getNumber("Breech Open Period") * LifeBoatAPI.LBMaths.lbmaths_secondsToTicks
    BREECH_OPEN_CLOSE_DELAY = property.getNumber("Breech Delay") * LifeBoatAPI.LBMaths.lbmaths_secondsToTicks
    MAGAZINE_LOAD_DELAY = property.getNumber("Magazine Load Delay") * LifeBoatAPI.LBMaths.lbmaths_secondsToTicks

    TRIGGER = input.getBool(CHANNELS.BINARY.INPUT.TRIGGER)
    CANNON_LOADED = input.getBool(CHANNELS.BINARY.INPUT.CANNON_LOADED)
    MAGAZINE_BEFORE_BREECH_LOADED = input.getBool(CHANNELS.BINARY.INPUT.MAGAZINE_BEFORE_BREECH_LOADED)
    TURRET_MAGAZINE_FULLY_LOADED = input.getBool(CHANNELS.BINARY.INPUT.TURRET_MAGAZINE_FULLY_LOADED)

    STATE_MACHINE:lbstatemachine_onTick()
end


function onDraw()
    screen.drawText(0,0, STATE_MACHINE.currentState)
end

