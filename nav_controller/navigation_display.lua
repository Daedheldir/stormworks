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

require("NavBusChannels")

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
        simulator:setInputBool(8, screenConnection.isTouched)
        simulator:setInputNumber(8, screenConnection.width)
        simulator:setInputNumber(9, screenConnection.height)
        simulator:setInputNumber(10, screenConnection.touchX)
        simulator:setInputNumber(11, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.COMPASS, simulator:getSlider(1)*0.5)       -- set input 31 to the value of slider 1
        simulator:setInputNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.GPS_X, -11227)--simulator:getSlider(2)*5 - 2.5)       -- set input 31 to the value of slider 1
        simulator:setInputNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.GPS_Y, -19056)--simulator:getSlider(3)*5 - 2.5)       -- set input 31 to the value of slider 1
        simulator:setInputNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.TARGET_X, -11225.63)--simulator:getSlider(4)*1000 - 500)       -- set input 31 to the value of slider 1
        simulator:setInputNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.TARGET_Y, -19086.57)--simulator:getSlider(5)*1000 - 500)       -- set input 31 to the value of slider 1

        simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("LifeBoatAPI")
require("MathAdditions")
require("ColorDefinitions")

GPS_X = 0
GPS_Y = 0
TARGET_GPS_X = 0
TARGET_GPS_Y = 0

AZIMUTH = 0
ZOOM = 1
SCALE = 0.5 --1px = x m
POSITION_MARKER_SIZE = 3
ZOOM_IN = LifeBoatAPI.LBTouchScreen:lbtouchscreen_newButton(0,0,7,7,"+", ColorDefinitions.white, ColorDefinitions.gray, ColorDefinitions.white, ColorDefinitions.green, ColorDefinitions.white)
ZOOM_OUT = LifeBoatAPI.LBTouchScreen:lbtouchscreen_newButton(0,7,7,7,"-", ColorDefinitions.white, ColorDefinitions.gray, ColorDefinitions.white, ColorDefinitions.green, ColorDefinitions.white)


TARGET_ETA = 0
TARGET_DIST = 0

function onTick()
    LifeBoatAPI.LBTouchScreen:lbtouchscreen_onTick(7)

    if ZOOM_IN:lbbutton_isHeld() then
        ZOOM = ZOOM - ZOOM/10
    elseif ZOOM_OUT:lbbutton_isHeld() then
        ZOOM = ZOOM + ZOOM/10
    end
    ZOOM = MathExtension.clamp(0.1, 50, ZOOM)

    GPS_X = input.getNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.GPS_X)
    GPS_Y = input.getNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.GPS_Y)
    TARGET_GPS_X = input.getNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.TARGET_X)
    TARGET_GPS_Y = input.getNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.TARGET_Y)
    AZIMUTH = LifeBoatAPI.LBMaths.lbmaths_compassToAzimuth(-input.getNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.COMPASS))
    TARGET_ETA = input.getNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.TIME_TO_TARGET)
    TARGET_DIST = input.getNumber(CHANNELS.NAVIGATION_DISPLAY.NUMBER.INPUT.DISTANCE_TO_TARGET)
end



function onDraw()
    local screen_center = LifeBoatAPI.LBVec:new(screen:getWidth() / 2, screen:getHeight() / 2)
    local screen_height = screen.getHeight()
    screen.drawMap(GPS_X, GPS_Y, ZOOM)

    local target_vec = LifeBoatAPI.LBVec:new(GPS_X - TARGET_GPS_X, GPS_Y - TARGET_GPS_Y)
    local map_scale = (ZOOM * 1000) / screen:getWidth() --0.1 zoom means 100 meters left to right on screen, 50 is 50km left to right
    local target_vec_map = LifeBoatAPI.LBVec:new(screen_center.x - target_vec.x / map_scale, screen_center.y + target_vec.y / map_scale)
    screen.setColor(255,255,255,50)
    screen.drawLine(screen_center.x, screen_center.y, target_vec_map.x, target_vec_map.y)
    
    screen.setColor(255,255,255,255)
    screen.drawCircle(screen_center.x, screen_center.y, POSITION_MARKER_SIZE)
    screen.drawLine(screen_center.x, screen_center.y,
        screen_center.x - math.sin(AZIMUTH) * POSITION_MARKER_SIZE * 2,
        screen_center.y - math.cos(AZIMUTH) * POSITION_MARKER_SIZE * 2)

    screen.drawCircle(target_vec_map.x, target_vec_map.y, POSITION_MARKER_SIZE/2)

    ZOOM_IN:lbbutton_draw()
    ZOOM_OUT:lbbutton_draw()
    screen.drawText(1, screen_height-20, string.format("ETA:%.1fmin", TARGET_ETA/60))
    screen.drawText(1, screen_height-13, string.format("Dist:%.2fkm", TARGET_DIST))
    screen.drawText(1, screen_height-6, string.format("X:%.0f Y:%.0f", GPS_X, GPS_Y))
end
