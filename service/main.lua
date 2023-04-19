
local skynet = require "skynet"
--local json = require "cjson"

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
    -- socket.write(to, message)
    return { code = 0, message = "发送成功" }
end

skynet.start(function ()
    skynet.error("[Start Main] Server Start....")

    local gate = skynet.newservice("gate")
    -- skynet.call(gate, "lua", "start")

    -- socket.start(listen_id, function (fd, addr)
    --     skynet.error("Accept client socket:", fd, addr)

    --     socket.start(fd)
    --     Client_fd[fd] = nil
    --     skynet.fork(function ()
    --         while true do
    --             local str = socket.readline(fd)
    --             if not str then
    --                 break
    --             end

    --             local data = Decode(str, "|")
    --             local cmd = data.cmd

    --             local func = CMD[cmd]
    --             if func then
    --                 local res = func(fd, str)
    --                 local res_str = res
    --                 socket.write(fd, res_str)
    --             else
    --                 skynet.error("Unknown commond = ", cmd)
    --             end

    --             local userName = Client_fd[fd]
    --             if userName then
    --                 Online_User[userName] = nil
    --                 Client_fd[fd] = nil
    --             end

    --             skynet.error("Disconnect client socket = ", fd)
    --             socket.closed(fd)
    --         end
    --     end)
    -- end)

    -- local worker = skynet.newservice("worker", 1, "worker")
    -- local buy = skynet.newservice("buy", 1, "buy")

    -- skynet.send(worker, "lua", "StartWork")
    -- skynet.sleep(200)
    -- skynet.send(worker, "lua", "StopWork")

    -- skynet.send(buy, "lua", "Buy")

    skynet.exit()
end)