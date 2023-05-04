local skynet = require "skynet"
local playerSys = require "system.player.PlayerSystem"

local player = playerSys:new()

local function init(mysql_db, redis_db)
    player:initDB(mysql_db, redis_db)
end

init(...)

skynet.start(function ()
    skynet.dispatch("lua", function (session, address, api, ...)
        skynet.error("[PLAYER] : API = " .. api)
        local func = player[api]
        if not func then
            skynet.error("[LOGIN Error] : not found function = " .. api)
            skynet.ret()
            return
        end

        skynet.ret(skynet.pack(func(player, ...)))
    end)
end)