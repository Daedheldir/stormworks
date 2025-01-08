---@section RadarTarget 1 RADARTARGETCLASS
require("LifeBoatAPI.Maths.LBMaths")
---@class RadarTarget
---@field id number
---@field detected boolean
---@field distance number
---@field horizontal_distance number
---@field vertical_distance number
---@field azimuth number
---@field elevation number
---@field time_since_detected number
---@ge
RadarTarget = {
    --- @overload fun():RadarTarget
    --- @overload fun(cls, id, detected, distance, azimuth, elevation, time_since_detected):RadarTarget
    --- @param cls RadarTarget
    ---@param id number
    ---@param detected boolean
    ---@param distance number
    ---@param azimuth number
    ---@param elevation number
    ---@param time_since_detected number
    --- @return RadarTarget
    new = function(cls, id, detected, distance, azimuth, elevation, time_since_detected)
        local target = {
            id = id or 0,
            detected = detected or false,
            distance = distance or 0,
            azimuth = azimuth or 0,
            elevation = elevation or 0,
            time_since_detected = detected and 0 + time_since_detected or TARGET_DETECTION_LIFETIME
        }
        target.horizontal_distance = math.cos(target.elevation * LifeBoatAPI.LBMaths.lbmaths_2pi) * target.distance
        target.vertical_distance = math.sin(target.elevation * LifeBoatAPI.LBMaths.lbmaths_2pi) * target.distance

        return LifeBoatAPI.lb_copy(cls, target)
    end;

    ---@section radarTarget_updateTimeSinceDetection 
    ---@param self RadarTarget
    ---@param step number how much to increase the time since detection
    radarTarget_updateTimeSinceDetection = function(self, step)
        self.time_since_detected = self.time_since_detected + step
    end;
    ---@endsection
}
---@endsection