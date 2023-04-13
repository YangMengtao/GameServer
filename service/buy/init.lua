
local skynet = require "skynet"
local service = require "service"

service.m_CatFoodPrice = 5
service.m_CatFoodCnt = 0

service.CMD.Buy = function (source)
    local leftMoney = skynet.call("worker", "lua", "UpdateMoney", -service.m_CatFoodPrice)
    if leftMoney >= 0 then
        service.m_CatFoodCnt = service.m_CatFoodCnt + 1
        skynet.error("Buy cat food success!, cnt = " .. service.m_CatFoodCnt)
        return true
    end

    skynet.error("Buy failed, money not enough")
    skynet.call("worker", "lua", "UpdateMoney", service.m_CatFoodPrice)
end

service.Start(...)