local _M=class("EntityCall")
function _M:ctor()
		 self.id=0
		 self.className=name
		 self.type = KBEngine.ENTITYCALL_TYPE_CELL
		 self.networkInterface = KBEngine.app
		 self.bundle = nil		 
end

function _M:isBase()
		return self.type == KBEngine.ENTITYCALL_TYPE_BASE
end

function _M:isCell()

		return self.type == KBEngine.ENTITYCALL_TYPE_CELL
end

function _M:newCall()
		if self.bundle == nil then
			self.bundle = KBEngine.Bundle.new()
		end
		if self:isCell() then
			self.bundle:newMessage(KBEngine.messages.Baseapp_onRemoteCallCellMethodFromClient)
		else
			self.bundle:newMessage(KBEngine.messages.Entity_onRemoteMethodCall)
		end
		self.bundle:writeInt32(self.id)
		
		return self.bundle
end

function _M:sendCall(bundle)
		if bundle == nil then
			bundle = self.bundle
		end
		bundle:send(self.networkInterface)
		if self.bundle == bundle then
		   self.bundle = nil
		end
end

return _M
