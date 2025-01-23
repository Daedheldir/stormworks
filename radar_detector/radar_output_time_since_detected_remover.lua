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
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        for i = 1, 8, 1 do
            simulator:setInputBool(i, true)
            local target_num_index = i + (i - 1) * 3
            simulator:setInputNumber(target_num_index, i)
            simulator:setInputNumber(target_num_index + 1, i)
            simulator:setInputNumber(target_num_index + 2, i)
            simulator:setInputNumber(target_num_index + 3, i)
        end
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

ticks = 0
function onTick()
    for i = 1, 8, 1 do
        output.setBool(i, input.getBool(i))
        local in_target_num_index = i + (i - 1) * 3
        local out_target_num_index = i + (i - 1) * 2
        output.setNumber(out_target_num_index, input.getNumber(in_target_num_index))
        output.setNumber(out_target_num_index + 1, input.getNumber(in_target_num_index + 1))
        output.setNumber(out_target_num_index + 2, input.getNumber(in_target_num_index + 2))
    end
end

