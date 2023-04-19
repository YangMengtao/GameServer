local skynet = require "skynet"
require "skynet.manager" -- 引入 skynet.manager 模块

skynet.start(function()
    skynet.start(function()
        skynet.newservice("socket")
        local httpd = skynet.newservice("httpd")
        skynet.call(httpd, "lua", "start", {
            port = 3636,
            accesslog = skynet.getenv("accesslog") or "access.log",
            autoindex = true,
            root = "./www"
        })
    
        skynet.dispatch("http", function(session, address, method, header, url, body)
            local respheader = {
                ["Content-Type"] = "text/html",
            }
            local respbody = "<html><head><title>Hello Skynet</title></head><body><h1>Hello Skynet!</h1></body></html>"
            local status = 200
            skynet.ret(skynet.pack(status, respheader, respbody))
        end)
    end)
end)