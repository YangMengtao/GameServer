-- base

local Class = {}

function Class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self:ctor()
    return o
end

function Class:ctor()
    
end

function Class:dtor()
    
end

return Class
