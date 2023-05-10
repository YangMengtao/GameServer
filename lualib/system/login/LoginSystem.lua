local system = require "common.system"

local skynet = require "skynet"
local crypt = require "skynet.crypt"
local errcode = require "system.login.LoginErrcode"
local md5 = require "md5"

local LoginSystem = system:new()

function LoginSystem:ctor()
    self:initSql()
end

function LoginSystem:initSql()
    self.m_QueryPasswordSql = "SELECT uid,password FROM user WHERE username='%s'"
    self.m_NewUserSql = "INSERT INTO user (username, password) VALUES ('%s', '%s')"
end

function LoginSystem:genToken(uid)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7) .. tostring(uid))
    local token = ""
    for i = 1, 32 do
        token = token .. string.char(math.random(97, 122))
    end
    return token
end

-- FOR CLIENT API
function LoginSystem:login(data)
    local sql = string.format(self.m_QueryPasswordSql, data.username)
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
    local ret = {}
    if result then
        if #result > 0 then
            local uid = result[1].uid
            local password = result[1].password
            if password == md5.sumhexa(tostring(data.password)) then
                local token = self:getToken(uid)
                if token ~= nil and token ~= "" then
                    ret.errcode = errcode.ERR_REPEAT_LOGIN
                    ret.token = token
                    return ret
                end
                token = self:genToken(uid)
                local eno, t = self:setToOnline(uid, token)
                if errcode.SUCCEESS ~= eno then
                    token = t
                end
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
            result = skynet.call(self.m_MysqlDB, "lua", "excute", string.format(self.m_NewUserSql, data.username, md5.sumhexa(data.password)))
            if result then
                local sql = string.format(self.m_QueryPasswordSql, data.username)
                local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
                local uid = result[1].uid
                local token = self:genToken(uid)
                self:setToOnline(uid, token)
                ret.token = token
                ret.errcode = errcode.SUCCEESS
                return ret
            end
        end
    end

    ret.errcode = errcode.UNKNOWN
    return ret
end

return LoginSystem