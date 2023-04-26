local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"

local function response(id, write, ...)
    local ok, err = httpd.write_response(write, ...)
    if not ok then
        skynet.error(string.format("fd = %d, %s", id, err))
    end
end

local SSLCTX_SERVER = nil
local function GenInterface(protocol, fd)
	if protocol == "http" then
		return {
			init = nil,
			close = nil,
			read = sockethelper.readfunc(fd),
			write = sockethelper.writefunc(fd),
		}
	elseif protocol == "https" then
		local tls = require "http.tlshelper"
		if not SSLCTX_SERVER then
			SSLCTX_SERVER = tls.newctx()
			-- gen cert and key
			-- openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-cert.pem
			local certfile = skynet.getenv("certfile") or "./server-cert.pem"
			local keyfile = skynet.getenv("keyfile") or "./server-key.pem"
			print(certfile, keyfile)
			SSLCTX_SERVER:set_cert(certfile, keyfile)
		end
		local tls_ctx = tls.newtls("server", SSLCTX_SERVER)
		return {
			init = tls.init_responsefunc(fd, tls_ctx),
			close = tls.closefunc(tls_ctx),
			read = tls.readfunc(fd, tls_ctx),
			write = tls.writefunc(fd, tls_ctx),
		}
	else
		error(string.format("Invalid protocol: %s", protocol))
	end
end

local function request_handler(id, addr, protocol)
    local interface = GenInterface(protocol, id)
    if interface.init then
        interface.init()
    end
    local code, url, method, header, body = httpd.read_request(interface.read, 8192)
    skynet.error(string.format("id = %d, addr = %s, method = %s, url = %s, body = %s", id, addr, method, url, body))
    local path, query = urllib.parse(url)
    if path == "/login" and method == "POST" then
        -- 处理登录请求
        -- ...
        response(id, interface.write, code, {}, "OK")
    else
        response(id, interface.write, code, {}, "Not Found")
    end
end

skynet.start(function()
    local protocol = "http"
    local fd = socket.listen("0.0.0.0", 3636)
    skynet.error(string.format("Listen web port 3636 protocol:%s", protocol))
	socket.start(fd , function(id, addr)
		skynet.error(string.format("%s connected, pass it to agent :%08x", addr, id))
        request_handler(id, addr, protocol)
	end)
end)
