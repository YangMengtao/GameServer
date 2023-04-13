
local skynet = require "skynet"
local cluster = require "skynet.cluster"

local M = {
    m_ID = 0,
    m_Name = "",

    FuncExit = nil,
    FuncInit = nil,
    CMD = {},
}

local function TrackBack(err)
    skynet.error(tostring(err))
    skynet.error(debug.traceback())
end

local function dispatch(session, address, cmd, ...)
    local func = M.CMD[cmd]
    if not func then
        skynet.ret()
        return
    end

    local ret = table.pack(xpcall(func, TrackBack, address, ...))
    if not ret[1] then
        skynet.ret();
        return
    end

    skynet.retpack(table.unpack(ret, 2))
end

local function Init()
    skynet.error(M.m_ID .. " " .. M.m_Name .. "init")
    skynet.dispatch("lua", dispatch)
    if M.FuncInit then
        M.FuncInit()
    end
end

function  M.Start(id, name)
    M.m_ID = id
    M.m_Name = name
    skynet.start(Init)
end

return M