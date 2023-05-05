local system = require "common.system"
local errcode = require "system.player.PlayerErrcode"

local skynet = require "skynet"
local cjson = require "cjson"

local PlayerSystem = system:new()

function PlayerSystem:ctor()
    self:initSql()
end

function PlayerSystem:initSql()
    self.m_QueryByUidSql = "SELECT id,uid,nickname,money,curlevel,item,team FROM player WHERE uid='%d'"
    self.m_NewPlayerSql = "INSERT INTO player (uid,nickname) VALUES ('%d', '%s')"
    self.m_UpatePlayerSql = "UPDATE player SET nickname = %s,SET money = %d,SET curlevel = %d,SET item = %s WHERE uid = '%d'"
    self.m_NewMemberSql = "INSERT INTO team_member (pid,hp,energy) VALUES ('%d', '%d', '%d')"
    self.m_QueryTeamMember = "SELECT id,alive,weaponid,armorid,normalskillid,ultraskillid,hp,energy,practiceattrs,rewardattrs FROM team_member WHERE pid = '%d'"
    self.m_UpdateMemberInfo = "UPDATE team_member SET alive = '%d',SET weaponid = '%d',SET armorid = '%d',SET normalskillid = '%d',SET ultraskillid = '%d',SET hp = '%d',SET energy = '%d' WHERE id = '%d'"
end

function PlayerSystem:createPlayer(uid, nickname)
    -- 添加Player
    local sql = string.format(self.m_NewPlayerSql, uid, nickname)
    local result = skynet.call(self.m_MysqlDB, "lua", "excute", sql)
    if result and #result > 0 then
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
            ret.token = self:getToken(ret.uid)

            -- 添加一个team member
            if self:addNewMember(ret.id, 100, 0) then
                ret.team = self:queryMember(ret.id)
                if ret.team == nil then
                    return errcode.ERR_NO_MEMBER
                end
                self:setPlayerInRedis(ret)
            else
                return errcode.ERR_ADD_NEW_MEMBER_FAILED
            end
            return errcode.SUCCEESS
        end
    end
    return errcode.ERR_ADD_NEW_PLAYER_FAILED
end

function PlayerSystem:getPlayer(data)
    local uid = self:getUid(data.token)
    local info = self:findPlayerInRedis(uid)
    if info then
        return info
    end

    local ret = self:createPlayer(uid, data.nickname)
    if errcode.SUCCEESS ~= ret then
        return ret
    end
    return self:findPlayerInRedis(uid)
end

function PlayerSystem:getPlayerByUid(uid, nickname)
    local info = self:findPlayerInRedis(uid)
    if info then
        return true, info
    end

    local ret = self:createPlayer(uid, nickname)
    if errcode.SUCCEESS ~= ret then
        return false, ret
    end
    return true, self:findPlayerInRedis(uid)
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

function PlayerSystem:updateMoney(pid, value)
   local info = self:findPlayerInRedis(pid)
   if info then
        info.money = info.money + value
        self:setPlayerInRedis(info)
        return errcode.SUCCEESS
   end
   return errcode.ERR_UPDATE_MONEY_FAILED
end

function PlayerSystem:updateLevel(pid, value)
    local info = self:findPlayerInRedis(pid)
    if info then
         info.curlevel = value
         self:setPlayerInRedis(info)
         return errcode.SUCCEESS
    end
    return errcode.ERR_UPDATE_LEVEL_FAILED
 end

 function PlayerSystem:updateItem(pid, itemid, value)
    local info = self:findPlayerInRedis(pid)
    if info then
        local itemInfo = cjson.decode(info.item)
         local count = itemInfo[itemid]
         if count == nil then
            itemInfo[itemid] = value
         else
            itemInfo[itemid] = count + value
         end
         info.item = cjson.encode(itemInfo)
         self:setPlayerInRedis(info)
         return errcode.SUCCEESS
    end
    return errcode.ERR_UPDATE_ITEM_FAILED
 end

 function PlayerSystem:updateMember(pid, memberInfo)
    local info = self:findPlayerInRedis(pid)
    if info then
        for i = #info.team, 1, -1 do
            if info.team[i] == memberInfo.id then
                table.remove(info.team, i)
                break
            end
        end
        table.insert( info.team, memberInfo )
        self:setPlayerInRedis(info)
        return errcode.SUCCEESS
    end
    return errcode.ERR_UPDATE_MEMBER_INFO_FAILED
 end

function PlayerSystem:findPlayerInRedis(uid)
    local players = skynet.call(self.m_RedisDB, "lua", "get", "PlayerInfo") or {}
    if type(players) == "string" then
        players = cjson.decode(players)
    end
    return players[uid]
end

function PlayerSystem:setPlayerInRedis(info)
    local players = skynet.call(self.m_RedisDB, "lua", "get", "PlayerInfo") or {}
    if type(players) == "string" then
        players = cjson.decode(players)
    end
    players[info.id] = info
    local str = cjson.encode(players)
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

return PlayerSystem