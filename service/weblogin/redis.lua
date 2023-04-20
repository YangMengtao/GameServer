local skynet = require "skynet"
local redis = require "skynet.db.redis"

local RedisPool = {}

function RedisPool.connect()
    -- local host = skynet.getenv("redis_conf.host")
    -- local port = skynet.getenv("redis_conf.port")

    RedisPool.DB = redis.connect({
        host = "127.0.0.1",
        port = 6379,
        db = 0,
    })

    if not RedisPool.DB then
        skynet.error("failed to connect to redis server")
        return false
    end

    skynet.error("connect to redis server success!")
    return true
end

function RedisPool.query(cmd, ...)
    local res, err = RedisPool.DB[cmd](RedisPool.DB, ...)
    if not res then
        skynet.error("redis exec error: " .. err)
        return nil, err
    end
    return res, err
end

function RedisPool.disconnect()
    if RedisPool.DB then
        RedisPool.DB:disconnect()
    end
end

return RedisPool