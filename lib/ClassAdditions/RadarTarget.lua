require("LifeBoatAPI.Maths.LBVec")
require("LifeBoatAPI.Maths.LBMaths")

---@section RadarTarget 1 _RADARTARGETCLASS_
---@class RadarTarget
---@field id number
---@field detected boolean
---@field distance number
---@field horizontal_distance number
---@field vertical_distance number
---@field azimuth number
---@field elevation number
---@field time_since_detected number
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
        time_since_detected = time_since_detected or math.maxinteger
        local target = {
            id = id or 0,
            detected = detected or false,
            distance = distance or 0,
            azimuth = azimuth or 0,
            elevation = elevation or 0,
            time_since_detected = time_since_detected
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

    ---@section radarTarget_updateTimeSinceDetection 
    ---@param self RadarTarget
    ---@param velocity_per_tick number linear forward velocity of the radar
    radarTarget_updateDistance = function(self, velocity_per_tick)
        local alpha = 0.5*math.pi - self.azimuth*LifeBoatAPI.LBMaths.lbmaths_2pi
        local forward_dist = math.sin(alpha) * self.horizontal_distance
        local side_dist = math.cos(alpha) * self.horizontal_distance
        local new_forward_dist = forward_dist - velocity_per_tick
        local alpha2 = math.atan(new_forward_dist, side_dist)
        local new_azimuth = (0.5*math.pi - alpha2) / LifeBoatAPI.LBMaths.lbmaths_2pi
        local new_horizontal_dist = new_forward_dist / math.sin(alpha2)

        self.horizontal_distance = new_horizontal_dist
        self.azimuth = new_azimuth
        self.vertical_distance = math.sin(self.elevation * LifeBoatAPI.LBMaths.lbmaths_2pi) * self.horizontal_distance
        self.distance = math.sqrt(self.horizontal_distance^2 + self.vertical_distance^2)
    end;
    ---@endsection
    
    ---@section radarTarget_updateAzimuthWithAngularSpeed 
    ---@param self RadarTarget
    ---@param angular_speed_per_tick number angular speed of the radar
    radarTarget_updateAzimuthWithAngularSpeed = function (self, angular_speed_per_tick)
        self.azimuth = self.azimuth + angular_speed_per_tick
    end;
    ---@endsection
}
---@endsection _RADARTARGETCLASS_