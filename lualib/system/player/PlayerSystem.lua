local system = require "common.system"
local errcode = require "system.player.PlayerErrcode"

local skynet = require "skynet"
local cjson = require "cjson"

local PlayerSystem = system:new()

function PlayerSystem:ctor()
    self:initSql()
end

function PlayerSystem:initSql()
    self.m_QueryByUidSql = "SELECT id,uid,nickname,money,curlevel,item,lastOnline FROM player WHERE uid='%d'"
    self.m_NewPlayerSql = "INSERT INTO player (uid,nickname,lastOnline) VALUES ('%d', '%s', '%d')"
    self.m_UpatePlayerSql = "UPDATE player SET nickname = %s,SET money = %d,SET curlevel = %d,SET item = %s WHERE uid = '%d'"
    self.m_UpdatePlayerMonery = "UPDATE player SET money = %d WHERE uid = '%d'"
    self.m_UpdatePlayerLevel = "UPDATE player SET curlevel = %d WHERE uid = '%d'"
    self.m_UpdatePlayerNickName = "UPDATE player SET nickname = %s WHERE uid = '%d'"
    self.m_UpdatePlayerItem = "UPDATE player SET item = %s WHERE uid = '%d'"
    self.m_UpdatePlayerOnlineTime = "UPDATE player SET lastOnline = %d WHERE uid = '%d'"

    self.m_NewMemberSql = "INSERT INTO team_member (pid,hp,energy) VALUES ('%d', '%d', '%d')"
    self.m_QueryTeamMember = "SELECT id,alive,weaponid,armorid,normalskillid,ultraskillid,hp,energy,practiceattrs,rewardattrs FROM team_member WHERE pid = '%d'"
    self.m_UpdateMemberInfo = "UPDATE team_member SET alive = '%d',SET weaponid = '%d',SET armorid = '%d',SET normalskillid = '%d',SET ultraskillid = '%d',SET hp = '%d',SET energy = '%d' WHERE id = '%d'"
end

function PlayerSystem:createPlayer(uid, nickname)
    -- 添加Player
    local time = os.time()
    local sql = string.format(self.m_NewPlayerSql, uid, nickname, time)
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
    if result then
        -- 添加player成功查询新增player数据
        sql = string.format(self.m_QueryByUidSql, uid)
        result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
        if result then
            local ret = {}
            ret.id = result[1].id
            ret.uid = result[1].uid
            ret.nickname = result[1].nickname
            ret.money = result[1].money
            ret.curlevel = result[1].curlevel
            ret.item = result[1].item
            ret.lasttime = time
            ret.errcode = errcode.SUCCEESS
            ret.token = self:getToken(ret.uid)

            -- 添加一个team member
            if self:addNewMember(ret.id, 100, 0) then
                ret.team = self:queryMember(ret.id)
                if ret.team == nil then
                    ret.errcode = errcode.ERR_NO_MEMBER
                    return errcode.ERR_NO_MEMBER
                end
                self:setPlayerInRedis(ret)
            else
                ret.errcode = errcode.ERR_ADD_NEW_MEMBER_FAILED
                return errcode.ERR_ADD_NEW_MEMBER_FAILED
            end
            return errcode.SUCCEESS
        end
    end
    return errcode.ERR_ADD_NEW_PLAYER_FAILED
end

function PlayerSystem:getPlayerByUid(uid)
    -- 查询player数据
    local sql = string.format(self.m_QueryByUidSql, uid)
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
    if result and #result > 0 then
        local ret = {}
        ret.id = result[1].id
        ret.uid = result[1].uid
        ret.nickname = result[1].nickname
        ret.money = result[1].money
        ret.curlevel = result[1].curlevel
        ret.item = result[1].item
        ret.lasttime = os.time()
        ret.token = self:getToken(ret.uid)
        ret.team = self:queryMember(ret.id)
        ret.errcode = errcode.SUCCEESS
        return ret;
    end

    return nil
end

function PlayerSystem:addNewMember(pid, hp, energy)
    local sqlMember = string.format(self.m_NewMemberSql, pid, hp, energy)
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", sqlMember)
    if result then
        return true
    end
    return false
end

function PlayerSystem:queryMember(pid)
    local sqlMember = string.format(self.m_QueryTeamMember, pid)
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", sqlMember)
    if result then
        local members = {}
        for i = 1, #result do
            local member = {}
            member.id = result[i].id
            member.alive = result[i].alive
            member.weaponid = result[i].weaponid
            member.armorid = result[i].armorid
            member.normalskillid = result[i].normalskillid
            member.ultraskillid = result[i].ultraskillid
            member.hp = result[i].hp
            member.energy = result[i].energy
            member.practiceattrs = result[i].practiceattrs
            member.rewardattrs = result[i].rewardattrs
            table.insert(members, member)
        end
        return members
    end
    return nil
end

function PlayerSystem:findPlayerInRedis(uid)
    local players = skynet.call(self.m_RedisDB, "lua", "get", "PlayerInfo") or {}
    if type(players) == "string" then
        skynet.error("[PLAYER] find player in redis players = " .. players)
        players = cjson.decode(players)
    end
    for _, info in ipairs(players) do
        if tonumber(info.uid) == tonumber(uid) then
            return info
        end
    end
    return nil
end

function PlayerSystem:setPlayerInRedis(info)
    local players = skynet.call(self.m_RedisDB, "lua", "get", "PlayerInfo") or {}
    if type(players) == "string" then
        players = cjson.decode(players)
    end
    table.insert(players, info)
    local str = cjson.encode(players)
    skynet.error("[PLAYER]set player in redis data = " .. str)
    skynet.call(self.m_RedisDB, "lua", "set", "PlayerInfo", str)
end

function PlayerSystem:updateToMysql()
    local players = skynet.call(self.m_RedisDB, "lua", "get", "PlayerInfo") or {}
    if type(players) == "string" then
        players = cjson.decode(players)
    end

    for pid, info in ipairs(players) do
        local playerSql = string.format(self.m_UpatePlayerSql, info.nickname, info.money, info.curlevel, info.item, pid)
        local result = skynet.call(self.m_MysqlDB, "lua", "excute", playerSql)
        if not result then
            skynet.error("[PLAYER ERROR] player info save to mysql faild, pid = " .. pid)
        end
        for _, member in ipairs(info.team) do
            local memberSql = string.format(self.m_UpdateMemberInfo, member.alive, member.weaponid, member.armorid, member.normalskillid, member.ultraskillid, member.hp, member.energy, member.practiceattrs, member.rewardattrs, member.id)
            local result = skynet.call(self.m_MysqlDB, "lua", "excute", memberSql)
            if not result then
                skynet.error("[PLAYER ERROR] member info save to mysql faild, id = " .. member.id .. " pid = " .. pid)
            end
        end
    end
end


-- FOR CLINET API
function PlayerSystem:getPlayer(data)
    local uid, code = self:getUid(data.token)
    if uid == nil then
        return {errcode = code}
    end
    local info = self:findPlayerInRedis(uid)
    if info then
        return info
    end
    local p = self:getPlayerByUid(uid)
    if p ~= nil then
        if p.team == nil then
            p.errcode = errcode.ERR_NO_MEMBER
            return p
        else
            local sql = string.format(self.m_UpdatePlayerOnlineTime, p.lasttime, uid)
            local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
            if not result then
                skynet.error("[PLAYER ERROR] player info update last online time faild, uid = " .. uid)
                return { errcode.HANDLE_SQL_FAILED }
            end
            self:setPlayerInRedis(p)
            return self:findPlayerInRedis(uid)
        end
    end
    local ret = self:createPlayer(uid, data.nickname)
    if errcode.SUCCEESS ~= ret then
        return ret
    end
    return self:findPlayerInRedis(uid)
end

function PlayerSystem:updateMoney(data)
    local uid, code = self:getUid(data.token)
    if uid == nil then
        return {errcode = code}
    end
    local info = self:findPlayerInRedis(uid)
    if info then
        info.money = info.money + data.value
        local sql = string.format(self.m_UpdatePlayerMonery, info.money, uid)
        local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
        if not result then
            skynet.error("[PLAYER ERROR] player info update money faild, uid = " .. uid)
            return { errcode.HANDLE_SQL_FAILED }
        end
        self:setPlayerInRedis(info)
        return { errcode.SUCCEESS, money = info.money }
    end
    return { errcode.ERR_UPDATE_MONEY_FAILED }
end
 
function PlayerSystem:updateLevel(data)
    local uid, code = self:getUid(data.token)
    if uid == nil then
        return {errcode = code}
    end
    local info = self:findPlayerInRedis(uid)
    if info then
        info.curlevel = data.value
        local sql = string.format(self.m_UpdatePlayerLevel, info.curlevel, uid)
        local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
        if not result then
            skynet.error("[PLAYER ERROR] player info update level faild, uid = " .. uid)
            return { errcode.HANDLE_SQL_FAILED }
        end
        self:setPlayerInRedis(info)
        return { errcode.SUCCEESS, info.curlevel }
    end
    return { errcode.ERR_UPDATE_LEVEL_FAILED }
end
 
function PlayerSystem:updateItem(data)
    local uid, code = self:getUid(data.token)
    if uid == nil then
        return {errcode = code}
    end
    local info = self:findPlayerInRedis(uid)
    if info then
        local itemInfo = cjson.decode(info.item)
        local count = itemInfo[data.itemid]
        if count == nil then
            itemInfo[data.itemid] = data.value
        else
            itemInfo[data.itemid] = count + data.value
        end
        info.item = cjson.encode(itemInfo)
        local sql = string.format(self.m_UpdatePlayerItem, info.item, uid)
        local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
        if not result then
            skynet.error("[PLAYER ERROR] player info update item faild, uid = " .. uid)
            return { errcode.HANDLE_SQL_FAILED }
        end
        self:setPlayerInRedis(info)
        return { errcode.SUCCEESS, item = info.item }
    end
    return { errcode.ERR_UPDATE_ITEM_FAILED }
end

function PlayerSystem:updateMember(data)
    local uid, code = self:getUid(data.token)
    if uid == nil then
        return {errcode = code}
    end
    local info = self:findPlayerInRedis(uid)
    if info then
        local member = cjson.decode(data.memberInfo)
        local team = cjson.decode(info.team)
        for i = #team, 1, -1 do
            if team[i] == member.id then
                table.remove(team, i)
                break
            end
        end
        table.insert( team, member )
        info.team = cjson.encode(team)
        local sql = string.format(self.m_UpdateMemberInfo, info.team, uid)
        local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
        if not result then
            skynet.error("[PLAYER ERROR] player info update member data faild, uid = " .. uid)
            return { errcode.HANDLE_SQL_FAILED }
        end
        self:setPlayerInRedis(info)
        return { errcode.SUCCEESS, team = info.team }
    end
    return { errcode.ERR_UPDATE_MEMBER_INFO_FAILED }
end

return PlayerSystem