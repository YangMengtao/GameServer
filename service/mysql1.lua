local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

local function ConvertToTab(res, tab, finalTable)
    if finalTable == nil then
        return
    end

    tab = tab or 0
    if tab == 0 then
        skynet.error("---------------------- dump -------------------------")
    end
    if type(res) == "table" then
        -- skynet.error(string.rep("\t", tab) .. "{")
        for k, v in pairs(res) do
            if type(v) == "table" then
                ConvertToTab(v, tab + 1, finalTable)
            else
                -- skynet.error(string.rep("\t", tab), k, "=", v, ",")
                finalTable[k] = v
            end
        end
        -- skynet.error(string.rep("\t", tab) .. "}")
    else
        skynet.error(string.rep("\t", tab), res)
    end
end

local IsSuccess = function (res)
    if res.badreult then
        return false, res.errno, res.err
    end

    return true, nil, nil
end

local DataBase = {}

function DataBase.ConnectMySql()
    DataBase.m_ConnectHandle = mysql.connect(
        {
            host = "127.0.0.1",
            port = 3306,
            database = "login_system",
            user = "root",
            password = "123456",
            max_packet_size = 1024 * 1024,
            on_connet = nil,
        }
    )

    if not DataBase.m_ConnectHandle then
        skynet.error("connect mysql failed!")
        skynet.exit()
    else
        skynet.error("connect mysql success!")
    end
end

function DataBase.DisconnectMySql()
    if DataBase.m_ConnectHandle then
        DataBase.m_ConnectHandle:disconnect()
        DataBase.m_ConnectHandle = nil
    end
end

function DataBase.Query(sql)
    if DataBase.m_ConnectHandle then
        local res = self.m_ConnectHandle:query(sql)
        local tmp = {}
        ConvertToTab(res, 0, tmp)
    end
    return nil
end

local function Init()
    skynet.dispatch("lua", function (session, source, cmd, ...)
        local func = DataBase[cmd]
        if not func then
            skynet.error("mysql not found function : " .. cmd)
        end
    end)
end

skynet.start(Init)

return DataBase

-- local res = Query(db, string.format("select id from user where username='%s'", "aaaa"))
-- if #res > 0 then
--     res = Query(db, "select * form user")
--     local flag, code, msg = isSuccess(res)
--     if not flag then
--         skynet.error("QUERY FAILED = errcode = " .. code .. " msg = " .. msg)
--     end
-- else
--     res = Query(db, "insert into user(username,password) values (\'aaaa\',\'123456\')")
--     local flag, code, msg = isSuccess(res)
--     if not flag then
--         skynet.error("QUERY FAILED = errcode = " .. code .. " msg = " .. msg)
--     end
-- end
