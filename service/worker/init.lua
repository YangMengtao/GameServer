
local skynet = require "skynet"
local service = require "service"

service.m_Money = 0
service.m_IsWorking = false

service.Update = function (frame)
    if service.m_IsWorking then
        service.m_Money = service.m_Money + 1
        skynet.error(service.m_ID .. "_" .. service.m_Name .. "money = " .. tostring(service.m_Money))
    end
end

service.Timer = function ()
    local begin = skynet.now()
    local frame = 0

    while true do
        frame = frame + 1
        local isOk, err = pcall(service.Update, frame)
        if not isOk then
            skynet.error(err)
        end

        local waitTime = frame * 20 - (skynet.now() - begin)
        if waitTime <= 0 then
            waitTime = 2
        end
        skynet.sleep(waitTime)
    end
end

service.FuncInit = function ()
    skynet.fork(service.Timer)
end

service.CMD.StartWork = function (source)
    service.m_IsWorking = true
end

service.CMD.StopWork = function (source)
    service.m_IsWorking = false
end

service.CMD.UpdateMoney = function (source, value)
    service.m_Money = service.m_Money + value
    return service.m_Money
end

service.Start(...)