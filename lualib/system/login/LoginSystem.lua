local skynet = require "skynet"
local crypt = require "skynet.crypt"
local Class = require "common.class"
local errcode = require "system.login.LoginErrcode"

local LoginSystem = Class:new()

function LoginSystem:ctor()
    self.m_MysqlDB = nil
    self.m_RedisDB = nil
    self.m_UserList = {}
    self:initSql()
end

function LoginSystem:initSql()
    self.m_QueryPasswordSql = "SELECT id,password FROM user WHERE username='%s'"
    self.m_NewUserSql = "INSERT INTO user (username, password) VALUES ('%s', '%s')"
end

function LoginSystem:initDB(mysql_db, redis_db)
    self.m_MysqlDB = mysql_db
    self.m_RedisDB = redis_db
end

function LoginSystem:getToken(uid)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7) .. tostring(uid))
    local token = ""
    for i = 1, 32 do
        token = token .. string.char(math.random(97, 122))
    end
    return token
end

--[[
    data.token
    data.username
    data.password
]]
function LoginSystem:login(data)
    local sql = string.format(self.m_QueryPasswordSql, data.username)
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
    local ret = {}
    if result then
        if #result > 0 then
            local uid = result[1].id
            local password = result[1].password
            if password == tostring(data.password) then
                local token = self:getToken(uid)
                self.m_UserList[token] = uid
                ret.token = token
                ret.errcode = errcode.SUCCEESS
                return ret
            else
                ret.errcode = errcode.ERR_USER_OR_PASSWORD
                return ret
            end
        else
            ret.errcode = errcode.ERR_NOT_FOUND_USER
            return ret
        end
    end

    ret.errcode = errcode.UNKNOWN
    return ret
end

function LoginSystem:register(data)
    local ret = {}
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", string.format(self.m_QueryPasswordSql, data.username))
    if result then
        if #result > 0 then
            ret.errcode = errcode.ERR_ALREADY_HAS_ACCOUNT
            return ret
        else
            result = skynet.call(self.m_MysqlDB, "lua", "excute", string.format(self.m_NewUserSql, data.username, data.password))
            if result then
                ret.errcode = errcode.SUCCEESS
                return ret
            end
        end
    end

    ret.errcode = errcode.UNKNOWN
    return ret
end

function LoginSystem:getUserId(data)
    return { self.m_UserList[data.token] }
end

return LoginSystem