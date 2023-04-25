local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

local M = {}

local function TrackBack(err)
    skynet.error("[Mysql Error] : " .. tostring(err))
    skynet.error("[Mysql Error] : " .. debug.traceback())
end

function M.excute(sql)
    if M.m_HandleID then
        skynet.error(sql)
        local res, err = M.m_HandleID:query(sql)
        if not res then
            skynet.error("[Mysql Error] : mysql query error: " .. err)
            return nil, err, 500
        end

        return res, err, 0
    end

    return nil, nil, -1
end

function M.disconnect()
    if M.m_HandleID then
        M.m_HandleID:disconnect()
        M.m_HandleID = nil
    end
end

skynet.start(function ()
    M.m_HandleID = mysql.connect(
        {
            host = skynet.getenv("mysql_host"),
            port = skynet.getenv("mysql_port"),
            database = skynet.getenv("mysql_database"),
            user = skynet.getenv("mysql_user"),
            password = skynet.getenv("mysql_password"),
            max_packet_size = skynet.getenv("mysql_max_packet_size"),
        }
    )

    if M.m_HandleID == nil then
        skynet.error("[Mysql Error] : connect mysql failed!")
        return false
    end

    skynet.dispatch("lua", function (session, address, cmd, ...)
        local func = M[cmd]
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
    end)

    skynet.error("[Mysql] : connect mysql success!")
end)