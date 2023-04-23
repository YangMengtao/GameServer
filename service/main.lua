local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local webInterface = require "WebInterface"
--local cjson = require "cjson"

local mode, protocol = ...
protocol = protocol or "http"

local function response(id, write, ...)
	local ok, err = httpd.write_response(write, ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end

-- message callback
skynet.start(skynet.dispatch("lua", function (source, session, fd)
    socket.start(fd)

    local wi = webInterface.Gen(protocol, fd)
    if wi then
        if wi.init then
            wi.init()
        end
        local code, url, method, header, body = httpd.read_request(wi.read)
        if code then
            if code ~= 200 then
                response(fd, wi.write, code)
            else
                local path, query = urllib.parse(url)
                local tmp = "{ code = " .. code 
                if query then
                    local q = urllib.parse_query(query)
                    for k, v in pairs(q) do
                        tmp = tmp .. ", " .. k .. "=" .. v
                    end
                    
                end
                tmp = "}"
                response(fd, wi.write, code, tmp)
            end
        else
            if url == sockethelper.socket_error then
                skynet.error("[Error]:socket closed")
            else
                skynet.error("[Error]:" .. url)
            end
        end
    end

    socket.close(fd)

    if wi and wi.close then
        wi.close()
    end
end))

-- 初始化web socket
skynet.start(function ()
    local agent = {}
    -- 创建20个服务处理不同客户端发来的消息
    for i = 1, 20 do
        agent[i] = skynet.newservice(SERVICE_NAME, "agent", protocol)
    end

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
