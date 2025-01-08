-- Author: Daedheldir
-- GitHub: https://github.com/Daedheldir
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@enum
CHANNELS = {
    ---@section CHANNELS.RADAR_DETECTOR
    RADAR_DETECTOR = {
        ---@enum
        BINARY = {
            ---@enum
            INPUT = {
                TARGET_1_DETECTED = 1,
                TARGET_2_DETECTED = 2,
                TARGET_3_DETECTED = 3,
                TARGET_4_DETECTED = 4,
                TARGET_5_DETECTED = 5,
                TARGET_6_DETECTED = 6,
                TARGET_7_DETECTED = 7,
                TOUCHSCREEN_CLICKED = 28
            }
        },
        ---@enum
        NUMBER = {
            ---@enum
            INPUT = {
                TARGET_1_DISTANCE = 1,
                TARGET_1_AZIMUTH = 2,
                TARGET_1_ELEVATION = 3,
                TARGET_1_TIME_SINCE_DETECTED = 4, -- work to skip this possibly as the controller calculates this by itself
                TARGET_2_DISTANCE = 5,
                TARGET_2_AZIMUTH = 6,
                TARGET_2_ELEVATION = 7,
                TARGET_2_TIME_SINCE_DETECTED = 8, -- work to skip this possibly as the controller calculates this by itself
                TARGET_3_DISTANCE = 9,
                TARGET_3_AZIMUTH = 10,
                TARGET_3_ELEVATION = 11,
                TARGET_3_TIME_SINCE_DETECTED = 12, -- work to skip this possibly as the controller calculates this by itself
                TARGET_4_DISTANCE = 13,
                TARGET_4_AZIMUTH = 14,
                TARGET_4_ELEVATION = 15,
                TARGET_4_TIME_SINCE_DETECTED = 16, -- work to skip this possibly as the controller calculates this by itself
                TARGET_5_DISTANCE = 17,
                TARGET_5_AZIMUTH = 18,
                TARGET_5_ELEVATION = 19,
                TARGET_5_TIME_SINCE_DETECTED = 20, -- work to skip this possibly as the controller calculates this by itself
                TARGET_6_DISTANCE = 21,
                TARGET_6_AZIMUTH = 22,
                TARGET_6_ELEVATION = 23,
                TARGET_6_TIME_SINCE_DETECTED = 24, -- work to skip this possibly as the controller calculates this by itself
                TARGET_7_DISTANCE = 25,
                TARGET_7_AZIMUTH = 26,
                TARGET_7_ELEVATION = 27,
                TARGET_7_TIME_SINCE_DETECTED = 28, -- work to skip this possibly as the controller calculates this by itself
                TOUCHSCREEN_CLICK_X = 30,
                TOUCHSCREEN_CLICK_Y = 31,
                RADAR_ROTATION = 32
            },
            ---@enum
            OUTPUT = {
                SELECTED_TARGET_ID = 1,
                SELECTED_TARGET_AZIMUTH = 2,
                SELECTED_TARGET_ELEVATION = 3,
                SELECTED_TARGET_DISTANCE = 4,
                RADAR_ROTATION = 32
            }
        }
    },
    ---@endsection
    ---@section CHANNELS.RADAR_TO_GPS
    RADAR_TO_GPS = {
        ---@enum
        NUMBER = {
            ---@enum
            INPUT = {
                ---@enum
                TARGET_ID = 1,
                TARGET_AZIMUTH = 2,
                TARGET_ELEVATION = 3,
                TARGET_DISTANCE = 4,
                BASE_GPS_X = 5,
                BASE_GPS_Y = 6,
                BASE_GPS_Z = 7,
                BASE_COMPASS_HEADING = 17,
                RADAR_X_TILT = 16,
                RADAR_Z_TILT = 15,
            }
        }
    }
    ---@endsection
}
