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
        -- NEW! button/slider options from the UI
        simulator:setInputNumber(4, simulator:getSlider(1) - 0.5)      -- set input 31 to the value of slider 1
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("LifeBoatAPI")
GPS_X = 0
GPS_Y = 0
ZOOM = 1
HEADING_LINE_LENGTH = 8
COMPASS_VEC = LifeBoatAPI.LBVec:new(0,0)

function onTick()
    GPS_X = input.getNumber(1)
    GPS_Y = input.getNumber(2)
    ZOOM = input.getNumber(3)
    compass_rads = input.getNumber(4) * LifeBoatAPI.LBMaths.lbmaths_2pi
    COMPASS_VEC = LifeBoatAPI.LBVec:new(math.sin(compass_rads), math.cos(compass_rads))
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    center = LifeBoatAPI.LBVec:new(w / 2, h / 2)

    screen.drawMap(GPS_X, GPS_Y, ZOOM)
    screen.setColor(0, 255, 0)
    screen.drawCircleF(center.x, center.y, 2)
    screen.drawLine(center.x, center.y, center.x - COMPASS_VEC.x * HEADING_LINE_LENGTH, center.y - COMPASS_VEC.y * HEADING_LINE_LENGTH)
end
