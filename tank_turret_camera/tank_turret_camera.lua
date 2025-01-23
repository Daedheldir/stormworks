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
        simulator:setInputNumber(1, simulator:getSlider(1) - 0.5)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("LifeBoatAPI")

local TURRET_ROTATION = 0

function onTick()
    TURRET_ROTATION = LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(input.getNumber(1))
end

local TICKS_SPACING = 5

function onDraw()
    local screen_center = LifeBoatAPI.LBVec:new(screen.getWidth()/2, screen.getHeight()/2)
    local horizontal_lines_length = screen_center.x/2 + 1
    local vertical_lines_length = screen_center.y/2

    screen.setColor(0,255,0,120)

    screen.drawLine(screen_center.x, screen_center.y + 2, screen_center.x, screen_center.y + vertical_lines_length)
    screen.drawLine(screen_center.x + 2, screen_center.y, screen_center.x + horizontal_lines_length, screen_center.y)
    screen.drawLine(screen_center.x - 2, screen_center.y, screen_center.x - horizontal_lines_length, screen_center.y)

    for i = 0, vertical_lines_length/TICKS_SPACING, 1 do
        screen.drawLine(screen_center.x + 1, screen_center.y + 2 + i * TICKS_SPACING, screen_center.x + 2, screen_center.y + 2 + i * TICKS_SPACING)
        screen.drawLine(screen_center.x - 1, screen_center.y + 2 + i * TICKS_SPACING, screen_center.x, screen_center.y + 2 + i * TICKS_SPACING)
    end

    for i = 0, horizontal_lines_length/TICKS_SPACING, 1 do
        screen.drawLine(screen_center.x + 2 + i * TICKS_SPACING, screen_center.y - 2, screen_center.x + 2 + i * TICKS_SPACING, screen_center.y)
        screen.drawLine(screen_center.x + 2 + i * TICKS_SPACING, screen_center.y + 2, screen_center.x + 2 + i * TICKS_SPACING, screen_center.y)
        screen.drawLine(screen_center.x - 2 - i * TICKS_SPACING, screen_center.y - 2, screen_center.x - 2 - i * TICKS_SPACING, screen_center.y)
        screen.drawLine(screen_center.x - 2 - i * TICKS_SPACING, screen_center.y + 2, screen_center.x - 2 - i * TICKS_SPACING, screen_center.y)
    end

    --screen.drawRect(screen_center.x - 6, screen.getHeight() - 15, 11, 13)
    screen.drawRectF(screen_center.x - 6, screen.getHeight() - 15, 12, 14)
    screen.drawCircleF(screen_center.x, screen.getHeight() - 7, 3)
    screen.drawLine(screen_center.x, screen.getHeight() - 7, screen_center.x - 10*math.sin(TURRET_ROTATION), screen.getHeight() - 7 - 10*math.cos(TURRET_ROTATION))
end



