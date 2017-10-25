local _M = class("ActionSprite",UINode)
function _M:ctor(scene, res)
        _M.super.ctor(self)
        self.scene = scene
        self.res = res
        self.animations = {}
        self.speed=6
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

function _M:moveToPosition(position)
    self:_moveToPosition(position)
end

function _M:_moveToPosition(position)
        self:stopAllActions()
        local x = position.x - self:getPositionX()
        local y = position.y - self:getPositionY()
        local t = cc.pGetLength(cc.p(x,y))/16/ self.speed
        
        local act1 = cc.MoveTo:create(t, position)
        local delay = cc.DelayTime:create(0.1)
        local function callFunc()
              --self.onMoveToPositionOver
        end
        local act2 = cc.CallFunc:create(callFunc)
        local actF = cc.Sequence:create(act1, delay, act2)
        self:runAction(actF)
        self.isMoving = true;
        --self:setDirection(self:calcDirection(x, y));
end


function _M:onEnter() 
      self.isDestroyed = false;
      self:setSprite(self.res);
      --激活update
      --this.schedule(this.spriteUpdate, 0.15, cc.REPEAT_FOREVER, 0.15); 
      --self.runAction(cc.fadeIn(1.0));
     
end

return _M
