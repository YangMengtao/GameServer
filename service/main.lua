
local skynet = require "skynet"

skynet.start(function ()
    skynet.error("[Start Main] Server Start....")

    local worker = skynet.newservice("worker", 1, "worker")
    local buy = skynet.newservice("buy", 1, "buy")

    skynet.send(worker, "lua", "StartWork")
    skynet.sleep(200)
    skynet.send(worker, "lua", "StopWork")

    skynet.send(buy, "lua", "Buy")

    skynet.exit()
end)