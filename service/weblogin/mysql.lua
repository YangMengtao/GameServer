local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

local MySqlPool = {}

function MySqlPool.connect()
    local host = skynet.getenv("mysql_conf.host")
    local port = skynet.getenv("mysql_conf.port")
    local database = skynet.getenv("mysql_conf.database")
    local user = skynet.getenv("mysql_conf.user")
    local password = skynet.getenv("mysql_conf.password")
    local max_packet_size = skynet.getenv("mysql_conf.max_packet_size")

    
    MySqlPool.m_ConnectHandle = mysql.connect(
        {
            host = host,
            port = port,
            database = database,
            user = user,
            password = password,
            max_packet_size = max_packet_size,
        }
    )

    if not MySqlPool.m_ConnectHandle then
        skynet.error("connect mysql failed!")
        return false
    end

    skynet.error("connect mysql success!")
    return true
end

function MySqlPool.disconnect()
    if MySqlPool.m_ConnectHandle then
        MySqlPool.m_ConnectHandle:disconnect()
        MySqlPool.m_ConnectHandle = nil
    end
end

function MySqlPool.query(sql)
    if MySqlPool.m_ConnectHandle then
        local res, err, errno, sqlstate = MySqlPool.m_ConnectHandle:query(sql)
        if not res then
            skynet.error("mysql query error: " .. err)
            return false, err
        end

        return true, res, err, errno, sqlstate
    end

    return false
end

return MySqlPool