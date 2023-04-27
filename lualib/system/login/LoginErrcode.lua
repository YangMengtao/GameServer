local errcode = require "common.errcode"

local M = errcode
local Base = 10000

M.ERR_USER_OR_PASSWORD = -(Base + 1)
M.ERR_ALREADY_HAS_ACCOUNT = -(Base + 2)
M.ERR_NOT_FOUND_USER = -(Base + 3)
M.ERR_REPEAT_LOGIN = -(Base + 4)

return M