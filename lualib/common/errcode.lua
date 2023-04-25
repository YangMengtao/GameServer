local Class = require "common.class"

local ErrCode = Class:new()

function ErrCode:ctro()
    self.Common_Success = 0
    self.Common_Unknown = -99999
    
    self.Login_AccountOrPassword = -10001
    self.Login_NotAccount = -10002
    self.Login_AlreadyHasAccount = -10003
end

return ErrCode