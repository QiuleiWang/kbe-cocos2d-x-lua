local Timer = {}

local sharedScheduler = cc.Director:getInstance():getScheduler()

--开启定时器
function Timer.onTimer(callback, interval)
    return sharedScheduler:scheduleScriptFunc(callback, interval, false)
end

--取消定时器
function Timer.unTimer(handle)
    sharedScheduler:unscheduleScriptEntry(handle)
end

--延迟调用某个方法
function Timer.delayTimer(callback, time)
    local handle
    handle = sharedScheduler:scheduleScriptFunc(function()
        Timer.unTimer(handle)
        callback()
    end, time, false)
    return handle
end

return Timer
