local errcode = require "common.errcode"

local M = errcode
local Base = 11000

M.ERR_NO_PLAYER = -(Base + 1)
M.ERR_ADD_NEW_PLAYER_FAILED = -(Base + 2)
M.ERR_UPDATE_PLAYER_INFO_FAILED = -(Base + 3)
M.ERR_UPDATE_MONEY_FAILED = -(Base + 4)
M.ERR_UPDATE_LEVEL_FAILED = -(Base + 5)
M.ERR_UPDATE_ITEM_FAILED = -(Base + 6)
M.ERR_ADD_NEW_MEMBER_FAILED = -(Base + 7)
M.ERR_NO_MEMBER = -(Base + 8)
M.ERR_UPDATE_MEMBER_INFO_FAILED = -(Base + 9)

return M