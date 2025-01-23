---@enum
CHANNELS = {
    ---@section CHANNELS.MISSILE_DROP_COMPENSATOR
    MISSILE_DROP_COMPENSATOR = {
        ---@enum
        BINARY = {
            ---@enum
            INPUT = {
            },
            ---@enum
            OUTPUT = {
            }
        },
        ---@enum
        NUMBER = {
            ---@enum
            INPUT = {
                DISTANCE = 1,
                HEIGHT_DIFFERENCE = 2,
            },
            ---@enum
            OUTPUT = {
                ELEVATION_LOW = 1,
                ELEVATION_HIGH = 2
            }
        }
    },
    ---@endsection
}