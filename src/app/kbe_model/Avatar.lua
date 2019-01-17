local _M=class("Avatar",KBEngine.GameObject)
function _M:__init__()
		 _M.super.__init__(self)
end

function _M:relive(type)
		self:cellCall("relive", type)
end
  		
function _M:useTargetSkill(skillID, targetID)

		KBEngine.INFO_MSG(self.className .. '::useTargetSkill: ' .. skillID .. ", targetID: " .. targetID)
		self:cellCall("useTargetSkill", skillID, targetID)
end
  		
function _M:jump()
		
		self:cellCall("jump")
end  	
  		
function _M:onJump()

		KBEngine.INFO_MSG(self.className .. '::onJump: ' .. self.id) 
		KBEngine.Event.fire("otherAvatarOnJump", self)
end    
  		
function _M:onAddSkill(skillID)
		
		KBEngine.INFO_MSG(self.className .. "::onAddSkill(" .. skillID .. ")") 
		KBEngine.Event.fire("onAddSkill", self)
end   

function _M:onRemoveSkill(skillID)

		KBEngine.INFO_MSG(self.className .. "::onRemoveSkill(" .. skillID .. ")") 
		KBEngine.Event.fire("onRemoveSkill", self)
end  
  	
function _M:onEnterWorld()

		KBEngine.INFO_MSG(self.className .. '::onEnterWorld: ' .. self.id) 

		--请求获取技能列表
		if(self:isPlayer()) then
			KBEngine.Event.fire("onAvatarEnterWorld", KBEngine.app.entity_uuid, self.id, self)
			self:cellCall("requestPull")
		end
		
		_M.super.onEnterWorld(self)		
end

function _M:dialog_addOption(arg1, arg2, arg3, arg4)

end

function _M:dialog_close()

end

function _M:dialog_setText(arg1, arg2, arg3, arg4)

end

return _M





