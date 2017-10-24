local _M = class("ActionSprite",UINode)
function _M:ctor(scene, res)
        _M.super.ctor(self)
        self.scene = scene
        self.res = res
        self.animations = {}
        print("scenescenescenescene:",self.res..".json")
        self:setSprite(res)
end

function _M:setSprite(res)
         self.res=res
         if self.sprite then
         	  self.sprite:removeFromParent()
         end
         local jsonData=display.loadJson(self.res..".json")
         dump(jsonData)
         local sprite=UIImage.new(res..".png",cc.rect(0,0,jsonData.width * 3,jsonData.height * 3))
         sprite:addTo(self)
         self.sprite=sprite
end

function _M:onEnter() 
      self.isDestroyed = false;
      self:setSprite(self.res);
      --激活update
      --this.schedule(this.spriteUpdate, 0.15, cc.REPEAT_FOREVER, 0.15); 
      --self.runAction(cc.fadeIn(1.0));
     
end

return _M
