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
require("MathAdditions.MathAdditions")

PREVIOUS_WEAPON_SELECT_UP_STATE = false
PREVIOUS_WEAPON_SELECT_DOWN_STATE = false


selected_weapon = {
    loaded = false,
    weapon_type = -1,
    action = DefaultAction
}

WEAPONS_COUNT = property.getNumber("Hardpoints Count")

CHANNELS = {
    NUMBERS = {
        INPUT = {
            HARDPOINT_1_WEAPON_TYPE = 1,
            HARDPOINT_2_WEAPON_TYPE = 2,
            HARDPOINT_3_WEAPON_TYPE = 3,
            HARDPOINT_4_WEAPON_TYPE = 4,
            HARDPOINT_5_WEAPON_TYPE = 5,
            HARDPOINT_6_WEAPON_TYPE = 6,
            HARDPOINT_7_WEAPON_TYPE = 7,
            HARDPOINT_8_WEAPON_TYPE = 8
        },
        OUTPUT = {
            SELECTED_WEAPON_INDEX = 31,
            HARDPOINT_WEAPON_TYPE = 32
        }
    },
    BOOLEANS = {
        INPUT = {
            HARDPOINT_1_LOADED = 1,
            HARDPOINT_2_LOADED = 2,
            HARDPOINT_3_LOADED = 3,
            HARDPOINT_4_LOADED = 4,
            HARDPOINT_5_LOADED = 5,
            HARDPOINT_6_LOADED = 6,
            HARDPOINT_7_LOADED = 7,
            HARDPOINT_8_LOADED = 8,
            NEXT_HARDPOINT = 30,
            PREVIOUS_HARDPOINT = 31,
            TRIGGER_BUTTON = 32
        },
        OUTPUT = {
            HARDPOINT_1_LAUNCH = 1,
            HARDPOINT_2_LAUNCH = 2,
            HARDPOINT_3_LAUNCH = 3,
            HARDPOINT_4_LAUNCH = 4,
            HARDPOINT_5_LAUNCH = 5,
            HARDPOINT_6_LAUNCH = 6,
            HARDPOINT_7_LAUNCH = 7,
            HARDPOINT_8_LAUNCH = 8,
            SELECTED_HARDPOINT_FIRE = 31,
            SELECTED_HARDPOINT_LOADED = 32,
        }
    }
}

WEAPON_TYPES = {
    RADAR_MISSILE = 10,
    CANNON = 12
}

function DefaultAction(weapon, weapons_fire)
    return weapons_fire
end

function RadarMissileTriggerAction(weapon, weapons_fire)
    output.setBool(weapon.hardpoint, weapons_fire)
end
function CannonTriggerAction(weapon, weapons_fire)
    output.setBool(CHANNELS.BOOLEANS.OUTPUT.SELECTED_HARDPOINT_FIRE, weapons_fire)
end

WEAPON_HARDPOINTS = {}

function UpdateWeaponHardpoint()
    WEAPON_HARDPOINTS = {}
    for i = 1, WEAPONS_COUNT, 1 do
        local weapon = {
            hardpoint = i,
            loaded = input.getBool(i),
            weapon_type = input.getNumber(i),
            action = DefaultAction
        }
        if weapon.weapon_type == WEAPON_TYPES.RADAR_MISSILE then
            weapon.loaded = true
            weapon.action = RadarMissileTriggerAction
        elseif weapon.weapon_type == WEAPON_TYPES.CANNON then
            weapon.loaded = true -- Change this later to use the loaded flag from the canon itself
            weapon.action = CannonTriggerAction
        end
        table.insert(WEAPON_HARDPOINTS, i, weapon)
    end
end

SELECTED_HARDPOINT = 1


-- try to make the following logic:
-- if selected hardpoint is missile then release the hardpoint, if selected hardpoint is weapon, then trigger the weapon but don't release the hardpoint
-- this would need to be processed by a breakout board, which will release a selected hardpoint, or send trigger command through composite
-- check the possibility of using weapon groups / weapon types instead of selected hardpoints

function onTick()
    UpdateWeaponHardpoint()

    local weapon_select_up = input.getBool(CHANNELS.BOOLEANS.INPUT.NEXT_HARDPOINT)
    local weapon_select_down = input.getBool(CHANNELS.BOOLEANS.INPUT.PREVIOUS_HARDPOINT)
    local weapons_fire = input.getBool(CHANNELS.BOOLEANS.INPUT.TRIGGER_BUTTON)

    if weapon_select_up and PREVIOUS_WEAPON_SELECT_UP_STATE == false then
        SELECTED_HARDPOINT = SELECTED_HARDPOINT + 1
    elseif weapon_select_down and PREVIOUS_WEAPON_SELECT_DOWN_STATE == false then
        SELECTED_HARDPOINT = SELECTED_HARDPOINT - 1
    end
    SELECTED_HARDPOINT = mymath.loop(1, WEAPONS_COUNT, SELECTED_HARDPOINT)

    PREVIOUS_WEAPON_SELECT_UP_STATE = weapon_select_up
    PREVIOUS_WEAPON_SELECT_DOWN_STATE = weapon_select_down

    selected_weapon = WEAPON_HARDPOINTS[SELECTED_HARDPOINT]

    selected_weapon.action(selected_weapon, weapons_fire)

    output.setNumber(CHANNELS.NUMBERS.OUTPUT.SELECTED_WEAPON_INDEX, SELECTED_HARDPOINT)
    output.setNumber(CHANNELS.NUMBERS.OUTPUT.HARDPOINT_WEAPON_TYPE, selected_weapon.weapon_type)
    output.setBool(CHANNELS.BOOLEANS.OUTPUT.SELECTED_HARDPOINT_LOADED, selected_weapon.loaded)
end

