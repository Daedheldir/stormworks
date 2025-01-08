---@section math.clamp
function math.clamp(min, max, n)
    return math.min(math.max(n, min), max)
end
---@endsection
---@section math.loop
function math.loop(min, max, n)
    if n > max then
        return min
    elseif n < min then
        return max
    else
        return n
    end
end
---@endsection
---@section math.toStringRounded
function math.toStringRounded(n, decimals)
    local out = string.format("%f", n)
    if out:find(".") then
        decimals = decimals + 1
    end
    local trimmed_out = out:sub(1, decimals)
    if trimmed_out[-1] == "." then
        trimmed_out = out:sub(1, trimmed_out:len()-1)
    end
    return trimmed_out
end
---@endsection
---@section math.toStringRounded
---@section LBVec.globalGPSFromAzimuthElevationDistance
require("LifeBoatAPI.Maths.LBVec")
---comment
---@param azimuth number
---@param elevation number
---@param distance number
---@param base_gps LBVec
---@param compass number
---@param base_pitch number
---@param base_roll number
---@return LBVec
function LifeBoatAPI.LBVec.globalGPSFromAzimuthElevationDistance(azimuth, elevation, distance, base_gps, compass, base_pitch, base_roll)
    local azimuth_rads = azimuth * LifeBoatAPI.LBMaths.lbmaths_2pi
    local elevation_rads = elevation * LifeBoatAPI.LBMaths.lbmaths_2pi
    local bearing_rads = LifeBoatAPI.LBMaths.lbmaths_compassToAzimuth(compass)
    local base_pitch_rads = LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(base_pitch)

    local global_azimuth = azimuth_rads + bearing_rads
    local global_elevation = elevation_rads + base_pitch_rads

    return LifeBoatAPI.LBVec:new(
        distance * math.sin(global_azimuth) + base_gps.x,
        distance * math.cos(global_azimuth) + base_gps.y,
        distance * math.tan(global_elevation) + base_gps.z
    )
end
---@endsection