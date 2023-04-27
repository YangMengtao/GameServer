local skynet = require "skynet"
local socket = require "skynet.socket"

local M = {}
M.m_ListenId = 0
M.m_Agent = {}

local stop = function ()
    local mysql_pool = skynet.queryservice("mysql_pool")
    skynet.send(mysql_pool, "lua", "disconnect")
    local redis_pool = skynet.queryservice("redis_pool")
    skynet.send(redis_pool, "lua", "disconnect")
    socket.close(M.m_ListenId)
    skynet.exit()
end

-- 初始化web socket
skynet.start(function ()
    local protocol = skynet.getenv("protocol") or "http"
    -- 创建20个服务处理不同客户端发来的消息
    local count = skynet.getenv("agnet_count") or 10
    for i = 1, count do
        M.m_Agent[i] = skynet.newservice("agent")
    end

    -- 创建mysql服务
    local mysql_db = skynet.newservice("mysql_pool")
    -- test
    -- skynet.send("Mysql_Pool", "lua", "excute", "SELECT id,password FROM user WHERE username='aaaa'", function (...)
    --     local args = { ... }
    --     for key, value in pairs(args) do
    --         skynet.error(" test = " .. key .. " " .. value)
    --     end
    -- end)

    -- 创建redis服务
    local redis_db = skynet.newservice("redis_pool")
    -- test redis
    -- skynet.send(redis_db, "lua", "set", "testa", 123455)
    -- local ret = skynet.call(redis_db, "lua", "get", "testa")
    -- if ret then
    --     skynet.error("redis : v = " .. ret)
    -- end

    local login = skynet.newservice("login", mysql_db, redis_db)
    for _, value in ipairs(M.m_Agent) do
        skynet.send(value, "lua", "ADD_SYSTEM", "login", login)
    end

    local balance = 1
    local port = skynet.getenv("port") or 3636
	M.m_ListenId = socket.listen("0.0.0.0", port)

    skynet.error(string.format("listen web port = [%s] protocol = [%s]", port, protocol))

    socket.start(M.m_ListenId, function (id, addr)
        skynet.error(string.format("%s connected, pass it to agent :%08x", addr, M.m_Agent[balance]))
        skynet.send(M.m_Agent[balance], "lua", "", id)
		balance = balance + 1
		if balance > #M.m_Agent then
			balance = 1
		end
    end)

    stop()
end)
