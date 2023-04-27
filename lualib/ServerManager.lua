local skynet = require "skynet"
local Class = require "common.class"

local ServerManager = Class:new()

function ServerManager:ctor()
    self.m_Systems = {}
    self.m_UserList = {}
end

function ServerManager:addSystem(name, service)
    self.m_Systems[name] = service
end

function ServerManager:call(cmd, api, data)
    if "lgoin" == cmd then
        local service = self.m_Systems[cmd]
        if service ~= nil then
            local ret = skynet.call(service, "lua", api, data)
            return ret
        else
            skynet.error("[System Error] : not found service = " .. cmd)
        end
    else
        
    end
    
    return { errcode = -6666}
end

return ServerManager