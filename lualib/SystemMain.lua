local cmd = require "common.cmd"
local serverManager = require "common.ServerManager"
local errCode = require "common.errcode"

GCmd = cmd:new()
GMgr = serverManager:new()
GErrCode = errCode:new()

GMySql = nil
GRedis = nil