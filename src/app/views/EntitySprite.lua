local _M = class("EntitySprite",require("views/ActionSprite"))
function _M:ctor(scene,entityID,res)
        _M.super.ctor(self,scene,res)
        self.entityID=entityID
        
end

function _M:setName(name)
		if self.ui_name==nil then
		   self.ui_name=display.newLabel("",20,cc.c3b(255,255,0))
		   self.ui_name:setAnchorPoint(0.5,0.5)
		   self.ui_name:setPosition(0,40)
		   self.ui_name:addTo(self,10)
		end
		self.ui_name:setString(name)
end

function _M:_moveToTarget(target)
		self.isMoving = true
		self:stopAllActions()
		self.chaseTarget = target
		self:updateAnim()
end

function _M:updateAnim(...)
		local arguments={...}
		if #arguments == 1 then
			_M.super(self,arguments[0])
		else    	
    		_M.super(self)
    	end	
    	
    	if  self.ui_name ~= nil then
        	self.ui_name.scaleX = self.scaleX;
        end

        if self.uiHP ~= nil then
       	   self.uiHP.scaleX = self.scaleX
       	end    	
end

return _M
