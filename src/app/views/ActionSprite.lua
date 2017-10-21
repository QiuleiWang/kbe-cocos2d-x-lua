local _M = class("ActionSprite",UINode)
function _M:ctor(scene, res)
        _M.super.ctor(self)
        self.scene = scene;
        self.res = res;
        self.animations = {}
end

function _M:setSprite(res)
         
end

function _M:onEnter() 
      self.isDestroyed = false;
      self:setSprite(self.res);
      --激活update
      --this.schedule(this.spriteUpdate, 0.15, cc.REPEAT_FOREVER, 0.15); 
      --self.runAction(cc.fadeIn(1.0));
     
end

return _M
