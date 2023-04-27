local skynet = require "skynet"
local Class = require "common.class"
local errcode = require "common.errcode"

local ServerManager = Class:new()

function ServerManager:ctor()
    self.m_Systems = {}
    self.m_UserList = {}
end

function ServerManager:addSystem(name, service)
    self.m_Systems[name] = service
end

function ServerManager:call(cmd, api, data)
    local service = self.m_Systems[cmd]
    if service ~= nil then
        local ret = skynet.call(service, "lua", api, data)
        return ret
    else
        skynet.error("[System Error] : not found service = " .. cmd)
        return { errcode = errcode.UNKNOWN}
    end
end

return ServerManager