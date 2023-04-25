local skynet = require "skynet"
local Class = require "common.EventDispatch"

local LoginSystem = Class:new()

function LoginSystem:ctor()
    self.m_UserList = {}

    self:initSql()
end

function LoginSystem:initSql()
    self.m_QueryPasswordSql = "SELECT id,password FROM user WHERE username='%s'"
    self.m_NewUserSql = "INSERT INTO user (username, password) VALUES ('%s', '%s')"
end

--[[
    data.username
    data.password
]]
function LoginSystem:login(data)
    if self.m_UserList[data.username] then
        local ret = {}
        ret.err = GErrCode.Common_Success
        ret.token = self.m_UserList[data.username]
        return GMgr:tableToString(ret)
    end
    local res, err, errno = skynet.send(GMySql, "excute", string.format(self.m_QueryPasswordSql, data.username))
    local ret = {}
    if res then
        if #res > 0 then
            local uid = res[1].id
            local password = res[2].password
            if password == tostring(data.password) then
                local token = GMgr:getToken(uid)
                self.m_UserList[data.username] = token
                ret.err = GErrCode.Common_Success
                ret.token = token
                return GMgr:tableToString(ret)
            end
        else
            ret.err = GErrCode.Login_NotAccount
            return GMgr:tableToString(ret)
        end
    end

    ret.err = GErrCode.Common_Unknown
    ret.msg = err
    return GMgr:tableToString(ret)
end

function LoginSystem:register(data)
    local res, err, errno = skynet.send(GMySql, "excute", string.format(self.m_QueryPasswordSql, data.username))
    local ret = {}
    if res then
        if #res > 0 then
            ret.err = GErrCode.Login_AlreadyHasAccount
            return GMgr:tableToString(ret)
        else
            res, err, errno = skynet.send(GMySql, "excute", string.format(self.m_NewUserSql, data.username, data.password))
            if res then
                ret.err = GErrCode.Common_Success
                return GMgr:tableToString(ret)
            end
        end
    end

    ret.err = GErrCode.Common_Unknown
    ret.msg = err
    return GMgr:tableToString(ret)
end

return LoginSystem