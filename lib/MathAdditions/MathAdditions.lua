---@section MathExtension 1 _MATHEXTENSIONCLASS_
---@class MathExtension
MathExtension = {
    ---@section clamp
    clamp = function(min, max, n)
        return math.min(math.max(n, min), max)
    end,
    ---@endsection
    ---@section loop
    loop = function(min, max, n)
        if n > max then
            return min
        elseif n < min then
            return max
        else
            return n
        end
    end,
    ---@endsection
    ---@section toStringRounded
    toStringRounded = function(n, decimals)
        local out = string.format("%f", n)
        if out:find(".") then
            decimals = decimals + 1
        end
        local trimmed_out = out:sub(1, decimals)
        if trimmed_out[-1] == "." then
            trimmed_out = out:sub(1, trimmed_out:len() - 1)
        end
        return trimmed_out
    end,
    ---@endsection
    ---@section calculateFiringAngle
    calculateFiringAngle = function(velocity, gravity, distance, height)
        -- Calculate coefficients for the quadratic equation
        local a = (gravity * distance ^ 2) / (2 * velocity ^ 2)
        local b = -distance
        local c = height - (gravity * distance ^ 2) / (2 * velocity ^ 2)

        -- Discriminant of the quadratic equation
        local discriminant = b ^ 2 - 4 * a * c

        if discriminant < 0 then
            return nil
        else
            -- Calculate the two solutions for tan(theta)
            local sqrt_discriminant = math.sqrt(discriminant)
            local tan_theta1 = (-b + sqrt_discriminant) / (2 * a)
            local tan_theta2 = (-b - sqrt_discriminant) / (2 * a)

            -- Calculate the angles in degrees
            local theta1 = math.deg(math.atan(tan_theta1))
            local theta2 = math.deg(math.atan(tan_theta2))

            -- Output the results
            return theta1, theta2
        end
    end,
    ---@endsection
    ---@section simpleFiringAngle
    simpleFiringAngle = function(velocity, gravity, distance, height)
        local angle = math.deg(math.atan(height + (gravity * distance ^ 2) / (2 * velocity ^ 2), distance)) / 360
        return angle
    end,
    ---@endsection
}
---@endsection _MATHEXTENSIONCLASS_