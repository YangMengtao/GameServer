
local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

skynet.start(function ()
    skynet.error("[Start Main] Server Start....")

    local db = mysql.connet(
        {
            host = "127.0.0.1",
            port = 3306,
            database = "login_system",
            user = "root",
            password = "123456",
            max_packet_size = 1024 * 1024,
            on_connet = nil,
        }
    )

    local res = db:query("insert into user(username,) values (\'aaaa\')")

    res = db:query('select * form user')
    for k, v in pairs(res) do
        print(k .. " " .. v.id .. "  " .. v.username)
    end

    local worker = skynet.newservice("worker", 1, "worker")
    local buy = skynet.newservice("buy", 1, "buy")

    skynet.send(worker, "lua", "StartWork")
    skynet.sleep(200)
    skynet.send(worker, "lua", "StopWork")

    skynet.send(buy, "lua", "Buy")

    skynet.exit()
end)