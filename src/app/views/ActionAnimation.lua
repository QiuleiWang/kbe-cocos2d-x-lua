local _M = class("ActionAnimation",UINode)
function _M:ctor(scene, res)
        _M.super.ctor(self)
        self.scene = scene;
        self.res = res;
        self.animations = {}
end
return _M
