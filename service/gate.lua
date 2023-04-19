local skynet = require "skynet"
local socket = require "skynet.socket"

local HandleMessage = function (fd, msg)
    skynet.error("clinet fd = " .. fd .. " msg = " .. msg)

    skynet.write(fd, "s2c = " .. msg)
end

local HandleConnection = function (fd, addr)
    skynet.error(string.format("New client from %s:%d", addr, fd))

    -- 监听客户端消息
    socket.start(fd)

   -- 循环接收客户端消息
   while true do
        -- 接收客户端消息
        local msg, err = socket.read(fd)
        if err then
            skynet.error(string.format("Client %d closed: %s", fd, err))
            socket.close(fd)
            return
        end

        -- 处理客户端消息
        HandleMessage(fd, msg)
    end
end

-- 启动Skynet服务
skynet.start(function ()
    -- 监听端口
    local listen_fd = socket.listen("0.0.0.0", 3636)
    skynet.error(string.format("Listen on 0.0.0.0:3636"))
    -- 开始监听客户端连接
    socket.start(listen_fd, function(fd, addr)
        -- 处理客户端连接
        skynet.fork(HandleConnection, fd, addr)
    end)
end)