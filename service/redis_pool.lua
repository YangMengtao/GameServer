local skynet = require "skynet"
local redis = require "skynet.db.redis"

local M = {}

function M.excute(cmd, ...)
    local res, err = M.m_HandleID[cmd](M.m_HandleID, ...)
    if not res then
        skynet.error("[Redis Error] : redis exec error: " .. err)
        return nil, err
    end
    return res, err
end

function M.disconnect()
    if M.m_HandleID then
        M.m_HandleID:disconnect()
    end
end

skynet.start(function ()
    M.m_HandleID = redis.connect({
        host = skynet.getenv("redis_host"),
        port = skynet.getenv("redis_port"),
        db = skynet.getenv("redis_db"),
    })

    if not M.m_HandleID then
        skynet.error("[Redis Error] : failed to connect to redis server")
        return false
    end

    skynet.error("[Redis] : connect to redis server success!")
    return true
end)