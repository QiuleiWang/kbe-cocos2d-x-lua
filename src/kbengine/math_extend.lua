local _M=KBEngine or {}
function _M.clampf(value, min_inclusive, max_inclusive) 
    if min_inclusive > max_inclusive then
        local temp = min_inclusive
        min_inclusive = max_inclusive
        max_inclusive = temp
    end
    if value<min_inclusive then
    	return min_inclusive
    else
    	if value<max_inclusive then
    		return value
    	else
    		return max_inclusive
    	end
    end
end

function _M.int82angle(angle, half)
	local value=254.0
	if not half then
	   	value=128.0
	end
	return angle * (math.pi / value)
end

function _M.angle2int8(v, half)

	local angle = 0
	if not half then
		angle = math.floor((v * 128.0) / math.pi + 0.5)
	else
		angle = _M.clampf(math.floor( (v * 254.0) / math.pi + 0.5), -128.0, 127.0)
	end

	return angle
end
