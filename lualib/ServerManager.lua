local skynet = require "skynet"
local Class = require "common.class"
local md5 = require "md5"

local ServerManager = Class:new()

function ServerManager:ctor()
    self.m_Systems = {}
    self.m_UserList = {}
end

function ServerManager:addSystem(name, service)
    self.m_Systems[name] = service
end

function ServerManager:call(cmd, api, data)
    local system = self.m_Systems[cmd]
    if system ~= nil then
        local func = system[api]
        if func then
            return func(system, data)
        else
            skynet.error("[System Error] : not found system = " .. cmd .. " function  = " .. api)
        end
    else
        skynet.error("[System Error] : not found system, system cmd = " .. cmd)
    end
    return "{ err = -9999}"
end

return ServerManager