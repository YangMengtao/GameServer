local skynet = require "skynet"
local redis = require "skynet.db.redis"

local M = {}

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

    skynet.dispatch("lua", function (session, address, cmd, ...)
        local func = assert(M.m_HandleID[cmd], string.format("[Mysql Error] : Unknown command %s", tostring(cmd)))
        skynet.ret(skynet.pack(func(M.m_HandleID, ...)))
    end)

    skynet.error("[Redis] : connect to redis server success!")
    return true
end)