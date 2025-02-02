CHANNELS = {
    NAVIGATION = {
        BINARY = {
            INPUT = {
                AUTOPILOT_TOGGLE = 1,
                OWN_COORDS_TOGGLE = 2
            }
        },
        NUMBER = {
            INPUT = {
                COMPASS = 1,
                GPS_X = 2,
                GPS_Y = 3,
                TARGET_X = 4,
                TARGET_Y = 5,
                YAW_INPUT = 6,
                SPEED = 7
            },
            OUTPUT = {
                TIME_TO_TARGET = 27,
                DISTANCE_TO_TARGET = 28,
                VECTOR_TO_TARGET_X = 29,
                VECTOR_TO_TARGET_Y = 30,
                AZIMUTH = 31,
                TARGET_ANGLE = 32
            }
        }
    },
    NAVIGATION_DISPLAY = {
        BINARY = {
        },
        NUMBER = {
            INPUT = {
                COMPASS = 1,
                GPS_X = 2,
                GPS_Y = 3,
                TARGET_X = 4,
                TARGET_Y = 5,
                TIME_TO_TARGET = 27,
                DISTANCE_TO_TARGET = 28,
            }
        }
    }
}
