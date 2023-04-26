local loginErr = require "system.login.LoginErrcode"

local errcode = {}

errcode.Common =
{
    SUCCEESS = 0,
    UNKNOWN = -1,
}

errcode.Login = loginErr

return errcode