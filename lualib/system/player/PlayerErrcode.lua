local errcode = require "common.errcode"

local M = errcode
local Base = 11000

M.ERR_PLAYER = -(Base + 1)

return M