CHANNELS = {
    NUMBER = {
        INPUT = {
            
        },
        OUTPUT = {
            CURRENT_STATE = 1
        }
    },
    BINARY = {
        INPUT = {
            TRIGGER = 1,
            CANNON_LOADED = 2,
            MAGAZINE_BEFORE_BREECH_LOADED = 3,
            TURRET_MAGAZINE_FULLY_LOADED = 4
        },
        OUTPUT = {
            FIRE = 1,
            BREECH = 2,
            CANNON_FEED = 3,
            MAGAZINE_FEED = 4
        }
    }
}