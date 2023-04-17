
local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

local function dump(res, tab)
    tab = tab or 0
    if tab == 0 then
        skynet.error("dump")
    end

    if type(res) == "table" then
        skynet.error(string.rep("t", tab) .. "{")
        for k, v in pairs(res) do
            if type(v) == "table" then
                dump(v, tab + 1)
            else
                skynet.error(string.rep("t", tab), k, " = ", v, ",")
            end
        end
        skynet.error(string.rep("t", tab) .. "}")
    else
        skynet.error(string.rep("\t", tab), res)
    end
end

skynet.start(function ()
    skynet.error("[Start Main] Server Start....")

    local db = mysql.connect(
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

    if not db then
        skynet.error("connect mysql failed!")
        skynet.exit()
    else
        skynet.error("connect mysql success!")
    end

    local res = db:query("insert into user(username,) values (\'aaaa\')")
    dump(res)

    res = db:query('select * form user')
    dump(res)

    db:disconnect()

    local worker = skynet.newservice("worker", 1, "worker")
    local buy = skynet.newservice("buy", 1, "buy")

    skynet.send(worker, "lua", "StartWork")
    skynet.sleep(200)
    skynet.send(worker, "lua", "StopWork")

    skynet.send(buy, "lua", "Buy")

    skynet.exit()
end)