local skynet = require "skynet"
local socket = require "skynet.socket"

-- 初始化web socket
skynet.start(function ()
    local agent = {}
    local protocol = skynet.getenv("protocol") or "http"
    -- 创建20个服务处理不同客户端发来的消息
    for i = 1, 20 do
        agent[i] = skynet.newservice("agent")
    end

    -- 创建mysql服务
    GMySql = skynet.newservice("mysql_pool")

    -- 创建redis服务
    --GRedis = skynet.newservice("redis_pool")

    local balance = 1
    local port = 3636
	local id = socket.listen("0.0.0.0", port)

    skynet.error(string.format("listen web port = [%s] protocol = [%s]", port, protocol))

    socket.start(id, function (id, addr)
        skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
        skynet.send(agent[balance], "lua", id)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
    end)
end)
