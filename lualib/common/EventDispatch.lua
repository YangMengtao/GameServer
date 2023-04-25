local skynet = require "skynet"
local Class = require "common.class"

local EventDispatch = Class:new()

function EventDispatch:ctor()
    self.m_EventList = {}
end

function EventDispatch:addEvent(id, func)
    if type(id) == "number" then
        self.m_EventList[id] = self.m_EventList[id] or {}
        local has = false
        for _, e in ipairs(self.m_EventList[id]) do
            if e == func then
                has = true
                break
            end
        end
        if not has then
            table.insert(self.m_EventList[id], func)
        end
        return
    end

    skynet.error("[Event Error] : id must a number, id = " .. id)
end

function EventDispatch:removeEvent(id, func)
    if type(id) == "number" then
        local event = self.m_EventList[id]
        if event == nil then
            skynet.error("[Event Error] : not found id, id = " .. id)
        else
            local index = -1
            for k, e in ipairs(self.m_EventList[id]) do
                if e == func then
                    index = k
                    break
                end
            end
            if index ~= -1 then
                table.remove(self.m_EventList[id], index)
            end
        end
        return
    end

    skynet.error("[Event Error] : id must a number, id = " .. id)
end

function EventDispatch:dispatch(id, args)
    if type(id) == "number" then
        local event = self.m_EventList[id]
        if event == nil then
            skynet.error("[Event Error] : not found id, id = " .. id)
        else
            for _, e in ipairs(self.m_EventList[id]) do
                e(args)
            end
        end
        return
    end

    skynet.error("[Event Error] : id must a number, id = " .. id)
end

return EventDispatch