local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local webInterface = require "WebInterface"
local cjson = require "cjson"
require "SystemMain"

local function response(id, write, ...)
	local ok, err = httpd.write_response(write, ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end

-- message callback
skynet.start(function ()
    local protocol = skynet.getenv("protocol") or "http"
    skynet.dispatch("lua", function (source, session, fd)
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
                    if query then
                        local cmd = string.sub(path, 2)
                        local q = urllib.parse_query(query)
                        local api = q["api"]
                        local args = cjson.decode(q["data"])
                        local ret = GMgr:call(cmd, api, args)
                        response(fd, wi.write, code, cjson.encode(ret))
                    else
                        response(fd, wi.write, code, "error")
                    end
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
    end)
end)