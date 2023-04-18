
local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local socket = require "skynet.socket"
--local json = require "cjson"

local function convertToTab(res, tab, finalTable)
    if finalTable == nil then
        return
    end

    tab = tab or 0
    if tab == 0 then
        skynet.error("---------------------- dump -------------------------")
    end
    if type(res) == "table" then
        -- skynet.error(string.rep("\t", tab) .. "{")
        for k, v in pairs(res) do
            if type(v) == "table" then
                convertToTab(v, tab + 1, finalTable)
            else
                -- skynet.error(string.rep("\t", tab), k, "=", v, ",")
                finalTable[k] = v
            end
        end
        -- skynet.error(string.rep("\t", tab) .. "}")
    else
        skynet.error(string.rep("\t", tab), res)
    end
end

local isSuccess = function (res)
    if res.badreult then
        return false, res.errno, res.err
    end

    return true, nil, nil
end

local Query = function (db, sql)
    local res = db:query(sql)
    local tmp = {}
    convertToTab(res, 0, tmp)
    return tmp
end

local Decode = function (str, reps)
    local resultStrList = {}
    string.gsub(str, '[^' .. reps .. ']+', function (w)
        table.insert(resultStrList, w)
    end)
    return resultStrList
end

local CMD = {}
local Client_fd = {}
local Online_User = {}

function CMD.login(db, fd, msg)
    -- local data = json.decode(msg)
    local data = Decode(msg, "|")
    local userName = data[1]
    local passWord = data[2]

    local check_username_sql = string.format("SELECT id FROM user WHERE username='%s'", userName)
    local check_password_sql = string.format("SELECT id FROM user WHERE password='%s'", passWord)
    local res = Query(db, check_username_sql)
    if #res > 0 then
        local success, code, msg = isSuccess(res)
        if success then
            res = Query(db, check_password_sql)
            success, code, msg = isSuccess(res)
            if success then
                if #res > 0 then
                    if Online_User[userName] then
                        return {cdoe = 1, message = "该用户已经在线"}
                    end
                    Online_User[userName] = fd
                    Client_fd[fd] = userName
                    return {code = 0, message = "登录成功"}
                else
                    return { code = 3, message = "账户密码不正确,登录失败"}
                end
            else
                return { code = 2, message = "errcode = " .. code .. " msg = " .. msg}
            end
        else
            return { code = 2, message = "errcode = " .. code .. " msg = " .. msg}
        end
    end
end

function CMD.send(fd, msg)
    local data = Decode(msg, "|")
    local to_user = data[1]
    local message = data[2]
    local to = Online_User[to_user]
    if not to then
        return { code = 1, message = "对方不在线" }
    end
    socket.write(to, message)
    return { code = 0, message = "发送成功" }
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

    local res = Query(db, string.format("select id from user where username='%s'", "aaaa"))
    if #res > 0 then
        res = Query(db, "select * form user")
        local flag, code, msg = isSuccess(res)
        if not flag then
            skynet.error("QUERY FAILED = errcode = " .. code .. " msg = " .. msg)
        end
    else
        res = Query(db, "insert into user(username,password) values (\'aaaa\',\'123456\')")
        local flag, code, msg = isSuccess(res)
        if not flag then
            skynet.error("QUERY FAILED = errcode = " .. code .. " msg = " .. msg)
        end
    end

    local listen_id = socket.listen("0.0.0.0", 3636)
    skynet.error("Listen socket : ", "0.0.0.0", 3636)

    socket.start(listen_id, function (fd, addr)
        skynet.error("Accept client socket:", fd, addr)

        socket.start(fd)
        Client_fd[fd] = nil
        skynet.fork(function ()
            while true do
                local str = socket.readline(fd)
                if not str then
                    break
                end

                local data = Decode(str, "|")
                local cmd = data.cmd

                local func = CMD[cmd]
                if func then
                    local res = func(fd, str)
                    local res_str = res
                    socket.write(fd, res_str)
                else
                    skynet.error("Unknown commond = ", cmd)
                end

                local userName = Client_fd[fd]
                if userName then
                    Online_User[userName] = nil
                    Client_fd[fd] = nil
                end

                skynet.error("Disconnect client socket = ", fd)
                socket.closed(fd)
            end
        end)
    end)

    db:disconnect()

    -- local worker = skynet.newservice("worker", 1, "worker")
    -- local buy = skynet.newservice("buy", 1, "buy")

    -- skynet.send(worker, "lua", "StartWork")
    -- skynet.sleep(200)
    -- skynet.send(worker, "lua", "StopWork")

    -- skynet.send(buy, "lua", "Buy")

    skynet.exit()
end)