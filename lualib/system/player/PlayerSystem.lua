local system = require "common.system"
local errcode = require "system.player.PlayerErrcode"

local skynet = require "skynet"

local PlayerSystem = system:new()

function PlayerSystem:ctor()
    self:initSql()
end

function PlayerSystem:initSql()
    self.m_QueryByUidSql = "SELECT id,uid,nickname,money,curlevel,item,team FROM player WHERE uid='%s'"
    self.m_NewPlayerSql = "INSERT INTO player (uid,nickname,curlevel) VALUES ('%s', '%s', '%s')"
    self.m_UpateNickNameSql = "UPDATE player SET nickname = %s WHERE uid = '%s'"
end

function PlayerSystem:createPlayer()
    
end

function PlayerSystem:getPlayerByUid(uid)
    local sql = string.format(self.m_QueryByUidSql, uid)
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
    local ret = {}
    if result then
        if #result > 0 then
            local uid = result[1].uid
            local password = result[1].password
            if password == md5.sumhexa(tostring(data.password)) then
                local token = self:getToken(uid)
                if token then
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
    else
        self:createPlayer()
    end

    ret.errcode = errcode.UNKNOWN
    return ret
end

