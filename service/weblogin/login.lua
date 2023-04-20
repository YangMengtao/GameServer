local skynet = require "skynet"
local mysql_pool = require "mysql"
local redis_pool = require "redis"
local cjson = require "cjson"

local CMD = {}
local user_token = {}
local token_user = {}

function CMD.auth(username, password)
    local res = mysql_pool:query(string.format("SELECT * FROM user WHERE username='%s'", username))
    if res and res[1] and res[1].password == password then
        local token = skynet.call(".login", "lua", "gen_token", username)
        return token
    else
        return nil, "Invalid username or password"
    end
end

function CMD.gen_token(username)
    local old_token = user_token[username]
    if old_token then
        token_user[old_token] = nil
    end
    local token = skynet.call(".login", "lua", "random_string", 32)
    user_token[username] = token
    token_user[token] = username
    skynet.timeout(600000, function() -- token过期时间为10分钟
        user_token[username] = nil
        token_user[token] = nil
    end)
    return token
end

function CMD.check_token(token)
    local username = token_user[token]
    if username then
        return username
    else
        return nil, "Invalid token"
    end
end

function CMD.random_string(len)
    local str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local ret = ""
    for i = 1, len do
        local rand = math.random(#str)
        ret = ret .. string.sub(str, rand, rand)
    end
    return ret
end

skynet.start(function()
    mysql_pool.connect()
    redis_pool.connect()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        local f = assert(CMD[cmd])
        skynet.retpack(f(...))
    end)
end)
