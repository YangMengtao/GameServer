local Class = require "common.class"
local errcode = require "common.errcode"

local skynet = require "skynet"
local cjson = require "cjson"

local system = Class:new()

function system:initDB(mysql_db, redis_db)
    self.m_MysqlDB = mysql_db
    self.m_RedisDB = redis_db
end

function system:getUid(token)
    local code = self:checkToken(token)

    if code == errcode.SUCCEESS then
        local online_users = skynet.call(self.m_RedisDB, "lua", "get", "OnlineUsers")
        if online_users then
            online_users = cjson.decode(online_users)
            return online_users[token]
        end
    end
    
    return nil, code
end

function system:getToken(uid)
    local online_users = skynet.call(self.m_RedisDB, "lua", "get", "OnlineUsers")
    if online_users then
        online_users = cjson.decode(online_users)
        for token, v in pairs(online_users) do
            if tonumber(v) == tonumber(uid) then
                if skynet.call(self.m_RedisDB, "lua", "get", token) ~= nil then
                    return token
                end
                break
            end
        end
    end
    return nil
end

function system:setToOnline(uid, token)
    skynet.error("[SYSTEM] set to online token = " .. token .. " uid =" .. uid)
    local online_users = skynet.call(self.m_RedisDB, "lua", "get", "OnlineUsers") or {}
    if online_users and online_users[token] == nil then
        if type(online_users) == "string" then
            online_users = cjson.decode(online_users)
        end
        online_users[token] = uid
        local value = cjson.encode(online_users)
        skynet.error(string.format("[Logic Error] : current online user info = %s", value))
        skynet.call(self.m_RedisDB, "lua", "set", "OnlineUsers", value)
        skynet.call(self.m_RedisDB, "lua", "set", token, uid)
        skynet.call(self.m_RedisDB, "lua", "expire", token, skynet.getenv("redis_token_expire"))
        return errcode.SUCCEESS
    else
        skynet.error(string.format("[Logic Error] : user uid = %s alredy exists, token is %s", uid, token))
        return errcode.UNKNOWN, self:getToken(uid)
    end
end

function system:checkToken(token)
    skynet.error("[SYSTEM] check token = " .. token)
    local uid = skynet.call(self.m_RedisDB, "lua", "get", tostring(token))
    if uid then
        skynet.call(self.m_RedisDB, "lua", "expire", token, skynet.getenv("redis_token_expire"))
        return errcode.SUCCEESS
    end

    -- 更新在线玩家
    local online_users = skynet.call(self.m_RedisDB, "lua", "get", "OnlineUsers")
    if online_users then
        online_users = cjson.decode(online_users)
        online_users[token] = nil
        local value = cjson.encode(online_users)
        skynet.error(string.format("[Logic Error] : current online user info = %s", value))
        skynet.call(self.m_RedisDB, "lua", "set", "OnlineUsers", value)
    end

    return errcode.INVALID_TOKEND
end

return system