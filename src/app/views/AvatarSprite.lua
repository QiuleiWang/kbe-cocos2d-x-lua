local _M = class("AvatarSprite",require("views/EntitySprite"))
function _M:ctor(scene,entityID,res)
        _M.super.ctor(self,scene,entityID,res)
end

return _M
