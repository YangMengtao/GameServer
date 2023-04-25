local skynet = require "skynet"
local Class = require "common.class"
local md5 = require "md5"

local login = require "system.LoginSystem"

local ServerManager = Class:new()

function ServerManager:ctor()
    self.m_Systems = {}

    self:addSystem()
end

function ServerManager:addSystem()
    self.m_Systems[GCmd:GetLoginCmd()] = login:new()
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

function ServerManager:getToken(uid)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7) .. tostring(uid))
    local token = ""
    for i = 1, 32 do
        token = token .. string.char(math.random(97, 122))
    end
    return token
end

return ServerManager