local skynet = require "skynet"
local httpd = require "skynet.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"

local function response(id, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
    if not ok then
        skynet.error(string.format("response failed : %s", err))
    end
end

local function request_handler(id, addr, method, header, url, body, ...)
    skynet.error(string.format("id = %d, addr = %s, method = %s, url = %s, body = %s", id, addr, method, url, body))
    local path, query = urllib.parse(url)
    if path == "/login" and method == "POST" then
        -- 处理登录请求
        -- ...
        response(id, 200, {}, "OK")
    else
        response(id, 404, {}, "Not Found")
    end
end

skynet.start(function()
    local address = "0.0.0.0:3636"
    local id = assert(httpd.listen(address, function(id, addr, method, header, url, body)
        local path, query = urllib.parse(url)
        request_handler(id, addr, method, header, url, body)
    end))
    skynet.error(string.format("Listen web port %d success!", 8000))
end)
