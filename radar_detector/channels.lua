-- Author: Daedheldir
-- GitHub: https://github.com/Daedheldir
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@enum
CHANNELS = {
    ---@section CHANNELS.RADAR_OUTPUT_TIME_SINCE_DETECTED_REMOVER
    RADAR_OUTPUT_TIME_SINCE_DETECTED_REMOVER = {
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
                TARGET_8_DISTANCE = 29,
                TARGET_8_AZIMUTH = 30,
                TARGET_8_ELEVATION = 31,
                TARGET_8_TIME_SINCE_DETECTED = 32
            },
            OUTPUT = {
                TARGET_1_DISTANCE = 1,
                TARGET_1_AZIMUTH = 2,
                TARGET_1_ELEVATION = 3,
                TARGET_2_DISTANCE = 4,
                TARGET_2_AZIMUTH = 5,
                TARGET_2_ELEVATION = 6,
                TARGET_3_DISTANCE = 7,
                TARGET_3_AZIMUTH = 8,
                TARGET_3_ELEVATION = 9,
                TARGET_4_DISTANCE = 10,
                TARGET_4_AZIMUTH = 11,
                TARGET_4_ELEVATION = 12,
                TARGET_5_DISTANCE = 13,
                TARGET_5_AZIMUTH = 14,
                TARGET_5_ELEVATION = 15,
                TARGET_6_DISTANCE = 16,
                TARGET_6_AZIMUTH = 17,
                TARGET_6_ELEVATION = 18,
                TARGET_7_DISTANCE = 19,
                TARGET_7_AZIMUTH = 20,
                TARGET_7_ELEVATION = 21,
                TARGET_8_DISTANCE = 22,
                TARGET_8_AZIMUTH = 23,
                TARGET_8_ELEVATION = 24,
            }
        }
    },
    ---@endsection
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
                TARGET_8_DETECTED = 8,
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
                TARGET_2_DISTANCE = 4,
                TARGET_2_AZIMUTH = 5,
                TARGET_2_ELEVATION = 6,
                TARGET_3_DISTANCE = 7,
                TARGET_3_AZIMUTH = 8,
                TARGET_3_ELEVATION = 9,
                TARGET_4_DISTANCE = 10,
                TARGET_4_AZIMUTH = 11,
                TARGET_4_ELEVATION = 12,
                TARGET_5_DISTANCE = 13,
                TARGET_5_AZIMUTH = 14,
                TARGET_5_ELEVATION = 15,
                TARGET_6_DISTANCE = 16,
                TARGET_6_AZIMUTH = 17,
                TARGET_6_ELEVATION = 18,
                TARGET_7_DISTANCE = 19,
                TARGET_7_AZIMUTH = 20,
                TARGET_7_ELEVATION = 21,
                TARGET_8_DISTANCE = 22,
                TARGET_8_AZIMUTH = 23,
                TARGET_8_ELEVATION = 24,
                BASE_GPS_X = 26,
                BASE_GPS_Y = 27,
                BASE_FORWARD_VELOCITY = 28,
                BASE_ANGULAR_SPEED = 29,
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
    ---@section CHANNELS.RADAR_TARGETING
    RADAR_TARGETING = {
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
            }
        },
        ---@enum
        NUMBER = {
            ---@enum
            INPUT = {
                TARGET_1_DISTANCE = 1,
                TARGET_1_AZIMUTH = 2,
                TARGET_1_ELEVATION = 3,
                TARGET_2_DISTANCE = 4,
                TARGET_2_AZIMUTH = 5,
                TARGET_2_ELEVATION = 6,
                TARGET_3_DISTANCE = 7,
                TARGET_3_AZIMUTH = 8,
                TARGET_3_ELEVATION = 9,
                TARGET_4_DISTANCE = 10,
                TARGET_4_AZIMUTH = 11,
                TARGET_4_ELEVATION = 12,
                TARGET_5_DISTANCE = 13,
                TARGET_5_AZIMUTH = 14,
                TARGET_5_ELEVATION = 15,
                TARGET_6_DISTANCE = 16,
                TARGET_6_AZIMUTH = 17,
                TARGET_6_ELEVATION = 18,
                TARGET_7_DISTANCE = 19,
                TARGET_7_AZIMUTH = 20,
                TARGET_7_ELEVATION = 21,
                TARGET_8_DISTANCE = 22,
                TARGET_8_AZIMUTH = 23,
                TARGET_8_ELEVATION = 24,
                SELECTED_TARGET_AZIMUTH = 29,
                SELECTED_TARGET_ELEVATION = 30,
                SELECTED_TARGET_DISTANCE = 31,
                TARGETING_RADAR_ROTATION = 32
            },
            OUTPUT = {
                SELECTED_TARGET_AZIMUTH = 1,
                SELECTED_TARGET_ELEVATION = 2,
                SELECTED_TARGET_DISTANCE = 3,
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
                TARGET_AZIMUTH = 1,
                TARGET_ELEVATION = 2,
                TARGET_DISTANCE = 3,
                BASE_GPS_X = 5,
                BASE_GPS_Y = 6,
                BASE_GPS_Z = 7,
                BASE_COMPASS_HEADING = 17,
                RADAR_X_TILT = 16,
                RADAR_Z_TILT = 15,
            },
            ---@enum
            OUTPUT = {
                TARGET_GLOBAL_GPS_X = 1,
                TARGET_GLOBAL_GPS_Y = 2,
                TARGET_GLOBAL_ALTITUDE = 3
            }
        }
    }
    ---@endsection
}
