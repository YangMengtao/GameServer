local skynet = require "skynet"
local login = require "system.login.LoginSystem"

local login = login:new()

local function init(mysql_db, redis_db)
    login:initDB(mysql_db, redis_db)
end

init(...)

skynet.start(function ()
    skynet.dispatch("lua", function (session, address, api, ...)
        skynet.error("[LOGIN] : API = " .. api)
        local func = login[api]
        if not func then
            skynet.error("[LOGIN Error] : not found function = " .. api)
            skynet.ret()
            return
        end

        skynet.ret(skynet.pack(func(login, ...)))
    end)
end)