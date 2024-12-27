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
