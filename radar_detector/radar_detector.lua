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
    simulator:setScreen(1, "5x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputNumber(1, simulator:getSlider(1) * 50000)
        simulator:setInputNumber(2, simulator:getSlider(2) - 0.5)
        simulator:setInputNumber(3, simulator:getSlider(3) * 0.5 - 0.25)
        simulator:setInputNumber(4, 1)

        simulator:setInputBool(2, true)
        simulator:setInputNumber(5, 23000)
        simulator:setInputNumber(6, 0.02)
        simulator:setInputNumber(7, 0.08)
        simulator:setInputNumber(8, 1)

        simulator:setInputBool(3, true)
        simulator:setInputNumber(9, 13000)
        simulator:setInputNumber(10, 0.05)
        simulator:setInputNumber(11, 0.02)
        simulator:setInputNumber(12, 1)

        simulator:setInputBool(4, true)
        simulator:setInputNumber(13, 33000)
        simulator:setInputNumber(14, 0.12)
        simulator:setInputNumber(15, 0.01)
        simulator:setInputNumber(16, 1)

        simulator:setInputBool(5, true)
        simulator:setInputNumber(17, 8000)
        simulator:setInputNumber(18, 0.3)
        simulator:setInputNumber(19, 0.03)
        simulator:setInputNumber(20, 1)

        simulator:setInputBool(28, simulator:getIsClicked(5))
        simulator:setInputNumber(30, simulator:getSlider(5) * screenConnection.width)
        simulator:setInputNumber(31, simulator:getSlider(6) * screenConnection.height)
        simulator:setInputNumber(32, ticks / 120)

        simulator:setProperty("Target Merge Tolerance", 1000)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("LifeBoatAPI.Maths.LBVec")
require("LifeBoatAPI.Maths.LBMaths")
require("LifeBoatAPI.Utils.LBTableUtils")
require("LifeBoatAPI.Tickable.LBTouchScreen")
require("MathAdditions")
require("RadarTarget")

RADAR_ROTATION_RADS = 0
ZOOM_LEVEL = 8 --km
TARGET_DETECTION_LIFETIME = 4 * LifeBoatAPI.LBMaths.lbmaths_secondsToTicks

--- @type table<number, RadarTarget>
DETECTED_TARGETS = {}
--- @type table<number, LBTouchScreenButton>
TARGET_BUTTONS = {}
SELECTED_TARGET_ID = 0

MAX_PROCESSED_TARGETS_PER_TICK = 6
MAX_DETECTED_TARGETS = 64

RADAR_SWEEP_RANGE = 1 -- 1 == ONE FULL TURN == 360 DEGREES
RADAR_ELEVATION_RANGE = 0.5
TARGET_MERGE_TOLERANCE = 1

---Sorts RadarTargets based on their time since detection
---@param targets table<number, RadarTarget>
---@param descending boolean|nil
function sortRadarTargetsByDetectionTime(targets, descending)
    descending = descending or false
    local sort_func = function(left, right) return left.time_since_detected < right.time_since_detected end
    if descending then
        sort_func = function(left, right) return left.time_since_detected > right.time_since_detected end
    end
    table.sort(targets, sort_func)
end

---@param targets table<number, RadarTarget>
---@param selected_target_id number
function getNextFreeTargetId(targets, selected_target_id)
    ---@type table<number, number>
    local target_ids = {}
    for key, tgt in pairs(targets) do
        table.insert(target_ids, tgt.id)
    end
    table.sort(target_ids, function (a, b) return a < b end)
    if target_ids[#target_ids] < 1 then
        return 1
    end 
    local last_id = 1
    for i = 1, #target_ids, 1 do
        if last_id + 1 < target_ids[i] and last_id + 1 ~= selected_target_id then
            return last_id + 1
        end
        if last_id < target_ids[i] then
            last_id = target_ids[i]
        end
    end
    return last_id + 1
end

---@param tgt_1 RadarTarget
---@param tgt_2 RadarTarget
function calculateDistanceBetweenTargets(tgt_1, tgt_2)
    local tgt_1_vec = LifeBoatAPI.LBVec:newFromAzimuthElevation(tgt_1.azimuth, tgt_1.elevation, tgt_1.distance)
    local tgt_2_vec = LifeBoatAPI.LBVec:newFromAzimuthElevation(tgt_2.azimuth, tgt_2.elevation, tgt_2.distance)
    local diff = tgt_1_vec:lbvec_sub(tgt_2_vec)
    return diff:lbvec_length()
end


--- @param detected_targets table<number, RadarTarget>
--- @param max_detected_targets_count number
function processRadarTargets(detected_targets, max_detected_targets_count)
    --targets start at 1, 5, 9
    -- 1
    -- 5 = 2 + 3
    -- 9 = 3 + 3 + 3
    -- 13 = 4 + 3 + 3 + 3
    -- target_num = i + (i - 1)*3

    local new_targets_detected = false
    local detected_targets_count = 0
    -- add newly detected targets
    for i = 1, 7, 1 do
        local target_detected = input.getBool(i)
        if target_detected then
            detected_targets_count = detected_targets_count + 1
            new_targets_detected = true
            local target_num_index = i + (i - 1) * 3
            local new_target = RadarTarget:new(
                nil,
                target_detected,
                input.getNumber(target_num_index),
                input.getNumber(target_num_index + 1),
                input.getNumber(target_num_index + 2),
                input.getNumber(target_num_index + 3) + i / 1000
            )
            if new_target.horizontal_distance < ZOOM_LEVEL * 1000 then
                table.insert(detected_targets, new_target)
            end
        end
        if detected_targets_count >= max_detected_targets_count then
            break
        end
    end

    sortRadarTargetsByDetectionTime(detected_targets)

    --remove oldest targets if too many are detected
    if #detected_targets > MAX_DETECTED_TARGETS then
        local sub_table = {}
        for i = 1, MAX_DETECTED_TARGETS, 1 do
            table.insert(sub_table, detected_targets[-i])
        end
        detected_targets = sub_table
    end

    -- update detection times
    --- @type table<number, RadarTarget>
    local active_targets = {}
    for i, target in ipairs(detected_targets) do
        local step = 1
        if SELECTED_TARGET_ID == target.id then
            step = 0.1
        end
        target:radarTarget_updateTimeSinceDetection(step)
        if target.time_since_detected < TARGET_DETECTION_LIFETIME then
            table.insert(active_targets, target)
        end
    end

    if not new_targets_detected then
        return active_targets
    end

    -- remove duplicate targets if new targets were added
    local distance_tolerance = TARGET_MERGE_TOLERANCE * ZOOM_LEVEL * 1000
    local azimuth_tolerance = TARGET_MERGE_TOLERANCE * RADAR_SWEEP_RANGE
    local elevation_tolerance = TARGET_MERGE_TOLERANCE * RADAR_ELEVATION_RANGE
    for i, tgt_1 in ipairs(active_targets) do
        local elements_to_remove = {}
        for j = i + 1, #active_targets, 1 do
            if #active_targets < j then
                break
            end
            local tgt_2 = active_targets[j]
            --local distance_tolerance = TARGET_MERGE_TOLERANCE * ZOOM_LEVEL * 1000
            --local azimuth_tolerance = TARGET_MERGE_TOLERANCE * RADAR_SWEEP_RANGE
            --local elevation_tolerance = TARGET_MERGE_TOLERANCE * RADAR_ELEVATION_RANGE
            -- if there is another target close to current one then merge them
            --if math.abs(tgt_1.distance - tgt_2.distance) < distance_tolerance
            --    and math.abs(tgt_1.azimuth - tgt_2.azimuth) < azimuth_tolerance
            --    and math.abs(tgt_1.elevation - tgt_2.elevation) < elevation_tolerance then
            --        table.insert(elements_to_remove, tgt_1.time_since_detected < tgt_2.time_since_detected and j or i)
            --        if tgt_1.time_since_detected < tgt_2.time_since_detected then
            --            tgt_1.id = tgt_2.id
            --        else
            --            tgt_2.id = tgt_1.id
            --        end
            local tgt_distance = calculateDistanceBetweenTargets(tgt_1, tgt_2)
            if tgt_distance < TARGET_MERGE_TOLERANCE then
                table.insert(elements_to_remove, tgt_1.time_since_detected < tgt_2.time_since_detected and j or i)
                if tgt_1.time_since_detected < tgt_2.time_since_detected then
                    tgt_1.id = tgt_2.id
                else
                    tgt_2.id = tgt_1.id
                end
            end
        end
        for k = #elements_to_remove, 1, -1 do
            table.remove(active_targets, elements_to_remove[k])
        end
    end

    --assign new ids to targets that dont have them
    for i, target in ipairs(active_targets) do
        if target.id == 0 then
            target.id = getNextFreeTargetId(active_targets, SELECTED_TARGET_ID)
        end
    end
    return active_targets
end

---@param screen Simulator_ScreenAPI
---@param radar_radius number
---@param center LBVec
---@param radar_rotation_rads number
---@param zoom_level number
function drawRadarDetector(screen, radar_radius, center, radar_rotation_rads, zoom_level)
    local radar_line_end_pos = LifeBoatAPI.LBVec:new(math.sin(radar_rotation_rads), math.cos(radar_rotation_rads))
    local distance_text = tostring(zoom_level) .. "km"
    screen.setColor(0, 255, 0, 255)
    screen.drawText(center.x - radar_radius, center.y - radar_radius, distance_text)
    screen.drawCircle(center.x, center.y, radar_radius)
    screen.drawCircle(center.x, center.y, radar_radius / 2)
    screen.drawLine(center.x, center.y, center.x + radar_line_end_pos.x * radar_radius,
        center.y - radar_line_end_pos.y * radar_radius)

    screen.setColor(0, 255, 0, 125)
    screen.drawLine(center.x, center.y - radar_radius, center.x, center.y + radar_radius)
    screen.drawLine(center.x - radar_radius, center.y, center.x + radar_radius, center.y)

    for index, target in ipairs(DETECTED_TARGETS) do
        if target.detected then
            local target_vec = LifeBoatAPI.LBVec:new(math.sin(target.azimuth * LifeBoatAPI.LBMaths.lbmaths_2pi),
                math.cos(target.azimuth * LifeBoatAPI.LBMaths.lbmaths_2pi))
            target_vec = target_vec:lbvec_scale((radar_radius) * (target.horizontal_distance / 1000) /
                ZOOM_LEVEL)
            local target_pos = LifeBoatAPI.LBVec:new(center.x + target_vec.x, center.y - target_vec.y)
            local alpha = LifeBoatAPI.LBMaths.lbmaths_lerp(255, 0, target.time_since_detected / TARGET_DETECTION_LIFETIME)
            screen.setColor(255, 0, 0, alpha)
            screen.drawCircle(target_pos.x, target_pos.y, 1)
            screen.drawText(target_pos.x - 2, target_pos.y - 7, tostring(target.id)) -- target id
        end
    end
end

---@param screen Simulator_ScreenAPI
---@param left_top_point LBVec
---@param width number
function drawTargetsTable(screen, left_top_point, width)
    screen.setColor(255, 255, 255, 255)
    screen.drawRect(left_top_point.x, left_top_point.y, width - 1, screen.getHeight() - 1)
    local target_box_height = 12

    --- @type table<number, LBTouchScreenButton>
    TARGET_BUTTONS = {}
    local targets = DETECTED_TARGETS

    local buttons_max_count = math.floor((screen.getHeight() - 1) / target_box_height)
    buttons_max_count = buttons_max_count > #targets and #targets or buttons_max_count

    sortRadarTargetsByDetectionTime(targets, true)
    for i = 1, buttons_max_count, 1 do
        target = targets[i]
        if not target.detected then
            goto continue
        end
        if SELECTED_TARGET_ID == target.id then
            screen.setColor(0, 255, 0, 255)
        else
            screen.setColor(255, 255, 255, 255)
        end
        local target_box_left_top = LifeBoatAPI.LBVec:new(left_top_point.x,
        left_top_point.y + (i - 1) * target_box_height)
        screen.drawRect(target_box_left_top.x, target_box_left_top.y, width - 1, target_box_height)

        TARGET_BUTTONS[target.id] = LifeBoatAPI.LBTouchScreen:lbtouchscreen_newButton_Minimalist(target_box_left_top.x, target_box_left_top.y, 12, target_box_height, tostring(target.id))
        TARGET_BUTTONS[target.id]:lbbutton_draw()
        --screen.drawText(target_box_left_top.x + 2, target_box_left_top.y + 3, tostring(i)) -- target id
        target_box_left_top.y = target_box_left_top.y + 1
        local str = math.toStringRounded(target.horizontal_distance / 1000, 3)
        screen.drawText(target_box_left_top.x + 14, target_box_left_top.y, string.format("H: %s km", str))

        str = math.toStringRounded(target.vertical_distance / 1000, 3)
        screen.drawText(target_box_left_top.x + 14, target_box_left_top.y + 6, string.format("V: %s km", str))
        ::continue::
    end
end


--TODO: MODIFY THIS TO MERGE TARGETS BASED ON PROXIMITY IN METERS, NOT AZIMUTH-ELEVATION-DISTANCE
function onTick()
    LifeBoatAPI.LBTouchScreen:lbtouchscreen_onTick(27)
    for key, value in pairs(TARGET_BUTTONS) do
        if value:lbbutton_isReleased() then
            if SELECTED_TARGET_ID == key then
                SELECTED_TARGET_ID = -1
            else
                SELECTED_TARGET_ID = key
            end
        end
    end


    TARGET_MERGE_TOLERANCE = property.getNumber("Target Merge Tolerance") / 100
    DETECTED_TARGETS = processRadarTargets(DETECTED_TARGETS, MAX_PROCESSED_TARGETS_PER_TICK)
    RADAR_ROTATION_RADS = math.fmod(input.getNumber(CHANNELS.RADAR_DETECTOR.NUMBER.INPUT.RADAR_ROTATION), 1) * LifeBoatAPI.LBMaths.lbmaths_2pi

    local selected_target_exists = false
    local selected_target_key = -1
    for key, tgt in pairs(DETECTED_TARGETS) do
        if tgt.id == SELECTED_TARGET_ID then
            selected_target_exists = true
            selected_target_key = key
            break
        end
    end
    if not selected_target_exists then
        SELECTED_TARGET_ID = -1
    elseif DETECTED_TARGETS[selected_target_key] then
        local tgt = DETECTED_TARGETS[selected_target_key]
        output.setNumber(CHANNELS.RADAR_DETECTOR.NUMBER.OUTPUT.SELECTED_TARGET_ID, tgt.id)
        output.setNumber(CHANNELS.RADAR_DETECTOR.NUMBER.OUTPUT.SELECTED_TARGET_AZIMUTH, tgt.azimuth)
        output.setNumber(CHANNELS.RADAR_DETECTOR.NUMBER.OUTPUT.SELECTED_TARGET_ELEVATION, tgt.elevation)
        output.setNumber(CHANNELS.RADAR_DETECTOR.NUMBER.OUTPUT.SELECTED_TARGET_DISTANCE, tgt.distance)
    end
end


function onDraw()
    local screen_size = LifeBoatAPI.LBVec:new(screen.getWidth(), screen.getHeight())
    local screen_center = LifeBoatAPI.LBVec:new(screen_size.x / 2, screen_size.y / 2)
    local screen_longer_side = screen_size.x > screen_size.y and screen_size.x or screen_size.y
    local screen_shorter_side = screen_size.x < screen_size.y and screen_size.x or screen_size.y
    local radar_radius = ((2 * screen_longer_side / 3) < screen_shorter_side) and (screen_longer_side / 2) or
        screen_shorter_side / 2
    local radar_center = LifeBoatAPI.LBVec:new(radar_radius, screen_size.y / 2)

    drawRadarDetector(screen, radar_radius, radar_center, RADAR_ROTATION_RADS, ZOOM_LEVEL)
    drawTargetsTable(screen, LifeBoatAPI.LBVec:new(radar_center.x + radar_radius, 0), screen_size.x - 2 * radar_radius)
end
