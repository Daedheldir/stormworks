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


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        simulator:setInputBool(1, simulator:getIsClicked(1))
        simulator:setInputBool(2, simulator:getIsClicked(2))
        simulator:setInputBool(3, simulator:getIsClicked(3))

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("MathAdditions")

PREVIOUS_WEAPON_SELECT_UP_STATE = false
PREVIOUS_WEAPON_SELECT_DOWN_STATE = false

SELECTED_WEAPON_INDEX = 1
SELECTED_WEAPON_TYPE = 0
SELECTED_WEAPON_LOADED = false
WEAPONS_COUNT = 4--property.getNumber("Weapons Count")

WEAPON_HARDPOINTS = {}
for i = 1, WEAPONS_COUNT, 1 do
    local weapon = {
        loaded = false,
        weapon_type = -1,
    }
    table.insert(WEAPON_HARDPOINTS, i, weapon)
end

function onTick()
    local WEAPON_SELECT_UP = input.getBool(1)
    local WEAPON_SELECT_DOWN = input.getBool(2)

    if WEAPON_SELECT_UP and PREVIOUS_WEAPON_SELECT_UP_STATE == false then
        SELECTED_WEAPON_INDEX = SELECTED_WEAPON_INDEX + 1
    elseif WEAPON_SELECT_DOWN and PREVIOUS_WEAPON_SELECT_DOWN_STATE == false then
        SELECTED_WEAPON_INDEX = SELECTED_WEAPON_INDEX - 1
    end
    SELECTED_WEAPON_INDEX = math.clamp(1, WEAPONS_COUNT, SELECTED_WEAPON_INDEX)

    PREVIOUS_WEAPON_SELECT_UP_STATE = WEAPON_SELECT_UP
    PREVIOUS_WEAPON_SELECT_DOWN_STATE = WEAPON_SELECT_DOWN

    SELECTED_WEAPON_TYPE = WEAPON_HARDPOINTS[SELECTED_WEAPON_INDEX].weapon_type
    SELECTED_WEAPON_LOADED = WEAPON_HARDPOINTS[SELECTED_WEAPON_INDEX].loaded

    local WEAPONS_FIRE = input.getBool(3)

    -- Reset all weapon fire outputs
    if WEAPONS_FIRE then
        output.setBool(SELECTED_WEAPON_INDEX, true)
    else
        for i = 1, WEAPONS_COUNT, 1 do
            output.setBool(i, false)
        end
    end
    output.setNumber(32, SELECTED_WEAPON_INDEX)
    output.setBool(31, SELECTED_WEAPON_LOADED)
end

