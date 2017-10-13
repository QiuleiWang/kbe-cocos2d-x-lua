local _M=class("MailBox")
function _M:ctor()
		 self.id=0
		 self.className=name
		 self.type = KBEngine.MAILBOX_TYPE_CELL
		 self.networkInterface = KBEngine.app
		 self.bundle = nil		 
end

function _M:isBase()
		return self.type == KBEngine.MAILBOX_TYPE_BASE
end

function _M:isCell()

		return self.type == KBEngine.MAILBOX_TYPE_CELL
end

function _M:newMail()
		if self.bundle == nil then
			self.bundle = KBEngine.Bundle.new()
		end
		if self:isCell() then
			self.bundle:newMessage(KBEngine.messages.Baseapp_onRemoteCallCellMethodFromClient)
		else
			self.bundle:newMessage(KBEngine.messages.Base_onRemoteMethodCall)
		end
		self.bundle:writeInt32(self.id)
		
		return self.bundle
end

function _M:postMail(bundle)
		if bundle == nil then
			bundle = self.bundle
		end
		bundle:send(self.networkInterface)
		if self.bundle == bundle then
		   self.bundle = nil
		end
end

return _M
