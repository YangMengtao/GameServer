local Class = require "common.class"

local CMD = Class:new()

function CMD:GetLoginCmd()
    return "login"
end

return CMD