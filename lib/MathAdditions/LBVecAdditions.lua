require("LifeBoatAPI.Maths.LBVec")
require("LifeBoatAPI.Maths.LBMaths")

---TODO: THIS DOES NOT GET INCLUDED IN THE OUTPUT FOR WHATEVER REASON!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
---@section LBVecExtension 1 _LBVECEXTENSIONCLASS_
---@class LBVecExtension
LBVecExtension = {
    ---@section sqrLength
    ---@param self LBVec
    ---@return number
    sqrLength = function(self)
        return self.x*self.x + self.y*self.y + self.z*self.z
    end;
    ---@endsection

    ---@section sqrDistance

    ---@param lhs LBVec
    ---@param rhs LBVec
    ---@return number
    sqrDistance = function(lhs, rhs)
        return LBVecExtension.sqrLength(lhs:lbvec_sub(rhs))
    end;
    ---@endsection

    ---@section globalGPSFromAzimuthElevationDistance
    ---@param vec LBVec
    ---@param angle number
    ---@return LBVec
    rotateRoll = function(vec, angle)
        return LifeBoatAPI.LBVec:new(
            vec.x * math.cos(angle) + vec.z * math.sin(angle),
            vec.y,
            vec.z * math.cos(angle) - vec.x * math.sin(angle)
        )
    end;

    ---@param vec LBVec
    ---@param angle number
    ---@return LBVec
    rotatePitch = function(vec, angle)
        return LifeBoatAPI.LBVec:new(
            vec.x,
            vec.y * math.cos(angle) - vec.z * math.sin(angle),
            vec.z * math.cos(angle) + vec.y * math.sin(angle)
        )
    end;

    ---@param vec LBVec
    ---@param angle number
    ---@return LBVec
    rotateYaw = function(vec, angle)
        return LifeBoatAPI.LBVec:new(
            vec.x * math.cos(angle) - vec.y * math.sin(angle),
            vec.y * math.cos(angle) + vec.x * math.sin(angle),
            vec.z
        )
    end;
    ---comment
    ---@param azimuth number
    ---@param elevation number
    ---@param distance number
    ---@param base_gps LBVec
    ---@param compass number
    ---@param base_pitch number
    ---@param base_roll number
    ---@return LBVec
    globalGPSFromAzimuthElevationDistance = function(azimuth, elevation, distance, base_gps, compass, base_pitch, base_roll)
        -- x - forward, y - up, z - right, should be converted to x - forward, y - right, z - up
        local azimuth_rads = azimuth * LifeBoatAPI.LBMaths.lbmaths_2pi
        local elevation_rads = elevation * LifeBoatAPI.LBMaths.lbmaths_2pi
        local base_azimuth_rads = compass * LifeBoatAPI.LBMaths.lbmaths_2pi
        local base_pitch_rads = LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(base_pitch)
        local base_roll_rads = LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(base_roll)

        local horizontal_distance = math.cos(elevation_rads) * distance
        local vertical_distance = math.sin(elevation_rads) * distance

        local local_gps = LifeBoatAPI.LBVec:new(
            horizontal_distance * math.sin(azimuth_rads),
            horizontal_distance * math.cos(azimuth_rads),
            vertical_distance
        )

        local gps_roll_corrected = LBVecExtension.rotateRoll(local_gps, base_roll_rads)
        local gps_pitch_corrected = LBVecExtension.rotatePitch(gps_roll_corrected, base_pitch_rads)
        local gps_yaw_corrected = LBVecExtension.rotateYaw(gps_pitch_corrected, base_azimuth_rads)

        local global_gps = gps_yaw_corrected:lbvec_add(base_gps)

        return global_gps
        -- TODO: This looks good in the simulator but when ran in the game the altitude seems off, needs testing with a constant target vector
    end;
    ---@endsection
}
---@endsection _LBVECEXTENSIONCLASS_