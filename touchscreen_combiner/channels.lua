---@enum
CHANNELS = {
    ---@section CHANNELS.TOUCHSCREEN_COMBINER
    TOUCHSCREEN_COMBINER = {
        ---@enum
        BINARY = {
            ---@enum
            INPUT = {
                TOUCHSCREEN_1_CLICKED = 1,
                TOUCHSCREEN_2_CLICKED = 5,
                TOUCHSCREEN_3_CLICKED = 9
            },
            ---@enum
            OUTPUT = {
                TOUCHSCREEN_CLICKED = 1
            }
        },
        ---@enum
        NUMBER = {
            ---@enum
            INPUT = {
                TOUCHSCREEN_1_WIDTH = 1,
                TOUCHSCREEN_1_HEIGHT = 2,
                TOUCHSCREEN_1_CLICK_X = 3,
                TOUCHSCREEN_1_CLICK_Y = 4,
                TOUCHSCREEN_2_WIDTH = 5,
                TOUCHSCREEN_2_HEIGHT = 6,
                TOUCHSCREEN_2_CLICK_X = 7,
                TOUCHSCREEN_2_CLICK_Y = 8,
                TOUCHSCREEN_3_WIDTH = 9,
                TOUCHSCREEN_3_HEIGHT = 10,
                TOUCHSCREEN_3_CLICK_X = 11,
                TOUCHSCREEN_3_CLICK_Y = 12,
            },
            ---@enum
            OUTPUT = {
                TOUCHSCREEN_WIDTH = 1,
                TOUCHSCREEN_HEIGHT = 2,
                TOUCHSCREEN_CLICK_X = 3,
                TOUCHSCREEN_CLICK_Y = 4,
            }
        }
    },
    ---@endsection
}